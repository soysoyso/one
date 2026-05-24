<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@include file="./common/head.jsp"%>

<script src="/js/postcode.v2.js"></script>
<body>
    <%@include file="./common/top.jsp"%>
    <div class="container">
        <div class="title">
            <div>
                <h4><b>사고접수</b></h4>
                <%-- 관리대상 고속도로 목록 --%>
                <select class="form-select ms-3" id="srchSiteCd" style="width:300px">

                    <option value="">전체</option>
                    <c:forEach items="${siteList}" var="site">
                        <option value="${site.siteCd}">${site.siteName}</option>
                    </c:forEach>
                </select>

                <div class="btn-zone">
                    <!-- 사고등록 버튼 -->
                    <button type="button" class="btn bg-danger-subtle ms-1" id="btnIncidentInsert">사고 등록</button>
                    <!-- 전화접수 버튼 -->
                    <button type="button" class="btn bg-danger ms-1" data-bs-toggle="modal" data-bs-target="#phoneApplication">전화 접수</button>
                </div>
            </div>
        </div>

        <!-- 사고접수 현황 -->
        <div class="mt-2">
            <div class="ing-zone">
                <div class="box ims-status-box" data-status="STS001">
                <div class="danger"><p>접수</p><p id="receivedCnt"></p></div>
            </div>
                <div class="box ims-status-box" data-status="STS002">
                <div class="ing"><p>처리 중</p><p id="processingCnt"></p></div>
            </div>
            <div class="box ims-status-box" data-status="STS003">
                <div class="success"><p>완료</p><p id="completedCnt"></p></div>
            </div>
                <div class="box ims-status-box" data-status="STS004">
                <div class="cancel"><p>취소</p><p id="canceledCnt"></p></div>
            </div>
                <div class="box ims-status-box" data-status="">
                <div class="total"><p>전체</p><p id="totalCnt"></p></div>
            </div>
            </div>
        </div>
        <!-- // 사고접수 현황 -->

        <div class="search-zone">
            <div class="row">

                <div class="form-group col-3 mb-3">
                    <label class="form-label">상태</label>
                    <select class="form-select" id="srchStatusCd">
                        <option value="">전체</option>
                        <c:forEach items="${statusList}" var="status">
                            <option value="${status.cdCode}">${status.cdCodeNm}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group col-3 mb-3">
                    <label class="form-label">시작 날짜</label>
                    <input class="form-control" type="date" id="srchStrtDt">
                </div>
                <div class="form-group col-3 mb-3">
                    <label class="form-label">종료 날짜</label>
                    <input class="form-control" type="date" id="srchEndDt">
                </div>
            </div>

            <div class="row align-items-end">
                <div class="form-group col-3 mb-3">
                    <label class="form-label">접수번호</label>
                    <input class="form-control" type="text" id="srchReportNo" onkeyup="enterkey()" >
                </div>
                <div class="form-group col-3 mb-3">
                    <label class="form-label">전화번호</label>
                    <input class="form-control" type="text" id="srchCellPhone" onkeyup="enterkey()" >
                </div>
                <div class="form-group col-5 mb-3 d-flex align-items-end gap-2">
                    <button type="button" class="btn btn-primary" id="btnSearch">검색</button>
                </div>
            </div>
        </div>

        <div class="" style="display: flex !important; justify-content: space-between; align-items: center;">
            <p id="sosCount">사고 접수 목록 (총 <b>0</b>건)</p>
            <button type="button" class="btn bg-success" id="btn-excel">엑셀 다운로드</button>
        </div>

        <!-- 검색 결과 -->
        <div class="data-zone">
            <table class="table">
                <thead>
                    <tr>
                        <th>현장</th>
                        <th>접수 번호</th>
                        <th width="10%">접수 시간</th>
                        <th width="10%">완료 시간</th>
                        <th>위치 정보</th>
                        <th>전화번호</th>
                        <th width="5%">상태</th>
                        <th width="10%">상세보기</th>
                        <th width="10%">보고서</th>
                    </tr>
                </thead>
                <tbody id="sosTableBody">
                    <%-- 목록 --%>
                    <tr id="loadingMsgRow" style="display:none;">
                        <td colspan="9" style="text-align:center; color:gray;">조회 중입니다...</td>
                    </tr>
                </tbody>
            </table>
            <div id="paginationZone" class="text-center mt-3"></div>
        </div>
    </div>

	<div id="loadingOverlay" class="loading-overlay d-none"  style="z-index:999999">
		<div class="spinner"></div>
		<p style="margin-top: 10px !important;">처리 중입니다. 잠시만 기다려주세요.</p>
	</div>
