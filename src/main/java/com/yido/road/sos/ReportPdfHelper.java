package com.yido.road.sos;

import com.yido.road.sos.model.Incident;
import org.springframework.util.StringUtils;

import java.time.format.DateTimeFormatter;

public final class ReportPdfHelper {

	private ReportPdfHelper() {}

	public static String buildIncidentHtml(Incident inc, String contextPath) {
		String reportNo = nullSafe(inc.getReportNo());
		String siteName = inc.getSiteName() != null ? inc.getSiteName() : "알수없음";
		String addr     = nullSafe(inc.getAddr());
		String tel      = nullSafe(inc.getCellPhone());
		String manager  = nullSafe(inc.getManagerNm());
		String status   = nullSafe(inc.getStatusNm());
		String method   = nullSafe(inc.getIntakeMethodNm());
		String reportDt = nullSafe(inc.getReportDateFmt());
		String updateDt = nullSafe(inc.getUpdateDateFmt());
        String ocrReadKm= nullSafe(inc.getOcrReadKm());

		String rptImgUrl = hasRptImg(inc)
				? contextPath + "/sos/img/rpt/" + urlEnc(reportNo)
				: null;
		String fieldImgUrl = hasFieldImg(inc)
				? contextPath + "/sos/img/field/" + urlEnc(reportNo)
				: null;

		String css =
				"@font-face{ font-family:'NotoSansKR'; src:url('" + contextPath + "/css/NotoSansKR-Regular.ttf') format('truetype'); font-weight:400; font-style:normal; }" +
				"@font-face{ font-family:'NotoSansKR'; src:url('" + contextPath + "/css/NotoSansKR-Bold.ttf') format('truetype'); font-weight:700; font-style:normal; }" +
				"  @page { size: A4; margin: 24mm 18mm; }" +
				"  body { font-family: 'NotoSansKR', sans-serif; font-size: 10pt; color:#222; }" +
				"  h1 { font-size: 12pt; margin: 0 0 16pt 0; font-weight:700; }" +
				"  .meta { margin: 8pt 0 16pt 0; }" +
				"  .grid { width:100%; border-collapse:collapse; }" +
				"  .grid th, .grid td { border:1px solid #ccc; text-align:left; vertical-align:top; }" +
				"  .imgwrap { margin-top: 5pt; }" +
				"  .imgwrap img { max-width:300px; height:auto; border:1px solid #999; display:block; margin:6pt 0; }"+
				"  .imggrid { width:100%; border-collapse:collapse; margin-top:6pt; }" +
				"  .imggrid td { width:50%; padding:6pt; text-align:center; vertical-align:top; border:0; }" +
				"  .imgtitle { font-size:10pt; font-weight:700; margin:0 0 4pt 0; }" +
				"  .imggrid img { width:300px; height:auto; border:1px solid #999; display:inline-block; }";

		StringBuilder sb = new StringBuilder(4096);
		sb.append("<!DOCTYPE html><html xmlns='http://www.w3.org/1999/xhtml' lang='ko'><head><meta charset='UTF-8'/>")
				.append("<style>").append(css).append("</style>")
				.append("</head><body>");

		sb.append("<h1>사고접수 보고서</h1>");
		sb.append("<table class='grid'>")
				.append("<tr><th>현장명</th><td>").append(escape(siteName)).append("</td></tr>")
				.append("<tr><th>접수번호</th><td>").append(escape(reportNo)).append("</td></tr>")
				.append("<tr><th>접수일시</th><td>").append(escape(reportDt)).append("</td></tr>")
				.append("<tr><th>주소</th><td>").append(escape(addr)).append("</td></tr>")
                .append("<tr><th>기점 지점</th><td>").append(escape(ocrReadKm)).append("</td></tr>")
				.append("<tr><th>연락처</th><td>").append(escape(tel)).append("</td></tr>")
				.append("<tr><th>상태</th><td>").append(escape(status)).append("</td></tr>")
				.append("<tr><th>접수방법</th><td>").append(escape(method)).append("</td></tr>")
				.append("<tr><th>담당자</th><td>").append(escape(manager)).append("</td></tr>")
				.append("<tr><th>최종수정</th><td>").append(escape(updateDt)).append("</td></tr>")
				.append("</table>");

		// 이미지 섹션
		if (rptImgUrl != null || fieldImgUrl != null) {
			sb.append("<table class='imggrid'><tr>");

			if (rptImgUrl != null) {
				sb.append("<td>")
						.append("<div class='imgtitle'>접수 이미지</div>")
						.append("<img src='").append(rptImgUrl).append("' alt='접수 이미지'/>")
						.append("</td>");
			} else {
				sb.append("<td></td>");
			}

			if (fieldImgUrl != null) {
				sb.append("<td>")
						.append("<div class='imgtitle'>현장 이미지</div>")
						.append("<img src='").append(fieldImgUrl).append("' alt='현장 이미지'/>")
						.append("</td>");
			} else {
				sb.append("<td></td>");
			}

			sb.append("</tr></table>");
		}


		sb.append("</body></html>");
		return sb.toString();
	}

	private static boolean hasRptImg(Incident inc) {
		return StringUtils.hasText(inc.getRptImgPath()) && StringUtils.hasText(inc.getRptImgName());
	}
	private static boolean hasFieldImg(Incident inc) {
		return StringUtils.hasText(inc.getImgPath()) && StringUtils.hasText(inc.getImgName());
	}
	private static String nullSafe(String s) { return (s == null ? "" : s); }
	private static String urlEnc(String s) {
		try { return java.net.URLEncoder.encode(nullSafe(s), java.nio.charset.StandardCharsets.UTF_8.name()); }
		catch (Exception e) { return nullSafe(s); }
	}
	private static String escape(String s) {
		if (s == null) return "";
		return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
	}
}