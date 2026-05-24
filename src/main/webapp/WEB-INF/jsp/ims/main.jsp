<%@ page contentType="text/html;charset=UTF-8" language="java"  pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<sec:authentication property="principal.userName" var="userName" />
<sec:authentication property="principal.bizDivCd" var="bizDivCd" />
<%@include file="./common/head.jsp" %>
<%@include file="./common/menu.jsp" %>
<%@include file="./common/modal.jsp" %>

<body>
<div class="container">
    <div class="top-zone">
        <div class="logo"><img src="/img/logo-ko.png?v=1.0" class="img-fluid"></div>
        <div class="menu fs-3" data-bs-toggle="offcanvas" data-bs-target="#offcanvasRight" aria-controls="offcanvasRight"><i class="bi bi-list"></i></div>
    </div>
    <div class="info-zone">
        <div>
            <h2><b>${userName}</b>님, <span> 안전하세요.</span></h2>
            <p>
                ${siteInfo.siteName}
                <span> ${me.deptNm} </span>
            </p>
        </div>
        <div class="weather">
            <h2 id="weatherIcon">-</h2>
            <p id="weatherText">확인중...</p>
            <p id="weatherTemp" class="fw-bold">--°</p>
        </div>
    </div>

    <%-- geo-utils.js가 채우는 hidden 값들 --%>
    <input type="hidden" id="lat" name="lat" value="">
    <input type="hidden" id="lng" name="lng" value="">
    <input type="hidden" id="accuracyM" name="accuracyM" value="">
    <input type="hidden" id="capturedTs" name="capturedTs">
    <input type="hidden" id="addr" name="addr" value="">

    <c:choose>

        <%-- APPLY : 도로팀 화면--%>
        <c:when test="${bizDivCd eq 'RECEIPT'}">

        <div class="card">
            <jsp:include page="./porthole/report-form.jsp" />
        </div>
        </c:when>

        <%-- RECEIPT : 교통팀 화면 --%>
        <c:when test="${bizDivCd eq 'APPLY'}">
        <div class="d-flex mb-3" style="justify-content: space-between; align-items: center;">
            <h5 class="fw-bold mb-0">오늘의 작업 현황</h5>
            <div class="fs-6" onclick="location.href='/pothole/list'">전체보기 <i class="bi bi-chevron-right"></i></div>
        </div>
        <div class="row gap-3 m-0 text-center">
            <div class="card col" onclick="location.href='/pothole/list?status=working'" style="cursor:pointer;">
                <div><img src="/img/icon/icon-vest.png" class="img-fluid mb-2" style="max-width: 60px;"></div>
                <h2 class="display-4 fw-bold">
                <c:out value="${todayWorkingCnt}" default="0"/>
                </h2>
                <p class="fs-6 mb-0"><b>진행중</b>인 작업 건수</p>
            </div>

            <div class="card col" onclick="location.href='/pothole/list?status=received'" style="cursor:pointer;">
                <div><img src="/img/icon/icon-file.png" class="img-fluid mb-2" style="max-width: 60px;"></div>
                <h2 class="display-4 fw-bold">
                  <c:out value="${todayReceivedCnt}" default="0"/>
                </h2>
                <p class="fs-6 mb-0"><b>대기중</b>인 작업 건수</p>
            </div>
        </div>

        <h5 class="mt-4 fw-bold">최근 접수 내역</h5>

        <div id="recent-list-container"></div>
        <div class="text-center">
            <button type="button" id="btn-more-recent" class="btn btn-outline-secondary w-100" style="display:none;">
                더보기
            </button>
        </div>
        </c:when>
    </c:choose>

    <%--
    <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#staticBackdrop">
        모달샘플
    </button>
    <div class="modal fade" id="staticBackdrop" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-body">
                    <div id="message">
                        <h2>저장하지 않고<br>작성을 취소하시겠습니까?</h2>
                        <p>저장을 원하시면 '저장 후 페이지 나가기'를 클릭해주세요.</p>
                    </div>
                    <div><img src="/img/icon/icon-modal.png" class="img-fluid mt-2"></div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" data-bs-dismiss="modal">그냥 페이지 나가기</button>
                    <button type="button" class="btn btn-outline-primary">저장 후 페이지 나가기</button>
                </div>
            </div>
        </div>
    </div>
  --%>

</div>
</body>
<script>

let recentOffset = 0;
const recentLimit = 5;

$(document).ready(function() {
   const bizDivCd = "${bizDivCd}";

    // RECEIPT (교통팀) 일때만 접수내역 조회
    if (bizDivCd === "APPLY") {
        loadRecentPotholes(false);

        $('#btn-more-recent').on('click', function() {
            loadRecentPotholes(true);
        });
    }

    // 더보기 클릭
    $('#btn-more-recent').on('click', function() {
        loadRecentPotholes(true);
    });

    // 위치 및 날씨정보 조회
    requestPositionForPothole();
});

