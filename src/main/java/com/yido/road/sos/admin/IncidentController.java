package com.yido.road.sos.admin;

import com.yido.road.sos.ReportPdfHelper;
import com.yido.road.sos.component.storage.S3StorageService;
import com.yido.road.sos.model.GeocodeResponse;
import com.yido.road.sos.model.Incident;
import com.yido.road.sos.model.IncidentDetailDto;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.CommonService;
import com.yido.road.sos.service.api.GeocodeService;
import com.yido.road.sos.service.IncidentService;
import com.yido.road.sos.service.SiteInfoService;
import com.yido.road.sos.util.ResultVO;
import com.yido.road.sos.component.storage.UploadResult;
import com.yido.road.sos.util.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.validation.Valid;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Controller
@Slf4j
@RequiredArgsConstructor
@RequestMapping("/admin/sos")
public class IncidentController {

    @Value("${sos.url}") String sosUrl;

    private final GeocodeService geocodeService;
    private final SiteInfoService siteInfoService;
    private final CommonService commonService;
    private final IncidentService incidentService;
    private final S3StorageService storageService;

    /**
     * incident 테이블 상태별 건수 집계 (일자 기준)
     *
     * @return
     * @throws Exception
     */
    @RequestMapping("/getIncidentStatusSummaryByDate")
    @ResponseBody
    public Map<String, Object> getIncidentStatusSummaryByDate(@AuthenticationPrincipal UserCustom loginUser) throws Exception {
        Map<String, Object> params = new HashMap<String, Object>();
        String siteCdCsv = loginUser.getSiteCdList(); // "0001,0002" or null

        if (siteCdCsv != null && !siteCdCsv.trim().isEmpty()) {
            List<String> siteCdList = Arrays.asList(siteCdCsv.split(","));
            params.put("siteCdList", siteCdList);
        }
        Map<String, Object> summary = incidentService.getIncidentStatusSummaryByDate(params);
        return summary;

    }

    /**
     * 사고접수 목록 조회
     *
     * @param params
     * @return
     */
    @GetMapping("/data")
    @ResponseBody
    public Map<String, Object> getSosListData(@RequestParam Map<String, Object> params) {

        log.debug("[getSosListData] params : " + params);
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        List<String> siteCdListParam = new ArrayList<>();
        String strtDt = (params.get("strtDt") != null) ? params.get("strtDt").toString() : "";
        String endDt = (params.get("endDt") != null) ? params.get("endDt").toString() : "";
        String siteCd = (params.get("siteCd") != null) ? params.get("siteCd").toString() : "";
        String siteCdListStr = (params.get("siteCdList") != null) ? params.get("siteCdList").toString() : "";
        String statusCd = (params.get("statusCd") != null) ? params.get("statusCd").toString() : "";
        String reportNo = (params.get("reportNo") != null) ? params.get("reportNo").toString() : "";
        String cellPhone = (params.get("cellPhone") != null) ? params.get("cellPhone").toString() : "";

        int page = Integer.parseInt(params.getOrDefault("page", "1").toString());
        int pageSize = 10;
        int offset = (page - 1) * pageSize;

        params.put("offset", offset);
        params.put("pageSize", pageSize);

        if (!strtDt.isEmpty()) params.put("startDt", strtDt);
        if (!endDt.isEmpty()) params.put("endDt", endDt);
        if (!statusCd.isEmpty()) params.put("statusCd", statusCd);
        if (!reportNo.isEmpty()) params.put("reportNo", reportNo);
        if (!cellPhone.isEmpty()) params.put("cellPhone", cellPhone);

        if (!siteCd.isEmpty()) {
            // 선택한 현장
            params.put("siteCd", siteCd);
        } else {
            // 전체 현장 (관리대상 현장만)
            siteCdListParam = siteInfoService.selectAllSite(auth.getName());
        }

        params.put("siteCdList", siteCdListParam);

        // 조회
        List<Incident> list = incidentService.selectIncidentList(params);
        int totalCount = incidentService.selectIncidentCount(params);

        // 사고접수 현황 집계 (당일꺼만)
        Map<String, Object> summary = incidentService.getIncidentStatusSummaryByDate(params);

        Map<String, Object> pageInfo = new HashMap<>();
        pageInfo.put("currentPage", page);
        pageInfo.put("pageSize", pageSize);
        pageInfo.put("totalPages", (int) Math.ceil(totalCount / (double) pageSize));

        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("pageInfo", pageInfo);
        result.put("totalCount", totalCount);
        result.put("summary", summary);

        return result;
    }