<%@include file="./common/modal.jsp"%>
<%@include file="./common/insertIncidentModal.jsp"%>
<%@include file="./common/showIncidentModal.jsp"%>
<%@include file="./common/reportIncidentModal.jsp"%>
<%@include file="./common/script.jsp"%>
</body>
<script>

const siteCd        = '${siteInfo.siteCd}';         // 현장코드
const siteName      = '${siteInfo.siteName}';       // 현장명
const siteCdList    = '${siteCdList}';              // 관리대상 현장코드 (콤마로 구분)


$(document).ready(function() {

    $('#insSiteCd').val(siteCd);

	doSearch();
    bindStatusSummaryBoxes(); // 상단 현황 박스 클릭 시 상태필터 조회

    // 검색 버튼 클릭
  	$('#btnSearch').on('click', function() {
        doSearch(1);
    });

    // url 전송 버튼 클릭
  	$('#btnSendUrl').on('click', function() {
        doSendUrl();
    });

    // 사고접수 등록 모달 > GPS 좌표 갱신 버튼 클릭
    $('#btnInsGeocode').on('click', function () {
        geocodeInsAddr();
    });

    // 사고접수 상세 모달 > GPS 좌표 갱신 버튼 클릭
    $('#btnPopGeocode').on('click', function () {
        geocodePopAddr();
    });

});

function bindStatusSummaryBoxes() {

    $(document)
        .off('click.incSummary', '.ims-status-box')
        .on('click.incSummary', '.ims-status-box', function () {

            var status = String($(this).data('status') || '');

            // active UI
            $('.ims-status-box').removeClass('active');
            $(this).addClass('active');

            $('#srchStatusCd').val(status);

            doSearch(1);
        });
}


(function(){
    if (!!window.EventSource) {

        const es = new EventSource('/admin/alerts/stream?siteCdList=' + encodeURIComponent(siteCdList));

        es.addEventListener('connected', function(){ console.log('SSE connected'); });

        es.addEventListener('incident-created', function(e){
            const data = JSON.parse(e.data);

            showToast();
            doSearch(1);

            if (data.summary) {
                $('#receivedCnt').text(data.summary.received_cnt ?? 0);
                $('#processingCnt').text(data.summary.processing_cnt ?? 0);
                $('#completedCnt').text(data.summary.completed_cnt ?? 0);
                $('#canceledCnt').text(data.summary.canceled_cnt ?? 0);
                $('#totalCnt').text(data.summary.total_cnt ?? 0);
            }
        });

        es.onerror = function(){ console.warn('SSE error (자동 재연결)'); };
    }

    function showToast(){
        const el = document.getElementById('incident-created-toast');
        if (!el) { console.warn('incident-created-toast element not found'); return; }

        el.style.display = 'block';
        const toast = bootstrap.Toast.getOrCreateInstance(el, { autohide: true, delay: 3000 });
        toast.show();
    }
})();


function setSectionDisabled(sectionBox, disabled) {
    const controls = sectionBox.querySelectorAll('input, select, textarea');
    controls.forEach(el => {
        if (disabled) el.setAttribute('disabled', 'disabled');
        else el.removeAttribute('disabled');
    });
}

let lastYmd = getYmd();

// 30초마다 현황 집계 갱신
setInterval(() => {
    getSummary();
    // 날짜도 바뀌었을 수 있으니 기준만 갱신
    const nowYmd = getYmd();
    if (nowYmd !== lastYmd) lastYmd = nowYmd;
}, 30_000);

// 탭을 다시 볼 때 즉시 갱신
document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') {
        getSummary();
        const nowYmd = getYmd();
        if (nowYmd !== lastYmd) lastYmd = nowYmd;
    }
});

function buildSearchParams(extra) {
    const base = {
        strtDt: $('#srchStrtDt').val() + " 00:00:00",
        endDt: $('#srchEndDt').val() + " 23:59:59",
        siteCd: $('#srchSiteCd').val(),
        statusCd: $('#srchStatusCd').val(),
        reportNo: $('#srchReportNo').val(),
        cellPhone: $('#srchCellPhone').val()
    };

    // 추가 파라미터 합치기 (엑셀용 siteName 등)
    if (extra) {
        for (const k in extra) {
            base[k] = extra[k];
        }
    }

    return base;
}


