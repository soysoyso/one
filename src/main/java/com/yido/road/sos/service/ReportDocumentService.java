package com.yido.road.sos.service;

import org.apache.poi.xwpf.usermodel.Borders;
import org.apache.poi.xwpf.usermodel.ParagraphAlignment;
import org.apache.poi.xwpf.usermodel.TextAlignment;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFRun;
import org.apache.poi.xwpf.usermodel.XWPFTable;
import org.apache.poi.xwpf.usermodel.XWPFTableCell;
import org.apache.poi.xwpf.usermodel.XWPFTableRow;
import org.openxmlformats.schemas.wordprocessingml.x2006.main.CTTblWidth;
import org.openxmlformats.schemas.wordprocessingml.x2006.main.STTblWidth;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

@Service
public class ReportDocumentService {

    public byte[] buildPotholeLedgerDocx(Map<String, Object> data) throws Exception {
        try (XWPFDocument doc = new XWPFDocument();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            addTitle(doc, text(data.get("reportYear")) + "년 도로파손(포트홀) 관리대장");
            addMetaLine(doc, "현장: " + text(data.get("siteName")));

            List<Map<String, Object>> groups = list(data.get("monthGroups"));
            if (groups.isEmpty()) {
                addMetaLine(doc, "출력할 데이터가 없습니다.");
            }

            for (Map<String, Object> group : groups) {
                addSectionTitle(doc, text(group.get("month")) + "월");
                addLedgerTable(doc, list(group.get("rows")));
            }

            doc.write(out);
            return out.toByteArray();
        }
    }

    public byte[] buildPotholeLedgerHwpx(Map<String, Object> data) throws Exception {
        String body = buildHwpxBody(data);

        try (ByteArrayOutputStream out = new ByteArrayOutputStream();
             ZipOutputStream zip = new ZipOutputStream(out, StandardCharsets.UTF_8)) {

            put(zip, "mimetype", "application/hwp+zip");
            put(zip, "META-INF/container.xml",
                    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
                            "<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">" +
                            "<rootfiles><rootfile full-path=\"Contents/content.hpf\" media-type=\"application/hwpml-package+xml\"/>" +
                            "</rootfiles></container>");
            put(zip, "version.xml",
                    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
                            "<hv:version xmlns:hv=\"http://www.hancom.co.kr/hwpml/2011/version\" app=\"road-sos\"/>");
            put(zip, "Contents/content.hpf",
                    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
                            "<opf:package xmlns:opf=\"http://www.idpf.org/2007/opf\" version=\"3.0\" unique-identifier=\"road-sos\">" +
                            "<opf:metadata><opf:title>도로파손 관리대장</opf:title><opf:language>ko-KR</opf:language></opf:metadata>" +
                            "<opf:manifest><opf:item id=\"header\" href=\"header.xml\" media-type=\"application/xml\"/>" +
                            "<opf:item id=\"section0\" href=\"section0.xml\" media-type=\"application/xml\"/></opf:manifest>" +
                            "<opf:spine><opf:itemref idref=\"section0\"/></opf:spine></opf:package>");
            put(zip, "Contents/header.xml", buildHwpxHeader());
            put(zip, "Contents/section0.xml", body);

            zip.finish();
            return out.toByteArray();
        }
    }

    private void addTitle(XWPFDocument doc, String title) {
        XWPFParagraph p = doc.createParagraph();
        p.setAlignment(ParagraphAlignment.CENTER);
        XWPFRun run = p.createRun();
        run.setFontFamily("맑은 고딕");
        run.setFontSize(18);
        run.setBold(true);
        run.setText(title);
    }

    private void addMetaLine(XWPFDocument doc, String text) {
        XWPFParagraph p = doc.createParagraph();
        XWPFRun run = p.createRun();
        run.setFontFamily("맑은 고딕");
        run.setFontSize(10);
        run.setText(text);
    }

    private void addSectionTitle(XWPFDocument doc, String title) {
        XWPFParagraph p = doc.createParagraph();
        p.setBorderBottom(Borders.SINGLE);
        XWPFRun run = p.createRun();
        run.setFontFamily("맑은 고딕");
        run.setFontSize(13);
        run.setBold(true);
        run.setText(title);
    }

