package com.yido.road.sos.security;


import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class CommonAuthenticationFailureHandler implements AuthenticationFailureHandler {

    private static final String DEFAULT_MSG = "ID 또는 비밀번호가 일치하지 않습니다.";

    @Override
    public void onAuthenticationFailure(HttpServletRequest request,
                                        HttpServletResponse response,
                                        AuthenticationException exception) throws IOException {

        String loginType = request.getParameter("loginType");
        String msg = DEFAULT_MSG;

        if (exception instanceof DisabledException) {
            msg = "사용 중지된 계정입니다.";
        }

        request.getSession().setAttribute("LOGIN_ERROR_MESSAGE", msg);

        if ("admin".equals(loginType)) {
            response.sendRedirect("/admin/login-error?error");
        } else {
            response.sendRedirect("/manage/login-error?error");
        }
    }
}