// incident 테이블 상태별 건수 집계 (일자 기준)
function getSummary() {
	$.ajax({
        url: "/admin/sos/getIncidentStatusSummaryByDate",
        type: "post",
        dataType: 'json',
        contentType:"application/json; charset=utf-8",
        success:function(data){
            // 대시보드 카운트 반영
            if (data) {
                $('#receivedCnt').text(data.received_cnt ?? 0);
                $('#processingCnt').text(data.processing_cnt ?? 0);
                $('#completedCnt').text(data.completed_cnt ?? 0);
                $('#canceledCnt').text(data.canceled_cnt ?? 0);
                $('#totalCnt').text(data.total_cnt ?? 0);
            }
        }
    })
}

//엑셀 버튼 클릭
$('#btn-excel').on('click', function(){
    const params = buildSearchParams();
    location.href = "/admin/sos/excelDownload?" + $.param(params);
});

// 사고접수 목록 조회
function doSearch(page = 1) {

    if (!page) page = 1;

    const params = buildSearchParams();
    params.page = page;

	// 로딩 메시지 표시
	$('#loadingMsgRow').show();

	$.ajax({
		url: "/admin/sos/data"
   		, type: "get"
	  	, dataType: 'json'
 		, data: params
	   	, contentType: 'application/x-www-form-urlencoded; charset=UTF-8'
	   	, success: function(data) {

       		const tbody = document.querySelector("#sosTableBody");
            const summary = data.summary;
       		let rowHtml = '';

	         if (data && data.list && data.list.length > 0) {
	             for (let i = 0; i < data.list.length; i++) {
	                 const sos = data.list[i];
	                 rowHtml += '<tr>';
                     rowHtml += '<td>' + (sos.siteName || '알수없음') + '</td>';
	                 rowHtml += '<td>' + (sos.reportNo || '') + '</td>';
	                 rowHtml += '<td>' + (sos.reportDate || '') + '</td>';
	                 rowHtml += '<td>' + setUpdDt(sos) + '</td>';
	                 rowHtml += '<td>' + (sos.addr || '') + '</td>';
	                 rowHtml += '<td>' + (sos.cellPhone || '') + '</td>';
	                 rowHtml += '<td>' + setStatus(sos) + '</td>';
	                 rowHtml += '<td>' + setDetailBtn(sos) + '</td>';
	                 rowHtml += '<td>' + setReportBtn(sos) + '</td>';
	                 rowHtml += '</tr>';

	             }
	         } else {
	             rowHtml += '<tr><td colspan="9" style="text-align:center;">조회 결과가 없습니다.</td></tr>';
	         }

	         // 기존 목록 덮어쓰기
	         tbody.innerHTML = rowHtml;

             // 집계 표출 (당일꺼만)
            $('#receivedCnt').text(summary.received_cnt ?? 0);
            $('#processingCnt').text(summary.processing_cnt ?? 0);
            $('#completedCnt').text(summary.completed_cnt ?? 0);
            $('#canceledCnt').text(summary.canceled_cnt ?? 0);
            $('#totalCnt').text(summary.total_cnt ?? 0);
            // end.

	         // 총 건수 및 페이징            <p id="sosCount">사고 접수 목록 (총 <b>0</b>건)</p>
	         document.querySelector("#sosCount").innerHTML = '사고 접수 목록 (총 <b>' + data.totalCount.toLocaleString() + '</b>건)';
	         document.querySelector("#paginationZone").innerHTML = renderPagination(data.pageInfo);

	     },
	     error: function () {
	         $('#sosTableBody').html('<tr><td colspan="9" style="text-align:center; color:red;">조회 중 오류가 발생했습니다.</td></tr>');
	     },
	     complete: function () {
	         // 로딩 메시지 감추기 (마지막에 무조건 감춤)
	         $('#loadingMsgRow').hide();
	     }
	});
}

// 상세보기 버튼
function setDetailBtn(sosData){
    var rn = encodeURIComponent(sosData.reportNo || '');
    return '<button class="btn bg-secondary-subtle" onclick="showDetailModal(\'' + rn + '\')">상세보기</button>';
}

// 보고서 버튼 (완료 상태(STS003)만 노출)
function setReportBtn(sosData){
    if (sosData.statusCd !== 'STS003') return '';

    var rn = encodeURIComponent(sosData.reportNo || '');

    // ✅ PDF 다운로드
    var downloadUrl = '/pdf/report/download?reportNo=' + rn;

    // ✅ PDF 미리보기 (새 창)
    // - 컨트롤러에서 Content-Disposition: inline 으로 내려주면 브라우저에서 바로 열림
    var previewUrl = downloadUrl + '&inline=true';

    return ''
        + '<a class="btn text-success" href="' + downloadUrl + '">'
        +   '<i class="bi bi-download"></i> 다운로드'
        + '</a>'
        + '<a class="btn" href="' + previewUrl + '" target="_blank" rel="noopener">'
        +   '<i class="bi bi-search"></i> 미리보기'
        + '</a>';
}



