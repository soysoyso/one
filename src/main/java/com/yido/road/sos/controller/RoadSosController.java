package com.yido.road.sos.controller;

import com.yido.road.sos.component.storage.S3StorageService;
import com.yido.road.sos.model.AdminUser;
import com.yido.road.sos.model.Incident;
import com.yido.road.sos.model.SiteInfo;
import com.yido.road.sos.service.CommonService;
import com.yido.road.sos.service.IncidentService;
import com.yido.road.sos.service.SiteInfoService;
import com.yido.road.sos.util.ResultVO;
import com.yido.road.sos.component.storage.UploadResult;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@Slf4j
@RequestMapping("/sos")
@RequiredArgsConstructor
public class RoadSosController {

    private final SiteInfoService siteInfoService;
    private final CommonService commonService;
    private final IncidentService incidentService;
    private final S3StorageService storageService;

    /**
     * 고속도로 사고접수 메인화면
     *
     * @param model
     * @param req
     * @return
     */
    @RequestMapping(value = "/main")
    public String main(Model model, HttpServletRequest req, RedirectAttributes ra) {

        return "/sos/main";
    }

    @RequestMapping(value = "/notFound")
    public String notFound(Model model, HttpServletRequest req) {
        return "/sos/notFound";
    }

    /**
     * 온라인접수 완료
     *
     * @param model
     * @param req
     * @param reportNo -> 접수번호
     * @return
     */
    @RequestMapping(value = "/success/{reportNo}")
    public String success(Model model, HttpServletRequest req
            , @PathVariable String reportNo) {

        log.debug("접수내역 조회 :: reportNo : " + reportNo);
        // 접수번호로 접수내역 조회
        Incident incident = incidentService.selectIncidentByReportNo(reportNo);
        log.debug("접수내역 조회 :: incident : " + incident);

        if (incident == null) return "redirect:/sos/notFound?errorCode=02";

        String candidateSiteNames =
                incidentService.getSiteNamesFromSiteCdList(incident.getSiteCdList());

        model.addAttribute("incident", incident);
        model.addAttribute("candidateSiteNames", candidateSiteNames);

        return "/sos/success";
    }


    /**
     * 사고접수
     *
     * @param incident
     * @param photo
     * @return
     * @throws Exception
     */
    @RequestMapping("/insert")
    @ResponseBody
    public ResultVO sosInsert(@ModelAttribute Incident incident,
                              @RequestParam(value = "photo", required = false) MultipartFile photo) throws Exception {

        ResultVO result = new ResultVO();

        log.debug("[sosInsert] Incident:" + incident);

        try {
            // 사진업로드 및 파일경로/파일명 획득
            UploadResult up = null;
            if (photo != null && !photo.isEmpty()) {
                up = storageService.upload(photo, "sos/");
            }
            if (up != null) {
                incident.setRptImgPath(up.getPath());
                incident.setRptImgName(up.getName());
            }
            // end.

            // reportNo 발급/insert/log/SSE까지 서비스에서 처리
            Map<String, Object> out = incidentService.insertIncidentWithReportNo(incident);

            result.setData(out); // 단일이면 reportNo, 복수면 reportNoList 같은 구조로 리턴
            return result;

        } catch (Exception e) {
            e.printStackTrace();
            result.setCode("9999");
            result.setMessage("처리중 오류가 발생하였습니다.");
            return result;
        }

    }


    @InitBinder
    public void initBinder(WebDataBinder binder) {
        binder.registerCustomEditor(LocalDateTime.class, "capturedAt", new java.beans.PropertyEditorSupport() {
            @Override
            public void setAsText(String text) throws IllegalArgumentException {
                if (text == null || text.trim().isEmpty()) {
                    setValue(null);
                    return;
                }
                // ISO 8601 with 'Z' → Instant → UTC LocalDateTime
                java.time.Instant ins = java.time.Instant.parse(text.trim());
                setValue(java.time.LocalDateTime.ofInstant(ins, java.time.ZoneOffset.UTC));
            }
        });
    }

    @GetMapping("/img/rpt/{reportNo}")
    public void viewRptImg(@PathVariable String reportNo, HttpServletResponse res) {
        Incident inc = incidentService.selectIncidentImgByReportNo(reportNo);
        String key = (inc.getRptImgPath() == null || inc.getRptImgName() == null)
                ? null : inc.getRptImgPath() + inc.getRptImgName();
        if (key == null) { res.setStatus(HttpServletResponse.SC_NO_CONTENT); return; }
        storageService.streamInline(key, res);
    }

    @GetMapping("/img/field/{reportNo}")
    public void viewFieldImg(@PathVariable String reportNo, HttpServletResponse res) {
        Incident inc = incidentService.selectIncidentImgByReportNo(reportNo);
        String key = (inc.getImgPath() == null || inc.getImgName() == null)
                ? null : inc.getImgPath() + inc.getImgName();
        if (key == null) { res.setStatus(HttpServletResponse.SC_NO_CONTENT); return; }

        storageService.streamInline(key, res);
    }

    /**
     * 사용자 위치 기반으로 근처 고속도로 추천
     * @param lat
     * @param lng
     * @return
     */
    @GetMapping("/nearby-sections")
    @ResponseBody
    public Map<String, Object> nearbySections(@RequestParam("lat") double lat,@RequestParam("lng") double lng) {

        log.debug("[nearbySections] lat:{},lng:{}", lat, lng);

        Map<String, Object> res = new HashMap<String, Object>();
        Map<String, Object> param = new HashMap<String, Object>();
        param.put("lat", lat);
        param.put("lng", lng);
        param.put("radiusM", 1000); // 1km
        param.put("limit", 10);

        List<Map<String, Object>> list = siteInfoService.selectNearbySections(param);

        if (list == null || list.isEmpty()) {
            list = siteInfoService.selectAllSections(new HashMap<String, Object>());
            res.put("fallback", "ALL");
        } else {
            res.put("fallback", "NEARBY");
        }
        res.put("result", true);
        res.put("list", list);
        return res;
    }


}