// 최근 접수 내역 조회
function loadRecentPotholes(append) {

    $.ajax({
        url: '/pothole/recent',
        type: 'get',
        dataType: 'json',
        data: {
            offset: recentOffset,
            limit: recentLimit
        },
        success: function(res) {

            const list = res && res.list ? res.list : [];
            const hasMore = res && res.hasMore === true;

            renderRecentList(list, append, (res.totalCount || 0));

            // offset 증가
            recentOffset += list.length;

            // 더보기 버튼 제어
            if (hasMore) {
                $('#btn-more-recent').show();
            } else {
                $('#btn-more-recent').hide();
            }
        },
        error: function() {
            $('#recent-list-container').html("<p class='text-danger p-3 text-center'>최근 접수 내역 조회 중 오류가 발생했습니다.</p>");
            $('#btn-more-recent').hide();
        }
    });
}

function renderRecentList(list, append, totalCount) {

    const $box = $('#recent-list-container');

    if (!append) {
        $box.empty();
    }

    // 처음 로드인데 데이터 없음
    if (!append && (!list || list.length === 0)) {
        $box.html("<p class='text-muted p-3 text-center'>최근 접수 내역이 없습니다.</p>");
        return;
    }

    // append일 때는 아무것도 없으면 그냥 종료
    if (append && (!list || list.length === 0)) {
        return;
    }

    // ims-list wrapper가 없으면 만들어둠
    if ($box.find('.ims-list').length === 0) {
        $box.append(
            "<div class='ims-list mt-2'>"
          + "  <div class='total' id='recentTotal'></div>"
          + "</div>"
        );
    }

    $('#recentTotal').text("총 " + formatNumber(totalCount) + "건");


    let html = "";

list.forEach(function(item) {

    const reportNo    = item.reportNo;
    const statusCd    = item.statusCd;
    const addr        = item.addr || '';
    const direction   = item.directionCd || '';
    const workStartAt = item.workStartAt || '';
    const workEndAt   = item.workEndAt || '';
    const reportDate  = item.reportDate || '';
    const applicant   = item.userName || '';
    const staText     = item.staText || '';
    const receiptGbNm = item.receiptGbNm || '';

    let cardId = '';
    let stateText = '';
    let datePrefix = '';
    let dateValue = '';

    if (statusCd === 'RECEIVED') {
        cardId='received'; stateText='접수'; datePrefix='접수일시: ';
        dateValue = reportDate;
    } else if (statusCd === 'WORKING') {
        cardId='working'; stateText='작업중'; datePrefix='작업일시: ';
        dateValue = workStartAt;
    } else if (statusCd === 'DONE' || statusCd === 'COMPLETE') {
        cardId='completed'; stateText='완료'; datePrefix='완료일시: ';
        dateValue = workEndAt;
    } else if (statusCd === 'HOLD') {
        cardId='hold'; stateText='보류'; datePrefix='보류일시: ';
        dateValue = reportDate;
    } else {
        cardId=''; stateText=statusCd; datePrefix='';
        dateValue = '';
    }

    // 방향 매핑
    let dirClass = '';
    let dirText = '';

    if (direction) {
        if (item.directionCdNm) {
            dirText = '(' + escapeHtml(item.directionCdNm) + ')';
        } else {
            dirText = '(' + escapeHtml(direction) + ')';
        }

        const seq = direction.split('_')[1] || '';
        if (seq === '1') dirClass = 'upward';
        if (seq === '2') dirClass = 'downward';
    }

    const detailUrl = "/pothole/detail/" + encodeURIComponent(reportNo);

    html += ""
      + "<div class='list-type card mb-3' id='" + cardId + "' onclick=\"location.href='" + detailUrl + "'\">"
      + "  <div class='detail-photo'>"
      + "    <img src='/img/ex-pothole.jpg' class='img-fluid w-100'>"
      + "  </div>"
      + "  <div class='detail'>"
      + "    <div>"
      + "      <span class='state'>" + stateText + "</span>"
      + "      <span class='applicant-date'>" + reportDate + "</span>"
      + "      <span class='applicant-date photo-type-block ms-2'></span>"
      + "    </div>"
      + "    <p class='mb-0'>"
      + "      <span class='badge type'>" + escapeHtml(receiptGbNm) + "</span>"
      + "      <span><b class='" + dirClass + "'>" + dirText + "</b></span>"
      + "    </p>"
      + "    <p class='mb-0'>" + escapeHtml(addr) + "</p>"
      + "    <div>"
      + "      <span class='applicant fw-bold'> STA " + escapeHtml(staText) + "</span>"
      + "      <span class='applicant fw-bold'>" + escapeHtml(applicant) + "</span>"
      + "    </div>"
      + "  </div>"
      + "</div>";
});

    $box.find('.ims-list').append(html);
}

</script>
</html>