// 완료시간
function setUpdDt(sosData){
    if (sosData.statusCd === 'STS003') return sosData.updateDatetime;
    else return '';
}

// 상태
function setStatus(sosData){
    if (!sosData) return '';
    const cd = sosData.statusCd || sosData.status_cd || '';

    switch (cd) {
        case 'STS001':
            return '<span class="text-danger">접수</span>';
        case 'STS002':
            return '<span class="text-warning">처리중</span>';
        case 'STS003':
            return '<span class="text-success">완료</span>';
        case 'STS004':
            return '<span class="">취소</span>';
        default:
            return '<span>-</span>';
    }
}

document.addEventListener('DOMContentLoaded', function () {
	const today = new Date();

	flatpickr("#srchStrtDt", {
		dateFormat: "Y-m-d"
		, defaultDate: today
		, locale: "ko"
		, maxDate: new Date().fp_incr(365 * 5)
		, minDate: new Date().fp_incr(-365 * 5)
		, allowInput: true
	});

	flatpickr("#srchEndDt", {
		dateFormat: "Y-m-d"
		, defaultDate: today
		, locale: "ko"
		, maxDate: new Date().fp_incr(365 * 5)
		, minDate: new Date().fp_incr(-365 * 5)
		, allowInput: true
	});

	flatpickr("#insReportDt", {
         locale: 'ko'
        , mode: "single"
        , minDate : today
        , dateFormat: "Y-m-d H:i"
        , enableTime: true        // 시간 선택 활성화
        , time_24hr: false         // 24시간 형식 사용
        , confirmIcon: "<i class='fa fa-check'></i>"
        , showMonths : 1
        , defaultDate: today
		, allowInput: true

    });

    // 전화접수 모달 열릴때, 전화번호 입력하는 곳으로 포커스 가게 하기
    $('#phoneApplication').on('shown.bs.modal', function () {
        const $input = $('#sendPhoneNumber');
        setTimeout(() => {
            $input.trigger('focus');
            const v = $input.val();
            const el = $input.get(0);
            if (el && el.setSelectionRange) el.setSelectionRange(v.length, v.length);
        }, 150);
    });
});

// 사고접수 등록
$('#btnIncidentInsert').on('click', function() {
	popInsertInit();
	$('#incident-insert-modal').modal('show');
});

