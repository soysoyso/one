package com.yido.road.sos.admin;

import com.yido.road.sos.model.DailyCheckLog;
import com.yido.road.sos.model.DailyCheckPhoto;
import com.yido.road.sos.repository.main.DailyCheckPhotoMapper;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.AdminDailyCheckService;
import com.yido.road.sos.service.AdminUserService;
import com.yido.road.sos.util.ResultVO;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.util.FileCopyUtils;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/daily-checks")
public class AdminDailyCheckController {
    private final AdminDailyCheckService adminDailyCheckService;
    private final AdminUserService adminUserService;
    private final DailyCheckPhotoMapper dailyCheckPhotoMapper;

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
}
