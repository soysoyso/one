package com.yido.road.sos.admin;


import com.yido.road.sos.model.Incident;
import com.yido.road.sos.service.IncidentService;

import com.yido.road.sos.service.PdfService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * The type Pdf enc controller.
 */
@Controller
@Slf4j
@RequestMapping("/pdf")
public class PdfEncController {

    @Autowired
    private PdfService pdfService;
    @Autowired
    private IncidentService incidentService;

    @GetMapping(value = "/report/download", produces = MediaType.APPLICATION_PDF_VALUE)
    public ResponseEntity<byte[]> downloadPdf(
            @RequestParam("reportNo") String reportNo,
            @RequestParam(value = "inline", required = false) String inline
    ) throws Exception {

        byte[] pdfBytes = pdfService.buildIncidentPdf(reportNo);

        Incident inc = incidentService.getIncidentDetail(reportNo).getIncident();
        String fileName = "사고접수 보고서_" + inc.getReportNo() + ".pdf";

        String encodedFileName = URLEncoder.encode(fileName, StandardCharsets.UTF_8.toString())
                .replaceAll("\\+", "%20");

        HttpHeaders headers = new HttpHeaders();

        if ("true".equalsIgnoreCase(inline)) {
            headers.set(HttpHeaders.CONTENT_DISPOSITION,
                    "inline; filename*=UTF-8''" + encodedFileName);
        } else {
            headers.set(HttpHeaders.CONTENT_DISPOSITION,
                    "attachment; filename*=UTF-8''" + encodedFileName);
        }

        headers.setContentType(MediaType.APPLICATION_PDF);
        headers.setContentLength(pdfBytes.length);

        return new ResponseEntity<>(pdfBytes, headers, HttpStatus.OK);
    }


}