    /**
     * 사고접수 목록 엑셀다운로드
     *
     * @param params
     * @param response
     * @throws IOException
     */
    @GetMapping("/excelDownload")
    public void downloadExcel(@RequestParam Map<String, Object> params, HttpServletResponse response) throws IOException {

        List<Incident> list = incidentService.selectIncidentList(params);

        // 파일명 설정
        String fileName = URLEncoder.encode("사고접수 목록.xlsx", "UTF-8").replaceAll("\\+", "%20");
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        // 엑셀 생성
        XSSFWorkbook workbook = new XSSFWorkbook();
        XSSFSheet sheet = workbook.createSheet("사고접수 목록");

        // 헤더
        String[] headers = { "현장", "접수번호", "접수방법", "접수시간", "완료시간", "사고위치(주소)", "전화번호", "상태", "담당자", "처리내용"};
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) {
            headerRow.createCell(i).setCellValue(headers[i]);
        }

        // 데이터
        int rowNum = 1;
        for (Incident incident : list) {
            Row row = sheet.createRow(rowNum++);
            String siteName = incident.getSiteName() == null ? "알수없음" :  incident.getSiteName();

            row.createCell(0).setCellValue(siteName);
            row.createCell(1).setCellValue(incident.getReportNo());
            row.createCell(2).setCellValue(incident.getIntakeMethodNm());
            row.createCell(3).setCellValue(incident.getReportDateFmt());

            if (incident.getStatusCd().equals("STS003")) row.createCell(4).setCellValue(incident.getUpdateDateFmt());
            else row.createCell(4).setCellValue("");

            row.createCell(5).setCellValue(incident.getAddr());
            row.createCell(6).setCellValue(incident.getCellPhone());
            row.createCell(7).setCellValue(incident.getStatusNm());
            row.createCell(8).setCellValue(incident.getManagerId());
            row.createCell(9).setCellValue(incident.getProcessNote());
        }

