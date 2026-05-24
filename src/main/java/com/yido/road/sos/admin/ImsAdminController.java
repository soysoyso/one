package com.yido.road.sos.admin;

import com.yido.road.sos.model.*;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.*;
import com.yido.road.sos.service.api.StaService;
import com.yido.road.sos.util.ResultVO;
import com.yido.road.sos.util.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/admin/ims")
public class ImsAdminController {

    private final SiteInfoService siteInfoService;
    private final CommonService commonService;
    private final AdminPotholeService adminPotholeService;
    private final AdminUserService adminUserService;
    private final PotholeImageService potholeImageService;
    private final PotholeService potholeService;
    private final ImsReportPdfService imsReportPdfService;
    private final StaService staService;

    /**
     * 현장관리 화면
     *
     * @param model
     * @param req
     * @return
     */
    @RequestMapping(value = "/dashboard")
    public String dashboard(Model model, HttpServletRequest req,  @AuthenticationPrincipal UserCustom loginUser) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        List<SiteInfo> siteList = new ArrayList<>();
        List<String> siteCdList = new ArrayList<>();

        // 관리대상 현장목록 조회
        String userId = loginUser.getUserId();
        List<SiteInfo> manageSiteList = siteInfoService.getManageSiteByUserId(userId);

        if (manageSiteList.size() > 0) {

            for (SiteInfo site : manageSiteList) {
                siteCdList.add(site.getSiteCd());
            }

            // 부모 현장코드 기준으로 본인 + 자식 현장 조회
            siteList = siteInfoService.selectSiteListByParent(siteCdList);

        } else {

            siteCdList = siteInfoService.selectAllSite(auth.getName());
            siteList = siteInfoService.selectSiteList(new SiteInfo());
        }

        model.addAttribute("siteList", siteList);
        model.addAttribute("siteCdList", siteCdList.toString());

        model.addAttribute("workStatusList", commonService.codes("005"));     // 작업상태 공통코드
        model.addAttribute("workTypeList", commonService.codes("006"));       // 작업유형 공통코드
        model.addAttribute("weatherList", commonService.codes("007"));        // 날씨 공통코드
        model.addAttribute("pavementTypeList", commonService.codes("008"));        // 포장형식 공통코드
        model.addAttribute("occurPlaceList", commonService.codes("009"));        // 발생장소 공통코드
        model.addAttribute("roadDirList", commonService.codes("ROAD_DIR"));   // 방향 공통코드

