package com.yido.road.sos.admin;

import com.yido.road.sos.model.CdCommon;
import com.yido.road.sos.model.SiteInfo;
import com.yido.road.sos.security.UserCustom;
import com.yido.road.sos.service.AdminUserService;
import com.yido.road.sos.service.CommonService;
import com.yido.road.sos.service.PotholeService;
import com.yido.road.sos.service.SiteInfoService;
import com.yido.road.sos.util.Globals;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@Slf4j
@RequiredArgsConstructor
@RequestMapping("")
public class LoginController {

    private final CommonService commonService;
    private final PotholeService potholeService;
    private final AdminUserService adminUserService;

    // 루트는 항상 사용자 화면으로
    @RequestMapping("/")
    public String goMain(HttpServletRequest request) {

        String queryString = request.getQueryString();

        if (queryString != null && queryString.length() > 0) {
            return "redirect:/sos/main?" + queryString;
        }

        return "redirect:/sos/main";
    }

    // /admin 진입 시: 세션 있으면 대시보드, 없으면 로그인
    @RequestMapping("/admin")
    public String adminEntry(HttpServletRequest request) {
        UserCustom session = (UserCustom) request.getSession().getAttribute("session");
        return (session == null) ? "redirect:/admin/login" : "forward:/admin/ims/dashboard";
    }

    // 관리자 로그인 화면
    @RequestMapping("/admin/login")
    public String adminLogin() {
        return "/admin/login";
    }

    // 관리자 로그인 실패
    @RequestMapping(value = "/admin/login-error", method = RequestMethod.GET)
    public String adminLoginError(@RequestParam(required = false) String error,
                                  Model model) {
        if (error != null) {
            model.addAttribute("errorMessage", "ID 또는 비밀번호가 일치하지 않습니다.");
            log.info("Admin login failed: invalid credentials");
        }
        return "/admin/login";
    }

    /* 운영관리 메인 */
    @RequestMapping("/manage")
    public String manageEntry(HttpServletRequest req,Model model) {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        // 로그인 안 된 경우
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getPrincipal())) {
            return "redirect:/manage/login";
        }

        UserCustom user = (UserCustom) auth.getPrincipal();

        // 마지막 접수유형 조회
        String lastReceiptGbCd = "";
        if (user != null && user.getUserId() != null && !user.getUserId().trim().isEmpty()) {
            lastReceiptGbCd = adminUserService.selectLastReceiptGbCd(user.getUserId());
        }
        model.addAttribute("lastReceiptGbCd", lastReceiptGbCd);

        CdCommon receiptGb = new CdCommon();
        receiptGb.setCdDiv("006");
        List<CdCommon> receiptGbList = commonService.getCommonCodeList(receiptGb);
        model.addAttribute("receiptGbList", receiptGbList); // 접수유형

        // 업무구분별 데이터 세팅
        String bizDivCd = user.getBizDivCd();

        if ("RECEIPT".equals(bizDivCd)) {
            model.addAttribute("viewType", "A");
        } else if ("APPLY".equals(bizDivCd)) {
            model.addAttribute("viewType", "B");

            Map<String, Object> param = new HashMap<>();
            param.put("userId", user.getUserId());
            Map<String, Object> cnt = potholeService.selectTodayStatusCounts(param);

            model.addAttribute("todayReceivedCnt", cnt.get("today_received_cnt"));
            model.addAttribute("todayWorkingCnt",  cnt.get("today_processing_cnt"));
        }

        SiteInfo siteInfo = user.getSiteInfo();

        model.addAttribute("siteInfo", siteInfo);
        model.addAttribute("kakaoMapKey", Globals.kakaoMapKey);

        model.addAttribute("roadDirList",
                commonService.getRoadDirListBySiteCd(siteInfo != null ? siteInfo.getSiteCd() : ""));

        return "/ims/main";
    }

    // 운영관리 로그인 화면
    @RequestMapping("/manage/login")
    public String manageLogin(Authentication authentication) {

        // 이미 로그인된 상태면 메인으로 보내기
        if (authentication != null
                && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal())) {
            return "redirect:/manage";
        }

        // 로그인 안 된 상태 → 로그인 페이지
        return "/ims/auth/login";
    }

    // 운영관리 로그인 실패
    @RequestMapping(value = "/manage/login-error", method = RequestMethod.GET)
    public String manageLoginError(HttpServletRequest request, Model model) {
        String msg = (String) request.getSession().getAttribute("LOGIN_ERROR_MESSAGE");
        if (msg != null) {
            model.addAttribute("errorMessage", msg);
            request.getSession().removeAttribute("LOGIN_ERROR_MESSAGE");
        }

        return "/ims/auth/login";
    }
}