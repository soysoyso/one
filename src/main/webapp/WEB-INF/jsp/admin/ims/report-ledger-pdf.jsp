<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <link rel="stylesheet" href="/css/report-ledger-pdf.css" />
</head>
<body>

<div class="cover-page">
    <div class="cover-inner">
        <div class="cover-site"><c:out value="${data.siteName}" /></div>
        <div class="cover-title">포트홀 관리대장</div>
        <div class="cover-year"><c:out value="${data.reportYear}" />.</div>
        <div class="cover-footer">
            <c:out value="${data.siteName}" />
        </div>

    </div>
</div>

<div class="ledger-page">

    <div class="month-summary-title">◎ <c:out value="${data.reportYear}" />년도 정비 현황</div>

    <table class="summary-table">
        <colgroup>
            <col style="width: 25%;" />
            <col style="width: 50%;" />
            <col style="width: 25%;" />
        </colgroup>
        <thead>
        <tr>
            <th>구 분</th>
            <th><c:out value="${data.reportYear}" />년도 정비 현황</th>
            <th>비 고</th>
        </tr>
        </thead>
        <tbody>
        <tr>
            <td>포트홀</td>
            <td><c:out value="${data.yearSummary.potholeCount}" /></td>
            <td></td>
        </tr>
        <tr>
            <td>패칭보수</td>
            <td><c:out value="${data.yearSummary.patchCount}" /></td>
            <td></td>
        </tr>
        <tr>
            <td>기 타</td>
            <td><c:out value="${data.yearSummary.etcCount}" /></td>
            <td></td>
        </tr>
        </tbody>
    </table>

</div>

<div class="page-break"></div>

<c:forEach items="${data.monthGroups}" var="group" varStatus="gStatus">
    <div class="ledger-page">
        <div class="month-summary-title">◎ <c:out value="${group.month}" />.01 정비 현황</div>

        <table class="summary-table">
            <colgroup>
                <col style="width: 25%;" />
                <col style="width: 50%;" />
                <col style="width: 25%;" />
            </colgroup>
            <thead>
            <tr>
                <th>구 분</th>
                <th><c:out value="${data.reportYear}" />년도 정비 현황</th>
                <th>비 고</th>
            </tr>
            </thead>
            <tbody>
            <tr>
                <td>포트홀</td>
                <td><c:out value="${group.summary.potholeCount}" /></td>
                <td></td>
            </tr>
            <tr>
                <td>패칭보수</td>
                <td><c:out value="${group.summary.patchCount}" /></td>
                <td></td>
            </tr>
            <tr>
                <td>기 타</td>
                <td><c:out value="${group.summary.etcCount}" /></td>
                <td></td>
            </tr>
            </tbody>
        </table>

        <div class="month-detail-title">- 정비내역_<c:out value="${group.month}" />월</div>

        <table class="detail-table">
            <colgroup>
                <col class="c-no" />
                <col class="c-dir" />
                <col class="c-loc" />
                <col class="c-lane" />
                <col class="c-w" />
                <col class="c-h" />
                <col class="c-d" />
                <col class="c-a" />
                <col class="c-rd" />
                <col class="c-wd" />
                <col class="c-rmk" />
            </colgroup>
            <thead>
            <tr>
                <th rowspan="2">번호</th>
                <th rowspan="2">방향</th>
                <th rowspan="2">위치</th>
                <th rowspan="2">차로</th>
                <th colspan="4">작업면적</th>
                <th colspan="2">조치내용</th>
                <th rowspan="2">비고</th>
            </tr>
            <tr>
                <th colspan="4">( W × L × T = ㎡ )</th>
                <th>발생일자</th>
                <th>처리일자</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach items="${group.rows}" var="row" varStatus="st">
                <tr>
                    <td><c:out value="${st.index + 1}" /></td>
                    <td><c:out value="${row.directionNm}" /></td>
                    <td><c:out value="${row.locationInfo}" /></td>
                    <td><c:out value="${row.detailInfo}" /></td>
                    <td><c:out value="${row.widthM}" /></td>
                    <td><c:out value="${row.heightM}" /></td>
                    <td><c:out value="${row.depthCm}" /></td>
                    <td><c:out value="${row.areaM2}" /></td>
                    <td><c:out value="${row.reportDateMmdd}" /></td>
                    <td><c:out value="${row.workDateMmdd}" /></td>
                    <td></td>
                </tr>
            </c:forEach>

            <div class="page-break"></div>

            </tbody>
        </table>

        <c:forEach items="${group.rows}" var="item">
            <table class="photo-table">
                <colgroup>
                    <col style="width: 6%;" />
                    <col style="width: 44%;" />
                    <col style="width: 6%;" />
                    <col style="width: 44%;" />
                </colgroup>

                <tr>
                    <td colspan="2" class="photo-box">
                        <c:if test="${not empty item.beforeImgBase64}">
                            <img src="${item.beforeImgBase64}" alt="작업 전" class="photo-img" />
                        </c:if>
                    </td>
                    <td colspan="2" class="photo-box">
                        <c:if test="${not empty item.afterImgBase64}">
                            <img src="${item.afterImgBase64}" alt="작업 후" class="photo-img" />
                        </c:if>
                    </td>
                </tr>
                <tr>
                    <th>위치</th>
                    <td>
                        <c:out value="${item.reportDateMmdd}" />
                        <c:if test="${not empty item.directionNm}"> <c:out value="${item.directionNm}" /></c:if>
                        <c:if test="${not empty item.locationInfo}"> <c:out value="${item.locationInfo}" /></c:if>
                    </td>
                    <th>위치</th>
                    <td>
                        <c:out value="${item.workDateMmdd}" />
                        <c:if test="${not empty item.directionNm}"> <c:out value="${item.directionNm}" /></c:if>
                        <c:if test="${not empty item.locationInfo}"> <c:out value="${item.locationInfo}" /></c:if>
                    </td>
                </tr>
                <tr>
                    <th>내용</th>
                    <td>포트홀 보수작업 (전)</td>
                    <th>내용</th>
                    <td>포트홀 보수작업 (후)</td>
                </tr>
            </table>
        </c:forEach>
    </div>

    <c:if test="${!gStatus.last}">
        <div class="page-break"></div>
    </c:if>
</c:forEach>

</body>
</html>