    private void addLedgerTable(XWPFDocument doc, List<Map<String, Object>> rows) {
        XWPFTable table = doc.createTable(Math.max(rows.size() + 1, 2), 9);
        setTableWidth(table);

        String[] headers = {"NO", "접수번호", "일자", "현장", "방향", "위치", "포장", "발생장소", "면적"};
        XWPFTableRow header = table.getRow(0);
        for (int i = 0; i < headers.length; i++) {
            setCellText(header.getCell(i), headers[i], true);
        }

        if (rows.isEmpty()) {
            XWPFTableRow row = table.getRow(1);
            setCellText(row.getCell(0), "-", false);
            setCellText(row.getCell(1), "데이터 없음", false);
            return;
        }

        for (int i = 0; i < rows.size(); i++) {
            Map<String, Object> r = rows.get(i);
            XWPFTableRow row = table.getRow(i + 1);
            setCellText(row.getCell(0), String.valueOf(i + 1), false);
            setCellText(row.getCell(1), text(r.get("reportNo")), false);
            setCellText(row.getCell(2), text(r.get("reportDate")), false);
            setCellText(row.getCell(3), text(r.get("siteName")), false);
            setCellText(row.getCell(4), text(r.get("directionNm")), false);
            setCellText(row.getCell(5), firstNotBlank(text(r.get("locationInfo")), text(r.get("region"))), false);
            setCellText(row.getCell(6), text(r.get("pavementText")), false);
            setCellText(row.getCell(7), text(r.get("occurPlaceText")), false);
            setCellText(row.getCell(8), text(r.get("areaM2")), false);
        }
    }

    private void setTableWidth(XWPFTable table) {
        CTTblWidth tblWidth = table.getCTTbl().getTblPr().isSetTblW()
                ? table.getCTTbl().getTblPr().getTblW()
                : table.getCTTbl().getTblPr().addNewTblW();
        tblWidth.setW(BigInteger.valueOf(5000));
        tblWidth.setType(STTblWidth.PCT);
    }

    private void setCellText(XWPFTableCell cell, String value, boolean bold) {
        cell.removeParagraph(0);
        XWPFParagraph p = cell.addParagraph();
        p.setAlignment(ParagraphAlignment.CENTER);
        p.setVerticalAlignment(TextAlignment.CENTER);
        XWPFRun run = p.createRun();
        run.setFontFamily("맑은 고딕");
        run.setFontSize(9);
        run.setBold(bold);
        run.setText(value == null ? "" : value);
    }

    private String buildHwpxHeader() {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
                "<hh:head xmlns:hh=\"http://www.hancom.co.kr/hwpml/2011/head\">" +
                "<hh:beginNum page=\"1\" footnote=\"1\" endnote=\"1\" pic=\"1\" tbl=\"1\" equation=\"1\"/>" +
                "</hh:head>";
    }

    private String buildHwpxBody(Map<String, Object> data) {
        StringBuilder sb = new StringBuilder();
        sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        sb.append("<hs:sec xmlns:hs=\"http://www.hancom.co.kr/hwpml/2011/section\">");
        paragraph(sb, text(data.get("reportYear")) + "년 도로파손(포트홀) 관리대장");
        paragraph(sb, "현장: " + text(data.get("siteName")));

        for (Map<String, Object> group : list(data.get("monthGroups"))) {
            paragraph(sb, text(group.get("month")) + "월");
            for (Map<String, Object> row : list(group.get("rows"))) {
                paragraph(sb,
                        text(row.get("reportNo")) + " / " +
                                text(row.get("reportDate")) + " / " +
                                firstNotBlank(text(row.get("locationInfo")), text(row.get("region"))) + " / " +
                                text(row.get("pavementText")) + " / " +
                                text(row.get("occurPlaceText")) + " / " +
                                text(row.get("areaM2")) + "㎡");
            }
        }

        sb.append("</hs:sec>");
        return sb.toString();
    }

    private void paragraph(StringBuilder sb, String text) {
        sb.append("<hp:p xmlns:hp=\"http://www.hancom.co.kr/hwpml/2011/paragraph\">")
                .append("<hp:run><hp:t>")
                .append(xml(text))
                .append("</hp:t></hp:run></hp:p>");
    }

    private void put(ZipOutputStream zip, String path, String content) throws Exception {
        zip.putNextEntry(new ZipEntry(path));
        zip.write(content.getBytes(StandardCharsets.UTF_8));
        zip.closeEntry();
    }

    private String text(Object value) {
        return value == null ? "" : String.valueOf(value);
    }

    private String firstNotBlank(String first, String second) {
        return first != null && !first.trim().isEmpty() ? first : second;
    }

    private String xml(String value) {
        if (value == null) return "";
        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&apos;");
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> list(Object value) {
        if (value instanceof List) {
            return (List<Map<String, Object>>) value;
        }
        return new ArrayList<Map<String, Object>>();
    }
}