// 사고접수 상세보기
function showDetailModal(reportNo) {

    popInit(); // 모달초기화

 	// 사고접수 상세 조회
	$.ajax({
		url: "/admin/sos/getSosInfo",
		type: "post",
		dataType: 'json',
		data: {"reportNo" : reportNo},
		contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
		success: function(data) {

		    if (!data) return;
            console.log(data);
            const $m = $('#incident-modal');  // 모달 스코프

            const bust = () => '?v=' + Date.now();

            const inc = data.incident || {};
            const timeline = data.timeline || [];

            const reportNo      = inc.reportNo || '';
            const reportDate    = inc.reportDate || '';
            const addr          = inc.addr || '';
            const managerNm     = inc.managerNm || '';
            const lat           = inc.lat || '';
            const lng           = inc.lng || '';
            const updateDt      = inc.updateDatetime || '';
            const ocrReadKm     = inc.ocrReadKm || '';

            $('#popReportNo').val(reportNo);
            $('#hiddenReportNo').val(reportNo);
            $('#popSiteName').val(inc.siteName || '알수없음');
            $('#popSite').val(inc.siteCd);
            $('#popStatus').val(inc.statusCd || '');
            $('#popIntakeMethodCd').val(inc.intakeMethodCd || '');
            $('#popAddr').val(addr);
            $('#popLat').val(lat);
            $('#popLng').val(lng);
            $('#popTel').val(inc.cellPhone || '');
            $('#popReportDt').val(reportDate);
            $('#popContent').val(inc.processNote || '');

            if (managerNm)  $('#popManager').val(managerNm);


            // 기점지점
            $('#popOcrReadKm').val(ocrReadKm);

            // 최종수정시간
            if (updateDt) {
                $('.popUpdDt').css('display','');
                $('#popUpdDt').text(updateDt);
            }

            // 접수사진 존재여부
            const hasRpt = !!(inc.rptImgPath && inc.rptImgName);
            if (hasRpt) {
                const rptSrc = '/sos/img/rpt/' + encodeURIComponent(reportNo) + bust();
                $('#popRptImgUrl').attr('src', rptSrc).removeClass('d-none');
                $('#noPhoto').addClass('d-none');
            } else {
                $('#popRptImgUrl').addClass('d-none').attr('src', '');
                $('#noPhoto').removeClass('d-none');
            }

            // === 현장사진(1장) ===
            // 서버 응답의 inc.imgPath / inc.imgName 존재 여부로 판단
            const hasField = !!(inc.imgPath && inc.imgName);

            // 프록시 엔드포인트를 src로 사용 (캐시 방지 쿼리 파라미터는 선택)
            const imgUrl = hasField
                ? '/sos/img/field/' + encodeURIComponent(reportNo) + '?v=' + Date.now()
                : '';

            if (imgUrl) {
                $('.popImgUrl').show();
                $('#popImgUrl')
                    .attr('src', imgUrl)
                    .removeClass('d-none')
                    .off('error')
                    .on('error', function () {
                        // 만약 404/권한 등으로 로딩 실패하면 깔끔히 숨김
                        $('.popImgUrl').hide();
                        $(this).addClass('d-none').attr('src', '');
                        const tc = document.getElementById('thumbnailContainer');
                        if (tc) tc.innerHTML = '';
                    });

                var col = document.createElement('div');
                col.className = 'col-auto';

                col.innerHTML =
                    '<div class="thumb-item">'
                    +   '<img src="' + imgUrl + '" alt="현장사진">'
                    +   '<button type="button" class="thumb-remove" aria-label="삭제">&times;</button>'
                    + '</div>';

                // 삭제
                col.querySelector('.thumb-remove').addEventListener('click', function () {
                    removePhoto('show');
                    $('.popImgUrl').hide();
                    $('#popImgUrl').addClass('d-none').attr('src', '');
                    thumbnailContainer.innerHTML = '';
                });

                thumbnailContainer.appendChild(col);

            } else {
                // 현장사진 없음 처리
                $('.popImgUrl').hide();
                $('#popImgUrl').addClass('d-none').attr('src', '');
                const thumbnailContainer = document.getElementById('thumbnailContainer');
                if (thumbnailContainer) thumbnailContainer.innerHTML = '';
            }

            var divCnt = "";
            if (!Array.isArray(timeline) || timeline.length === 0) {
                $('#popTimeline').html("<p>이력없음</p>");
            } else {
                for (let i = 0; i < timeline.length; i++) {
                    if (timeline[i].userNm == null) {
                        divCnt += '<p>' + (timeline[i].eventDt || '') + ' | ' + (timeline[i].statusNm || '') + '</p>';
                    } else {
                        divCnt += '<p>' + (timeline[i].eventDt || '') + ' | ' + (timeline[i].statusNm || '') + ' | ' + timeline[i].userNm + '</p>';
                    }
                }
                $('#popTimeline').html(divCnt);
            }

            //if(lat && lng) {
                // ── 정확도/신선도 평가 ──
                const accuracyM = (inc.accuracyM != null) ? Number(inc.accuracyM) : null;
                // coordAgeMs가 없으면 capturedTs로 계산 (서버/클라 무엇이 오든 대응)
                let coordAgeMs = (inc.coordAgeMs != null) ? Number(inc.coordAgeMs) : null;
                if (coordAgeMs == null && inc.capturedTs != null) {
                    coordAgeMs = Math.max(0, Date.now() - Number(inc.capturedTs));
                }

                let level = 'good'; // good | warn | bad
                if ((accuracyM != null && accuracyM > ACC_WARN) || (coordAgeMs != null && coordAgeMs > FRESH_WARN)) {
                    level = 'bad';
                } else if ((accuracyM != null && accuracyM > ACC_OK) || (coordAgeMs != null && coordAgeMs > FRESH_OK)) {
                    level = 'warn';
                }

                renderLocReliability(level, accuracyM, coordAgeMs); // 신뢰도 메세지 세팅
                setMapLinks(lat, lng, addr, 'update');  // 좌표 및 지도버튼 세팅
            //} else {
                // 위도, 경도 값이 없으므로, 지도 버튼 숨기고, 위치 수정 가능하게 처리
               // $('.mapLink').hide();
               // $('#popAddr').prop('readOnly', false);
            //}

            $('#incident-modal').modal('show');
		},
		error: function(data) {
			//alert(data);
		}
	});
}

