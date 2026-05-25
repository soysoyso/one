package com.yido.road.sos.service;

import com.yido.road.sos.model.DailyCheckLog;
import com.yido.road.sos.model.DailyCheckLogItem;
import com.yido.road.sos.model.DailyCheckPhoto;
import com.yido.road.sos.model.SituationLog;
import com.yido.road.sos.enums.ReportTemplateCode;
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
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

@Service
public class ReportDocumentService {
    private static final String FONT = "맑은 고딕";

    public byte[] buildPotholeTemplateDocx(ReportTemplateCode templateCode, Map<String, Object> data) throws Exception {
        if (templateCode == ReportTemplateCode.POTHOLE_LEDGER) {
            return buildPotholeLedgerDocx(data);
        }

        XWPFDocument doc = new XWPFDocument();
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try {
            addTitle(doc, templateCode.getDisplayName());
            addMetaLine(doc, "현장: " + value(data.get("siteName")));
            addMetaLine(doc, "보고연도: " + value(data.get("reportYear")));
            addMetaLine(doc, "출력일시: " + nowText());
            addTemplateSummary(doc, templateCode, data);
            addTemplateRows(doc, templateCode, data);

            doc.write(out);
            return out.toByteArray();
        } finally {
            doc.close();
            out.close();
        }
    }

    public byte[] buildPotholeTemplateHwpx(ReportTemplateCode templateCode, Map<String, Object> data) throws Exception {
        if (templateCode == ReportTemplateCode.POTHOLE_LEDGER) {
            return buildPotholeLedgerHwpx(data);
        }

        List<String> lines = new ArrayList<String>();
        lines.add(templateCode.getDisplayName());
        lines.add("현장: " + value(data.get("siteName")));
        lines.add("보고연도: " + value(data.get("reportYear")));
        lines.add("출력일시: " + nowText());
        appendTemplateSummaryLines(lines, templateCode, data);
        for (Map<String, Object> row : flattenPotholeRows(data)) {
            lines.add(value(row.get("reportNo")) + " / "
                    + value(row.get("reportDate")) + " / "
                    + firstNotBlank(value(row.get("locationInfo")), value(row.get("region"))) + " / "
                    + value(row.get("detailInfo")) + " / "
                    + value(row.get("areaM2")));
        }
        return buildSimpleHwpx(templateCode.getDisplayName(), lines);
    }

    public byte[] buildPotholeLedgerDocx(Map<String, Object> data) throws Exception {
        XWPFDocument doc = new XWPFDocument();
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try {
            addTitle(doc, value(data.get("reportYear")) + "년 도로파손(포트홀) 관리대장");
            addMetaLine(doc, "현장: " + value(data.get("siteName")));
            addMetaLine(doc, "출력일시: " + nowText());

            List<Map<String, Object>> groups = mapList(data.get("monthGroups"));
            if (groups.isEmpty()) {
                addMetaLine(doc, "출력할 데이터가 없습니다.");
            }
            for (Map<String, Object> group : groups) {
                addSectionTitle(doc, value(group.get("month")) + "월");
                addPotholeLedgerTable(doc, mapList(group.get("rows")));
            }

            doc.write(out);
            return out.toByteArray();
        } finally {
            doc.close();
            out.close();
        }
    }

    public byte[] buildPotholeLedgerHwpx(Map<String, Object> data) throws Exception {
        List<String> lines = new ArrayList<String>();
        lines.add(value(data.get("reportYear")) + "년 도로파손(포트홀) 관리대장");
        lines.add("현장: " + value(data.get("siteName")));
        lines.add("출력일시: " + nowText());
        for (Map<String, Object> group : mapList(data.get("monthGroups"))) {
            lines.add(value(group.get("month")) + "월");
            for (Map<String, Object> row : mapList(group.get("rows"))) {
                lines.add(value(row.get("reportNo")) + " / " + value(row.get("reportDate")) + " / "
                        + firstNotBlank(value(row.get("locationInfo")), value(row.get("region"))) + " / "
                        + value(row.get("areaM2")));
            }
        }
        return buildSimpleHwpx("도로파손 관리대장", lines);
    }

