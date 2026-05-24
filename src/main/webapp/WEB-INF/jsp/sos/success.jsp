<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<jsp:useBean id="now" class="java.util.Date" /> <%-- 캐시 방지용 v 파라미터 --%>

<%@include file="../common/head.jsp"%>
<%@include file="../common/script.jsp"%>
<body class="user">
    <div class="header">
        <h5>고속도로 사고 접수</h5>
    </div>
    <div class="container">
        <h5 class="text-primary pt-4"><b>신고 접수 완료</b></h5>
        <p>담당자가 확인 후 전화 드릴 예정입니다.</p>

        <div class="dash-box my-4 text-start">

        <div class="mb-3">
            <div style="font-weight: 700; font-size: 0.9rem;">접수 번호</div>
            <div style="font-weight: 400; font-size: 0.95rem;">
                ${incident.reportNo}
            </div>
        </div>


        <!-- 고속도로 -->
        <div class="mb-3">
            <div style="font-weight: 700; font-size: 0.9rem;">고속도로</div>
            <div style="font-weight: 400; font-size: 0.95rem;">
                <c:choose>
                    <c:when test="${not empty candidateSiteNames}">
                        ${candidateSiteNames}
                    </c:when>
                    <c:otherwise>
                        ${incident.siteName}
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 접수일시 -->
        <div class="mb-3">
            <div style="font-weight: 700; font-size: 0.9rem;">접수일시</div>
            <div style="font-weight: 400; font-size: 0.95rem;">
                ${incident.reportDateFmt}
            </div>
        </div>

        <!-- 주소 -->
        <div class="mb-3">
            <div style="font-weight: 700; font-size: 0.9rem;">주소</div>
            <div style="font-weight: 400; font-size: 0.95rem; line-height: 1.45;">
                ${incident.addr}
            </div>
        </div>

        <!-- 이미지 -->
        <c:if test="${not empty incident.rptImgPath and not empty incident.rptImgName}">
            <div class="mt-3">
                <img
                    src="<c:url value='/sos/img/rpt/${incident.reportNo}'/>?v=${now.time}"
                    class="img-fluid img-ex"
                    alt="접수 이미지" />
            </div>
        </c:if>

    </div>


    </div>

    <div class="footer">
        <%--
        <div class="box">
        <p>확인서가 카카오톡으로 전송됩니다.<br><b class="text-primary">구조대 도착 예정시간: 15분 내외</b></p>
        </div>--%>
        <button type="button" class="btn bg-primary mt-0" onclick="location.href='/sos/main'">새 신고 접수</button>

    </div>

</body>
<script>

</script>