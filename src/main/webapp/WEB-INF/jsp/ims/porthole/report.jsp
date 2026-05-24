<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java"  pageEncoding="UTF-8"%>
<%request.setAttribute("pageTitle", "접수하기");%>
<%@include file="../common/head.jsp" %>
<%@include file="../common/header.jsp" %>
<body class="sub">
<div class="container">
    <%-- geo-utils.js가 채우는 hidden 값들 --%>
    <input type="hidden" id="lat" name="lat" value="">
    <input type="hidden" id="lng" name="lng" value="">
    <input type="hidden" id="accuracyM" name="accuracyM" value="">
    <input type="hidden" id="capturedTs" name="capturedTs">
    <input type="hidden" id="addr" name="addr" value="">

    <%@include file="report-form.jsp" %>
</div>
</body>
<script>
    $(document).ready(function() {
        // 위치 및 날씨정보 조회
        requestPositionForPothole();
    });
</script>
</html>