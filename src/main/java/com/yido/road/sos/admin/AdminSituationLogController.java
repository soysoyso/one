package com.yido.road.sos.admin;

import com.yido.road.sos.model.SituationLog;
import com.yido.road.sos.enums.ReportExportFormat;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.AdminUserService;
import com.yido.road.sos.service.CommonService;
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
@RequestMapping("/admin/situation-logs")
public class AdminSituationLogController {
    private final SituationLogService situationLogService;
    private final AdminUserService adminUserService;
    private final CommonService commonService;
    private final ReportDocumentService reportDocumentService;

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @GetMapping("")
    public String list(Model model, @AuthenticationPrincipal UserCustom loginUser) {
        String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        model.addAttribute("today", today);
        model.addAttribute("siteList", adminUserService.getAvailableSiteList(loginUser));
        model.addAttribute("shiftList", commonService.codes("SITUATION_SHIFT"));
        return "admin/situationLog";
    }

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @GetMapping("/data")
    @ResponseBody
    public Map<String, Object> data(@RequestParam Map<String, Object> params) {
        return situationLogService.getSituationLogListData(params);
    }

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @GetMapping("/{situationId}")
    @ResponseBody
    public ResultVO detail(@PathVariable("situationId") Long situationId) {
        ResultVO result = new ResultVO();
        SituationLog detail = situationLogService.getSituationLog(situationId);
        if (detail == null) {
            result.setCode("9999");
            result.setMessage("상황일지 정보를 찾을 수 없습니다.");
            return result;
        }
        result.setData(detail);
        return result;
    }

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @PostMapping("/save")
    @ResponseBody
    public ResultVO save(@RequestParam Map<String, Object> params, @AuthenticationPrincipal UserCustom loginUser) {
        return situationLogService.saveSituationLog(params, loginUser);
    }

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @PostMapping("/delete")
    @ResponseBody
    public ResultVO delete(@RequestParam("situationId") Long situationId, @AuthenticationPrincipal UserCustom loginUser) {
        return situationLogService.deleteSituationLog(situationId, loginUser);
    }

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @GetMapping("/export")
    public void export(@RequestParam Map<String, Object> params,
                       @RequestParam(value = "format", defaultValue = "docx") String format,
                       HttpServletResponse response) throws Exception {
        ReportExportFormat exportFormat = ReportExportFormat.from(format);
        Map<String, Object> data = situationLogService.getSituationLogReportData(params);

        byte[] bytes;
        String fileName = "상황일지." + exportFormat.getExtension();
        if (exportFormat == ReportExportFormat.DOCX) {
            bytes = reportDocumentService.buildSituationLogDocx(data);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "지원하지 않는 출력 형식입니다.");
            return;
        }

        setDownloadHeaders(response, fileName, exportFormat.getContentType());
        response.setContentLength(bytes.length);
        response.getOutputStream().write(bytes);
    }

    private void setDownloadHeaders(HttpServletResponse response, String fileName, String contentType) throws Exception {
        String encodedFileName = URLEncoder.encode(fileName, "UTF-8").replace("+", "%20");
        response.setContentType(contentType);
        response.setCharacterEncoding("UTF-8");
        response.setHeader(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encodedFileName);
        response.setHeader(HttpHeaders.CACHE_CONTROL, "no-store, no-cache, must-revalidate, max-age=0");
        response.setHeader(HttpHeaders.PRAGMA, "no-cache");
    }
}
