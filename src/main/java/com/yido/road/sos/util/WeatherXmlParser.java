package com.yido.road.sos.util;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.NodeList;

import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;

/*
 * 기상청 XML 응답 파싱 유틸
 * - 날씨 코드(SKY, PTY)만 추출하여 화면/저장용으로 사용
 */
public class WeatherXmlParser {

    /**
     * 하늘 상태 코드(SKY) 추출
     * - 맑음/구름많음/흐림 판단용
     */
    public static Integer pickSky(String xml) {
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();
            Document doc = db.parse(
                    new ByteArrayInputStream(xml.getBytes(StandardCharsets.UTF_8))
            );

            XPath xpath = XPathFactory.newInstance().newXPath();

            // category가 SKY인 fcstValue
            String expr =
                    "//item[category='SKY']/fcstValue/text()";

            NodeList nodes = (NodeList)
                    xpath.evaluate(expr, doc, XPathConstants.NODESET);

            if (nodes.getLength() > 0) {
                return Integer.parseInt(nodes.item(0).getNodeValue());
            }
        } catch (Exception e) {
            // ignore
        }
        return null;
    }

    /**
     * 강수 형태 코드(PTY) 추출
     * - 비/눈/없음 판단용
     */
    public static Integer pickPty(String xml) {
        if (xml == null || xml.length() == 0) return null;

        // category=PTY 인 항목의 fcstValue 추출
        // (기상청 XML 구조: <category>PTY</category> ... <fcstValue>0</fcstValue>)
        String pattern =
                "<category>PTY</category>[\\s\\S]*?<fcstValue>(\\d+)</fcstValue>";

        java.util.regex.Matcher m =
                java.util.regex.Pattern.compile(pattern).matcher(xml);

        if (m.find()) {
            return toInt(m.group(1));
        }
        return null;
    }
    /**
     * 기온(TMP) 추출
     */
    public static Integer pickTmp(String xml) {
        if (xml == null || xml.length() == 0) return null;

        String pattern =
                "<category>TMP</category>[\\s\\S]*?<fcstValue>(-?\\d+)</fcstValue>";

        java.util.regex.Matcher m =
                java.util.regex.Pattern.compile(pattern).matcher(xml);

        if (m.find()) {
            return toInt(m.group(1));
        }
        return null;
    }
    /**
     * 안전한 Integer 변환
     */
    private static Integer toInt(String s) {
        try {
            return Integer.valueOf(s);
        } catch (Exception e) {
            return null;
        }
    }

}
