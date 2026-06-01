package com.yido.road.sos.controller;

import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.CommonService;
import com.yido.road.sos.enums.ReportExportFormat;
import com.yido.road.sos.service.ReportDocumentService;
import com.yido.road.sos.service.SituationLogService;
import com.yido.road.sos.util.ResultVO;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletResponse;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/manage/situation-logs")
public class ManageSituationLogController {
    private final SituationLogService situationLogService;
    private final CommonService commonService;
    private final ReportDocumentService reportDocumentService;

    @PreAuthorize("hasAuthority('ATH300')")
    @GetMapping("")
    public String list(Model model, @AuthenticationPrincipal UserCustom loginUser) {
        model.addAttribute("today", new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
        model.addAttribute("siteInfo", loginUser == null ? null : loginUser.getSiteInfo());
        model.addAttribute("shiftList", commonService.codes("SITUATION_SHIFT"));
        return "ims/situation-log/list";
    }

    @PreAuthorize("hasAuthority('ATH300')")
    @GetMapping("/data")
    @ResponseBody
    public Map<String, Object> data(@RequestParam Map<String, Object> params,
                                    @AuthenticationPrincipal UserCustom loginUser) {
        params.put("siteCd", siteCd(loginUser));
        return situationLogService.getSituationLogListData(params);
    }

    @PreAuthorize("hasAuthority('ATH300')")
    @GetMapping("/{situationId}")
    @ResponseBody
    public ResultVO detail(@PathVariable("situationId") Long situationId,
                           @AuthenticationPrincipal UserCustom loginUser) {
        ResultVO result = new ResultVO();
        Object detail = situationLogService.getSituationLog(situationId);
        if (detail == null) {
            result.setCode("9999");
            result.setMessage("상황일지 정보를 찾을 수 없습니다.");
            return result;
        }
        result.setData(detail);
        return result;
    }

    @PreAuthorize("hasAuthority('ATH300')")
    @PostMapping("/save")
    @ResponseBody
    public ResultVO save(@RequestParam Map<String, Object> params,
                         @AuthenticationPrincipal UserCustom loginUser) {
        params.put("siteCd", siteCd(loginUser));
        params.put("useYn", "Y");
        return situationLogService.saveSituationLog(params, loginUser);
    }

    @PreAuthorize("hasAuthority('ATH300')")
    @PostMapping("/delete")
    @ResponseBody
    public ResultVO delete(@RequestParam("situationId") Long situationId,
                           @AuthenticationPrincipal UserCustom loginUser) {
        return situationLogService.deleteSituationLog(situationId, loginUser);
    }

    @PreAuthorize("hasAuthority('ATH300')")
    @GetMapping("/export")
    public void export(@RequestParam Map<String, Object> params,
                       @RequestParam(value = "format", defaultValue = "docx") String format,
                       @AuthenticationPrincipal UserCustom loginUser,
                       HttpServletResponse response) throws Exception {
        params.put("siteCd", siteCd(loginUser));
        ReportExportFormat exportFormat = ReportExportFormat.from(format);
        if (exportFormat != ReportExportFormat.DOCX) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "지원하지 않는 출력 형식입니다.");
            return;
        }

        Map<String, Object> data = situationLogService.getSituationLogReportData(params);
        byte[] bytes = reportDocumentService.buildSituationLogDocx(data);
        String fileName = "상황일지." + exportFormat.getExtension();
        String encodedFileName = URLEncoder.encode(fileName, "UTF-8").replace("+", "%20");
        response.setContentType(exportFormat.getContentType());
        response.setCharacterEncoding("UTF-8");
        response.setHeader(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encodedFileName);
        response.setHeader(HttpHeaders.CACHE_CONTROL, "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader(HttpHeaders.PRAGMA, "no-cache");
        response.setContentLength(bytes.length);
        response.getOutputStream().write(bytes);
    }

    private String siteCd(UserCustom loginUser) {
        if (loginUser == null || loginUser.getSiteInfo() == null) {
            return "";
        }
        return loginUser.getSiteInfo().getSiteCd();
    }
}
