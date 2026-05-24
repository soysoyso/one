package com.yido.road.sos.service;


import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import lombok.extern.slf4j.Slf4j;
import org.jsoup.Jsoup;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.URI;
import java.util.Collections;

/**
 * JSP(HTML) 화면을 가져와(OpenHTMLtoPDF) PDF byte[]로 변환하는 서비스
 * - 파일 저장 없음
 * - 암복호화 없음
 * - 현재 요청의 JSESSIONID를 전달해서 동일 세션으로 HTML fetch
 */
@Slf4j
@Service
public class PdfService {

    /**
     * 예: https://your-domain.com  또는  http://localhost:8080
     * - application.properties에 server.host.name 로 관리 추천
     */
    @Value("${server.host.name}")
    private String serverHostName;

    private final RestTemplate restTemplate = new RestTemplate();

    /**
     * 사고접수 보고서 PDF 생성
     */
    public byte[] buildIncidentPdf(String reportNo) throws Exception {
        String url = serverHostName + "/admin/sos/report/" + reportNo;

        // 1) JSP 렌더링 결과(HTML) 가져오기 (현재 세션 쿠키 포함)
        String html = fetchHtmlWithSession(url);

        // 2) 상대경로 이미지/CSS 해석 기준(baseUrl)
        String baseUrl = baseUrlFrom(url);

        // 3) HTML -> PDF bytes
        return renderHtmlToPdf(html, baseUrl);
    }



    /**
     * 현재 요청 컨텍스트에서 JSESSIONID 추출 (요청 스레드 내 호출 가정)
     */
    private String resolveSessionId() {
        RequestAttributes attrs = RequestContextHolder.getRequestAttributes();
        if (attrs == null) return null;

        HttpServletRequest request =
                (HttpServletRequest) attrs.resolveReference(RequestAttributes.REFERENCE_REQUEST);
        if (request == null) return null;

        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;

        for (Cookie c : cookies) {
            if ("JSESSIONID".equalsIgnoreCase(c.getName())) {
                return c.getValue();
            }
        }
        return null;
    }

    /**
     * baseUrl 계산: 리소스 상대경로 해석 기준(URL의 디렉터리 부분)
     */
    private String baseUrlFrom(String url) {
        URI u = URI.create(url);
        String s = u.toString();
        int slash = s.lastIndexOf('/');
        return (slash > 8) ? s.substring(0, slash + 1) : s;
    }

    /**
     * HTML -> PDF (OpenHTMLtoPDF)
     * - openhtmltopdf는 XHTML에 더 안정적이라 JSoup로 한번 정리
     * - script/noscript 제거(실행 안되므로)
     * - A4 @page 기본 스타일 주입
     */
    private byte[] renderHtmlToPdf(String rawHtml, String baseUrl) throws Exception {

        org.jsoup.nodes.Document doc = Jsoup.parse(rawHtml, baseUrl);
        doc.select("script,noscript").remove();

        // meta charset 보강
        if (doc.head().selectFirst("meta[charset]") == null) {
            doc.head().append("<meta charset=\"utf-8\"/>");
        }

        // PDF 기본 스타일 주입 (원하면 여기 더 추가)
        doc.head().prependElement("style").attr("type", "text/css").appendText(
                "@page{size:A4;margin:15mm;}" +
                        "body{font-family:'Noto Sans KR',sans-serif;font-size:11pt;line-height:1.5;}" +
                        "table{border-collapse:collapse;}" +
                        "th,td{border:0.5pt solid #d0d0d0;padding:4px 6px;}"
        );

        // XHTML 출력 설정
        doc.outputSettings()
                .syntax(org.jsoup.nodes.Document.OutputSettings.Syntax.xml)
                .escapeMode(org.jsoup.nodes.Entities.EscapeMode.xhtml)
                .prettyPrint(false);

        String xhtml = "<html>" + doc.head().outerHtml() + doc.body().outerHtml() + "</html>";

        try (ByteArrayOutputStream bos = new ByteArrayOutputStream()) {
            PdfRendererBuilder b = new PdfRendererBuilder();
            b.useFastMode();
            b.withHtmlContent(xhtml, baseUrl);

            // ✅ 폰트 임베드(있으면)
            // resources/fonts/NotoSansKR-Regular.ttf
            InputStream reg = getClass().getResourceAsStream("/fonts/NotoSansKR-Regular.ttf");
            if (reg != null) {
                b.useFont(() -> reg, "Noto Sans KR", 400, PdfRendererBuilder.FontStyle.NORMAL, true);
            } else {
                log.warn("폰트 리소스 누락: /fonts/NotoSansKR-Regular.ttf (기본 폰트로 진행)");
            }

            InputStream bold = getClass().getResourceAsStream("/fonts/NotoSansKR-Bold.ttf");
            if (bold != null) {
                b.useFont(() -> bold, "Noto Sans KR", 700, PdfRendererBuilder.FontStyle.NORMAL, true);
            }

            b.toStream(bos);
            b.run();
            return bos.toByteArray();
        }
    }


    private String fetchHtmlWithSession(String url) {
        HttpHeaders headers = new HttpHeaders();
        headers.setAccept(Collections.singletonList(MediaType.TEXT_HTML));

        // ✅ 현재 요청의 Cookie 헤더를 그대로 전달 (JSESSIONID + remember-me 등 전부 포함)
        HttpServletRequest curReq = currentRequest();
        if (curReq != null) {
            String cookieHeader = curReq.getHeader(HttpHeaders.COOKIE);
            if (cookieHeader != null && cookieHeader.trim().length() > 0) {
                headers.add(HttpHeaders.COOKIE, cookieHeader);
            }

            // (선택) PDF 렌더링 결과가 로그인/권한에 따라 달라질 수 있으면 헤더도 전달
            String ua = curReq.getHeader("User-Agent");
            if (ua != null) headers.add("User-Agent", ua);
        }

        RequestEntity<Void> req = new RequestEntity<>(headers, HttpMethod.GET, URI.create(url));
        ResponseEntity<String> resp = restTemplate.exchange(req, String.class);

        if (!resp.getStatusCode().is2xxSuccessful() || resp.getBody() == null) {
            throw new IllegalStateException("HTML fetch 실패: " + resp.getStatusCode());
        }

        String body = resp.getBody();

        // ✅ 로그인 화면을 가져온 경우를 즉시 감지 (PDF에 로그인화면 찍히는 원인)
        if (containsLoginPage(body)) {
            throw new IllegalStateException("인증 실패: 보고서 대신 로그인 페이지 HTML을 가져왔습니다. (쿠키 전달/권한 확인 필요)");
        }

        return body;
    }

    private HttpServletRequest currentRequest() {
        RequestAttributes attrs = RequestContextHolder.getRequestAttributes();
        if (attrs == null) return null;
        return (HttpServletRequest) attrs.resolveReference(RequestAttributes.REFERENCE_REQUEST);
    }

    private boolean containsLoginPage(String html) {
        if (html == null) return false;
        // 네 프로젝트 로그인 폼에 맞춰 키워드 2~3개만 잡아두면 안정적
        return html.contains("/admin/checkLogin")
                || html.contains("name=\"userId\"")
                || html.contains("name=\"userPwd\"")
                || html.contains("/admin/login");
    }
}
