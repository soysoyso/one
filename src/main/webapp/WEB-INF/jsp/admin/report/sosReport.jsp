<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>사고접수 보고서</title>

    <style>
        /* PDF 엔진에 따라 @font-face 지원이 다를 수 있음(지원되면 사용) */
        @font-face {
            font-family: 'NotoSansKR';
            src: url('<c:url value="/css/NotoSansKR-Regular.ttf"/>') format('truetype');
            font-weight: 400;
            font-style: normal;
        }
        @font-face {
            font-family: 'NotoSansKR';
            src: url('<c:url value="/css/NotoSansKR-Bold.ttf"/>') format('truetype');
            font-weight: 700;
            font-style: normal;
        }

        @page { size: A4; margin: 24mm 18mm; }

        body { font-family: 'NotoSansKR', sans-serif; font-size: 10pt; color: #222; }
        h1 { font-size: 12pt; margin: 0 0 16pt 0; font-weight: 700; }

        .grid { width: 100%; border-collapse: collapse; }
        .grid th, .grid td { border: 1px solid #ccc; text-align: left; vertical-align: top; padding: 6pt 8pt; }
        .grid th { width: 22%; background: #f6f6f6; font-weight: 700; }

        .imggrid { width: 100%; border-collapse: collapse; margin-top: 10pt; }
        .imggrid td { width: 50%; padding: 6pt; text-align: center; vertical-align: top; border: 0; }

        .imgtitle { font-size: 10pt; font-weight: 700; margin: 0 0 4pt 0; text-align:left; }
        .imgbox { border: 1px solid #999; padding: 6pt; }
        .imgbox img { width: 300px; height: auto; display: inline-block; }

        .nodata { color: #999; font-size: 9pt; text-align: left; }
    </style>
</head>

<body>
<h1>사고접수 보고서</h1>

<table class="grid">
    <tr>
        <th>현장명</th>
        <td><c:out value="${empty inc.siteName ? '알수없음' : inc.siteName}"/></td>
    </tr>
    <tr>
        <th>접수번호</th>
        <td><c:out value="${inc.reportNo}"/></td>
    </tr>
    <tr>
        <th>접수일시</th>
        <td>
            <!-- inc.reportDateFmt 가 있으면 그걸 쓰고, 없으면 reportDate -->
            <c:choose>
                <c:when test="${not empty inc.reportDateFmt}">
                    <c:out value="${inc.reportDateFmt}"/>
                </c:when>
                <c:otherwise>
                    <c:out value="${inc.reportDate}"/>
                </c:otherwise>
            </c:choose>
        </td>
    </tr>
    <tr>
        <th>주소</th>
        <td><c:out value="${inc.addr}"/></td>
    </tr>
    <tr>
        <th>기점 지점</th>
        <td><c:out value="${inc.ocrReadKm}"/></td>
    </tr>
    <tr>
        <th>연락처</th>
        <td><c:out value="${inc.cellPhone}"/></td>
    </tr>
    <tr>
        <th>상태</th>
        <td>
            <!-- statusNm 있으면 그걸 표시 -->
            <c:out value="${not empty inc.statusNm ? inc.statusNm : inc.statusCd}"/>
        </td>
    </tr>
    <tr>
        <th>접수방법</th>
        <td>
            <c:out value="${not empty inc.intakeMethodNm ? inc.intakeMethodNm : inc.intakeMethodCd}"/>
        </td>
    </tr>
    <tr>
        <th>담당자</th>
        <td><c:out value="${inc.managerNm}"/></td>
    </tr>
    <tr>
        <th>최종수정</th>
        <td>
            <c:choose>
                <c:when test="${not empty inc.updateDateFmt}">
                    <c:out value="${inc.updateDateFmt}"/>
                </c:when>
                <c:otherwise>
                    <c:out value="${inc.updateDatetime}"/>
                </c:otherwise>
            </c:choose>
        </td>
    </tr>
</table>

<!-- 이미지 URL 구성: 서버가 프록시 엔드포인트를 제공하니 그걸 그대로 씀 -->
<c:set var="reportNo" value="${inc.reportNo}"/>
<c:set var="rptImgUrl" value="${pageContext.request.contextPath}/sos/img/rpt/${reportNo}"/>
<c:set var="fieldImgUrl" value="${pageContext.request.contextPath}/sos/img/field/${reportNo}"/>
<c:if test="${not empty inc.rptImgPath or not empty inc.imgPath}">
    <table class="imggrid">
        <tr>

            <!-- 접수 이미지 -->
            <td>
                <c:if test="${not empty inc.rptImgPath}">
                    <div class="imgtitle">접수 이미지</div>
                    <div class="imgbox">
                        <img src="<c:out value='${rptImgUrl}'/>" alt="접수 이미지"/>
                    </div>
                </c:if>
            </td>

            <!-- 현장 이미지 -->
            <td>
                <c:if test="${not empty inc.imgPath}">
                    <div class="imgtitle">현장 이미지</div>
                    <div class="imgbox">
                        <img src="<c:out value='${fieldImgUrl}'/>" alt="현장 이미지"/>
                    </div>
                </c:if>
            </td>

        </tr>
    </table>
</c:if>

</body>
</html>
