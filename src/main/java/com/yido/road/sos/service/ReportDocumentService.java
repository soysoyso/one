package com.yido.road.sos.service;

import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import com.yido.road.sos.enums.ReportTemplateCode;
import com.yido.road.sos.model.DailyCheckLog;
import com.yido.road.sos.model.DailyCheckLogItem;
import com.yido.road.sos.model.DailyCheckPhoto;
import com.yido.road.sos.model.SituationLog;
import org.apache.poi.util.Units;
import org.apache.poi.xwpf.usermodel.Borders;
import org.apache.poi.xwpf.usermodel.Document;
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

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Date;
import java.util.List;
import java.util.Map;

@Service
public class ReportDocumentService {
    private static final String FONT = "Malgun Gothic";

    public byte[] buildPotholeTemplateDocx(ReportTemplateCode templateCode, Map<String, Object> data) throws Exception {
        XWPFDocument doc = new XWPFDocument();
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try {
            addTitle(doc, documentTitle(templateCode, data));
            addMetaLine(doc, "현장: " + firstNotBlank(value(data.get("siteName")), "전체"));
            addMetaLine(doc, "보고연도: " + value(data.get("reportYear")));
            addMetaLine(doc, "출력일시: " + nowText());

            if (templateCode == ReportTemplateCode.POTHOLE_LEDGER) {
                addPotholeLedgerDocxBody(doc, data);
            } else if (templateCode == ReportTemplateCode.POTHOLE_SUMMARY) {
                addPotholeSummaryDocxBody(doc, data);
            } else if (templateCode == ReportTemplateCode.MAINTENANCE_LOG) {
                addMaintenanceLogDocxBody(doc, data);
            } else if (templateCode == ReportTemplateCode.LANDSCAPE_DAILY_WORK) {
                addLandscapeDailyWorkDocxBody(doc, data);
            } else if (templateCode == ReportTemplateCode.MAINTENANCE_RESULT) {
                addMaintenanceResultDocxBody(doc, data);
            } else if (templateCode == ReportTemplateCode.PHOTO_BOARD) {
                addPhotoBoardDocxBody(doc, data);
            } else {
                addBasicPotholeDocxBody(doc, data);
            }

            doc.write(out);
            return out.toByteArray();
        } finally {
            doc.close();
            out.close();
        }
    }

    public byte[] buildPotholeTemplatePdf(ReportTemplateCode templateCode, Map<String, Object> data) throws Exception {
        String html = buildTemplateHtml(templateCode, data);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try {
            PdfRendererBuilder builder = new PdfRendererBuilder();
            builder.useFastMode();
            builder.withHtmlContent(html, "");
            builder.toStream(out);
            builder.run();
            return out.toByteArray();
        } finally {
            out.close();
        }
    }