    public byte[] buildDailyCheckDocx(Map<String, Object> data) throws Exception {
        XWPFDocument doc = new XWPFDocument();
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try {
            addTitle(doc, "일상점검일지");
            addMetaLine(doc, "출력일시: " + nowText());

            List<DailyCheckLog> logs = dailyLogs(data.get("dailyChecks"));
            if (logs.isEmpty()) {
                addMetaLine(doc, "출력할 일상점검 데이터가 없습니다.");
            }
            for (DailyCheckLog log : logs) {
                addSectionTitle(doc, firstNotBlank(log.getCheckNo(), "일상점검") + " - " + value(log.getCheckDate()));
                addKeyValueTable(doc, new String[][]{
                        {"점검일자", value(log.getCheckDate()), "현장", firstNotBlank(log.getSiteName(), log.getSiteCd())},
                        {"체크리스트", value(log.getChecklistName()), "작성자", firstNotBlank(log.getWriterNm(), log.getWriterId())},
                        {"상태", firstNotBlank(log.getStatusNm(), log.getStatusCd()), "비고", value(log.getRemark())}
                });
                addDailyCheckItemTable(doc, log.getItems());
                addPhotoSummary(doc, log.getPhotos());
            }

            doc.write(out);
            return out.toByteArray();
        } finally {
            doc.close();
            out.close();
        }
    }

    public byte[] buildDailyCheckHwpx(Map<String, Object> data) throws Exception {
        List<String> lines = new ArrayList<String>();
        lines.add("일상점검일지");
        lines.add("출력일시: " + nowText());
        for (DailyCheckLog log : dailyLogs(data.get("dailyChecks"))) {
            lines.add(firstNotBlank(log.getCheckNo(), "일상점검") + " - " + value(log.getCheckDate()));
            lines.add("현장: " + firstNotBlank(log.getSiteName(), log.getSiteCd()));
            lines.add("작성자: " + firstNotBlank(log.getWriterNm(), log.getWriterId()));
            if (log.getItems() != null) {
                for (DailyCheckLogItem item : log.getItems()) {
                    lines.add(value(item.getItemName()) + ": " + value(item.getCheckValue()));
                }
            }
        }
        return buildSimpleHwpx("일상점검일지", lines);
    }

    public byte[] buildSituationLogDocx(Map<String, Object> data) throws Exception {
        XWPFDocument doc = new XWPFDocument();
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try {
            addTitle(doc, "상황일지");
            addMetaLine(doc, "기간: " + value(data.get("startDate")) + " ~ " + value(data.get("endDate")));
            addMetaLine(doc, "출력일시: " + nowText());
            addSituationLogTable(doc, situationLogs(data.get("situationLogs")));

            doc.write(out);
            return out.toByteArray();
        } finally {
            doc.close();
            out.close();
        }
    }

    public byte[] buildSituationLogHwpx(Map<String, Object> data) throws Exception {
        List<String> lines = new ArrayList<String>();
        lines.add("상황일지");
        lines.add("기간: " + value(data.get("startDate")) + " ~ " + value(data.get("endDate")));
        lines.add("출력일시: " + nowText());
        for (SituationLog log : situationLogs(data.get("situationLogs"))) {
            lines.add(value(log.getLogDate()) + " " + value(log.getEventTime()) + " "
                    + firstNotBlank(log.getShiftNm(), log.getShiftCd()) + " / "
                    + firstNotBlank(log.getTitle(), log.getContent()));
            lines.add(value(log.getContent()));
        }
        return buildSimpleHwpx("상황일지", lines);
    }

    private void addPotholeLedgerTable(XWPFDocument doc, List<Map<String, Object>> rows) {
        XWPFTable table = doc.createTable(Math.max(rows.size() + 1, 2), 9);
        setTableWidth(table);
        String[] headers = {"NO", "접수번호", "일자", "현장", "방향", "위치", "포장", "발생장소", "면적"};
        setHeaderRow(table.getRow(0), headers);

        if (rows.isEmpty()) {
            setCellText(table.getRow(1).getCell(0), "-", false);
            setCellText(table.getRow(1).getCell(1), "데이터 없음", false);
            return;
        }

        for (int i = 0; i < rows.size(); i++) {
            Map<String, Object> row = rows.get(i);
            XWPFTableRow tr = table.getRow(i + 1);
            setCellText(tr.getCell(0), String.valueOf(i + 1), false);
            setCellText(tr.getCell(1), value(row.get("reportNo")), false);
            setCellText(tr.getCell(2), value(row.get("reportDate")), false);
            setCellText(tr.getCell(3), value(row.get("siteName")), false);
            setCellText(tr.getCell(4), value(row.get("directionNm")), false);
            setCellText(tr.getCell(5), firstNotBlank(value(row.get("locationInfo")), value(row.get("region"))), false);
            setCellText(tr.getCell(6), value(row.get("pavementText")), false);
            setCellText(tr.getCell(7), value(row.get("occurPlaceText")), false);
            setCellText(tr.getCell(8), value(row.get("areaM2")), false);
        }
    }

