package com.yido.road.sos.service;

import com.yido.road.sos.component.HttpServletResponseWrapperForString;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.RequestDispatcher;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.io.StringWriter;

@Service
public class JspRenderService {

    public String renderToString(String jspPath, HttpServletRequest req, HttpServletResponse res) throws Exception {

        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        HttpServletResponseWrapperForString respWrapper = new HttpServletResponseWrapperForString(res, pw);

        RequestDispatcher rd = req.getRequestDispatcher(jspPath);
        rd.include(req, respWrapper);

        pw.flush();
        return sw.toString();
    }
}