    public byte[] buildDailyCheckDocx(Map<String, Object> data) throws Exception {
        XWPFDocument doc = new XWPFDocument();
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        try {
            addTitle(doc, "일상점검 일지");
            addMetaLine(doc, "출력일시: " + nowText());

            List<DailyCheckLog> logs = dailyLogs(data.get("dailyChecks"));
            if (logs.isEmpty()) {
                addMetaLine(doc, "출력할 일상점검 데이터가 없습니다.");
            }
            for (DailyCheckLog log : logs) {
                addSectionTitle(doc, firstNotBlank(log.getCheckNo(), "일상점검") + " / " + value(log.getCheckDate()));
                addKeyValueTable(doc, new String[][]{
                        {"점검일자", value(log.getCheckDate()), "현장", firstNotBlank(log.getSiteName(), log.getSiteCd())},
                        {"체크리스트", value(log.getChecklistName()), "작성자", firstNotBlank(log.getWriterNm(), log.getWriterId())},
                        {"상태", firstNotBlank(log.getStatusNm(), log.getStatusCd()), "비고", value(log.getRemark())}
                });
                addDailyCheckItemTable(doc, log.getItems());
                addDailyPhotoSummary(doc, log.getPhotos());
            }

            doc.write(out);
            return out.toByteArray();
        } finally {
            doc.close();
            out.close();
        }
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

    private void addPotholeLedgerDocxBody(XWPFDocument doc, Map<String, Object> data) {
        for (Map<String, Object> group : mapList(data.get("monthGroups"))) {
            addSectionTitle(doc, value(group.get("month")) + "월 접수 및 처리대장");
            addTable(doc,
                    new String[]{"NO", "접수번호", "일자", "현장", "방향", "위치", "파손형태", "발생위치", "면적"},
                    new String[]{"rowNo", "reportNo", "reportDate", "siteName", "directionNm", "locationInfo", "pavementText", "occurPlaceText", "areaM2"},
                    withRowNo(mapList(group.get("rows"))));
        }
        if (flattenPotholeRows(data).isEmpty()) {
            addMetaLine(doc, "출력할 관리대장 데이터가 없습니다.");
        }
    }

    private void addPotholeSummaryDocxBody(XWPFDocument doc, Map<String, Object> data) {
        addSectionTitle(doc, "연간 집계");
        Map<String, Object> year = asMap(data.get("yearSummary"));
        addKeyValueTable(doc, new String[][]{
                {"총 접수건수", value(year.get("potholeCount")), "총 면적", value(year.get("areaM2"))},
                {"집계월수", String.valueOf(mapList(data.get("monthGroups")).size()), "비고", "월별 포트홀 접수 집계"}
        });

        addSectionTitle(doc, "월별 집계");
        List<Map<String, Object>> groups = mapList(data.get("monthGroups"));
        XWPFTable table = doc.createTable(Math.max(groups.size() + 1, 2), 5);
        setTableWidth(table);
        setHeaderRow(table.getRow(0), new String[]{"월", "접수건수", "보수완료", "기타", "비고"});
        if (groups.isEmpty()) {
            setCellText(table.getRow(1).getCell(0), "-", false);
            setCellText(table.getRow(1).getCell(1), "데이터 없음", false);
            return;
        }
        for (int i = 0; i < groups.size(); i++) {
            Map<String, Object> group = groups.get(i);
            Map<String, Object> summary = asMap(group.get("summary"));
            XWPFTableRow row = table.getRow(i + 1);
            setCellText(row.getCell(0), value(group.get("month")), false);
            setCellText(row.getCell(1), value(summary.get("potholeCount")), false);
            setCellText(row.getCell(2), value(summary.get("patchCount")), false);
            setCellText(row.getCell(3), value(summary.get("etcCount")), false);
            setCellText(row.getCell(4), "", false);
        }
    }

    private void addMaintenanceLogDocxBody(XWPFDocument doc, Map<String, Object> data) {
        addSectionTitle(doc, "시간순 유지보수 작업일지");
        addTable(doc,
                new String[]{"일자", "시간", "접수번호", "현장", "위치", "작업구분", "작업내용", "담당자"},
                new String[]{"reportDate", "workTimeRange", "reportNo", "siteName", "locationInfo", "receiptGbNm", "processNote", "managerNm"},
                enrichMaintenanceRows(flattenPotholeRows(data)));
    }

    private void addLandscapeDailyWorkDocxBody(XWPFDocument doc, Map<String, Object> data) {
        addSectionTitle(doc, "조경 작업일보");
        addKeyValueTable(doc, new String[][]{
                {"작업일", value(data.get("reportYear")), "현장", firstNotBlank(value(data.get("siteName")), "전체")},
                {"작업분야", "조경/환경 정비", "작성", nowText()}
        });
        addTable(doc,
                new String[]{"구간", "작업내용", "투입장비", "투입자재", "작업량", "비고"},
                new String[]{"staText", "processNote", "equipmentText", "materialText", "workQty", "reportRemark"},
                flattenPotholeRows(data));
    }

    private void addMaintenanceResultDocxBody(XWPFDocument doc, Map<String, Object> data) {
        List<Map<String, Object>> rows = flattenPotholeRows(data);
        if (rows.isEmpty()) {
            addMetaLine(doc, "출력할 결과보고 데이터가 없습니다.");
            return;
        }
        for (Map<String, Object> row : rows) {
            addSectionTitle(doc, "결과보고 - " + value(row.get("reportNo")));
            addKeyValueTable(doc, new String[][]{
                    {"문서번호", value(row.get("docNo")), "접수번호", value(row.get("reportNo"))},
                    {"현장", value(row.get("siteName")), "위치", value(row.get("locationInfo"))},
                    {"처리내용", firstNotBlank(value(row.get("processNote")), value(row.get("deliveryNote"))), "비고", value(row.get("reportRemark"))},
                    {"실작업량", value(row.get("workQty")), "환산작업량", value(row.get("convertWorkQty"))},
                    {"정산작업량", value(row.get("accountWorkQty")), "작업시간", workTimeRange(row)}
            });
        }
    }

    private void addPhotoBoardDocxBody(XWPFDocument doc, Map<String, Object> data) throws Exception {
        List<Map<String, Object>> rows = flattenPotholeRows(data);
        if (rows.isEmpty()) {
            addMetaLine(doc, "출력할 사진대지 데이터가 없습니다.");
            return;
        }
        for (Map<String, Object> row : rows) {
            addSectionTitle(doc, "사진대지 - " + value(row.get("reportNo")));
            addKeyValueTable(doc, new String[][]{
                    {"현장", value(row.get("siteName")), "위치", value(row.get("locationInfo"))},
                    {"내용", firstNotBlank(value(row.get("processNote")), value(row.get("deliveryNote"))), "비고", value(row.get("reportRemark"))}
            });
            XWPFTable table = doc.createTable(2, 2);
            setTableWidth(table);
            setHeaderRow(table.getRow(0), new String[]{"조치 전", "조치 후"});
            addImageOrText(table.getRow(1).getCell(0), value(row.get("beforeImgBase64")), "조치 전 사진 없음");
            addImageOrText(table.getRow(1).getCell(1), value(row.get("afterImgBase64")), "조치 후 사진 없음");
        }
    }

    private void addBasicPotholeDocxBody(XWPFDocument doc, Map<String, Object> data) {
        addTable(doc,
                new String[]{"접수번호", "일자", "현장", "위치", "파손형태", "발생위치", "면적"},
                new String[]{"reportNo", "reportDate", "siteName", "locationInfo", "pavementText", "occurPlaceText", "areaM2"},
                flattenPotholeRows(data));
    }

    private String buildTemplateHtml(ReportTemplateCode templateCode, Map<String, Object> data) {
        StringBuilder html = new StringBuilder();
        html.append("<html><head><meta charset='UTF-8'/>");
        html.append("<style>");
        html.append("@page{size:A4;margin:14mm;}body{font-family:'Malgun Gothic',sans-serif;font-size:11px;color:#111;}");
        html.append("h1{text-align:center;font-size:22px;margin:0 0 12px;}h2{font-size:15px;margin:18px 0 8px;border-bottom:2px solid #222;padding-bottom:4px;}");
        html.append(".meta{margin:2px 0;color:#333}.summary{display:table;width:100%;margin:10px 0;border-collapse:collapse}.summary div{display:table-cell;border:1px solid #999;padding:8px;text-align:center}");
        html.append("table{width:100%;border-collapse:collapse;margin-top:8px;}th,td{border:1px solid #999;padding:5px;vertical-align:top;}th{background:#f1f4f8;}");
        html.append(".result{page-break-inside:avoid;margin-bottom:14px}.photo-grid{width:100%;display:table;table-layout:fixed;margin-top:8px}.photo-cell{display:table-cell;width:50%;border:1px solid #999;padding:8px;text-align:center;vertical-align:middle}.photo-cell img{max-width:100%;height:210px;object-fit:contain}.caption{font-weight:bold;margin-bottom:6px}");
        html.append("</style></head><body>");
        html.append("<h1>").append(xml(documentTitle(templateCode, data))).append("</h1>");
        html.append("<p class='meta'>현장: ").append(xml(firstNotBlank(value(data.get("siteName")), "전체"))).append("</p>");
        html.append("<p class='meta'>보고연도: ").append(xml(value(data.get("reportYear")))).append("</p>");
        html.append("<p class='meta'>출력일시: ").append(xml(nowText())).append("</p>");

        if (templateCode == ReportTemplateCode.POTHOLE_SUMMARY) {
            appendSummaryHtml(html, data);
        } else if (templateCode == ReportTemplateCode.MAINTENANCE_LOG) {
            appendTableHtml(html, "시간순 유지보수 작업일지",
                    new String[]{"일자", "시간", "접수번호", "현장", "위치", "작업구분", "작업내용", "담당자"},
                    new String[]{"reportDate", "workTimeRange", "reportNo", "siteName", "locationInfo", "receiptGbNm", "processNote", "managerNm"},
                    enrichMaintenanceRows(flattenPotholeRows(data)));
        } else if (templateCode == ReportTemplateCode.LANDSCAPE_DAILY_WORK) {
            appendTableHtml(html, "조경 작업일보",
                    new String[]{"구간", "작업내용", "투입장비", "투입자재", "작업량", "비고"},
                    new String[]{"staText", "processNote", "equipmentText", "materialText", "workQty", "reportRemark"},
                    flattenPotholeRows(data));
        } else if (templateCode == ReportTemplateCode.MAINTENANCE_RESULT) {
            appendResultHtml(html, flattenPotholeRows(data));
        } else if (templateCode == ReportTemplateCode.PHOTO_BOARD) {
            appendPhotoBoardHtml(html, flattenPotholeRows(data));
        } else {
            appendTableHtml(html, templateCode == ReportTemplateCode.POTHOLE_LEDGER ? "접수 및 처리대장" : "접수 내역",
                    new String[]{"접수번호", "일자", "현장", "위치", "파손형태", "발생위치", "면적"},
                    new String[]{"reportNo", "reportDate", "siteName", "locationInfo", "pavementText", "occurPlaceText", "areaM2"},
                    flattenPotholeRows(data));
        }

        html.append("</body></html>");
        return html.toString();
    }

    private void appendSummaryHtml(StringBuilder html, Map<String, Object> data) {
        Map<String, Object> year = asMap(data.get("yearSummary"));
        html.append("<div class='summary'><div><b>총 접수건수</b><br/>").append(xml(value(year.get("potholeCount")))).append("</div>")
                .append("<div><b>총 면적</b><br/>").append(xml(value(year.get("areaM2")))).append("</div>")
                .append("<div><b>집계월수</b><br/>").append(mapList(data.get("monthGroups")).size()).append("</div></div>");
        html.append("<h2>월별 집계</h2><table><tr><th>월</th><th>접수건수</th><th>보수완료</th><th>기타</th></tr>");
        for (Map<String, Object> group : mapList(data.get("monthGroups"))) {
            Map<String, Object> summary = asMap(group.get("summary"));
            html.append("<tr><td>").append(xml(value(group.get("month")))).append("</td><td>")
                    .append(xml(value(summary.get("potholeCount")))).append("</td><td>")
                    .append(xml(value(summary.get("patchCount")))).append("</td><td>")
                    .append(xml(value(summary.get("etcCount")))).append("</td></tr>");
        }
        html.append("</table>");
    }

    private void appendTableHtml(StringBuilder html, String title, String[] headers, String[] keys, List<Map<String, Object>> rows) {
        html.append("<h2>").append(xml(title)).append("</h2><table><tr>");
        for (String header : headers) {
            html.append("<th>").append(xml(header)).append("</th>");
        }
        html.append("</tr>");
        if (rows.isEmpty()) {
            html.append("<tr><td colspan='").append(headers.length).append("'>데이터 없음</td></tr>");
        }
        for (Map<String, Object> row : rows) {
            html.append("<tr>");
            for (String key : keys) {
                html.append("<td>").append(xml(value(row.get(key)))).append("</td>");
            }
            html.append("</tr>");
        }
        html.append("</table>");
    }

    private void appendResultHtml(StringBuilder html, List<Map<String, Object>> rows) {
        html.append("<h2>유지관리 결과보고</h2>");
        if (rows.isEmpty()) {
            html.append("<p>데이터 없음</p>");
            return;
        }
        for (Map<String, Object> row : rows) {
            html.append("<div class='result'><table>")
                    .append("<tr><th>문서번호</th><td>").append(xml(value(row.get("docNo")))).append("</td><th>접수번호</th><td>").append(xml(value(row.get("reportNo")))).append("</td></tr>")
                    .append("<tr><th>현장</th><td>").append(xml(value(row.get("siteName")))).append("</td><th>위치</th><td>").append(xml(value(row.get("locationInfo")))).append("</td></tr>")
                    .append("<tr><th>처리내용</th><td colspan='3'>").append(xml(firstNotBlank(value(row.get("processNote")), value(row.get("deliveryNote"))))).append("</td></tr>")
                    .append("<tr><th>실작업량</th><td>").append(xml(value(row.get("workQty")))).append("</td><th>환산작업량</th><td>").append(xml(value(row.get("convertWorkQty")))).append("</td></tr>")
                    .append("<tr><th>정산작업량</th><td>").append(xml(value(row.get("accountWorkQty")))).append("</td><th>비고</th><td>").append(xml(value(row.get("reportRemark")))).append("</td></tr>")
                    .append("</table></div>");
        }
    }

    private void appendPhotoBoardHtml(StringBuilder html, List<Map<String, Object>> rows) {
        html.append("<h2>사진대지</h2>");
        if (rows.isEmpty()) {
            html.append("<p>데이터 없음</p>");
            return;
        }
        for (Map<String, Object> row : rows) {
            html.append("<div class='result'><table><tr><th>접수번호</th><td>").append(xml(value(row.get("reportNo"))))
                    .append("</td><th>위치</th><td>").append(xml(value(row.get("locationInfo")))).append("</td></tr></table>");
            html.append("<div class='photo-grid'><div class='photo-cell'><div class='caption'>조치 전</div>");
            appendHtmlImageOrText(html, value(row.get("beforeImgBase64")), "조치 전 사진 없음");
            html.append("</div><div class='photo-cell'><div class='caption'>조치 후</div>");
            appendHtmlImageOrText(html, value(row.get("afterImgBase64")), "조치 후 사진 없음");
            html.append("</div></div></div>");
        }
    }

    private void appendHtmlImageOrText(StringBuilder html, String base64, String emptyText) {
        if (base64 == null || base64.trim().isEmpty()) {
            html.append(xml(emptyText));
            return;
        }
        String src = base64.startsWith("data:") ? base64 : "data:image/jpeg;base64," + base64;
        html.append("<img src='").append(xml(src)).append("'/>");
    }

    private List<Map<String, Object>> enrichMaintenanceRows(List<Map<String, Object>> rows) {
        for (Map<String, Object> row : rows) {
            row.put("workTimeRange", workTimeRange(row));
        }
        return rows;
    }

    private String workTimeRange(Map<String, Object> row) {
        String start = value(row.get("workStartAt"));
        String end = value(row.get("workEndAt"));
        if (start.isEmpty() && end.isEmpty()) return "";
        return start + " ~ " + end;
    }

    private List<Map<String, Object>> withRowNo(List<Map<String, Object>> rows) {
        for (int i = 0; i < rows.size(); i++) {
            rows.get(i).put("rowNo", String.valueOf(i + 1));
        }
        return rows;
    }

    private void addTable(XWPFDocument doc, String[] headers, String[] keys, List<Map<String, Object>> rows) {
        XWPFTable table = doc.createTable(Math.max(rows.size() + 1, 2), headers.length);
        setTableWidth(table);
        setHeaderRow(table.getRow(0), headers);
        if (rows.isEmpty()) {
            setCellText(table.getRow(1).getCell(0), "데이터 없음", false);
            return;
        }
        for (int r = 0; r < rows.size(); r++) {
            XWPFTableRow row = table.getRow(r + 1);
            Map<String, Object> data = rows.get(r);
            for (int c = 0; c < keys.length; c++) {
                setCellText(row.getCell(c), value(data.get(keys[c])), false);
            }
        }
    }

    private void addDailyCheckItemTable(XWPFDocument doc, List<DailyCheckLogItem> items) {
        List<DailyCheckLogItem> list = items == null ? new ArrayList<DailyCheckLogItem>() : items;
        XWPFTable table = doc.createTable(Math.max(list.size() + 1, 2), 4);
        setTableWidth(table);
        setHeaderRow(table.getRow(0), new String[]{"NO", "점검 항목", "결과", "필수"});
        if (list.isEmpty()) {
            setCellText(table.getRow(1).getCell(0), "점검 항목 없음", false);
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

    private void addDailyPhotoSummary(XWPFDocument doc, List<DailyCheckPhoto> photos) {
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
            setCellText(table.getRow(1).getCell(0), "상황일지 없음", false);
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

    private void addImageOrText(XWPFTableCell cell, String base64, String emptyText) throws Exception {
        cell.removeParagraph(0);
        XWPFParagraph p = cell.addParagraph();
        p.setAlignment(ParagraphAlignment.CENTER);
        XWPFRun run = p.createRun();
        byte[] imageBytes = decodeBase64Image(base64);
        if (imageBytes.length == 0) {
            run.setFontFamily(FONT);
            run.setText(emptyText);
            return;
        }
        run.addPicture(new ByteArrayInputStream(imageBytes), detectPictureType(imageBytes), "photo", Units.toEMU(220), Units.toEMU(160));
    }

    private byte[] decodeBase64Image(String value) {
        if (value == null || value.trim().isEmpty()) return new byte[0];
        String base64 = value.trim();
        int comma = base64.indexOf(',');
        if (base64.startsWith("data:") && comma >= 0) {
            base64 = base64.substring(comma + 1);
        }
        try {
            return Base64.getDecoder().decode(base64);
        } catch (IllegalArgumentException e) {
            return new byte[0];
        }
    }

    private int detectPictureType(byte[] bytes) {
        if (bytes.length > 8 && bytes[0] == (byte) 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
            return Document.PICTURE_TYPE_PNG;
        }
        return Document.PICTURE_TYPE_JPEG;
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

    private String documentTitle(ReportTemplateCode templateCode, Map<String, Object> data) {
        if (templateCode == ReportTemplateCode.POTHOLE_LEDGER) {
            return value(data.get("reportYear")) + "년 도로파손(포트홀) 관리대장";
        }
        return templateCode.getDisplayName();
    }

    private List<Map<String, Object>> flattenPotholeRows(Map<String, Object> data) {
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (Map<String, Object> group : mapList(data.get("monthGroups"))) {
            rows.addAll(mapList(group.get("rows")));
        }
        return rows;
    }

    private String value(Object value) {
        if (value == null) return "";
        if (value instanceof BigDecimal) {
            return ((BigDecimal) value).stripTrailingZeros().toPlainString();
        }
        return String.valueOf(value);
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
