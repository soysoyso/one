package com.yido.road.sos.controller;

import com.yido.road.sos.component.storage.S3StorageService;
import com.yido.road.sos.model.*;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.*;
import com.yido.road.sos.util.Globals;
import com.yido.road.sos.util.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@Slf4j
@RequestMapping("/pothole")
@RequiredArgsConstructor
public class PotholeController {

    private final PotholeService potholeService;
    private final PotholeImageService potholeImageService;
    private final S3StorageService storageService;
    private final AdminUserService adminUserService;
    private final CommonService commonService;

    /* 포트홀 접수하기 */
    @RequestMapping(value = "/report")
    public String report(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        UserCustom user = (UserCustom) auth.getPrincipal();

        SiteInfo siteInfo = user.getSiteInfo();

        // 마지막 접수유형 조회
        String lastReceiptGbCd = "";
        if (user != null && user.getUserId() != null && !user.getUserId().trim().isEmpty()) {
            lastReceiptGbCd = adminUserService.selectLastReceiptGbCd(user.getUserId());
        }

        model.addAttribute("siteInfo", siteInfo);
        model.addAttribute("kakaoMapKey", Globals.kakaoMapKey);
        model.addAttribute("lastReceiptGbCd", lastReceiptGbCd);
        model.addAttribute("roadDirList",
                commonService.getRoadDirListBySiteCd(siteInfo != null ? siteInfo.getSiteCd() : ""));

        CdCommon receiptGb = new CdCommon();
        receiptGb.setCdDiv("006");
        List<CdCommon> receiptGbList = commonService.getCommonCodeList(receiptGb);
        model.addAttribute("receiptGbList", receiptGbList); // 접수유형

        return "/ims/porthole/report";
    }

    /* 접수내역 조회 */
    @RequestMapping(value = "/list")
    public String list(Model model) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        UserCustom user = (UserCustom) auth.getPrincipal();

        SiteInfo siteInfo = user.getSiteInfo();

        model.addAttribute("workTypeList", commonService.codes("006"));       // 작업유형 공통코드
        model.addAttribute("siteInfo", siteInfo);
        model.addAttribute("roadDirList",
                commonService.getRoadDirListBySiteCd(siteInfo != null ? siteInfo.getSiteCd() : ""));

