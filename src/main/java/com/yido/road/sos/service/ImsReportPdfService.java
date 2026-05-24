package com.yido.road.sos.service;


import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

@Service
@Slf4j
@RequiredArgsConstructor
public class ImsReportPdfService {


    private final JspRenderService jspRenderService;

    public void makePdfFromJsp(Map<String, Object> data,
                               HttpServletRequest req,
                               HttpServletResponse res,
                               OutputStream os) throws Exception {

        req.setAttribute("data", data);

        String html = jspRenderService.renderToString(
                "/WEB-INF/jsp/admin/ims/report-pdf.jsp",
                req,
                res
        );

        PdfRendererBuilder builder = new PdfRendererBuilder();

        // ✅ baseUri (CSS/이미지 정상 로딩용)
        String baseUri = req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort();
        builder.withHtmlContent(html, baseUri);

        // ✅ 한글 폰트 등록
        registerKoreanFonts(builder);

        builder.toStream(os);
        builder.run();
    }

    /**
     * 로컬/운영 공통 한글 폰트 등록
     */
    private void registerKoreanFonts(PdfRendererBuilder builder) {

        try {
            // 1️⃣ classpath 폰트 (프로젝트에 포함한 경우)
            File r = extractFont("static/fonts/NotoSansKR-Regular.ttf");
            File m = extractFont("static/fonts/NotoSansKR-Medium.ttf");
            File b = extractFont("static/fonts/NotoSansKR-Bold.ttf");

            if (r != null) {
                log.info("Using classpath NotoSansKR fonts");
                builder.useFont(r, "Noto Sans KR");
                if (m != null) builder.useFont(m, "Noto Sans KR");
                if (b != null) builder.useFont(b, "Noto Sans KR");
                return;
            }

            // 2️⃣ 운영 서버 경로 (네가 올려둔 위치)
            File linuxRegular = new File("/usr/local/road-sos/webapps/ROOT/css/NotoSansKR-Regular.ttf");
            File linuxMedium  = new File("/usr/local/road-sos/webapps/ROOT/css/NotoSansKR-Medium.ttf");
            File linuxBold    = new File("/usr/local/road-sos/webapps/ROOT/css/NotoSansKR-Bold.ttf");

            if (linuxRegular.exists()) {
                log.info("Using Linux server NotoSansKR fonts");
                builder.useFont(linuxRegular, "Noto Sans KR");
                if (linuxMedium.exists()) builder.useFont(linuxMedium, "Noto Sans KR");
                if (linuxBold.exists()) builder.useFont(linuxBold, "Noto Sans KR");
                return;
            }

            // 3️⃣ 마지막 fallback (윈도우 맑은고딕)
            File winMalgun = new File("C:/Windows/Fonts/malgun.ttf");
            if (winMalgun.exists()) {
                log.info("Using Windows Malgun Gothic fallback");
                builder.useFont(winMalgun, "Malgun Gothic");
                return;
            }

            log.warn("⚠ 한글 폰트를 찾지 못했습니다. PDF 한글 깨질 수 있음.");

        } catch (Exception e) {
            log.error("폰트 등록 중 오류", e);
        }
    }

    /**
     * classpath 폰트를 temp 파일로 추출
     */
    private File extractFont(String classpathPath) {
        try {
            ClassPathResource resource = new ClassPathResource(classpathPath);
            if (!resource.exists()) return null;

            Path temp = Files.createTempFile("font-", "-" + new File(classpathPath).getName());
            temp.toFile().deleteOnExit();

            try (InputStream is = resource.getInputStream()) {
                Files.copy(is, temp, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            }

            return temp.toFile();

        } catch (Exception e) {
            return null;
        }
    }

    public void makeLedgerPdfFromJsp(Map<String, Object> data,
                                     HttpServletRequest req,
                                     HttpServletResponse res,
                                     OutputStream os) throws Exception {

        req.setAttribute("data", data);

        String html = jspRenderService.renderToString(
                "/WEB-INF/jsp/admin/ims/report-ledger-pdf.jsp",
                req,
                res
        );

        PdfRendererBuilder builder = new PdfRendererBuilder();

        String baseUri = req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort();
        builder.withHtmlContent(html, baseUri);

        registerKoreanFonts(builder);

        builder.toStream(os);
        builder.run();
    }
}