// 사고접수 상세보기 (보고서용)
function previewReport(reportNo) {

    popInit(); // 모달초기화

 	// 사고접수 상세 조회
	$.ajax({
		url: "/admin/sos/getSosInfo",
		type: "post",
		dataType: 'json',
		data: {"reportNo" : reportNo},
		contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
		success: function(data) {

		    if (!data) return;
            console.log(data);
            const $m = $('#incident-report-modal');  // 모달 스코프

            const bust = () => '?v=' + Date.now();

            const inc = data.incident || {};
            const timeline = data.timeline || [];

            const reportNo      = inc.reportNo || '';
            const reportDate    = inc.reportDate || '';
            const addr          = inc.addr || '';

            const managerNm     = inc.managerNm || '';
            const lat           = inc.lat || '';
            const lng           = inc.lng || '';
            const updateDt      = inc.updateDatetime || '';

            $('#rptReportNo').text(reportNo);
            $('#rptManager').text(managerNm);
            $('#rptReportDt').text(reportDate);
            $('#rptStatusNm').text(inc.statusNm || '');
            $('#rptIntakeMethodNm').text(inc.intakeMethodNm || '');
            $('#rptTel').text(inc.cellPhone || '');
            $('#rptUpdDt').text(updateDt);
            $('#rptSiteName').text(inc.siteName || '');
            $('#rptAddr').text(addr);
            if(lat && lng) {
                $('#rptGps').text(lat + ", " + lng);
            } else {
                $('#rptGps').text("정보없음");
            }

            $('#rptContent').text(inc.processNote || '');

            // 접수사진 존재여부
            const hasRpt = !!(inc.imgPath && inc.imgName);

            if (hasRpt) {

                const rptSrc = '/sos/img/field/' + encodeURIComponent(reportNo) + bust();
                $('#rptImgUrl').attr('src', rptSrc).removeClass('d-none');
            } else {

                $('#rptImgUrl').addClass('d-none').attr('src', '');
            }

            $('#incident-report-modal').modal('show');
		},
		error: function(data) {
			//alert(data);
		}
	});
}

// 사고접수 등록 > 저장 버튼 클릭
$('#btnSave').on('click', function () {

    if ($('#insertSiteCd').val() == "") {
        showToastMsg('고속도로를 선택해주세요.');
        return;
    }

    openConfirm('사고 접수를 등록하시겠습니까?', saveIncidentInsert);
});

// 사고접수 상세 > 저장 버튼 클릭
$('#btnEdit').on('click', function () {

    if ($('#popSite').val() == "") {
        showToastMsg('고속도로를 선택해주세요.');
        return;
    }

    openConfirm('사고 접수를 수정하시겠습니까?', saveIncidentUpdate);
});

// 공용 확인 모달 오픈 (메시지 + 확인 콜백 주입)
function openConfirm(message, onConfirm) {
    const $m   = $('#insertSosModal');
    const $btn = $m.find('#insertSosConfirmBtn');

    $m.find('#insertSosMessage').text(message);

    // 이전 핸들러 제거 후 1회성 바인딩(중복 전송 방지)
    $btn.off('click').one('click', async function () {
        try {
            $btn.prop('disabled', true);
            $('#loadingOverlay').removeClass('d-none');
            await onConfirm();                 // ✅ 실제 AJAX 실행
            $m.modal('hide');
        } catch (e) {
            // onConfirm 내부에서 alert 처리했다면 여기선 무시 가능
            console.error(e);
        } finally {
            $btn.prop('disabled', false);
            $('#loadingOverlay').addClass('d-none');
        }
    });

    $m.modal('show');
}

// 공용 AJAX 헬퍼
function postForm(url, formEl) {
    const fd = new FormData(formEl);
    return $.ajax({
        url: url,
        type: 'post',
        data: fd,
        processData: false,
        contentType: false,
        dataType: 'json'
    });
}

function setMapLinks(lat, lng, label, gubun) {

    var L = Number(lat), G = Number(lng);
    if (!isFinite(L) || !isFinite(G)) {
    $('#coordRow').hide();
    return;
    }

    var lat6 = L.toFixed(6);
    var lng6 = G.toFixed(6);
    var name = encodeURIComponent(label || '사고 위치');
    var q    = encodeURIComponent(lat6 + ',' + lng6);

    var kakaoWeb  = 'https://map.kakao.com/link/map/' + name + ',' + lat6 + ',' + lng6;
    var naverWeb  = 'https://map.naver.com/v5/search/' + q; // 단일 URL(PC/모바일 공용)
    var googleWeb = 'https://www.google.com/maps?q=' + lat6 + ',' + lng6 + '(' + name + ')';
    var googleDir = 'https://www.google.com/maps/dir/?api=1&destination=' + lat6 + ',' + lng6;

    if (gubun == 'insert') {
        $('#ins-coordText').val(lat6 + ', ' + lng6);
        $('#ins-linkKakao').attr('href', kakaoWeb);
        $('#ins-linkNaver').attr('href', naverWeb);
        $('#ins-linkGoogle').attr('href', googleWeb);

        $('#ins-copyAddr').off('click').on('click', function () {
            var addr = $('#popAddr').val() || '';
            if (!addr) { alert('복사할 주소가 없습니다.'); return; }
            navigator.clipboard.writeText(addr)
                .then(function(){ alert('주소를 복사했어요.'); })
                .catch(function(){ alert('복사 실패: 브라우저 권한을 확인해주세요.'); });
        });

        $('#coordRow').show();
    } else {
        $('#coordText').val(lat6 + ', ' + lng6);
        $('#linkKakao').attr('href', kakaoWeb);
        $('#linkNaver').attr('href', naverWeb);
        $('#linkGoogle').attr('href', googleWeb);

        $('#copyAddr').off('click').on('click', function () {
            var addr = $('#popAddr').val() || '';
            if (!addr) { alert('복사할 주소가 없습니다.'); return; }
            navigator.clipboard.writeText(addr)
                .then(function(){ alert('주소를 복사했어요.'); })
                .catch(function(){ alert('복사 실패: 브라우저 권한을 확인해주세요.'); });
        });

        $('#coordRow').show();
    }


}