        return "/ims/porthole/list";
    }

    /* 접수완료 */
    @PostMapping(value = "/insert", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseBody
    public Map<String, Object> insertPothole(@ModelAttribute Pothole pothole, HttpServletRequest req) {
        Map<String, Object> out = new HashMap<>();

        try {
            log.debug("[insertPothole] pothole = " + pothole);
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            UserCustom user = (UserCustom) auth.getPrincipal();

            String writerId = (user != null) ? user.getUserId() : null;
            pothole.setReceiverId(writerId);

            String reportNo = potholeService.insertPothole(pothole, req);

            Map<String, Object> data = new HashMap<>();
            data.put("reportNo", reportNo);

            out.put("code", "0000");
            out.put("message", "OK");
            out.put("data", data);

        } catch (Exception e) {
            log.error("[포트홀 접수] 실패", e);
            out.put("code", "9999");
            out.put("message", "접수 실패");
        }

        return out;
    }

    /**
     * 작업완료
     *
     * @param pothole
     * @param req
     * @return
     */
    @PostMapping(value = "/insert-work-complete", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseBody
    public Map<String, Object> insertWorkComplete(@ModelAttribute Pothole pothole,
                                                  HttpServletRequest req) {

        Map<String, Object> out = new HashMap<>();

        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            UserCustom user = (UserCustom) auth.getPrincipal();

            String writerId = (user != null) ? user.getUserId() : null;

            pothole.setReceiverId(writerId);
            pothole.setManagerId(writerId);
            pothole.setStatusCd("DONE");

            String reportNo = potholeService.insertWorkCompletePothole(pothole, req);

            Map<String, Object> data = new HashMap<>();
            data.put("reportNo", reportNo);

            out.put("code", "0000");
            out.put("message", "OK");
            out.put("data", data);

        } catch (Exception e) {
            log.error("[포트홀 작업완료 접수] 실패", e);
            out.put("code", "9999");
            out.put("message", "작업완료 실패");
        }

        return out;
    }

    /* 접수상세 */
    @RequestMapping(value = "/detail/{reportNo}")
    public String detail(Model model, @PathVariable String reportNo) {

        // 접수내용 조회
        Pothole detail = potholeService.selectPotholeByReportNo(reportNo);

        // 접수사진
        List<PotholeImage> photos = potholeImageService.selectPotholeImagesByReportNo(reportNo, "BEFORE");

        // 작업사진
        List<PotholeImage> afterPhotos = potholeImageService.selectPotholeImagesByReportNo(reportNo, "AFTER");

        // 해당 고속도로에 소속된 관리자 목록 조회
        String siteCd = null;

        if (detail != null) {
            siteCd = detail.getAdminSiteCd();
            if (siteCd == null || "".equals(siteCd)) {
                siteCd = detail.getSiteCd();
            }
        }

        List<AdminUser> adminUsers = new ArrayList<AdminUser>();
        if (siteCd != null && !"".equals(siteCd)) {
            adminUsers = adminUserService.selectPotholeAssigneeUsersBySiteCd(siteCd, null);
        }

        // 방향 공통코드
        List<CdCommon> roadDirList = commonService.getRoadDirListBySiteCd(siteCd);

        model.addAttribute("receiptGbList", commonService.codes("006"));    // 접수유형
        model.addAttribute("statusList", commonService.codes("005"));       // 작업상태
        model.addAttribute("adminUsers", adminUsers);
        model.addAttribute("detail", detail);
        model.addAttribute("photos", photos);
        model.addAttribute("afterPhotos", afterPhotos);
        model.addAttribute("roadDirList", roadDirList);

        return "/ims/porthole/detail";
    }

    /**
     * 포트홀 접수(BEFORE) 사진 조회 (이미지 미리보기 + 저장 시 원본 파일명 유지)
     */
    @GetMapping("/img/before/{reportNo}/{sortOrd}")
    public void viewBeforeImg(@PathVariable String reportNo,
                              @PathVariable Integer sortOrd,
                              HttpServletResponse res) {

        PotholeImage p = potholeImageService.selectPotholeImageOne(reportNo, "BEFORE", sortOrd);

        String key = (p == null || p.getImgPath() == null || p.getImgName() == null)
                ? null : p.getImgPath() + p.getImgName();

        if (key == null) {
            res.setStatus(HttpServletResponse.SC_NO_CONTENT);
            return;
        }

        // 저장 파일명 지정 (브라우저 "이미지 저장" 파일명에 반영되도록)
        String filename = p.getImgName(); // POTHOLE_I260305006_BEFORE_01.png

        // RFC 5987 대응(ContentDisposition 빌더 사용)
         ContentDisposition cd = ContentDisposition.inline()
                .filename(filename, StandardCharsets.UTF_8)
                .build();

        res.setHeader(HttpHeaders.CONTENT_DISPOSITION, cd.toString());

        storageService.streamInline(key, res);
    }

    /**
     * 포트홀 작업(AFTER) 사진 조회 (이미지 미리보기 + 저장 시 원본 파일명 유지)
     */
    @GetMapping("/img/after/{reportNo}/{sortOrd}")
    public void viewAfterImg(@PathVariable String reportNo,
                             @PathVariable Integer sortOrd,
                             HttpServletResponse res) {

        PotholeImage p = potholeImageService.selectPotholeImageOne(reportNo, "AFTER", sortOrd);

        String key = (p == null || p.getImgPath() == null || p.getImgName() == null)
                ? null : p.getImgPath() + p.getImgName();

        if (key == null) {
            res.setStatus(HttpServletResponse.SC_NO_CONTENT);
            return;
        }

        String filename = p.getImgName(); // POTHOLE_I260305006_AFTER_01.png

        ContentDisposition cd = ContentDisposition.inline()
                .filename(filename, StandardCharsets.UTF_8)
                .build();

        res.setHeader(HttpHeaders.CONTENT_DISPOSITION, cd.toString());

        storageService.streamInline(key, res);
    }

    /* 접수내용 수정 */
    @PostMapping(value = "/pothole-update", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseBody
    public Map<String, Object> updatePothole(@ModelAttribute Pothole pothole, HttpServletRequest request) {
        Map<String, Object> out = new HashMap<>();
        try {

            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            UserCustom user = (UserCustom) auth.getPrincipal();

            log.debug("[updatePothole] pothole : " + pothole);
            potholeService.updatePotholeWithPhotos(pothole, user.getUserId(), request);

            out.put("code", "0000");
            out.put("message", "OK");
        } catch (Exception e) {
            log.error("[포트홀 수정] 실패", e);
            out.put("code", "9999");
            out.put("message", "수정 실패");
        }
        return out;
    }

    /* 작업하기 */
    @PostMapping(value="/work-update", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseBody
    public Map<String, Object> updateWork(@ModelAttribute Pothole pothole, HttpServletRequest request) {

        Map<String, Object> out = new HashMap<String, Object>();

        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            UserCustom user = (UserCustom) auth.getPrincipal();

            log.debug("[updateWork] work : " + pothole);
            potholeService.updateWorkWithPhotos(pothole, user.getUserId(), request);

            out.put("code", "0000");
            out.put("message", "OK");

        } catch (IllegalStateException e) {
            out.put("code", "4090");
            out.put("message", e.getMessage());
        } catch (Exception e) {
            log.error("[작업 수정] 실패", e);
            out.put("code", "9999");
            out.put("message", "저장 실패");
        }

        return out;
    }


    /* 접수내용 + 작업내용 수정 */
    @PostMapping(value = "/pothole-update-all", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseBody
    public Map<String, Object> updatePotholeAll(@ModelAttribute Pothole pothole, HttpServletRequest request) {

        Map<String, Object> out = new HashMap<>();

        try {
            log.info("photosLen={}, workPhotosLen={}",
                    pothole.getPhotos()==null?0:pothole.getPhotos().length,
                    pothole.getWorkPhotos()==null?0:pothole.getWorkPhotos().length
            );

            log.debug("[updatePotholeAll] pothole : " + pothole);
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            UserCustom user = (UserCustom) auth.getPrincipal();

            potholeService.updatePotholeAllWithPhotos(pothole, user.getUserId(), request);

            out.put("code", "0000");
            out.put("message", "OK");

        } catch (Exception e) {
            log.error("[포트홀 통합 수정] 실패", e);

            out.put("code", "9999");
            out.put("message", "수정 실패");
        }

        return out;
    }


    /* 접수내역 조회 */
    @GetMapping("/recent")
    @ResponseBody
    public Map<String, Object> recentPotholes() {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        UserCustom session = (UserCustom) auth.getPrincipal();

        // ✅ request 파라미터 직접 조회 (메서드 파라미터 추가 안 함)
        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        HttpServletRequest request = attrs.getRequest();

        int offset = 0;
        int limit  = 5;

        try {
            if (request.getParameter("offset") != null) {
                offset = Integer.parseInt(request.getParameter("offset"));
            }
            if (request.getParameter("limit") != null) {
                limit = Integer.parseInt(request.getParameter("limit"));
            }
        } catch (Exception e) {
            // 파라미터 파싱 실패 시 기본값 유지
        }

        Map<String, Object> param = new HashMap<>();
        param.put("userId", session.getUserId());
        param.put("offset", offset);
        param.put("limit", limit + 1);
        param.put("recentDays", 3);  // 최근 3일
        param.put("excludeStatus", "DONE"); // 메인화면 최근접수내역에는 완료된 건은 제외

        List<Map<String, Object>> list = potholeService.selectRecentPotholeList(param);

        boolean hasMore = list.size() > limit;
        if (hasMore) {
            list = list.subList(0, limit);
        }

        int totalCount = potholeService.countTodayPotholeByUserSite(param);

        Map<String, Object> res = new HashMap<>();
        res.put("totalCount", totalCount);
        res.put("list", list);
        res.put("hasMore", hasMore);

        return res;
    }

    /* 접수내역(리스트 화면용) 조회 - 5개씩 + 더보기 + 필터/검색 */
    @GetMapping("/list-data")
    @ResponseBody
    public Map<String, Object> listData() {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        UserCustom session = (UserCustom) auth.getPrincipal();

        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        HttpServletRequest request = attrs.getRequest();

        int offset = 0;
        int limit  = 5;

        String status     = request.getParameter("status");      // all/received/working/completed/hold
        String srchStrtDt = request.getParameter("srchStrtDt");  // YYYY-MM-DD
        String srchEndDt  = request.getParameter("srchEndDt");   // YYYY-MM-DD
        String keyword    = request.getParameter("keyword");     // 담당자, 작업명
        String order = request.getParameter("order"); // newest/oldest
        String receiptTypeCd = request.getParameter("receiptTypeCd"); // 접수유형
        if (order == null || order.equals("")) order = "newest";

        if (request.getParameter("offset") != null) {
            offset = Integer.parseInt(request.getParameter("offset"));
        }
        if (request.getParameter("limit") != null) {
            limit = Integer.parseInt(request.getParameter("limit"));
        }

        // status → DB status_cd 매핑
        String statusCd = null;
        if (status != null && !status.equals("") && !status.equals("all")) {
            if (status.equals("received")) statusCd = "RECEIVED";
            else if (status.equals("working")) statusCd = "WORKING";
            else if (status.equals("completed")) statusCd = "DONE";
            else if (status.equals("hold")) statusCd = "HOLD";
        }

        Map<String, Object> param = new HashMap<>();
        param.put("userId", session.getUserId());

        // ✅ 페이징 (더보기)
        param.put("offset", offset);
        param.put("limit", limit + 1); // hasMore 판정용

        // ✅ 조건들 (XML에서 <if>로 걸리게)
        param.put("todayOnly", false); // 또는 아예 안 넣어도 됨(오늘만 필터를 끄는 용도)
        param.put("statusCd", statusCd);
        param.put("srchStrtDt", (srchStrtDt == null) ? "" : srchStrtDt);
        param.put("srchEndDt",  (srchEndDt == null) ? "" : srchEndDt);
        param.put("keyword",    (keyword == null) ? "" : keyword);
        param.put("receiptTypeCd",    (receiptTypeCd == null) ? "" : receiptTypeCd);
        param.put("order", order);

        // 1) 목록 조회
        List<Map<String, Object>> list = potholeService.selectRecentPotholeList(param);

        boolean hasMore = (list != null && list.size() > limit);
        if (hasMore) {
            list = list.subList(0, limit);
        }

        // 2) 총건수 조회
        int totalCount = potholeService.countTodayPotholeByUserSite(param);

        Map<String, Object> res = new HashMap<>();
        res.put("totalCount", totalCount);
        res.put("list", (list == null) ? new ArrayList<>() : list);
        res.put("hasMore", hasMore);

        return res;
    }

    /* 접수 삭제 */
    @PostMapping("/delete")
    @ResponseBody
    public Map<String, Object> deletePothole(@RequestParam String reportNo, HttpServletRequest req) {
        Map<String, Object> out = new HashMap<>();

        try {

            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            UserCustom user = (UserCustom) auth.getPrincipal();
            String updateIp = Utils.getClientIpAddress(req);

            log.info("[deletePothole] 현장관리 접수내역 삭제 - user:{}, reportNo:{}, ip:{}", reportNo, user.getUserId(), updateIp);
            potholeService.deletePothole(reportNo, user.getUserId(), updateIp);

            out.put("code", "0000");
            out.put("message", "OK");

        } catch (Exception e) {

            log.error("[포트홀 삭제] 실패. reportNo={}", reportNo, e);

            out.put("code", "9999");
            out.put("message", "삭제 실패");
        }

        return out;
    }



}

