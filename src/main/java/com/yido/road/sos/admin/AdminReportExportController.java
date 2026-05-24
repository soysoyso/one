package com.yido.road.sos.admin;

import com.yido.road.sos.enums.ReportExportFormat;
import com.yido.road.sos.enums.ReportTemplateCode;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.AdminPotholeService;
import com.yido.road.sos.service.ImsReportPdfService;
import com.yido.road.sos.service.ReportDocumentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/reports")
public class AdminReportExportController {

    private final AdminPotholeService adminPotholeService;
    private final ImsReportPdfService imsReportPdfService;
    private final ReportDocumentService reportDocumentService;

    @GetMapping("/templates")
    @ResponseBody
    public Map<String, Object> templates(@RequestParam(value = "format", required = false) String format) {
        Map<String, Object> out = new HashMap<String, Object>();
        List<Map<String, Object>> templates = new ArrayList<Map<String, Object>>();

        Map<String, Object> potholeLedger = new HashMap<String, Object>();
        potholeLedger.put("templateCode", ReportTemplateCode.POTHOLE_LEDGER.name());
        potholeLedger.put("templateName", ReportTemplateCode.POTHOLE_LEDGER.getDisplayName());
        potholeLedger.put("supportedFormats", new String[]{"pdf", "docx", "hwpx"});
        templates.add(potholeLedger);

        out.put("success", true);
        out.put("data", templates);
        return out;
    }

    @PostMapping("/export")
    public void export(@RequestParam("reportNos") List<String> reportNos,
                       @RequestParam(value = "template", defaultValue = "POTHOLE_LEDGER") String template,
                       @RequestParam(value = "format", defaultValue = "pdf") String format,
                       HttpServletRequest request,
                       HttpServletResponse response,
                       @AuthenticationPrincipal UserCustom loginUser) throws Exception {

        if (reportNos == null || reportNos.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        ReportTemplateCode templateCode = ReportTemplateCode.from(template);
        ReportExportFormat exportFormat = ReportExportFormat.from(format);

        if (templateCode != ReportTemplateCode.POTHOLE_LEDGER) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "현재 지원하지 않는 템플릿입니다.");
            return;
        }

        Map<String, Object> ledgerData = adminPotholeService.getLedgerPdfData(reportNos, loginUser);
        String reportYear = ledgerData.get("reportYear") == null ? "" : String.valueOf(ledgerData.get("reportYear"));
        String fileName = "포트홀_관리대장_" + reportYear + "년." + exportFormat.getExtension();

        if (exportFormat == ReportExportFormat.PDF) {
            setDownloadHeaders(response, fileName, exportFormat.getContentType());
            imsReportPdfService.makeLedgerPdfFromJsp(ledgerData, request, response, response.getOutputStream());
            return;
        }

        byte[] bytes;
        if (exportFormat == ReportExportFormat.DOCX) {
            bytes = reportDocumentService.buildPotholeLedgerDocx(ledgerData);
        } else if (exportFormat == ReportExportFormat.HWPX) {
            bytes = reportDocumentService.buildPotholeLedgerHwpx(ledgerData);
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