// URL 전송
function doSendUrl() {
    const regTel = /^01[016789]\d{7,8}$/; // 10~11자리
    const phoneInput = $("#sendPhoneNumber");
    const raw = phoneInput.val().replace(/\D/g,''); // 하이픈 제거한 순수 숫자

    if (!raw) {
        showToastMsg('휴대폰 번호를 입력해주세요.');
        return;
    }
    if (!regTel.test(raw)) {
        showToastMsg('올바른 휴대폰 번호를 입력해주세요.');
        return;
    }

    // 표시용(하이픈 포함)은 그대로
    $('#sendUrlPhone').text(phoneInput.val());

    const $m = $('#sendUrlModal');
    $m.data('phoneRaw', raw);

    // ✅ 확인 버튼: 중복 바인딩 방지 + 1회성 실행
    const $btn = $m.find('#sendUrlConfirmBtn');
    $btn.off('click').one('click', async function () {
        const phone = $m.data('phoneRaw'); // 저장해둔 숫자만
        try {
            $btn.prop('disabled', true);
            await sendUrl(phone);            // ← 여기서 실제 전송 호출

            showToastMsg('URL을 전송했습니다.');
            $m.modal('hide');
        } catch (e) {
            console.error(e);
            alert('전송 중 오류가 발생했습니다.');
        } finally {
            $btn.prop('disabled', false);
            $m.removeData('phoneRaw');
        }
    });

    // 모달 표시
    $m.modal('show');
}

// 실제 URL 전송 함수
function sendUrl(sendPhoneNumber) {

    return $.ajax({
        url: '/admin/sos/send-url',
        type: 'post',
        data: JSON.stringify({
            cellPhone: sendPhoneNumber
            , siteCd : siteCd
            , siteName : siteName
        }),
        contentType: 'application/json',
        dataType: 'json'
    }).then(function (res) {
        if (!res || res.code !== '0000') {
            throw new Error(res && res.message || 'send-url failed');
        }
    }).then(function (res) {
        console.log('[send-url] success:', res);
    });
}

// 자동 하이픈
(function bindPhoneMask(selectors) {
    // 기본 대상: #sendPhoneNumber, #insTel
    selectors = selectors || ['#sendPhoneNumber', '#insTel'];
    const els = document.querySelectorAll(selectors.join(','));
    els.forEach(el => {
        if (!el) return;
        // UX 힌트
        el.type = 'tel';
        el.inputMode = 'numeric';
        el.maxLength = 13; // 010-1234-5678 길이 고려

        el.addEventListener('input', function (e) {
            const digits = e.target.value.replace(/\D/g, '').slice(0, 11); // 최대 11자리
            e.target.value = formatPhone(digits);
        });
    });

function formatPhone(d){
    // 유선(02)
    if (d.startsWith('02')) {
    if (d.length <= 2) return d;
    if (d.length <= 5) return d.slice(0,2) + '-' + d.slice(2);
    if (d.length <= 9) return d.slice(0,2) + '-' + d.slice(2,5) + '-' + d.slice(5);
    return d.slice(0,2) + '-' + d.slice(2,6) + '-' + d.slice(6,10);
    }
    // 모바일(010/011/016/017/018/019)
    if (d.length < 4) return d;                                   // 0~3
    if (d.length < 8) return d.slice(0,3) + '-' + d.slice(3);     // 4~7  → 두 번째 하이픈 없음
    if (d.length === 10)                                          // 10   → 3-3-4 패턴
    return d.slice(0,3) + '-' + d.slice(3,6) + '-' + d.slice(6);
    // 8~9, 11 → 3-4-나머지
    return d.slice(0,3) + '-' + d.slice(3,7) + '-' + d.slice(7);
    }

})();