    private void addTemplateSummary(XWPFDocument doc, ReportTemplateCode templateCode, Map<String, Object> data) {
        Map<String, Object> yearSummary = asMap(data.get("yearSummary"));
        String[][] rows = new String[][]{
                {"템플릿", templateCode.getDisplayName(), "출력구분", templateCode.name()},
                {"접수건수", value(yearSummary.get("potholeCount")), "전체면적", value(yearSummary.get("areaM2"))},
                {"대상월수", String.valueOf(mapList(data.get("monthGroups")).size()), "비고", templateGuide(templateCode)}
        };
        addKeyValueTable(doc, rows);
    }

    private void addTemplateRows(XWPFDocument doc, ReportTemplateCode templateCode, Map<String, Object> data) {
        List<Map<String, Object>> rows = flattenPotholeRows(data);
        addSectionTitle(doc, "접수 내역");
        XWPFTable table = doc.createTable(Math.max(rows.size() + 1, 2), 9);
        setTableWidth(table);
        setHeaderRow(table.getRow(0), new String[]{"NO", "접수번호", "일자", "현장", "위치", "포장", "발생장소", "면적"});
        if (rows.isEmpty()) {
            setCellText(table.getRow(1).getCell(1), "출력할 데이터가 없습니다.", false);
            return;
        }
        for (int i = 0; i < rows.size(); i++) {
            Map<String, Object> row = rows.get(i);
            XWPFTableRow tr = table.getRow(i + 1);
            setCellText(tr.getCell(0), String.valueOf(i + 1), false);
            setCellText(tr.getCell(1), value(row.get("reportNo")), false);
            setCellText(tr.getCell(2), value(row.get("reportDate")), false);
            setCellText(tr.getCell(3), value(row.get("siteName")), false);
            setCellText(tr.getCell(4), firstNotBlank(value(row.get("locationInfo")), value(row.get("region"))), false);
            setCellText(tr.getCell(5), value(row.get("detailInfo")), false);
            setCellText(tr.getCell(6), value(row.get("pavementText")), false);
            setCellText(tr.getCell(7), value(row.get("occurPlaceText")), false);
            setCellText(tr.getCell(8), value(row.get("areaM2")), false);
        }
    }

    private void appendTemplateSummaryLines(List<String> lines, ReportTemplateCode templateCode, Map<String, Object> data) {
        Map<String, Object> yearSummary = asMap(data.get("yearSummary"));
        lines.add("템플릿: " + templateCode.name());
        lines.add("접수건수: " + value(yearSummary.get("potholeCount")));
        lines.add("전체면적: " + value(yearSummary.get("areaM2")));
        lines.add("비고: " + templateGuide(templateCode));
    }

    private String templateGuide(ReportTemplateCode templateCode) {
        if (templateCode == ReportTemplateCode.POTHOLE_SUMMARY) {
            return "기간별 포트홀 집계 기본 출력";
        }
        if (templateCode == ReportTemplateCode.MAINTENANCE_LOG) {
            return "접수별 유지보수 작업 내역 기본 출력";
        }
        if (templateCode == ReportTemplateCode.LANDSCAPE_DAILY_WORK) {
            return "조경 작업일보 기본 출력";
        }
        if (templateCode == ReportTemplateCode.MAINTENANCE_RESULT) {
            return "유지관리 결과보고서 기본 출력";
        }
        if (templateCode == ReportTemplateCode.PHOTO_BOARD) {
            return "사진대지 기본 출력. 사진 배치 정밀화는 후속 단계";
        }
        return "접수 기반 기본 출력";
    }

