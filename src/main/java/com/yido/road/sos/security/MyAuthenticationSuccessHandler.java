package com.yido.road.sos.security;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.DefaultRedirectStrategy;
import org.springframework.security.web.RedirectStrategy;
import org.springframework.security.web.WebAttributes;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;

import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

@Log4j2
@Component
public class MyAuthenticationSuccessHandler implements AuthenticationSuccessHandler {

    private RedirectStrategy redirectStrategy = new DefaultRedirectStrategy();

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException, ServletException {
        handle(request, response, authentication);
        clearAuthenticationAttributes(request);

    }

    protected void handle(HttpServletRequest request, HttpServletResponse response, Authentication authentication) throws IOException {

        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String targetUrl = "";

        UserCustom user = (UserCustom)auth.getPrincipal();
        HttpSession session = request.getSession();

        session.setAttribute("session",  user);
        session.setMaxInactiveInterval(12 * 60 * 60);

        targetUrl = determineTargetUrl(authentication, request, user);

        redirectStrategy.sendRedirect(request, response, targetUrl);
    }

    protected String determineTargetUrl(Authentication authentication,
                                        HttpServletRequest request,
                                        UserCustom user) {

        String loginType = request.getParameter("loginType"); // admin / manage

        boolean isAth100 = hasAuth(user, "ATH100"); // 최고관리자
        boolean isAth200 = hasAuth(user, "ATH200"); // 현장관리자
        boolean isAth300 = hasAuth(user, "ATH300"); // 오케이로드 사용자
        boolean isAth400 = hasAuth(user, "ATH400"); // 사고접수 관리자


        log.debug("loginType:" + loginType);
        log.debug("user:" + user);

        // =========================
        // admin 로그인
        // =========================
        if ("admin".equals(loginType)) {

            // 사고접수 관리자 → admin 메인
            if (isAth400) return "/admin/dashboard";
            // 현장관리자 → IMS 대시보드
            if (isAth200) return "/admin/ims/dashboard";
            // 최고관리자 → admin 메인
            if (isAth100) return "/admin/ims/dashboard";

            return "/admin/login-error";
        }


        // =========================
        // manage 로그인
        // =========================
        if ("manage".equals(loginType)) {

            // 사고접수(ATH400)
            if (isAth400) return "/sos";

            // ✅ 오케이로드(ATH300) 우선
            if (isAth300) return "/manage";

            // ✅ 운영관리(ATH200)
            if (isAth200) return "/admin/ims/dashboard";

            // ✅ 최고관리자(ATH100)
            if (isAth100) return "/admin/dashboard";

            return "/manage/login-error";
        }


        return "/manage/login";
    }

    private boolean hasAuth(UserCustom user, String auth) {
        return user.getAuthorities().stream()
                .anyMatch(a -> auth.equals(a.getAuthority()));
    }



    protected void clearAuthenticationAttributes(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        session.removeAttribute(WebAttributes.AUTHENTICATION_EXCEPTION);
    }

    public void setRedirectStrategy(RedirectStrategy redirectStrategy) {
        this.redirectStrategy = redirectStrategy;
    }
    protected RedirectStrategy getRedirectStrategy() {
        return redirectStrategy;
    }
}