        // 전송
        workbook.write(response.getOutputStream());
        workbook.close();
    }

    /* 사고접수 상세 */
    @RequestMapping("/getSosInfo")
    @ResponseBody
    public IncidentDetailDto getSosInfo(@RequestParam Map<String, Object> params, HttpServletRequest req) {
        String reportNo = (params.get("reportNo") != null) ? params.get("reportNo").toString() : "";
        IncidentDetailDto incident = incidentService.getIncidentDetail(reportNo);

        return incident;
    }

    /**
     * 사고접수 > 등록
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
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || auth instanceof AnonymousAuthenticationToken) {
            result.setCode("401");
            result.setMessage("로그인이 필요합니다.");
            return result;
        }

        try {
            // 사진업로드 및 파일경로/파일명 획득
            UploadResult up = null;
            if (photo != null && !photo.isEmpty()) {
                up = storageService.upload(photo, "sos-field/");
            }
            if (up != null) {
                incident.setImgPath(up.getPath());
                incident.setImgName(up.getName());
            }
            // end.

            // reportNo 발급/insert/log까지 서비스에서 처리
            Map<String, Object> out = incidentService.insertAdminIncident(incident);


        } catch (Exception e) {
            e.printStackTrace();
            result.setCode("9999");
            result.setMessage("처리중 오류가 발생하였습니다.");
            return result;
        }

        return result;
    }

    /**
     * 사고 접수 > 수정
     *
     * @param incident
     * @param photo
     * @return
     * @throws Exception
     */
    @RequestMapping("/update")
    @ResponseBody
    public ResultVO sosUpdate(@ModelAttribute Incident incident,
                              @RequestParam(value = "photo", required = false) MultipartFile photo,
                              @RequestParam(value = "imageChanged", required = false, defaultValue = "N") String imageChanged
    ) throws Exception {
        ResultVO result = new ResultVO();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || auth instanceof AnonymousAuthenticationToken) {
            result.setCode("401");
            result.setMessage("로그인이 필요합니다.");
            return result;
        }

        try {
            // 사진업로드 및 파일경로/파일명 획득
            UploadResult up = null;

            if ("Y".equals(imageChanged)) {
                if (photo != null && !photo.isEmpty()) {
                    // 1) 새 파일로 교체
                    up = storageService.upload(photo, "sos-field/");
                    incident.setImgPath(up.getPath());
                    incident.setImgName(up.getName());
                } else {
                    // 2) 기존 파일 삭제
                    incident.setImgPath(null);
                    incident.setImgName(null);
                }
            }
            // 3) imageChanged = N 이면 아무 것도 안 바꿈 (기존 이미지 유지)

            incident.setManagerId(auth.getName());
            log.debug("[sosUpdate] incident : " + incident);
            incidentService.updateIncidentAndLog(incident);

        } catch (Exception e) {
            e.printStackTrace();
            result.setCode("9999");
            result.setMessage("처리중 오류가 발생하였습니다.");
            return result;
        }

        return result;
    }

    /**
     * 고객에게 사고접수 URL 전송 (SMS)
     *
     * @param incident
     * @param req
     * @return
     * @throws Exception
     */
    @PostMapping(value = "/send-url", consumes = "application/json", produces = "application/json")
    @ResponseBody
    public ResultVO sendUrl(@Valid @RequestBody Incident incident
                            , HttpServletRequest req
    ) throws Exception {
        ResultVO res = new ResultVO();

        String ipAddr = Utils.getClientIpAddress(req);
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String adminId = (auth != null ? auth.getName() : "unknown");

        // 혹시 하이픈이 섞여 올 가능성 대비 (프런트에서 숫자만 보내더라도 안전망)
        String phoneDigits = incident.getCellPhone().replaceAll("\\D", "");

        Map<String, Object> params = new HashMap<>();

        String link = sosUrl;  // 전송할 링크
        String msg = String.join("\n",
                "[고속도로 사고접수 안내]",
                "아래 링크를 열고 위치 권한 허용 후 접수해 주세요.",
                "▶ " + link
        );

        params.put("title", "[고속도로 사고접수]");    // SMS 타이틀 : 고속도로 명
        params.put("msg", msg);                     // SMS 내용
        params.put("cellPhone", phoneDigits);       // 수신번호
        params.put("siteCd", incident.getSiteCd()); // 현장코드
        params.put("adminId", adminId);             // 관리자ID - 기록용
        params.put("adminIp", ipAddr);              // 관리자IP - 기록용

        // 실제 SMS 전송
        incidentService.sendSms(params);

        res.setCode("0000");
        res.setMessage("URL을 전송했습니다.");

        log.debug("res:"+ res);
        return res;
    }

    // /admin/sos/report/{reportNo}.pdf?inline=true  → 브라우저 미리보기
    // /admin/sos/report/{reportNo}.pdf              → 파일 다운로드
    @GetMapping("/report/{reportNo}.pdf")
    public void reportPdf(@PathVariable String reportNo,
                          @RequestParam(name = "inline", defaultValue = "false") boolean inline,
                          HttpServletRequest req,
                          HttpServletResponse res) {

        log.debug("[reportPdf] reportNo : " + reportNo);
        // 1) 데이터 조회
        Incident inc = incidentService.getIncidentDetail(reportNo).getIncident();
        if (inc == null) { res.setStatus(HttpServletResponse.SC_NOT_FOUND); return; }

        // 2) HTML 빌드
        String html = ReportPdfHelper.buildIncidentHtml(inc, req.getContextPath());

        // 3) 헤더 설정 (inline/attachment 토글)
        res.setContentType("application/pdf");

        String filename = "accident-report-" + reportNo + ".pdf";
        ContentDisposition cd = (inline ? ContentDisposition.inline() : ContentDisposition.attachment())
                .filename(filename, StandardCharsets.UTF_8)  // RFC 5987 처리
                .build();
        res.setHeader(HttpHeaders.CONTENT_DISPOSITION, cd.toString());
        res.setHeader("Cache-Control", "private, max-age=60");

        try (OutputStream os = res.getOutputStream()) {
            com.openhtmltopdf.pdfboxout.PdfRendererBuilder builder = new com.openhtmltopdf.pdfboxout.PdfRendererBuilder();
            builder.useFastMode();
            builder.withHtmlContent(html, getBaseUri(req)); // 이미지 불러올 base URI
            builder.toStream(os);
            builder.run();
            os.flush();
        } catch (Exception e) {
            res.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @RequestMapping("/report/{reportNo}")
    public String previewReport(@PathVariable String reportNo, Model model, HttpServletRequest req) {

        log.debug("[previewReport] reportNo : " + reportNo);

        Incident inc = incidentService.getIncidentDetail(reportNo).getIncident();
        model.addAttribute("inc", inc);

        return "/admin/report/sosReport";

    }

    private String getBaseUri(HttpServletRequest req) {
        String scheme = req.getScheme();
        String host = req.getServerName();
        int port = req.getServerPort();
        String ctx = req.getContextPath();
        String origin = scheme + "://" + host + ((port == 80 || port == 443) ? "" : ":" + port);
        return origin + (ctx != null ? ctx : "");
    }

    @GetMapping("/geocode")
    public ResponseEntity<GeocodeResponse> geocode(@RequestParam("addr") String addr) {
        String safeAddr = addr == null ? "" : addr.trim();
        if (safeAddr.isEmpty()) {
            return ResponseEntity.badRequest().body(GeocodeResponse.fail("addr is empty"));
        }

        GeocodeResponse res = geocodeService.geocode(safeAddr);

        // 프론트가 (!res.lat || !res.lng)로 체크하니까,
        // 실패해도 200으로 내려도 되고(프론트에서 alert), 더 엄격히 하려면 404/500도 가능.
        return ResponseEntity.ok(res);
    }

}