    private List<Map<String, Object>> flattenPotholeRows(Map<String, Object> data) {
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (Map<String, Object> group : mapList(data.get("monthGroups"))) {
            rows.addAll(mapList(group.get("rows")));
        }
        return rows;
    }

    private void addKeyValueTable(XWPFDocument doc, String[][] rows) {
        XWPFTable table = doc.createTable(rows.length, 4);
        setTableWidth(table);
        for (int i = 0; i < rows.length; i++) {
            XWPFTableRow row = table.getRow(i);
            setCellText(row.getCell(0), rows[i][0], true);
            setCellText(row.getCell(1), rows[i][1], false);
            setCellText(row.getCell(2), rows[i][2], true);
            setCellText(row.getCell(3), rows[i][3], false);
        }
    }

    private void addDailyCheckItemTable(XWPFDocument doc, List<DailyCheckLogItem> items) {
        List<DailyCheckLogItem> list = items == null ? new ArrayList<DailyCheckLogItem>() : items;
        XWPFTable table = doc.createTable(Math.max(list.size() + 1, 2), 4);
        setTableWidth(table);
        setHeaderRow(table.getRow(0), new String[]{"NO", "점검 항목", "결과", "필수"});
        if (list.isEmpty()) {
            setCellText(table.getRow(1).getCell(1), "점검 항목 없음", false);
            return;
        }
        for (int i = 0; i < list.size(); i++) {
            DailyCheckLogItem item = list.get(i);
            XWPFTableRow row = table.getRow(i + 1);
            setCellText(row.getCell(0), String.valueOf(i + 1), false);
            setCellText(row.getCell(1), value(item.getItemName()), false);
            setCellText(row.getCell(2), value(item.getCheckValue()), false);
            setCellText(row.getCell(3), "Y".equals(item.getRequiredYn()) ? "필수" : "선택", false);
        }
    }

    private void addPhotoSummary(XWPFDocument doc, List<DailyCheckPhoto> photos) {
        List<DailyCheckPhoto> list = photos == null ? new ArrayList<DailyCheckPhoto>() : photos;
        addMetaLine(doc, "사진: " + list.size() + "건");
        for (DailyCheckPhoto photo : list) {
            addMetaLine(doc, " - " + value(photo.getPhotoGb()) + " / " + value(photo.getImgName()));
        }
    }

    private void addSituationLogTable(XWPFDocument doc, List<SituationLog> logs) {
        XWPFTable table = doc.createTable(Math.max(logs.size() + 1, 2), 7);
        setTableWidth(table);
        setHeaderRow(table.getRow(0), new String[]{"NO", "일자", "구분", "시간", "현장", "제목", "내용"});
        if (logs.isEmpty()) {
            setCellText(table.getRow(1).getCell(1), "상황일지 없음", false);
            return;
        }
        for (int i = 0; i < logs.size(); i++) {
            SituationLog log = logs.get(i);
            XWPFTableRow row = table.getRow(i + 1);
            setCellText(row.getCell(0), String.valueOf(i + 1), false);
            setCellText(row.getCell(1), value(log.getLogDate()), false);
            setCellText(row.getCell(2), firstNotBlank(log.getShiftNm(), log.getShiftCd()), false);
            setCellText(row.getCell(3), value(log.getEventTime()), false);
            setCellText(row.getCell(4), firstNotBlank(log.getSiteName(), log.getSiteCd()), false);
            setCellText(row.getCell(5), value(log.getTitle()), false);
            setCellText(row.getCell(6), value(log.getContent()), false);
        }
    }

    private void addTitle(XWPFDocument doc, String title) {
        XWPFParagraph p = doc.createParagraph();
        p.setAlignment(ParagraphAlignment.CENTER);
        XWPFRun run = p.createRun();
        run.setFontFamily(FONT);
        run.setFontSize(18);
        run.setBold(true);
        run.setText(title);
    }

    private void addSectionTitle(XWPFDocument doc, String title) {
        XWPFParagraph p = doc.createParagraph();
        p.setBorderBottom(Borders.SINGLE);
        XWPFRun run = p.createRun();
        run.setFontFamily(FONT);
        run.setFontSize(13);
        run.setBold(true);
        run.setText(title);
    }

    private void addMetaLine(XWPFDocument doc, String text) {
        XWPFParagraph p = doc.createParagraph();
        XWPFRun run = p.createRun();
        run.setFontFamily(FONT);
        run.setFontSize(10);
        run.setText(text == null ? "" : text);
    }