// 모달 사진 삭제
function removePhoto(mode) {
    if (mode === 'insert') {
        photo2 = null;
        formFile2.value = '';                 // 폼 제출 시 파일 제거
        thumbnailContainer2.innerHTML = '';   // 미리보기 제거
    } else if (mode === 'show') {
        photo = null;
        formFile.value = '';                 // 폼 제출 시 파일 제거
        thumbnailContainer.innerHTML = '';   // 미리보기 제거
        $('#imageChanged').val('Y');
    }
}

$('#srchSiteCd').on('change', function () {

    doSearch(1);
});


</script>

<style>
    .form-control[readonly] { background-color: #fff; opacity: 1; }

    /* 라벨 간격 */
    .box .form-label { margin-bottom: 6px; }

    /* GPS 영역 정돈 */
    .coord-row {
        display: flex;
        gap: 10px;
        align-items: center;
        flex-wrap: wrap;
    }
    .coord-input { max-width: 320px; width: 100%; }

    /* input/select 통일 */
    .box .form-control,
    .box .form-select,
    .box .input-group-text { border-radius: 10px; }

    /* 사진 카드 느낌 */
    .photo-card {
        background: #f9fafb;
        border: 1px solid #eee;
        border-radius: 14px;
        padding: 12px;
        text-align: center;
        min-height: 220px;
        display: flex;
        align-items: center;
        justify-content: center;
        position: relative;
    }
    .photo-card img { max-height: 220px; width: auto; }

    /* ✅ 썸네일 카드 */
    .thumb-item {
        position: relative;
        width: 500px;
        height: 500px;
        margin: 8px;
        border: 1px solid #ddd;
        border-radius: 8px;
        overflow: hidden;
        background: #f8f9fa;
    }
    .thumb-item img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        display: block;
    }
    .thumb-remove {
        position: absolute;
        top: 4px;
        right: 4px;
        width: 22px;
        height: 22px;
        border-radius: 50%;
        background: rgba(0,0,0,0.6);
        color: #fff;
        border: none;
        font-size: 14px;
        line-height: 20px;
        text-align: center;
        cursor: pointer;
    }
    #popImgUrl {
        display: block;
        max-width: 100%;
        height: 220px;        /* 원하는 높이로 고정 */
        object-fit: contain;  /* 전체 보이게 (cover 원하면 cover) */
        border-radius: 12px;
        background: #f5f5f5;
    }

    /* ===============================
   등록 모달 썸네일: 500x500 고정 + col 확장 방지
   =============================== */

    /* 등록 모달 안의 썸네일 컨테이너는 row라도 괜찮게 고정 */
    #incident-insert-modal #thumbnailContainer2 {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
    }

    /* Bootstrap .col이 늘어나는 걸 막기 위한 래퍼(이걸 JS에서 붙일거야) */
    #incident-insert-modal .thumb-col {
        flex: 0 0 auto;     /* ✅ 절대 늘어나지 않게 */
        width: 500px;       /* ✅ 원하는 사이즈 */
        height: 500px;
        max-width: 100%;
    }

    /* JS에서 쓰는 .thumbnail-wrapper 자체를 500x500으로 강제 */
    #incident-insert-modal .thumbnail-wrapper {
        position: relative;
        width: 500px;       /* ✅ 여기서 딱 고정 */
        height: 500px;
        border: 1px solid #ddd;
        border-radius: 10px;
        overflow: hidden;
        background: #f8f9fa;
    }

    /* 이미지가 wrapper를 벗어나 커지는걸 방지 */
    #incident-insert-modal .thumbnail-wrapper img {
        width: 100%;
        height: 100%;
        object-fit: cover;  /* cover: 꽉 채우기 / contain: 다 보이게 */
        display: block;
    }

    /* 삭제 버튼 */
    #incident-insert-modal .thumbnail-remove2 {
        position: absolute;
        top: 8px;
        right: 8px;
        width: 28px;
        height: 28px;
        border-radius: 50%;
        background: rgba(0,0,0,0.65);
        color: #fff;
        border: none;
        font-size: 16px;
        line-height: 28px;
        text-align: center;
        cursor: pointer;
    }

    .ims-status-box { cursor: pointer; }
    .ims-status-box.active > div {
        outline: 2px solid #0d6efd;
        outline-offset: 2px;
        border-radius: 10px;
    }

</style>

</html>
