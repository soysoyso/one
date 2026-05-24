<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="cbOff" value="/img/cb_off.png" />
<c:set var="cbOn" value="/img/cb_on.png" />

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <link rel="stylesheet" href="/css/report-pdf.css" />
</head>

<body>
<div class="page">
    <div class="title">
        <c:out value="${data.reportYear}" />년 도로파손(포트홀) 관리대장
    </div>

    <div class="header-wrap">
        <table class="no-box">
            <tr>
                <th class="tc">NO</th>
                <td class="tc"><c:out value="${data.docNo}" /></td>
            </tr>
        </table>

        <table class="appr-box">
            <tr>
                <th class="tc">담 당</th>
                <th class="tc">팀 장</th>
                <th class="tc">소 장</th>
            </tr>
            <tr>
                <td class="sign-cell"></td>
                <td class="sign-cell"></td>
                <td class="sign-cell"></td>
            </tr>
        </table>
    </div>

    <table class="info">
        <colgroup>
            <col class="c1" />
            <col class="c2" />
            <col class="c3" />
            <col class="c4" />
            <col class="c5" />
            <col class="c6" />
            <col class="c7" />
            <col class="c8" />
        </colgroup>

        <tr>
            <th class="tc" rowspan="2">발생위치</th>
            <th class="tc">행정구역</th>
            <td class="val" colspan="2"><c:out value="${data.region}" /></td>
            <th class="tc">포장 형식</th>
            <th class="tc" colspan="3">발생 장소</th>
        </tr>

        <tr>
            <th class="tc">도로이정</th>
            <td class="val" colspan="2"><c:out value="${data.roadInfo}" /></td>

            <td class="chkline tc nowrap">
                <span class="chkopt">
                    아스팔트
                    <img class="cbimg" src="${data.isAsp ? cbOn : cbOff}" />
                </span>
                <span class="chkopt">
                    콘크리트
                    <img class="cbimg" src="${data.isCon ? cbOn : cbOff}" />
                </span>
            </td>

            <td class="chkline tc nowrap" colspan="3">
                <span class="chkopt">
                    도로부
                    <img class="cbimg" src="${data.isRoad ? cbOn : cbOff}" />
                </span>
                <span class="chkopt">
                    교량부
                    <img class="cbimg" src="${data.isBridge ? cbOn : cbOff}" />
                </span>
                <span class="chkopt">
                    터널부
                    <img class="cbimg" src="${data.isTunnel ? cbOn : cbOff}" />
                </span>
            </td>
        </tr>

        <tr>
            <th class="tc" rowspan="2">발생현황</th>
            <th class="tc">발생일자</th>
            <td class="val tc"><c:out value="${data.reportDate}" /></td>
            <th class="tc">발생(접보)시간</th>
            <td class="val tc"><c:out value="${data.reportTime}" /></td>
            <th class="tc">기상(날씨)</th>
            <td class="val tc" colspan="2"><c:out value="${data.weatherNm}" /></td>
        </tr>

        <tr>
            <th class="tc">발생수량</th>
            <td class="scopeText tc" colspan="6">
                <span class="k">가로</span> <c:out value="${data.widthM}" />m
                <span class="sep">|</span>
                <span class="k">세로</span> <c:out value="${data.heightM}" />m
                <span class="sep">|</span>
                <span class="k">면적</span> <c:out value="${data.areaM2}" />㎡
                <span class="sep">|</span>
                <span class="k">깊이</span> <c:out value="${data.depthCm}" />cm
            </td>
        </tr>

        <tr>
            <th class="tc" rowspan="2">조치현황</th>
            <th class="tc">조치일자</th>
            <td class="val tc"><c:out value="${data.workDate}" /></td>
            <th class="tc">조치(완료)시간</th>
            <td class="val tc"><c:out value="${data.workTime}" /></td>
            <th class="tc">기상(날씨)</th>
            <td class="val tc" colspan="2"><c:out value="${data.workWeatherNm}" /></td>
        </tr>

        <tr>
            <th class="tc">투입인원</th>
            <td class="val tc"><c:out value="${data.workers}" /></td>
            <th class="tc">투입장비</th>
            <td class="val" colspan="2"><c:out value="${data.equip}" /></td>
            <th class="tc">투입자재</th>
            <td class="val"><c:out value="${data.material}" /></td>
        </tr>
    </table>

    <table class="photo">
        <tr>
            <th class="tc">조치 전</th>
            <th class="tc">조치 후</th>
        </tr>
        <tr>
            <td class="ph-cell">
                <div class="ph-box">
                    <c:choose>
                        <c:when test="${not empty data.beforeImgBase64}">
                            <img src="${data.beforeImgBase64}" alt="before" />
                        </c:when>
                        <c:otherwise>
                            <div style="height:95mm;">&#160;</div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </td>

            <td class="ph-cell">
                <div class="ph-box">
                    <c:choose>
                        <c:when test="${not empty data.afterImgBase64}">
                            <img src="${data.afterImgBase64}" alt="after" />
                        </c:when>
                        <c:otherwise>
                            <div style="height:95mm;">&#160;</div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </td>
        </tr>
    </table>

    <div class="footer">주관부서 : 도로관리팀</div>
</div>
</body>
</html>