    private void setHeaderRow(XWPFTableRow row, String[] headers) {
        for (int i = 0; i < headers.length; i++) {
            setCellText(row.getCell(i), headers[i], true);
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
        run.setFontFamily(FONT);
        run.setFontSize(9);
        run.setBold(bold);
        run.setText(value == null ? "" : value);
    }

    private byte[] buildSimpleHwpx(String title, List<String> lines) throws Exception {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ZipOutputStream zip = new ZipOutputStream(out, StandardCharsets.UTF_8);
        try {
            put(zip, "mimetype", "application/hwp+zip");
            put(zip, "META-INF/container.xml", "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                    + "<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">"
                    + "<rootfiles><rootfile full-path=\"Contents/content.hpf\" media-type=\"application/hwpml-package+xml\"/>"
                    + "</rootfiles></container>");
            put(zip, "version.xml", "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                    + "<hv:version xmlns:hv=\"http://www.hancom.co.kr/hwpml/2011/version\" app=\"road-sos\"/>");
            put(zip, "Contents/content.hpf", "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                    + "<opf:package xmlns:opf=\"http://www.idpf.org/2007/opf\" version=\"3.0\" unique-identifier=\"road-sos\">"
                    + "<opf:metadata><opf:title>" + xml(title) + "</opf:title><opf:language>ko-KR</opf:language></opf:metadata>"
                    + "<opf:manifest><opf:item id=\"header\" href=\"header.xml\" media-type=\"application/xml\"/>"
                    + "<opf:item id=\"section0\" href=\"section0.xml\" media-type=\"application/xml\"/></opf:manifest>"
                    + "<opf:spine><opf:itemref idref=\"section0\"/></opf:spine></opf:package>");
            put(zip, "Contents/header.xml", "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                    + "<hh:head xmlns:hh=\"http://www.hancom.co.kr/hwpml/2011/head\">"
                    + "<hh:beginNum page=\"1\" footnote=\"1\" endnote=\"1\" pic=\"1\" tbl=\"1\" equation=\"1\"/>"
                    + "</hh:head>");
            put(zip, "Contents/section0.xml", buildHwpxSection(lines));
            zip.finish();
            return out.toByteArray();
        } finally {
            zip.close();
            out.close();
        }
    }

    private String buildHwpxSection(List<String> lines) {
        StringBuilder sb = new StringBuilder();
        sb.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        sb.append("<hs:sec xmlns:hs=\"http://www.hancom.co.kr/hwpml/2011/section\">");
        for (String line : lines) {
            sb.append("<hp:p xmlns:hp=\"http://www.hancom.co.kr/hwpml/2011/paragraph\">")
                    .append("<hp:run><hp:t>").append(xml(line)).append("</hp:t></hp:run></hp:p>");
        }
        sb.append("</hs:sec>");
        return sb.toString();
    }

    private void put(ZipOutputStream zip, String path, String content) throws Exception {
        zip.putNextEntry(new ZipEntry(path));
        zip.write(content.getBytes(StandardCharsets.UTF_8));
        zip.closeEntry();
    }

    private String value(Object value) {
        return value == null ? "" : String.valueOf(value);
    }

    private String firstNotBlank(String first, String second) {
        return first != null && !first.trim().isEmpty() ? first : value(second);
    }

    private String nowText() {
        return new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new Date());
    }

    private String xml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&apos;");
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> mapList(Object value) {
        if (value instanceof List) {
            return (List<Map<String, Object>>) value;
        }
        return new ArrayList<Map<String, Object>>();
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> asMap(Object value) {
        if (value instanceof Map) {
            return (Map<String, Object>) value;
        }
        return new java.util.HashMap<String, Object>();
    }

    @SuppressWarnings("unchecked")
    private List<DailyCheckLog> dailyLogs(Object value) {
        if (value instanceof List) {
            return (List<DailyCheckLog>) value;
        }
        return new ArrayList<DailyCheckLog>();
    }

    @SuppressWarnings("unchecked")
    private List<SituationLog> situationLogs(Object value) {
        if (value instanceof List) {
            return (List<SituationLog>) value;
        }
        return new ArrayList<SituationLog>();
    }
}
