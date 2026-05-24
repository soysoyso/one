package com.yido.road.sos.controller;

import lombok.RequiredArgsConstructor;

import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.*;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import javax.annotation.Resource;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.*;


@Controller
@Slf4j
@RequestMapping("/common")
public class CommonController {

    @Value("${Globals.File.UploadPath}") String serverPath;
/*
    @RequestMapping(value = "/downloadImage.do")
    public void downloadImage(HttpServletRequest request, HttpServletResponse response) {

        String fileName = request.getParameter("fileName");
        String division = request.getParameter("division");
        String folderName = request.getParameter("folderName");
        BufferedInputStream in = null;
        BufferedOutputStream out = null;

        try {
            FileUtils.downloadObject(division, folderName, fileName, serverPath + fileName);

            if(fileName.contains("../")){
                throw new IllegalArgumentException("Unable fileName");
            }

            File uFile = new File(serverPath, fileName);

            int fSize = (int) uFile.length();

            if (fSize > 0) {
                response.setContentLength(fSize);

                in = new BufferedInputStream(new FileInputStream(uFile));

                out = new BufferedOutputStream(response.getOutputStream());

                FileCopyUtils.copy(in, out);

                out.flush();
            }

            File delFile = new File(serverPath + fileName);

            if (delFile.exists()) {
                delFile.delete();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (out != null)
                    out.close();
                if (in != null)
                    in.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }*/
}