        return "/admin/ims/dashboard";
    }

    @RequestMapping(value = "/list")
    public String list(Model model, HttpServletRequest req,  @AuthenticationPrincipal UserCustom loginUser) {

        return "/admin/ims/list";
    }

    /* 관리자 설정 페이지
    @PreAuthorize("hasAnyRole('ATH100')")
    @GetMapping("/user/setting")
    public String userSetting(Model model,  @AuthenticationPrincipal UserCustom loginUser) {

        // 권한 공통코드 조회
        Map<String, Object> params = new HashMap<>();
        params.put("cdDiv", "003");
        params.put("excludeAuth", "ATH100");

        List<CdCommon> authList = commonService.selectCommonList(params);
        model.addAttribute("authList", authList);
        // end.

        List<SiteInfo> siteList = siteInfoService.selectSiteList(new SiteInfo());
        model.addAttribute("siteList", siteList);
        log.debug("111111");
        model.addAttribute("deptList", commonService.codes("DEPT"));
        log.debug("111111" + commonService.codes("DEPT"));
        return "admin/userSetting";
    }*/

    /**
     * 현장관리 목록 조회
     */
    @GetMapping("/data")
    @ResponseBody
    public Map<String, Object> getImsListData(@RequestParam Map<String, Object> params,
                                              @AuthenticationPrincipal UserCustom loginUser) {
        return adminPotholeService.getImsListData(params, loginUser);
    }

    /* 현장관리 상세모달 */
    @GetMapping("/detail")
    @ResponseBody
    public Map<String, Object> getImsDetail(@RequestParam("reportNo") String reportNo) {

        Map<String, Object> res = new HashMap<>();
        Map<String, Object> detail = adminPotholeService.selectImsPotholeDetail(reportNo);

        // 접수번호에 해당되는 현장코드로 사용자 목록 조회
        List<AdminUser> adminUsers = adminUserService.selectPotholeAssigneeUsersBySiteCd((String) detail.get("siteCd"), null);

        // 접수사진/작업사진
        List<PotholeImage> photos = potholeImageService.selectPotholeImagesByReportNo(reportNo, "BEFORE");
        List<PotholeImage> afterPhotos = potholeImageService.selectPotholeImagesByReportNo(reportNo, "AFTER");

        // ✅ 작업정보(장비/인력/자재/범위) 조회 추가
        Map<String, Object> work = adminPotholeService.selectWorkInfoByReportNo(reportNo);

        List<Map<String, Object>> histories = adminPotholeService.selectPotholeHistoryByReportNo(reportNo);

        res.put("detail", detail);
        res.put("adminUsers", adminUsers);
        res.put("photos", photos);
        res.put("afterPhotos", afterPhotos);
        res.put("histories", histories); // 이력
        res.putAll(work);

        return res;
    }

    /**
     * 현장관리 접수 등록&수정
     *
     * ① pothole 본문 데이터 저장
     * ② 사진 저장
     *
     * @param pothole
     * @param beforePhotos
     * @param afterPhotos
     * @param delBeforeSortOrds
     * @param delAfterSortOrds
     * @param request
     * @return
     */
    @PostMapping(value = "/save", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseBody
    public Map<String, Object> saveAll(
            @ModelAttribute Pothole pothole,
            @RequestParam(value = "formFileBefore", required = false) MultipartFile[] beforePhotos,
            @RequestParam(value = "formFileAfter", required = false) MultipartFile[] afterPhotos,
            @RequestParam(value = "delBeforeSortOrds", required = false) String delBeforeSortOrds,
            @RequestParam(value = "delAfterSortOrds", required = false) String delAfterSortOrds,
            @RequestParam(value = "workInfoJson", required = false) String workInfoJson,

            @RequestParam(value = "mainBeforeFrom", required = false) String mainBeforeFrom,
            @RequestParam(value = "mainBeforeKey",  required = false) String mainBeforeKey,
            @RequestParam(value = "mainAfterFrom",  required = false) String mainAfterFrom,
            @RequestParam(value = "mainAfterKey",   required = false) String mainAfterKey,
            @RequestParam(value = "photoMoveJson", required = false) String photoMoveJson,
            HttpServletRequest request
    ) {
        Map<String, Object> out = new HashMap<>();
        try {
            log.debug("[saveAll] pothole : " + pothole);

            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            UserCustom user = (UserCustom) auth.getPrincipal();

            pothole.setPhotos(beforePhotos);
            pothole.setWorkPhotos(afterPhotos);

            adminPotholeService.savePotholeAllWithPhotosForAdmin(
                    pothole,
                    user.getUserId(),
                    request,
                    delBeforeSortOrds,
                    delAfterSortOrds,
                    workInfoJson,
                    mainBeforeFrom, mainBeforeKey,
                    mainAfterFrom,  mainAfterKey,
                    photoMoveJson
            );
            out.put("code", "0000");
            out.put("message", "OK");
        } catch (Exception e) {
            log.error("[IMS 저장] 실패", e);
            out.put("code", "9999");
            out.put("message", "저장 실패");
        }
        return out;
    }
    
    /*  선택된 현장에 대한 사용자 목록 가져오기 */
    @GetMapping("/adminUsers")
    @ResponseBody
    public List<AdminUser> getImsAdminUsers(@RequestParam String siteCd) {
        List<AdminUser> adminUsers = adminUserService.selectPotholeAssigneeUsersBySiteCd(siteCd, null);
        return adminUsers;
    }

    /* 현장관리 문서번호 채번 */
    @GetMapping("/docno/next")
    @ResponseBody
    public Map<String, Object> nextDocNoForAdmin() {

        Map<String, Object> out = new HashMap<String, Object>();

        String docNo = potholeService.selectNextDocNo("A");

        out.put("code", "0000");
        out.put("docNo", docNo);

        return out;
    }

    /* 보고서 내용을 JSP HTML 형태로 렌더링 (PDF 생성 전 화면 확인용) */
    @GetMapping("/report/pdf/view")
    public String reportPdfView(@RequestParam("reportNo") String reportNo, Model model) throws Exception {

        Map<String, Object> data = adminPotholeService.getReportData(reportNo);


        model.addAttribute("data", data);

        return "/admin/ims/report-pdf";
    }


    /* 보고서를 PDF 파일로 생성하여 다운로드(attachment) 제공 */
    @GetMapping("/report/pdf")
    public void downloadReportPdf(@RequestParam("reportNo") String reportNo,
                                  HttpServletRequest request,
                                  HttpServletResponse response) throws Exception {

        Map<String, Object> reportData = adminPotholeService.getReportData(reportNo);

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=report_" + reportNo + ".pdf");

        imsReportPdfService.makePdfFromJsp(reportData, request, response, response.getOutputStream());
    }

    /* 보고서를 PDF로 생성하여 브라우저/iframe에서 바로 미리보기(inline) 제공 */
    @GetMapping("/report/pdf/preview")
    public void previewReportPdf(@RequestParam("reportNo") String reportNo,
                                 HttpServletRequest request,
                                 HttpServletResponse response) throws Exception {

        Map<String, Object> reportData = adminPotholeService.getReportData(reportNo);

        response.setContentType("application/pdf");
        // ✅ inline: 브라우저/iframe에서 바로 미리보기
        response.setHeader("Content-Disposition", "inline; filename=report_" + reportNo + ".pdf");
        // (선택) 캐시 방지
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader("Pragma", "no-cache");

        imsReportPdfService.makePdfFromJsp(reportData, request, response, response.getOutputStream());
    }

    @PostMapping("/report/ledger/pdf")
    public void downloadLedgerPdf(@RequestParam("reportNos") List<String> reportNos,
                                  HttpServletRequest request,
                                  HttpServletResponse response,
                                  @AuthenticationPrincipal UserCustom loginUser) throws Exception {

        if (reportNos == null || reportNos.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Map<String, Object> ledgerData = adminPotholeService.getLedgerPdfData(reportNos, loginUser);

        String fileName = "포트홀 관리대장_" + ledgerData.get("reportYear") + "년.pdf";
        String encodedFileName = java.net.URLEncoder.encode(fileName, "UTF-8").replace("+", "%20");

        response.setContentType("application/pdf");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encodedFileName);

        imsReportPdfService.makeLedgerPdfFromJsp(ledgerData, request, response, response.getOutputStream());
    }

    /* 마이페이지 */
    @RequestMapping(value = "/mypage")
    public String mypage(Model model, HttpServletRequest req) {
        return "/admin/mypage";
    }

    /* 이미지 일괄 다운로드 */
    @PostMapping("/photos/download")
    public void downloadSelectedPhotos(@RequestParam("reportNos") List<String> reportNos,
                                       HttpServletResponse response) throws Exception {

        potholeImageService.downloadSelectedPhotos(reportNos, response);
    }

    /* 관리자 > 현장관리 > 접수내역 삭제 */
    @PostMapping("/delete")
    @ResponseBody
    public Map<String, Object> deleteImsPothole(@RequestParam String reportNo, HttpServletRequest req) {

        Map<String, Object> out = new HashMap<>();

        try {
            Authentication auth = SecurityContextHolder.getContext().getAuthentication();
            UserCustom user = (UserCustom) auth.getPrincipal();
            String updateIp = Utils.getClientIpAddress(req);

            log.info("[deleteImsPothole] 관리자 현장관리 접수내역 삭제 - user:{}, reportNo:{}, ip:{}", reportNo, user.getUserId(), updateIp);
            potholeService.deletePothole(reportNo, user.getUserId(), updateIp);

            out.put("code", "0000");
            out.put("message", "OK");

        } catch (Exception e) {
            log.error("[관리자 포트홀 삭제] 실패. reportNo={}", reportNo, e);

            out.put("code", "9999");
            out.put("message", "삭제 실패");
        }

        return out;
    }

}