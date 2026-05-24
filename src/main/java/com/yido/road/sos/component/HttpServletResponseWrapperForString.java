package com.yido.road.sos.component;

import javax.servlet.ServletOutputStream;
import javax.servlet.WriteListener;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;
import java.io.IOException;
import java.io.PrintWriter;

public class HttpServletResponseWrapperForString extends HttpServletResponseWrapper {

    private final PrintWriter writer;

    public HttpServletResponseWrapperForString(HttpServletResponse response, PrintWriter writer) {
        super(response);
        this.writer = writer;
    }

    @Override
    public PrintWriter getWriter() {
        return writer;
    }

    @Override
    public ServletOutputStream getOutputStream() throws IOException {
        // JSP는 보통 getWriter()로 내려가지만 혹시 몰라서 막아둠
        return new ServletOutputStream() {
            @Override public boolean isReady() { return true; }
            @Override public void setWriteListener(WriteListener writeListener) {}
            @Override public void write(int b) {}
        };
    }
}