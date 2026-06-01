package com.yido.road.sos.admin;

import com.yido.road.sos.enums.ReportExportFormat;
import com.yido.road.sos.model.DailyCheckLog;
import com.yido.road.sos.model.DailyCheckPhoto;
import com.yido.road.sos.repository.main.DailyCheckPhotoMapper;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.AdminDailyCheckService;
import com.yido.road.sos.service.AdminUserService;
import com.yido.road.sos.service.ReportDocumentService;
import com.yido.road.sos.util.ResultVO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/daily-checks")
public class AdminDailyCheckController {
    private final AdminDailyCheckService adminDailyCheckService;
    private final AdminUserService adminUserService;
    private final DailyCheckPhotoMapper dailyCheckPhotoMapper;
    private final ReportDocumentService reportDocumentService;

    @Value("${Globals.File.UploadPath}")
    private String uploadRoot;

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @GetMapping("")
    public String list(Model model, @AuthenticationPrincipal UserCustom loginUser) {
        String today = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
        model.addAttribute("today", today);
        model.addAttribute("siteList", adminUserService.getAvailableSiteList(loginUser));
        return "admin/dailyCheckList";
    }

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @GetMapping("/data")
    @ResponseBody
    public Map<String, Object> data(@RequestParam Map<String, Object> params) {
        return adminDailyCheckService.getDailyCheckListData(params);
    }

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @GetMapping("/{checkId}")
    @ResponseBody
    public ResultVO detail(@PathVariable("checkId") Long checkId) {
        ResultVO result = new ResultVO();
        DailyCheckLog detail = adminDailyCheckService.getDailyCheckDetail(checkId);
        if (detail == null) {
            result.setCode("9999");
            result.setMessage("일상점검 정보를 찾을 수 없습니다.");
            return result;
        }
        result.setData(detail);
        return result;
    }

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @GetMapping("/photos/{photoId}")
    public void photo(@PathVariable("photoId") Long photoId, HttpServletResponse response) throws IOException {
        DailyCheckPhoto photo = dailyCheckPhotoMapper.selectDailyCheckPhoto(photoId);
        if (photo == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        File file = new File(new File(uploadRoot, photo.getImgPath()), photo.getImgName());
        if (!file.exists() || !file.isFile()) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        response.setContentType(resolveContentType(photo.getImgName()));
        response.setContentLengthLong(file.length());
        FileCopyUtils.copy(new FileInputStream(file), response.getOutputStream());
    }

    @PreAuthorize("hasAnyAuthority('ATH100','ATH200')")
    @GetMapping("/export")
    public void export(@RequestParam("checkIds") List<Long> checkIds,
                       @RequestParam(value = "format", defaultValue = "docx") String format,
                       HttpServletResponse response) throws Exception {
        ReportExportFormat exportFormat = ReportExportFormat.from(format);
        Map<String, Object> data = adminDailyCheckService.getDailyCheckReportData(checkIds);

        byte[] bytes;
        String fileName = "일상점검일지." + exportFormat.getExtension();
        if (exportFormat == ReportExportFormat.DOCX) {
            bytes = reportDocumentService.buildDailyCheckDocx(data);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "지원하지 않는 출력 형식입니다.");
            return;
        }

        setDownloadHeaders(response, fileName, exportFormat.getContentType());
        response.setContentLength(bytes.length);
        response.getOutputStream().write(bytes);
    }

    private String resolveContentType(String fileName) {
        String lower = fileName == null ? "" : fileName.toLowerCase();
        if (lower.endsWith(".png")) {
            return "image/png";
        }
        if (lower.endsWith(".gif")) {
            return "image/gif";
        }
        if (lower.endsWith(".webp")) {
            return "image/webp";
        }
        return "image/jpeg";
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
