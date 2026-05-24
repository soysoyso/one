package com.yido.road.sos.controller;

import com.yido.road.sos.component.storage.S3StorageService;
import com.yido.road.sos.model.AdminUser;
import com.yido.road.sos.model.CdCommon;
import com.yido.road.sos.model.Incident;
import com.yido.road.sos.model.SiteInfo;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.CommonService;
import com.yido.road.sos.service.IncidentService;
import com.yido.road.sos.service.SiteInfoService;
import com.yido.road.sos.service.UserService;
import com.yido.road.sos.util.Globals;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@Slf4j
@RequestMapping("/ims")
@RequiredArgsConstructor
public class ImsController {

    private final CommonService commonService;
    private final IncidentService incidentService;
    private final UserService userService;
    private final S3StorageService storageService;

    @RequestMapping(value = "/auth/agree")
    public String agree(Model model) {
        return "/ims/auth/agree";
    }

    @RequestMapping(value = "/auth/mypage")
    public String mypage(Model model) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        UserCustom user = (UserCustom) auth.getPrincipal();

        AdminUser adminUser = new AdminUser();
        adminUser.setUserId(user.getUserId());

        adminUser = userService.getAdminUser(adminUser);

        // 비밀번호는 화면에 노출X
        if (adminUser != null) {
            adminUser.setUserPwd(""); // 혹은 null
        }

        model.addAttribute("adminUser", adminUser);
        return "/ims/auth/mypage";
    }


    @RequestMapping(value = "/notFound")
    public String notFound(Model model, HttpServletRequest req) {
        return "/sos/notFound";
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
                setValue(LocalDateTime.ofInstant(ins, java.time.ZoneOffset.UTC));
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


}
