<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@include file="../common/head.jsp"%>

<script src="/js/postcode.v2.js"></script>

<body>
<%@include file="../common/top.jsp"%>

<div class="container">
    <div class="title">
        <div>
            <h4><b>현장관리</b></h4>
        </div>
    </div>

    <!-- 접수 현황 -->
    <div class="mt-2">
        <div class="ing-zone">

            <div class="box ims-status-box" data-status="RECEIVED">
                <div class="danger"><p>접수</p><p id="receivedCnt"></p></div>
            </div>

            <div class="box ims-status-box" data-status="WORKING">
                <div class="ing"><p>작업중</p><p id="workingCnt"></p></div>
            </div>

            <div class="box ims-status-box" data-status="DONE">
                <div class="success"><p>완료</p><p id="doneCnt"></p></div>
            </div>

            <div class="box ims-status-box" data-status="HOLD">
                <div class="cancel"><p>보류</p><p id="holdCnt"></p></div>
            </div>

            <div class="box ims-status-box" data-status="">
                <div class="total"><p>전체</p><p id="totalCnt"></p></div>
            </div>

        </div>
    </div>
    <!-- // 접수 현황 -->


    <!-- 검색영역 -->
    <div class="search-zone">
        <div class="row g-2 align-items-end">

            <div class="col-12 col-md-3 col-lg-2">
                <div class="d-flex flex-column">
                    <label class="form-label mb-1">현장</label>
                    <select class="form-select w-100" id="srchSiteCd">
                        <option value="">전체</option>
                        <c:forEach items="${siteList}" var="site">
                            <option value="${site.siteCd}">${site.siteName}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="col-12 col-md-3 col-lg-2">
                <div class="d-flex flex-column">
                    <label class="form-label mb-1">상태</label>
                    <select class="form-select w-100" id="srchStatusCd">
                        <option value="">전체</option>
                        <c:forEach items="${workStatusList}" var="workStatus">
                            <option value="${workStatus.cdCode}">${workStatus.cdCodeNm}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="col-12 col-md-3 col-lg-2">
                <div class="d-flex flex-column">
                    <label class="form-label mb-1">접수유형</label>
                    <select class="form-select w-100" id="srchWorkTypeCd">
                        <option value="">전체</option>
                        <c:forEach items="${workTypeList}" var="workType">
                            <option value="${workType.cdCode}">${workType.cdCodeNm}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="col-12 col-md-3 col-lg-2">
                <div class="d-flex flex-column">
                    <label class="form-label mb-1">접수일자(시작)</label>
                    <input class="form-control w-100" type="date" id="srchStrtDt">
                </div>
            </div>

            <div class="col-12 col-md-3 col-lg-2">
                <div class="d-flex flex-column">
                    <label class="form-label mb-1">접수일자(종료)</label>
                    <input class="form-control w-100" type="date" id="srchEndDt">
                </div>
            </div>

            <div class="col-12 col-lg-1">
                <button type="button" class="btn btn-primary w-100" id="btnSearch">검색</button>
            </div>

        </div>
    </div>

    <div style="display:flex !important; justify-content:space-between; align-items:center;">
        <div class="d-flex align-items-center gap-3">
            <p id="sosCount" class="mb-0">접수 내역 (총 <b>0</b>건)</p>

            <button type="button" id="btnViewAll" class="btn btn-outline-secondary btn-sm">
                전체보기
            </button>

            <button type="button" id="btnViewPaging" class="btn btn-outline-secondary btn-sm d-none">
                20개씩 보기
            </button>

            <div class="btn-group btn-group-sm" role="group">
                <input type="radio" class="btn-check" name="viewMode" id="btnViewList" autocomplete="off" checked>
                <label class="btn btn-outline-secondary" for="btnViewList">리스트 보기</label>

                <input type="radio" class="btn-check" name="viewMode" id="btnViewGallery" autocomplete="off">
                <label class="btn btn-outline-secondary" for="btnViewGallery">갤러리 보기</label>
            </div>
        </div>

        <div class="d-flex gap-2 align-items-center">
            <select class="form-select" id="ledgerExportTemplate" style="width: 190px;">
                <option value="POTHOLE_LEDGER">포트홀 관리대장</option>
                <option value="POTHOLE_SUMMARY">포트홀 집계표</option>
                <option value="MAINTENANCE_LOG">유지보수 일지</option>
                <option value="LANDSCAPE_DAILY_WORK">조경 작업일보</option>
                <option value="MAINTENANCE_RESULT">유지관리 결과보고서</option>
                <option value="PHOTO_BOARD">사진대지</option>
            </select>

            <select class="form-select" id="ledgerExportFormat" style="width: 110px;">
                <option value="pdf">PDF</option>
                <option value="docx">DOCX</option>
                <option value="hwpx">HWPX</option>
            </select>

            <button type="button" class="btn btn-outline-success" id="btnLedgerDownload">
                <i class="bi bi-download"></i> 보고서 다운로드
            </button>

            <button type="button" class="btn btn-outline-primary" id="btnPhotoDownload">
                <i class="bi bi-image"></i> 이미지 다운로드
            </button>

            <button type="button" class="btn btn-primary" id="btnImsAdd">
                <i class="bi bi-plus"></i> 접수 등록
            </button>
        </div>
    </div>
    <!-- 검색 결과 -->
    <div class="data-zone">
        <div id="galleryZone" class="row g-3 mt-2" style="display:none;"></div>
        <table class="table">
            <thead>
            <tr>
                <th><input class="form-check-input" type="checkbox" id="checkDefault"></th>
                <th>현장명</th>
                <th>접수유형</th>
                <th>접수코드</th>
                <th>상태</th>
                <%--<th>작업내용</th>--%>
                <th>방향</th>
                <th>위치정보</th>
                <th>접수일시</th>
                <th>작업시작일시</th>
                <th>작업종료일시</th>
                <th>미리보기</th>
            </tr>
            </thead>
            <tbody id="imsTableBody">
            <tr id="loadingMsgRow" style="display:none;">
                <td colspan="11" style="text-align:center; color:gray;">조회 중입니다...</td>
            </tr>
            </tbody>
        </table>
        <div id="paginationZone" class="text-center mt-3"></div>
    </div>
</div>

<div id="loadingOverlay" class="loading-overlay d-none">
    <div class="loading-box">

        <div class="loading-spinner"></div>

        <p id="loadingOverlayText">
            이미지 다운로드 중입니다.<br>
            잠시만 기다려주세요.
        </p>

    </div>
</div>
<%@include file="../common/modal.jsp"%>
<%@include file="../common/imsManageModal.jsp"%>
<%@include file="../common/script.jsp"%>

<script>
    const roadDirMap = {};
    const roadDirBySiteMap = {};

    <c:forEach items="${roadDirList}" var="dir">
    roadDirMap["${dir.cdCode}"] = "${dir.cdCodeNm}";

    if (!roadDirBySiteMap["${dir.cdValue1}"]) {
        roadDirBySiteMap["${dir.cdValue1}"] = [];
    }

    roadDirBySiteMap["${dir.cdValue1}"].push({
        cdCode: "${dir.cdCode}",
        cdCodeNm: "${dir.cdCodeNm}"
    });
    </c:forEach>

    const siteCd     = '${siteInfo.siteCd}';
    const siteName   = '${siteInfo.siteName}';
    const siteCdList = '${siteCdList}';

    var workStartPicker = null;
    var workEndPicker   = null;
    var insReportDtPicker = null;
    var viewAllMode = false;

    $(document).ready(function() {

        $('#insSiteCd').val(siteCd);

        doSearch(1);

        $('#btnSearch').on('click', function() { doSearch(1); });
        $('#btnInsGeocode').on('click', function () { geocodeInsAddr(); });

        $('#btnImsAdd').on('click', function() {
            popInsertInit();
            setImsMode('INSERT');

            // ✅ 문서번호 자동 세팅(관리자: A)
            fetchNextAdminDocNo(function(docNo){
                $('#insDocNo').val(docNo || '');
                $('#ims-add-modal').modal('show');
            });
        });

        bindWorkInfoRows();       // 작업정보 행 이벤트
        bindCheckAllRows();       // 전체선택 체크 동기화
        bindStatusSummaryBoxes(); // 상단 상태 필터 클릭 조회


        $('#btnViewAll').on('click', function () {
            viewAllMode = true;
            $('#btnViewAll').addClass('d-none');
            $('#btnViewPaging').removeClass('d-none');
            $('#checkDefault').prop('checked', false);
            doSearch(1);
        });

        $('#btnViewPaging').on('click', function () {
            viewAllMode = false;
            $('#btnViewPaging').addClass('d-none');
            $('#btnViewAll').removeClass('d-none');
            $('#checkDefault').prop('checked', false);
            doSearch(1);
        });
        $(document)
            .off('change.imsSite', '#insSiteCd')
            .on('change.imsSite', '#insSiteCd', function () {
                renderDirectionOptions($(this).val() || '', '');
            });

        $('#btnViewList').on('change', function () {
            // 리스트보기
            if (!this.checked) return;

            $('#imsTableBody').closest('table').show();
            $('#paginationZone').show();
            $('#galleryZone').hide();
        });

        $('#btnViewGallery').on('change', function () {
            // 갤러리보기
            if (!this.checked) return;

            $('#imsTableBody').closest('table').hide();
            $('#paginationZone').show();
            $('#galleryZone').show();

            renderGallery(window.lastSearchList || []);
        });
    });

    // 상단 상태 필터 클릭 조회
    function bindStatusSummaryBoxes() {

        // 박스 클릭 → 상태 필터 적용 후 조회
        $(document)
            .off('click.imsSummary', '.ims-status-box')
            .on('click.imsSummary', '.ims-status-box', function () {

                var status = String($(this).data('status') || '');

                // ✅ 박스 active UI
                $('.ims-status-box').removeClass('active');
                $(this).addClass('active');

                // ✅ 상태 select에 반영 (전체는 빈값)
                $('#srchStatusCd').val(status);
                $('#checkDefault').prop('checked', false);

                // ✅ 검색 실행
                doSearch(1);
            });
    }


    function fetchNextAdminDocNo(cb) {
        $.ajax({
            url: '/admin/ims/docno/next',
            type: 'get',
            dataType: 'json',
            success: function(res){
                if (res && res.code === '0000') {
                    if (cb) cb(res.docNo || '');
                    return;
                }
                alert((res && res.message) || '문서번호 채번 실패');
                if (cb) cb('');
            },
            error: function(){
                showSwal('error', '오류 발생', '문서번호 채번 중 오류가 발생했습니다.');
                if (cb) cb('');
            }
        });
    }

    // 검색 파라미터
    function buildSearchParams(extra) {
        var s = $('#srchStrtDt').val() || '';
        var e = $('#srchEndDt').val()  || '';

        var base = {
            strtDt: s ? (s + ' 00:00:00') : '',
            endDt:  e ? (e + ' 23:59:59') : '',
            siteCd: $('#srchSiteCd').val() || '',
            statusCd: $('#srchStatusCd').val() || '' ,
            workTypeCd: $('#srchWorkTypeCd').val() || ''
        };

        if (extra) {
            for (var k in extra) base[k] = extra[k];
        }
        return base;
    }

    // 목록 조회
    function doSearch(page) {

        if (!page) page = 1;

        var params = buildSearchParams();
        params.page = page;
        params.pageSize = viewAllMode ? 999999 : 20;

        $('#loadingMsgRow').show();

        $.ajax({
            url: '/admin/ims/data',
            type: 'get',
            dataType: 'json',
            data: params,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            success: function (data) {

                var tbody = document.querySelector('#imsTableBody');
                var rowHtml = '';

                var list = (data && data.list) ? data.list : [];
                window.lastSearchList = list;

                if ($('#btnViewGallery').is(':checked')) {
                    renderGallery(list);
                }

                if (list.length > 0) {
                    for (var i = 0; i < list.length; i++) {
                        var r = list[i] || {};

                        var reportNo    = r.reportNo || '';
                        var statusCd    = r.statusCd || '';
                        var workContent = r.workContent || r.detailInfo || '';
                        var directionCd = r.directionCd || '';

                        var locationInfo =
                            r.locationInfo ||
                            (
                                r.addr
                                    ? (r.staText
                                        ? (escapeHtml(r.addr) + '<br><span class="text-muted"> ( STA ' + escapeHtml(r.staText) + ' )</span>')
                                        : escapeHtml(r.addr))
                                    : (r.staText
                                        ? ('<span class="text-muted">STA ' + escapeHtml(r.staText) + '</span>')
                                        : '')
                            ) ||
                            '';

                        var reportDate  = r.reportDate || '';
                        var workStartAt = r.workStartAt || '';
                        var workEndAt   = r.workEndAt || '';

                        // 완료일 때만 버튼 노출
                        var canReport = (statusCd === 'DONE' || statusCd === 'COMPLETE');

                        rowHtml += ''
                            + '<tr>'
                            +   '<td><input class="form-check-input rowCheck" type="checkbox" value="' + escapeHtml(reportNo) + '"></td>'
                            +   '<td>' + escapeHtml(r.siteName || '') + '</td>'
                            +   '<td>' + escapeHtml(r.receiptGbNm || '') + '</td>'
                            +   '<td><a href="javascript:void(0);" onclick="openImsDetail(\'' + escapeHtml(reportNo) + '\')">' + escapeHtml(reportNo) + '</a></td>'
                            +   '<td>' + renderImsStatus(statusCd) + '</td>'
                            +   '<td>' + renderDirection(directionCd) + '</td>'
                            +   '<td>' + locationInfo + '</td>'
                            +   '<td>' + escapeHtml(reportDate) + '</td>'
                            +   '<td>' + escapeHtml(workStartAt) + '</td>'
                            +   '<td>' + escapeHtml(workEndAt) + '</td>'
                            +   '<td>'
                            +     (canReport
                                    ? ''
                                    + '<div class="d-flex flex-column gap-1 align-items-center">'
                                    +   '<button type="button" class="btn btn-outline-secondary btn-sm" onclick="previewReport(\'' + escapeHtml(reportNo) + '\')">미리보기</button>'
                                    +   '<button type="button" class="btn btn-success btn-sm" onclick="downloadReport(\'' + escapeHtml(reportNo) + '\')">다운로드</button>'
                                    + '</div>'
                                    : '<span class="text-muted">-</span>'
                            )
                            +   '</td>'
                            + '</tr>';
                    }
                } else {
                    rowHtml = '<tr><td colspan="11" style="text-align:center;">조회 결과가 없습니다.</td></tr>';
                }

                tbody.innerHTML = rowHtml;

                document.querySelector('#sosCount').innerHTML =
                    '접수 내역 (총 <b>' + ((data && data.totalCount) ? Number(data.totalCount).toLocaleString() : '0') + '</b>건)';

                if (viewAllMode) {
                    document.querySelector('#paginationZone').innerHTML = '';
                } else {
                    document.querySelector('#paginationZone').innerHTML = renderPagination(data.pageInfo);
                }

                var sum = (data && data.summary) ? data.summary : {};

                $('#receivedCnt').text(Number(sum.received_cnt || 0).toLocaleString());
                $('#workingCnt').text(Number(sum.working_cnt  || 0).toLocaleString());
                $('#doneCnt').text(Number(sum.done_cnt     || 0).toLocaleString());
                $('#holdCnt').text(Number(sum.hold_cnt     || 0).toLocaleString());
                $('#totalCnt').text(Number(sum.total_cnt    || 0).toLocaleString());

            },
            error: function () {
                $('#imsTableBody').html('<tr><td colspan="11" style="text-align:center; color:red;">조회 중 오류가 발생했습니다.</td></tr>');
                $('#receivedCnt').text('0');
                $('#workingCnt').text('0');
                $('#doneCnt').text('0');
                $('#holdCnt').text('0');
                $('#totalCnt').text('0');
            },
            complete: function () {
                $('#loadingMsgRow').hide();
            }
        });
    }

    function renderImsStatus(statusCd){
        switch (statusCd) {
            case 'RECEIVED': return "<span class='badge danger'>접수</span>";
            case 'WORKING':  return "<span class='badge ing'>작업중</span>";
            case 'DONE':
            case 'COMPLETE': return "<span class='badge success'>완료</span>";
            case 'HOLD':     return "<span class='badge hold'>보류</span>";
            default:         return "<span>-</span>";
        }
    }

    function renderGallery(list) {
        var $zone = $('#galleryZone');
        $zone.empty();
console.log(list);
        if (!list || list.length === 0) {
            $zone.html('<p class="text-center text-muted">조회 결과가 없습니다.</p>');
            return;
        }

        for (var i = 0; i < list.length; i++) {
            var r = list[i] || {};
            var reportNo = r.reportNo || '';
            var statusCd = r.statusCd || '';
            var statusHtml = renderImsStatus(statusCd);

            var imgSrc = reportNo ? '/pothole/img/before/' + reportNo + '/1' : '';

            var isDone = (statusCd === 'DONE' || statusCd === 'COMPLETE');
            var dateLabel = isDone
                ? '작업종료일시: ' + escapeHtml(r.workEndAt || '-')
                : '접수일시: ' + escapeHtml(r.reportDate || '-');

            var locationInfo = r.addr
                ? escapeHtml(r.addr) + (r.staText ? ' (STA ' + escapeHtml(r.staText) + ')' : '')
                : (r.staText ? 'STA ' + escapeHtml(r.staText) : '-');

            var card = ''
                + '<div class="col-6 col-md-4 col-lg-3">'
                + '  <div class="card h-100" style="cursor:pointer;" onclick="openImsDetail(\'' + escapeHtml(reportNo) + '\')">'
                + '    <img src="' + escapeHtml(imgSrc) + '" class="card-img-top" style="height:250px; object-fit:cover;"'
                + '         onerror="this.style.display=\'none\'; this.nextElementSibling.classList.remove(\'d-none\');">'
                + '    <div class="no-img-msg d-none" style="height:250px; display:flex; align-items:center; justify-content:center; background-color:#e1e1e1;">'
                + '      <p class="mb-0 text-muted">접수된 사진이 없습니다.</p>'
                + '    </div>'
                + '    <div class="card-body p-3">'
                + '      <div class="mb-1">' + statusHtml + '<span class="mb-1 small ms-2">' + escapeHtml(r.siteName || '') + '</span></div>'
                + '      <p class="mb-1 fw-bold">' + escapeHtml(r.receiptGbNm || '') + '</p>'
                + '      <p class="mb-3 small">' + locationInfo + '</p>'
                + '      <p class="mb-0 small text-muted">' + dateLabel + '</p>'
                + '    </div>'
                + '  </div>'
                + '</div>';

            $zone.append(card);
        }
    }

    function renderDirection(directionCd){
        if (!directionCd) return '-';
        return roadDirMap[directionCd] || directionCd;
    }

    function renderDirectionOptions(siteCd, selectedDirectionCd) {
        var $dir = $('#ims-add-modal').find('#inDirectionCd');
        var list = roadDirBySiteMap[siteCd] || [];

        console.log('=== renderDirectionOptions ===');
        console.log('siteCd =', siteCd);
        console.log('roadDirBySiteMap =', roadDirBySiteMap);
        console.log('list =', list);

        $dir.empty();
        $dir.append('<option value="">선택</option>');

        for (var i = 0; i < list.length; i++) {
            var item = list[i];
            var selected = (selectedDirectionCd === item.cdCode) ? ' selected' : '';
            $dir.append('<option value="' + item.cdCode + '"' + selected + '>' + item.cdCodeNm + '</option>');
        }

        console.log('option count =', $dir.find('option').length);
    }
    document.addEventListener('DOMContentLoaded', function () {

        var today = new Date();
        var oneMonthAgo = new Date();
        oneMonthAgo.setMonth(oneMonthAgo.getMonth() - 1);

        flatpickr('#srchStrtDt', {
            dateFormat: 'Y-m-d',
            defaultDate: oneMonthAgo,
            locale: 'ko',
            maxDate: new Date().fp_incr(365 * 5),
            minDate: new Date().fp_incr(-365 * 5),
            allowInput: true
        });

        flatpickr('#srchEndDt', {
            dateFormat: 'Y-m-d',
            defaultDate: today,
            locale: 'ko',
            maxDate: new Date().fp_incr(365 * 5),
            minDate: new Date().fp_incr(-365 * 5),
            allowInput: true
        });

        insReportDtPicker = flatpickr('#insReportDt', {
            locale: 'ko',
            mode: 'single',
            dateFormat: 'Y-m-d H:i',
            enableTime: true,
            time_24hr: true,
            defaultDate: today,
            allowInput: true
        });

        workStartPicker = flatpickr('#insWorkStartAt', {
            locale: 'ko',
            dateFormat: 'Y-m-d H:i',
            enableTime: true,
            time_24hr: true,
            allowInput: true
        });

        workEndPicker = flatpickr('#insWorkEndAt', {
            locale: 'ko',
            dateFormat: 'Y-m-d H:i',
            enableTime: true,
            time_24hr: true,
            allowInput: true
        });
    });
    // ✅ 보고서 미리보기/다운로드
    function previewReport(reportNo) {
        var url = '/admin/ims/report/pdf/preview?reportNo=' + encodeURIComponent(reportNo);
        window.open(url, '_blank');
    }

    function downloadReport(reportNo) {
        window.location.href = '/admin/ims/report/pdf?reportNo=' + encodeURIComponent(reportNo);
    }


    // 상세 조회(모달)
    function openImsDetail(reportNo) {

        $.ajax({
            url: '/admin/ims/detail',
            type: 'get',
            dataType: 'json',
            data: { reportNo: reportNo },
            success: function (data) {

                var detail = (data && data.detail) ? data.detail : {};
                var adminUsers = (data && data.adminUsers) ? data.adminUsers : [];
                if (!detail) return;

                $('#imsModalTitle').text('현장 접수 상세');
                $('#btnDeleteTop, #btnDeleteBottom').show();

                var receiverId = detail.receiverId || '';
                var managerId  = detail.managerId || '';

                fillAdminUserSelects(adminUsers, receiverId, managerId, '선택');

                var statusCd  = detail.statusCd || '';
                var weatherCd = detail.weatherCd || '';
                var temp = detail.temp || '';
                var workTemp = detail.workTemp || '';
                var workWeatherCd = detail.workWeatherCd || '';
                var addr      = detail.addr || '';          // 주소
                var detailInfo= detail.detailInfo || '';    // 위치상세정보
                var lat       = detail.lat || '';
                var lng       = detail.lng || '';

                var directionCd = detail.directionCd || '';
                var reportDate  = detail.reportDate || detail.report_date || '';
                var updateDt    = detail.updateDatetime || detail.update_datetime || detail.updDt || '';
                var managerNm   = detail.managerNm || detail.manager_nm || '';

                var deliveryNote = detail.deliveryNote || '';
                var processNote  = detail.processNote || '';

                var ws = detail.workStartAt || '';
                var we = detail.workEndAt || '';
                var pavementCsv = detail.pavementTypeCds || '';
                var occurCsv    = detail.occurPlaceCds || '';

                var docNo = detail.docNo || detail.doc_no || '';

                // 값 세팅
                $('#insDocNo').val(docNo);
                $('#insLaneInfo').val(detail.laneInfo || '');
                $('#insReportRemark').val(detail.reportRemark || '');
                $('#insWorkQty').val(detail.workQty != null ? String(detail.workQty) : '');
                $('#insConvertWorkQty').val(detail.convertWorkQty != null ? String(detail.convertWorkQty) : '');
                $('#insAccountWorkQty').val(detail.accountWorkQty != null ? String(detail.accountWorkQty) : '');
                var detailSiteCd = detail.siteCd || '';
                var parentSiteCd = detail.parentSiteCd || '';
                $('#insSiteCd').val(detailSiteCd);
                $('#insReportNo').val(reportNo);
                $('#insReceiptGbCd').val(detail.receiptGbCd || '');
                $('#insWeatherCd').val(weatherCd);          // 접수 날씨
                $('#insWorkweatherCd').val(workWeatherCd);  // 작업 날씨

                $('#insDeliveryNote').val(deliveryNote);
                $('#insProcessNote').val(processNote);

                $('#ins-coordText').val(lat + ',' + lng);
                renderDirectionOptions(parentSiteCd || detailSiteCd, directionCd);
                $('#insAddr').val(addr);
                $('#insDetailInfo').val(detailInfo);

                $('#insStatusCd').val(statusCd);
                $('#insReportDt').val(reportDate ? String(reportDate).substring(0, 16) : '');

                if (managerNm) $('#popManager').val(managerNm);

                $('#insTemp').val(temp);
                $('#insWorkTemp').val(workTemp);

                $('#insWorkStartAt').val(ws ? String(ws).substring(0, 16) : '');
                $('#insWorkEndAt').val(we ? String(we).substring(0, 16) : '');

                // STA
                var staText      = detail.staText || '';
                var staMeters    = (detail.staMeters != null) ? String(detail.staMeters) : '';
                //var staKmDecimal = (detail.staKmDecimal != null) ? String(detail.staKmDecimal) : '';
                var staKmDecimal = detail.staKmDecimalText || '';

                $('#insStaKmView').val(staKmDecimal);
                $('#insStaKmDecimal').val(staKmDecimal);
                $('#insStaMetersView').val(staMeters);

                // 저장용 hidden
                $('#insStaText').val(staText);
                $('#insStaMeters').val(staMeters);
                $('#insStaKmDecimal').val(staKmDecimal);

                // 최종수정시간
                if (updateDt) {
                    $('.popUpdDt').css('display', '');
                    $('#popUpdDt').text(updateDt);
                } else {
                    $('.popUpdDt').css('display', 'none');
                    $('#popUpdDt').text('');
                }

                applyCheckedFromCsv('.choice-pavement', pavementCsv);
                applyCheckedFromCsv('.choice-occur', occurCsv);

                // =========================
                // ✅ 작업 전/후 사진
                // =========================
                var beforeList = (data && data.photos) ? data.photos : [];
                var afterList  = (data && data.afterPhotos) ? data.afterPhotos : [];

                // 삭제목록/신규미리보기 초기화
                $('#delBeforeSortOrds').val('');
                $('#delAfterSortOrds').val('');
                _newBefore = [];
                _newAfter  = [];

                // 파일 input 초기화
                $('#formFileBefore').val('');
                $('#formFileAfter').val('');

                // 렌더링
                renderImsPhotos(reportNo, beforeList, 'thumbnailContainerBefore', 'photoCountBefore');
                renderImsPhotos(reportNo, afterList,  'thumbnailContainerAfter',  'photoCountAfter');

                initPhotoDragSort(); // 드래그 함수

                var equipments = (data && data.equipments) ? data.equipments : [];
                var personnels = (data && data.personnels) ? data.personnels : [];
                var materials  = (data && data.materials)  ? data.materials  : [];
                var scopes     = (data && data.scopes)     ? data.scopes     : [];

                renderEquipmentRows(equipments);
                renderPersonnelRows(personnels);
                renderMaterialRows(materials);
                renderScopeRows(scopes);

                // 지도/STA
                if (lat && lng) {
                    setMapLinks(lat, lng, addr);

                    var hasSta = (detail.staText || '').trim();
                    if (!hasSta) {
                        recalcStaForAdmin();
                    }
                } else {
                    $('.mapLink').hide();
                }

                // 알림톡 발송 체크
                $('#insAlarmSendYn').prop('checked', true);
                $('#insAlarmSendYnTop').prop('checked', true);

                // 이력
                renderHistoryList(data.histories);

                setImsMode('UPDATE');
                $('#imsReportNoHidden').val(reportNo);
                $('#ims-add-modal').modal('show');


            },
            error: function () {
                showSwal('error', '오류 발생', '상세 조회 중 오류가 발생했습니다.');
            }
        });
    }

    // 위 → 아래
    $('#insAlarmSendYnTop').on('change', function () {
        $('#insAlarmSendYn').prop('checked', $(this).is(':checked'));
    });

    // 아래 → 위
    $('#insAlarmSendYn').on('change', function () {
        $('#insAlarmSendYnTop').prop('checked', $(this).is(':checked'));
    });
    // ✅ 저장(등록)
    $(document)
        .off('click.imsSave', '#btnSave')
        .on('click.imsSave', '#btnSave', function () {

            // 1) STA 입력값 → hidden에 반영
            applyStaFromAdminInput();

            // 2) 필수값 체크
            if (!validateImsRequired()) return;

            // 3) 확인 모달 → 저장 실행
            openConfirm('현장 접수를 등록하시겠습니까?', saveImsAdd);
        });

    $(document)
        .off('click.imsSaveTop', '#btnSaveTop')
        .on('click.imsSaveTop', '#btnSaveTop', function () {
            $('#btnSave').trigger('click');
        });
    $(document)
        .off('click.imsEditTop', '#btnEditTop')
        .on('click.imsEditTop', '#btnEditTop', function () {
            $('#btnEdit').trigger('click');
        });
    // ✅ 수정
    $(document)
        .off('click.imsSave', '#btnEdit')
        .on('click.imsSave', '#btnEdit', function () {

            applyStaFromAdminInput();

            if (!validateImsRequired()) return;

            openConfirm('현장 접수를 수정하시겠습니까?', saveImsUpdate);
        });


    function openConfirm(message, onConfirm) {

        Swal.fire({
            text: message,
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: '확인',
            cancelButtonText: '취소',
            reverseButtons: true,
            allowOutsideClick: false
        }).then(async function(result) {

            if (!result.isConfirmed) return;

            try {

                $('#loadingOverlay').removeClass('d-none');

                await onConfirm();

            } catch (e) {

                console.error(e);

            } finally {

                $('#loadingOverlay').addClass('d-none');
            }
        });
    }

    function postForm(url, formEl) {
        var fd = new FormData(formEl);

        fd.set('alarmSendYn', $('#insAlarmSendYn').is(':checked') ? 'Y' : 'N');

        // ✅ 접수일시(reportDate): Y-m-d H:i → Y-m-d H:i:s
        var rd = (fd.get('reportDate') || '');
        fd.set('reportDate', normalizeYmdHms(rd));

        // ✅ 작업시작/종료: Y-m-d H:i → Y-m-d H:i:s
        var ws = (fd.get('workStartAt') || fd.get('insWorkStartAt') || '');
        if (ws) fd.set('workStartAt', normalizeYmdHms(ws));

        var we = (fd.get('workEndAt') || fd.get('insWorkEndAt') || '');
        if (we) fd.set('workEndAt', normalizeYmdHms(we));

        // =========================
        // ✅ 대표사진(선택값) 처리
        // - db  : key = sortOrd 그대로
        // - new : key = newId → 업로드 배열 index(0-base)로 변환해서 전송
        // =========================
        var bfFrom = (fd.get('mainBeforeFrom') || '').trim(); // 'db' | 'new'
        var bfKey  = (fd.get('mainBeforeKey')  || '').trim(); // sortOrd or newId

        var afFrom = (fd.get('mainAfterFrom') || '').trim();
        var afKey  = (fd.get('mainAfterKey')  || '').trim();

        // ✅ 신규 BEFORE 파일들 추가 + 대표 index 계산
        var bfMainIdx = '';
        for (var i = 0; i < _newBefore.length; i++) {
            if (_newBefore[i] && _newBefore[i].file) {
                fd.append('formFileBefore', _newBefore[i].file);

                if (bfFrom === 'new' && bfKey && String(_newBefore[i].id) === String(bfKey)) {
                    bfMainIdx = String(i); // 0-based index
                }
            }
        }

        // ✅ 신규 AFTER 파일들 추가 + 대표 index 계산
        var afMainIdx = '';
        for (var j = 0; j < _newAfter.length; j++) {
            if (_newAfter[j] && _newAfter[j].file) {
                fd.append('formFileAfter', _newAfter[j].file);

                if (afFrom === 'new' && afKey && String(_newAfter[j].id) === String(afKey)) {
                    afMainIdx = String(j); // 0-based index
                }
            }
        }

        // ✅ 신규 대표라면 key를 "index"로 바꿔서 서버로 보냄 (db는 그대로 sortOrd)
        if (bfFrom === 'new') fd.set('mainBeforeKey', bfMainIdx);
        if (afFrom === 'new') fd.set('mainAfterKey', afMainIdx);

        // ✅ 포장형식/발생장소 CSV 세팅
        fd.set('pavementTypeCds', getCheckedCsv('.choice-pavement'));
        fd.set('occurPlaceCds', getCheckedCsv('.choice-occur'));

        // ✅ 작업정보 JSON
        var workInfo = collectWorkInfoPayload();
        fd.append('workInfoJson', JSON.stringify(workInfo));

        // 이미지
        fd.set('photoMoveJson', JSON.stringify(buildPhotoMovePayload()));

        return $.ajax({
            url: url,
            type: 'post',
            data: fd,
            processData: false,
            contentType: false,
            dataType: 'json'
        });
    }

    // 이미지정보
    function buildPhotoMovePayload() {
        var arr = [];

        $('#thumbnailContainerBefore .thumbnail-item-wrapper[data-from="db"]').each(function (idx) {

            var origPhotoGb = String($(this).data('origPhotogb') || $(this).data('photogb'));

            arr.push({
                fromPhotoGb: origPhotoGb,
                fromSortOrd: Number($(this).data('sortord')),
                toPhotoGb: 'BEFORE',
                toSortOrd: idx + 1
            });
        });

        $('#thumbnailContainerAfter .thumbnail-item-wrapper[data-from="db"]').each(function (idx) {

            var origPhotoGb = String($(this).data('origPhotogb') || $(this).data('photogb'));

            arr.push({
                fromPhotoGb: origPhotoGb,
                fromSortOrd: Number($(this).data('sortord')),
                toPhotoGb: 'AFTER',
                toSortOrd: idx + 1
            });
        });

        console.log('photoMovePayload=', arr);

        return arr;
    }

    // 지도 링크
    function setMapLinks(lat, lng, label) {

        var L = Number(lat), G = Number(lng);
        if (!isFinite(L) || !isFinite(G)) {
            $('#ins-coordRow').hide();
            return;
        }

        var lat6 = L.toFixed(6);
        var lng6 = G.toFixed(6);

        var name = encodeURIComponent(label || '');
        var q    = encodeURIComponent(lat6 + ',' + lng6);

        var kakaoWeb  = 'https://map.kakao.com/link/map/' + name + ',' + lat6 + ',' + lng6;
        var naverWeb  = 'https://map.naver.com/v5/search/' + q;
        var googleWeb = 'https://www.google.com/maps?q=' + lat6 + ',' + lng6 + '(' + name + ')';

        $('#ins-coordText').val(lat6 + ', ' + lng6);
        $('#ins-linkKakao').attr('href', kakaoWeb);
        $('#ins-linkNaver').attr('href', naverWeb);
        $('#ins-linkGoogle').attr('href', googleWeb);

        $('#insLat').val(lat6);
        $('#insLng').val(lng6);

        $('#ins-coordRow').show();
    }

    // 관리자 select 세팅
    function fillAdminUserSelects(adminUsers, selectedReceiverId, selectedManagerId, placeholderText) {

        adminUsers = Array.isArray(adminUsers) ? adminUsers : [];

        var $receiver = $('#insReceiverId');
        var $manager  = $('#insManagerId');

        var ph = (placeholderText != null && placeholderText !== '') ? String(placeholderText) : '선택';

        $receiver.html("<option value=''>" + escapeHtml(ph) + "</option>");
        $manager.html("<option value=''>" + escapeHtml(ph) + "</option>");

        for (var i = 0; i < adminUsers.length; i++) {
            var u = adminUsers[i] || {};
            var uid = u.userId || '';
            var unm = u.userNm || '';
            if (!uid) continue;

            $receiver.append("<option value='" + escapeHtml(uid) + "'>" + escapeHtml(unm) + "</option>");
            $manager.append("<option value='" + escapeHtml(uid) + "'>" + escapeHtml(unm) + "</option>");
        }

        if (selectedReceiverId != null && selectedReceiverId !== '') {
            $receiver.val(String(selectedReceiverId));
        }
        if (selectedManagerId != null && selectedManagerId !== '') {
            $manager.val(String(selectedManagerId));
        }
    }

    // STA 재계산
    function recalcStaForAdmin() {
       // $('#insStaTextView').val(staTextHidden);
        var sc  = $('#insSiteCd').val() || '';
        var lat = $('#insLat').val() || '';
        var lng = $('#insLng').val() || '';

        if (!sc || !lat || !lng) {
            $('#insStaText').val('');
            $('#insStaMeters').val('');
            $('#insStaKmDecimal').val('');
            return;
        }

        var payload = {
            siteCd: sc,
            directionCd: 'ALL',
            lat: Number(lat),
            lng: Number(lng)
        };

        $.ajax({
            url: '/api/sta/calc',
            type: 'post',
            dataType: 'json',
            contentType: 'application/json; charset=UTF-8',
            data: JSON.stringify(payload),
            success: function (res) {

                if (!res || res.ok !== true || !res.data) {
                    $('#insStaText').val('');
                    $('#insStaMeters').val('');
                    $('#insStaKmDecimal').val('');
                    return;
                }

                var r = res.data || {};
                // 화면용: "STA 25.1"
                var staTextView = r.staText || '';

                // hidden용: "25.1" (STA/공백 제거)
                var staTextHidden = staTextView;
                if (staTextHidden) {
                    staTextHidden = String(staTextHidden)
                        .replace(/^STA\s*/i, '')  // 맨 앞 "STA " 제거
                        .trim();
                }

                var staMeters = r.staMeters != null ? String(r.staMeters) : '';
                var staKmDecimal = r.staKmDecimal != null ? String(r.staKmDecimal) : '';

                $('#insStaKmView').val(staKmDecimal);
                $('#insStaMetersView').val(staMeters);

                $('#insStaText').val(formatStaTextFromMeters(staMeters));
                $('#insStaMeters').val(staMeters);
                $('#insStaKmDecimal').val(staKmDecimal);
            },
            error: function () {
                $('#insStaText').val('');
                $('#insStaMeters').val('');
                $('#insStaKmDecimal').val('');
            }
        });
    }

    // 사진(작업 전/후)
    var MAX_PHOTO = 20;
    var _newBefore = []; // { id, url, fileName }
    var _newAfter  = [];
    var _uidSeq = 1;

    function buildPhotoUrl(gb, reportNo, sortOrd, imgName){
        var base = (gb === 'AFTER') ? '/pothole/img/after/' : '/pothole/img/before/';
        return base + reportNo + '/' + sortOrd + '?v=' + new Date().getTime();
    }

    function countThumb(containerId){
        return $('#' + containerId + ' .thumbnail-item-wrapper').length;
    }

    function setCount(photoGb){
        if (photoGb === 'AFTER') {
            $('#photoCountAfter').text(String(countThumb('thumbnailContainerAfter')));
        } else {
            $('#photoCountBefore').text(String(countThumb('thumbnailContainerBefore')));
        }
    }

    function addToCsvHidden($hidden, val){
        var cur = ($hidden.val() || '').trim();
        var arr = cur ? cur.split(',') : [];
        val = String(val);

        for (var i = 0; i < arr.length; i++){
            if (String(arr[i]).trim() === val) return;
        }
        arr.push(val);
        $hidden.val(arr.join(','));
    }

    /* 파일 선택 → 신규 미리보기 썸네일 추가 */
    function handleFileSelect(e, photoGb){

        var input = e.target;
        var files = input.files;
        if (!files || files.length === 0) return;

        var containerId = (photoGb === 'AFTER') ? 'thumbnailContainerAfter' : 'thumbnailContainerBefore';
        var bag = (photoGb === 'AFTER') ? _newAfter : _newBefore;

        for (var i = 0; i < files.length; i++){

            if (countThumb(containerId) >= MAX_PHOTO) break;

            var f = files[i];
            if (!f || !f.type || !f.type.startsWith('image/')) continue;

            var url = URL.createObjectURL(f);
            var id = String(_uidSeq++);
            bag.push({ id: id, url: url, file: f, fileName: f.name });

            var html = ''
                + '<div class="col-4 thumbnail-item-wrapper"'
                + '     data-from="new"'
                + '     data-photogb="' + escapeHtml(photoGb) + '"'
                + '     data-newid="' + escapeHtml(id) + '">'
                + '  <div class="thumbnail-item mb-3" style="position: relative; width: 100%;">'
                + '    <img src="' + url + '" alt="현장사진" style="width: 100%; object-fit: cover;">'
                + '<button type="button"  class="main-thumbnail-btn before-main-btn">대표사진</button>'
                + '    <button type="button" class="thumbnail-remove2" aria-label="삭제">×</button>'
                + '  </div>'
                + '</div>';

            if (photoGb === 'AFTER' && $('#btnWrapAfter').length) {
                $('#btnWrapAfter').before(html);
            } else if (photoGb === 'BEFORE' && $('#btnWrapBefore').length) {
                $('#btnWrapBefore').before(html);
            } else {
                $('#' + containerId).append(html);
            }
        }

        setCount(photoGb);
        input.value = '';
    }


    /* ---------------------------
     * DB 사진 렌더 (상세보기에서 사용)
     * --------------------------- */
    function renderImsPhotos(reportNo, list, containerId, countSpanId){

        $('#' + containerId + ' .thumbnail-item-wrapper').remove();

        for (var i = 0; i < (list || []).length; i++){
            var p = list[i] || {};
            var photoGb = p.photoGb || '';
            var sortOrd = p.sortOrd;

            if (sortOrd == null || sortOrd === '') continue;

            var url = buildPhotoUrl(photoGb, reportNo, sortOrd, p.imgName || '');

            // ✅ 대표 여부
            var isMain = (String(p.isMain || '') === 'Y');
            var btnCls = 'main-thumbnail-btn' + (isMain ? ' active' : '');

            var html = ''
                + '<div class="col-4 thumbnail-item-wrapper"'
                + '     data-from="db"'
                + '     data-photogb="' + escapeHtml(photoGb) + '"'
                + '     data-orig-photogb="' + escapeHtml(photoGb) + '"'
                + '     data-sortord="' + escapeHtml(String(sortOrd)) + '">'
                + '  <div class="thumbnail-item mb-3" style="position: relative; width: 100%;">'
                + '    <img src="' + url + '" alt="현장사진" style="width: 100%; object-fit: cover;">'
                + '    <button type="button" class="' + btnCls + '">대표사진</button>'
                + '    <button type="button" class="thumbnail-remove2" aria-label="삭제">×</button>'
                + '  </div>'
                + '</div>';

            if (containerId === 'thumbnailContainerAfter') {
                $('#btnWrapAfter').before(html);
            } else {
                $('#btnWrapBefore').before(html);
            }

            // ✅ 숨은필드도 같이 맞춰주기(상세 열자마자 대표값 서버로 보내지게)
            if (isMain) {
                if (photoGb === 'AFTER') {
                    $('#mainAfterFrom').val('db');
                    $('#mainAfterKey').val(String(sortOrd));
                } else {
                    $('#mainBeforeFrom').val('db');
                    $('#mainBeforeKey').val(String(sortOrd));
                }
            }
        }

        $('#' + countSpanId).text(String(countThumb(containerId)));
    }

    $(document).on('click', '.main-thumbnail-btn', function (e) {
        e.preventDefault();
        e.stopPropagation();

        var $btn = $(this);
        var $wrap = $btn.closest('.thumbnail-item-wrapper');

        var from = String($wrap.data('from') || ''); // db | new

        // 현재 사진이 들어있는 컨테이너 기준으로 작업전/작업후 판단
        var photoGb = $wrap.closest('#thumbnailContainerAfter').length > 0 ? 'AFTER' : 'BEFORE';
        $wrap.attr('data-photogb', photoGb).data('photogb', photoGb);

        var $container = photoGb === 'AFTER'
            ? $('#thumbnailContainerAfter')
            : $('#thumbnailContainerBefore');

        $container.find('.main-thumbnail-btn').removeClass('active');
        $btn.addClass('active');

        var key = '';

        if (from === 'db') {
            key = String($container.find('.thumbnail-item-wrapper[data-from="db"]').index($wrap) + 1);
        }

        if (from === 'new') {
            key = $wrap.data('newid') != null ? String($wrap.data('newid')) : '';
        }

        if (photoGb === 'AFTER') {
            $('#mainAfterFrom').val(from);
            $('#mainAfterKey').val(key);
        } else {
            $('#mainBeforeFrom').val(from);
            $('#mainBeforeKey').val(key);
        }
    });


    /* ---------------------------
     * X 버튼 클릭: DB/신규 분기 삭제
     * --------------------------- */
    function removeThumb($btn){
        var $wrap = $btn.closest('.thumbnail-item-wrapper');
        var from = $wrap.data('from') || '';
        var photoGb = $wrap.data('origPhotogb') || $wrap.data('photogb') || '';

        if (from === 'db') {
            var sortOrd = $wrap.data('sortord');
            if (sortOrd != null && sortOrd !== '') {
                if (photoGb === 'AFTER') addToCsvHidden($('#delAfterSortOrds'), sortOrd);
                else addToCsvHidden($('#delBeforeSortOrds'), sortOrd);
            }
            $wrap.remove();
            setCount(photoGb);
            return;
        }

        if (from === 'new') {
            var newId = $wrap.data('newid') || '';
            var bag = (photoGb === 'AFTER') ? _newAfter : _newBefore;

            for (var i = 0; i < bag.length; i++){
                if (bag[i] && bag[i].id === String(newId)) {
                    try { URL.revokeObjectURL(bag[i].url); } catch(e){}
                    bag.splice(i, 1);
                    break;
                }
            }
            $wrap.remove();
            setCount(photoGb);
        }
    }
    /* ---------------------------
     * 사진 바인딩(딱 1번만, 중복 방지)
     * --------------------------- */
    $(document)
        .off('click.imsPhoto', '#selectFileBtnBefore')
        .on('click.imsPhoto', '#selectFileBtnBefore', function(e){
            e.preventDefault();
            e.stopPropagation();
            $('#formFileBefore').val('');
            $('#formFileBefore')[0].click();
        });

    $(document)
        .off('click.imsPhoto', '#selectFileBtnAfter')
        .on('click.imsPhoto', '#selectFileBtnAfter', function(e){
            e.preventDefault();
            e.stopPropagation();
            $('#formFileAfter').val('');
            $('#formFileAfter')[0].click();
        });

    $(document)
        .off('change.imsPhoto', '#formFileBefore')
        .on('change.imsPhoto', '#formFileBefore', function(e){
            if (countThumb('thumbnailContainerBefore') >= MAX_PHOTO) {
                showSwal('warning', '확인 필요', '사진은 최대 ' + MAX_PHOTO + '장까지 등록 가능합니다.');
                $(this).val('');
                return;
            }
            handleFileSelect(e, 'BEFORE');
        });

    $(document)
        .off('change.imsPhoto', '#formFileAfter')
        .on('change.imsPhoto', '#formFileAfter', function(e){
            if (countThumb('thumbnailContainerAfter') >= MAX_PHOTO) {
                showSwal('warning', '확인 필요', '사진은 최대 ' + MAX_PHOTO + '장까지 등록 가능합니다.');
                $(this).val('');
                return;
            }
            handleFileSelect(e, 'AFTER');
        });

    $(document)
        .off('click.imsPhoto', '.thumbnail-remove2')
        .on('click.imsPhoto', '.thumbnail-remove2', function(e){
            e.preventDefault();
            e.stopPropagation();
            removeThumb($(this)); // ✅ removeThumb 하나만 쓰기
        });

    /* ---------------------------
     * 모달 초기화
     * --------------------------- */
    function popInsertInit() {

        // 값 초기화
        $('#insDocNo').val('');
        $('#insReportNo').val('');
        $('#insSiteCd').val(siteCd || '');
        $('#insReceiptGbCd').prop('selectedIndex', 1);
        $('#insReportDt').val('');
        $('#insStatusCd').val('');
        $('#insWeatherCd').val('');
        $('#insWorkweatherCd').val('');
        $('#insReceiverId').val('');
        $('#insManagerId').val('');

        renderDirectionOptions($('#insSiteCd').val() || '', '');
        $('#insAddr').val('');
        $('#insLat').val('');
        $('#insLng').val('');
        $('#ins-coordText').val('');

        $('#insStaTextView').val('');
        $('#insStaText').val('');
        $('#insStaMeters').val('');
        $('#insStaKmDecimal').val('');

        $('#insDeliveryNote').val('');
        $('#insProcessNote').val('');
        $('#insLaneInfo').val('');
        $('#insReportRemark').val('');
        $('#insWorkQty').val('');
        $('#insConvertWorkQty').val('');
        $('#insAccountWorkQty').val('');

        // 삭제목록/신규목록 초기화
        $('#delBeforeSortOrds').val('');
        $('#delAfterSortOrds').val('');
        clearNewBags();

        // 파일 input 초기화
        $('#formFileBefore').val('');
        $('#formFileAfter').val('');

        $('#insTemp').val('');      // 접수 기온
        $('#insWorkTemp').val('');  // 작업 기온

        $('#btnDeleteTop, #btnDeleteBottom').hide();

        // 이력 초기화
        $('#historyTableBody').html(
            '<tr>' +
            '   <td colspan="5" class="text-center text-muted">이력이 없습니다.</td>' +
            '</tr>'
        );
        // 썸네일 초기화(버튼만 남기고 전부 제거)
        $('#thumbnailContainerBefore .thumbnail-item-wrapper').remove();
        $('#thumbnailContainerAfter .thumbnail-item-wrapper').remove();

        // 등록모드 기본 option 문구 변경
        $('#insReceiverId option:first').text('현장을 선택해주세요');
        $('#insManagerId  option:first').text('현장을 선택해주세요');

        // ✅ 접수일시: 모달 열 때 "현재시간"으로 세팅
        if (insReportDtPicker) {
            insReportDtPicker.setDate(new Date(), true); // true = input에도 바로 반영
        } else {
            // flatpickr가 아직 없으면 fallback
            $('#insReportDt').val('');
        }

        // ✅ 작업시작일시: 현재시간
        if (workStartPicker) {
            workStartPicker.setDate(new Date(), true);
        } else {
            $('#insWorkStartAt').val(nowYmdHi());
        }

        // ✅ 작업종료일시: 기본 빈값
        if (workEndPicker) {
            workEndPicker.clear();
        } else {
            $('#insWorkEndAt').val('');
        }
        $('.choice-pavement').prop('checked', false);
        $('.choice-occur').prop('checked', false);

        setCount('BEFORE');
        setCount('AFTER');

        // 알림톡 발송 체크
        $('#insAlarmSendYn').prop('checked', true);
        $('#insAlarmSendYnTop').prop('checked', true);
    }

    /* ---------------------------
     * 저장(INSERT) AJAX
     * --------------------------- */
    function saveImsAdd() {
        var formEl = document.getElementById('insFileForm');
        return postForm('/admin/ims/save', formEl)
            .done(function (data) {
                if (data && data.code === '0000') {
                    showSuccessSwal('현장 접수가 등록되었습니다.')
                        .then(function () {
                            $('#ims-add-modal').modal('hide');
                            doSearch(1);
                        });
                    $('#ims-add-modal').modal('hide');
                    doSearch(1);
                } else {
                    showSwal('error', '처리 실패', (data && data.message) || '처리 중 오류가 발생했습니다.');
                    throw new Error('insert failed');
                }
            })
            .fail(function () {
                showSwal('error', '오류 발생', '서버 통신 중 오류가 발생했습니다.');
                throw new Error('ajax error');
            });
    }
    function saveImsUpdate() {
        var formEl = document.getElementById('insFileForm');

        if (!($('#imsReportNoHidden').val() || '').trim()) {
            alert('reportNo가 없어 수정할 수 없습니다.');
            throw new Error('missing reportNo');
        }

        return postForm('/admin/ims/save', formEl)
            .done(function (data) {
                if (data && data.code === '0000') {
                    showSuccessSwal('정상적으로 수정 되었습니다.')
                        .then(function () {
                            $('#ims-add-modal').modal('hide');
                            doSearch(1);
                        });
                    $('#ims-add-modal').modal('hide');
                    doSearch(1);
                } else {
                    showSwal('error', '처리 실패', (data && data.message) || '처리 중 오류가 발생했습니다.');
                    throw new Error('update failed');
                }
            })
            .fail(function () {
                showSwal('error', '오류 발생', '서버 통신 중 오류가 발생했습니다.');
                throw new Error('ajax error');
            });
    }


    /* ---------------------------
     * 주소 검색 / 좌표 갱신
     * --------------------------- */
    function doSearchInsAddr() {
        new daum.Postcode({
            oncomplete: function (data) {
                var addr = data.address;
                document.getElementById('insAddr').value = addr;

                $.ajax({
                    url: '/admin/sos/geocode',
                    type: 'get',
                    dataType: 'json',
                    data: { addr: addr },
                    success: function (res) {
                        if (!res || !res.lat || !res.lng) {
                            showToastMsg('좌표를 찾지 못했습니다. 주소를 더 구체적으로 입력해주세요.');
                            return;
                        }
                        setMapLinks(res.lat, res.lng, addr);
                        recalcStaForAdmin();
                    },
                    error: function () {
                        alert('좌표 조회 중 오류가 발생했어요.');
                    }
                });
            }
        }).open();
    }

    function geocodeInsAddr() {
        var addr = ($('#insAddr').val() || '').trim();
        if (!addr) {
            showToastMsg('주소를 먼저 입력해주세요.');
            return;
        }

        $.ajax({
            url: '/admin/sos/geocode',
            type: 'get',
            dataType: 'json',
            data: { addr: addr },
            success: function (res) {
                if (!res || !res.lat || !res.lng) {
                    showToastMsg('좌표를 찾지 못했습니다. 주소를 더 구체적으로 입력해주세요.');
                    return;
                }
                setMapLinks(res.lat, res.lng, addr);
                recalcStaForAdmin();
                showToastMsg('GPS 좌표를 갱신했어요.');
            },
            error: function () {
                alert('좌표 조회 중 오류가 발생했어요.');
            }
        });
    }

    /* ---------------------------
     * 작업정보(투입 장비/인력/자재/범위) row add/remove
     * --------------------------- */
    function bindWorkInfoRows() {
        // ✅ 투입 장비 추가
        $(document).on('click', '#add-equipment', function() {
            console.log('ssss');
            var row = ''
                + '<tr>'
                + '  <td><input type="text" class="form-control equip-name" placeholder="장비명"></td>'
                + '  <td><input type="number" class="form-control equip-own" placeholder="0"></td>'
                + '  <td><input type="number" class="form-control equip-use" placeholder="0"></td>'
                + '  <td><input type="text" class="form-control equip-remark" placeholder="비고"></td>'
                + '  <td><button type="button" class="btn btn-danger delete-row">삭제</button></td>'
                + '</tr>';
            $('#body-equipment').append(row);

            console.log('equipment rows:', $('#body-equipment tr').length);
            console.log($('#body-equipment').html());
        });

        // ✅ 투입 인력 추가
        $(document).on('click', '#add-personnel', function() {
            var row = ''
                + '<tr>'
                + '  <td><input type="text" class="form-control person-name" placeholder="이름"></td>'
                + '  <td><input type="text" class="form-control person-dept" placeholder="부서"></td>'
                + '  <td><input type="text" class="form-control person-labor" placeholder="인건비"></td>'
                + '  <td><button type="button" class="btn btn-danger delete-row">삭제</button></td>'
                + '</tr>';
            $('#body-personnel').append(row);
        });

        // ✅ 투입 자재 추가
        $(document).on('click', '#add-material', function() {
            var row = ''
                + '<tr>'
                + '  <td><input type="text" class="form-control mat-name" placeholder="자재명"></td>'
                + '  <td><input type="text" class="form-control mat-spec" placeholder="규격"></td>'
                + '  <td><input type="text" class="form-control mat-unit" placeholder="단위"></td>'
                + '  <td><input type="text" class="form-control mat-use" placeholder="사용량"></td>'
                + '  <td><input type="text" class="form-control mat-remain" placeholder="잔량"></td>'
                + '  <td><input type="text" class="form-control mat-amount" placeholder="금액"></td>'
                + '  <td><button type="button" class="btn btn-danger delete-row">삭제</button></td>'
                + '</tr>';
            $('#body-material').append(row);
        });

        // ✅ 작업 범위 추가
        $(document).on('click', '#add-scope', function() {
            var row = ''
                + '<tr>'
                + '  <td><input type="text" class="form-control sc-width" placeholder="가로(m)"></td>'
                + '  <td><input type="text" class="form-control sc-height" placeholder="세로(m)"></td>'
                + '  <td><input type="text" class="form-control sc-area" placeholder="면적(㎡)"></td>'
                + '  <td><input type="text" class="form-control sc-depth" placeholder="깊이(cm)"></td>'
                + '  <td><input type="text" class="form-control sc-span" placeholder="폭(m)"></td>'
                + '  <td><button type="button" class="btn btn-danger delete-row">삭제</button></td>'
                + '</tr>';
            $('#body-scope').append(row);
        });

        // ✅ 공통 삭제
        $(document).on('click', '.delete-row', function() {
            $(this).closest('tr').remove();
        });

    }

    function setImsMode(mode){
        $('#imsMode').val(mode);

        var isUpdate = (mode === 'UPDATE');

        if (isUpdate) {
            $('#imsModalTitle').text('현장 접수 상세');
            $('#btnSave, #btnSaveTop').hide();
            $('#btnDeleteTop, #btnDeleteBottom').show();
            $('#btnEdit, #btnEditTop').show();

            $('#insReportNoWrap').show();

            $('#insSiteCd').prop('disabled', true);
            $('#insReportDt').prop('disabled', true);
            $('#insReportNo').prop('disabled', true);

        } else {
            $('#imsModalTitle').text('현장 접수 등록');
            $('#btnSave, #btnSaveTop').show();
            $('#btnEdit, #btnEditTop').hide();

            $('#insReportNoWrap').hide();
            $('#insReportNo').val('');
            $('#imsReportNoHidden').val('');

            $('#insSiteCd').prop('disabled', false);
            $('#insReportDt').prop('disabled', false);
            $('#insReportNo').prop('disabled', false);
        }
    }

    // 등록/수정 모달 안에서 고속도로 변경 시 사용자 목록 갱신
    $(document).on('change', '#insSiteCd', function () {
        var sc = $('#insSiteCd').val() || '';

        renderDirectionOptions(sc, '');

        if (!sc) {
            return;
        }

        fetchAdminUsersBySite(sc);
    });

    function fetchAdminUsersBySite(siteCd) {
        $.ajax({
            url: '/admin/ims/adminUsers',
            type: 'get',
            dataType: 'json',
            data: { siteCd: siteCd },
            success: function (res) {

                var list = Array.isArray(res) ? res : [];
                fillAdminUserSelects(list, '', '', '선택');
            },
            error: function () {
                fillAdminUserSelects([], '', '');
                alert('담당자 목록 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function collectWorkInfoPayload() {

        // 1) 장비
        var equipments = [];
        $('#body-equipment tr').each(function(idx){
            var $tr = $(this);
            var name = toStr($tr.find('.equip-name').val());
            var own  = toNumOrNull($tr.find('.equip-own').val());
            var use  = toNumOrNull($tr.find('.equip-use').val());
            var remark = toStr($tr.find('.equip-remark').val());

            // 전부 비어있으면 스킵
            if (!name && own == null && use == null && !remark) return;

            equipments.push({
                sortOrd: idx + 1,
                equipName: name,
                ownQty: own,
                useQty: use,
                remark: remark
            });
        });

        // 2) 인력
        var personnels = [];
        $('#body-personnel tr').each(function(idx){
            var $tr = $(this);
            var nm = toStr($tr.find('.person-name').val());
            var dp = toStr($tr.find('.person-dept').val());
            var labor = toNumOrNull($tr.find('.person-labor').val());
            if (!nm && !dp && labor == null) return;

            personnels.push({
                sortOrd: idx + 1,
                personName: nm,
                deptName: dp,
                laborCost: labor
            });
        });

        // 3) 자재
        var materials = [];
        $('#body-material tr').each(function(idx){
            var $tr = $(this);
            var nm   = toStr($tr.find('.mat-name').val());
            var spec = toStr($tr.find('.mat-spec').val());
            var unit = toStr($tr.find('.mat-unit').val());
            var use  = toNumOrNull($tr.find('.mat-use').val());
            var remain = toNumOrNull($tr.find('.mat-remain').val());
            var amount = toNumOrNull($tr.find('.mat-amount').val());
            if (!nm && !spec && !unit && use == null && remain == null && amount == null) return;

            materials.push({
                sortOrd: idx + 1,
                materialName: nm,
                spec: spec,
                unit: unit,
                useQty: use,
                remainQty: remain,
                amount: amount
            });
        });

        // 4) 범위
        var scopes = [];
        $('#body-scope tr').each(function(idx){
            var $tr = $(this);
            var w = toNumOrNull($tr.find('.sc-width').val());
            var h = toNumOrNull($tr.find('.sc-height').val());
            var a = toNumOrNull($tr.find('.sc-area').val());
            var d = toNumOrNull($tr.find('.sc-depth').val());
            var s = toNumOrNull($tr.find('.sc-span').val());
            if (w == null && h == null && a == null && d == null && s == null) return;

            scopes.push({
                sortOrd: idx + 1,
                widthM: w,
                heightM: h,
                areaM2: a,
                depthCm: d,
                spanM: s
            });
        });

        return {
            equipments: equipments,
            personnels: personnels,
            materials: materials,
            scopes: scopes
        };
    }
    function renderEquipmentRows(list){
        var $tb = $('#body-equipment');
        $tb.empty();

        if (!list || list.length === 0) {
            $tb.append(''
                + '<tr>'
                + '<td><input type="text" class="form-control equip-name" placeholder="장비명"></td>'
                + '<td><input type="number" class="form-control equip-own" placeholder="0"></td>'
                + '<td><input type="number" class="form-control equip-use" placeholder="0"></td>'
                + '<td><input type="text" class="form-control equip-remark" placeholder="비고"></td>'
                + '<td><button type="button" class="btn btn-danger delete-row">삭제</button></td>'
                + '</tr>');
            return;
        }

        for (var i=0;i<list.length;i++){
            var r = list[i] || {};
            $tb.append(''
                + '<tr>'
                + '<td><input type="text" class="form-control equip-name" value="' + escapeHtml(r.equipName || '') + '"></td>'
                + '<td><input type="number" class="form-control equip-own" value="' + escapeHtml(r.ownQty != null ? String(r.ownQty) : '') + '"></td>'
                + '<td><input type="number" class="form-control equip-use" value="' + escapeHtml(r.useQty != null ? String(r.useQty) : '') + '"></td>'
                + '<td><input type="text" class="form-control equip-remark" value="' + escapeHtml(r.remark || '') + '"></td>'
                + '<td><button type="button" class="btn btn-danger delete-row">삭제</button></td>'
                + '</tr>');
        }
    }

    function renderPersonnelRows(list){
        var $tb = $('#body-personnel');
        $tb.empty();

        if (!list || list.length === 0) {
            $tb.append(''
                + '<tr>'
                + '<td><input type="text" class="form-control person-name" placeholder="이름"></td>'
                + '<td><input type="text" class="form-control person-dept" placeholder="부서"></td>'
                + '<td><input type="text" class="form-control person-labor" placeholder="인건비"></td>'
                + '<td><button type="button" class="btn btn-danger delete-row">삭제</button></td>'
                + '</tr>');
            return;
        }

        for (var i=0;i<list.length;i++){
            var r = list[i] || {};
            $tb.append(''
                + '<tr>'
                + '<td><input type="text" class="form-control person-name" value="' + escapeHtml(r.personName || '') + '"></td>'
                + '<td><input type="text" class="form-control person-dept" value="' + escapeHtml(r.deptName || '') + '"></td>'
                + '<td><input type="text" class="form-control person-labor" value="' + escapeHtml(r.laborCost != null ? String(r.laborCost) : '') + '"></td>'
                + '<td><button type="button" class="btn btn-danger delete-row">삭제</button></td>'
                + '</tr>');
        }
    }

    function renderMaterialRows(list){
        var $tb = $('#body-material');
        $tb.empty();

        if (!list || list.length === 0) {
            $tb.append(''
                + '<tr>'
                + '<td><input type="text" class="form-control mat-name" placeholder="자재명"></td>'
                + '<td><input type="text" class="form-control mat-spec" placeholder="규격"></td>'
                + '<td><input type="text" class="form-control mat-unit" placeholder="단위"></td>'
                + '<td><input type="text" class="form-control mat-use" placeholder="사용량"></td>'
                + '<td><input type="text" class="form-control mat-remain" placeholder="잔량"></td>'
                + '<td><input type="text" class="form-control mat-amount" placeholder="금액"></td>'
                + '<td><button type="button" class="btn btn-danger delete-row">삭제</button></td>'
                + '</tr>');
            return;
        }

        for (var i=0;i<list.length;i++){
            var r = list[i] || {};
            $tb.append(''
                + '<tr>'
                + '<td><input type="text" class="form-control mat-name" value="' + escapeHtml(r.materialName || '') + '"></td>'
                + '<td><input type="text" class="form-control mat-spec" value="' + escapeHtml(r.spec || '') + '"></td>'
                + '<td><input type="text" class="form-control mat-unit" value="' + escapeHtml(r.unit || '') + '"></td>'
                + '<td><input type="text" class="form-control mat-use" value="' + escapeHtml(r.useQty != null ? String(r.useQty) : '') + '"></td>'
                + '<td><input type="text" class="form-control mat-remain" value="' + escapeHtml(r.remainQty != null ? String(r.remainQty) : '') + '"></td>'
                + '<td><input type="text" class="form-control mat-amount" value="' + escapeHtml(r.amount != null ? String(r.amount) : '') + '"></td>'
                + '<td><button type="button" class="btn btn-danger delete-row">삭제</button></td>'
                + '</tr>');
        }
    }

    function renderScopeRows(list){
        var $tb = $('#body-scope');
        $tb.empty();

        if (!list || list.length === 0) {
            $tb.append(''
                + '<tr>'
                + '<td><input type="text" class="form-control sc-width" placeholder="가로(m)"></td>'
                + '<td><input type="text" class="form-control sc-height" placeholder="세로(m)"></td>'
                + '<td><input type="text" class="form-control sc-area" placeholder="면적(㎡)"></td>'
                + '<td><input type="text" class="form-control sc-depth" placeholder="깊이(cm)"></td>'
                + '<td><input type="text" class="form-control sc-span" placeholder="폭(m)"></td>'
                + '<td><button type="button" class="btn btn-danger delete-row">삭제</button></td>'
                + '</tr>');
            return;
        }

        for (var i=0;i<list.length;i++){
            var r = list[i] || {};
            $tb.append(''
                + '<tr>'
                + '<td><input type="text" class="form-control sc-width" value="'  + escapeHtml(r.widthM  != null ? String(r.widthM)  : '') + '"></td>'
                + '<td><input type="text" class="form-control sc-height" value="' + escapeHtml(r.heightM != null ? String(r.heightM) : '') + '"></td>'
                + '<td><input type="text" class="form-control sc-area" value="'   + escapeHtml(r.areaM2  != null ? String(r.areaM2)  : '') + '"></td>'
                + '<td><input type="text" class="form-control sc-depth" value="'  + escapeHtml(r.depthCm != null ? String(r.depthCm) : '') + '"></td>'
                + '<td><input type="text" class="form-control sc-span" value="'   + escapeHtml(r.spanM   != null ? String(r.spanM)   : '') + '"></td>'
                + '<td><button type="button" class="btn btn-danger delete-row">삭제</button></td>'
                + '</tr>');
        }
    }

    function focusInvalid(selector) {

        var $el = $(selector);

        if ($el.length === 0) return;

        var modalBody = $('#ims-add-modal .modal-body')[0];

        if (modalBody) {
            modalBody.scrollTo({
                top: $el.offset().top - $('#ims-add-modal .modal-body').offset().top + modalBody.scrollTop - 120,
                behavior: 'smooth'
            });
        } else {
            $el[0].scrollIntoView({
                behavior: 'smooth',
                block: 'center'
            });
        }

        setTimeout(function () {
            $el.focus();

            if ($el.hasClass('flatpickr-input') && $el[0]._flatpickr) {
                $el[0]._flatpickr.open();
            }
        }, 300);
    }

    function invalidRequired(message, selector) {

        Swal.fire({
            icon: 'warning',
            title: '필수항목 확인',
            text: message,
            confirmButtonText: '확인',
            allowOutsideClick: false
        }).then(function () {
            focusInvalid(selector);
        });

        return false;
    }

    function validateImsRequired() {

        if (!$('#insSiteCd').val()) {
            return invalidRequired('현장을 선택해주세요.', '#insSiteCd');
        }

        if (!$('#insReceiptGbCd').val()) {
            return invalidRequired('작업유형을 선택해주세요.', '#insReceiptGbCd');
        }

        if (!$('#insStatusCd').val()) {
            return invalidRequired('작업상태를 선택해주세요.', '#insStatusCd');
        }

        if (!$('#insReceiverId').val()) {
            return invalidRequired('접수자를 선택해주세요.', '#insReceiverId');
        }

        if (!$('#insWeatherCd').val()) {
            return invalidRequired('날씨를 선택해주세요.', '#insWeatherCd');
        }

        if (!$('#insTemp').val()) {
            return invalidRequired('기온을 입력해주세요.', '#insTemp');
        }

        if (!$('#insReportDt').val()) {
            return invalidRequired('접수일시를 입력해주세요.', '#insReportDt');
        }

        return true;
    }

    // 전체선택(헤더) ↔ row 체크박스 동기화
    function bindCheckAllRows() {

        // 헤더 전체선택 클릭 → 전체 row 체크
        $(document)
            .off('change.imsCheck', '#checkDefault')
            .on('change.imsCheck', '#checkDefault', function () {

                var isChecked = $(this).is(':checked');

                // 로딩행/빈행 제외하고 체크박스만
                $('#imsTableBody .rowCheck').prop('checked', isChecked);
            });

        // row 체크 변경 → 헤더 전체선택 상태 갱신
        $(document)
            .off('change.imsCheck', '#imsTableBody .rowCheck')
            .on('change.imsCheck', '#imsTableBody .rowCheck', function () {

                var total = $('#imsTableBody .rowCheck').length;
                var checked = $('#imsTableBody .rowCheck:checked').length;

                $('#checkDefault').prop('checked', total > 0 && total === checked);
            });
    }


    // 상태 변경 시 작업종료일시 자동 입력
    $(document).off('change.imsStatus', '#insStatusCd').on('change.imsStatus', '#insStatusCd', function () {

        var st = ($('#insStatusCd').val() || '').trim();

        var isDone = (st === 'DONE' || st === 'COMPLETE');

        if (isDone) {

            // 종료일시가 비어있을 때만 자동 입력
            var curWe = ($('#insWorkEndAt').val() || '').trim();
            if (!curWe) {
                // flatpickr 인스턴스가 있으면 그걸로 세팅(포맷 맞춤)
                if (workEndPicker) {
                    workEndPicker.setDate(new Date(), true);
                } else {
                    // fallback (YYYY-MM-DD HH:mm)
                    $('#insWorkEndAt').val(nowYmdHi());
                }
            }

        } else {

            // 완료가 아니면 종료일시 비우고 싶다면
            if (workEndPicker) workEndPicker.clear();
            else $('#insWorkEndAt').val('');
        }
    });

    function getCheckedCsv(selector) {
        var arr = [];
        $(selector + ':checked').each(function () {
            var v = ($(this).val() || '').trim();
            if (v) arr.push(v);
        });
        return arr.join(',');
    }

    function applyCheckedFromCsv(selector, csv) {
        var map = {};
        var s = (csv || '').trim();
        if (s) {
            var parts = s.split(',');
            for (var i = 0; i < parts.length; i++) {
                var v = (parts[i] || '').trim();
                if (v) map[v] = true;
            }
        }

        $(selector).each(function () {
            var v = (($(this).val() || '') + '').trim();
            $(this).prop('checked', !!map[v]);
        });
    }

    function formatStaTextFromMeters(staMeters) {
        if (staMeters === null || staMeters === undefined || staMeters === '') {
            return '';
        }

        var meters = parseInt(staMeters, 10);
        if (isNaN(meters)) return '';

        var km = Math.floor(meters / 1000);
        var m = meters % 1000;

        return km + '+' + String(m).padStart(3, '0') + 'k';
    }

    function applyStaFromAdminInput() {
        var kmView = document.getElementById('insStaKmView');
        var metersView = document.getElementById('insStaMetersView');

        var hText = document.getElementById('insStaText');
        var hKm = document.getElementById('insStaKmDecimal');
        var hM = document.getElementById('insStaMeters');

        if (!kmView || !metersView || !hText || !hKm || !hM) return;

        var raw = (kmView.value || '').trim();

        if (raw === '') {
            metersView.value = '';
            hText.value = '';
            hKm.value = '';
            hM.value = '';
            return;
        }

        raw = raw.replace(/[^0-9.]/g, '');

        var kmDecimal = parseFloat(raw);
        if (isNaN(kmDecimal)) {
            metersView.value = '';
            hText.value = '';
            hKm.value = '';
            hM.value = '';
            return;
        }

        var meters = Math.round(kmDecimal * 1000);

        metersView.value = String(meters);

        hM.value = String(meters);                  // 2700
        hKm.value = String(kmDecimal);              // 2.7
        hText.value = formatStaTextFromMeters(meters); // 2+700k
    }

    $(document)
        .off('input', '#insStaKmView')
        .on('input', '#insStaKmView', function () {
            applyStaFromAdminInput();
        });

    // 입력할 때마다 반영
    $(document).off('input', '#insStaTextView').on('input', '#insStaTextView', function () {
        applyStaFromAdminInput();
    });

    // 이미지 다운로드
    $(document)
        .off('click.imsPhotoDownload', '#btnPhotoDownload')
        .on('click.imsPhotoDownload', '#btnPhotoDownload', function () {

            var reportNos = getSelectedReportNos();

            if (reportNos.length === 0) {
                alert('다운로드할 접수를 선택해주세요.');
                return;
            }

            $('#loadingOverlay')
                .removeClass('d-none')
                .css('display', 'flex');

            var form = $('<form>', {
                method: 'POST',
                action: '/admin/ims/photos/download'
            });

            for (var i = 0; i < reportNos.length; i++) {
                form.append($('<input>', {
                    type: 'hidden',
                    name: 'reportNos',
                    value: reportNos[i]
                }));
            }

            $('body').append(form);

            setTimeout(function () {
                form.submit();
            }, 200);

            setTimeout(function () {
                $('#loadingOverlay')
                    .addClass('d-none')
                    .hide();

                form.remove();
            }, 1000);
        });

    function getSelectedReportNos() {
        var arr = [];
        $('#imsTableBody .rowCheck:checked').each(function () {
            var v = ($(this).val() || '').trim();
            if (v) arr.push(v);
        });
        return arr;
    }


    $(document)
        .off('click.imsLedger', '#btnLedgerDownload')
        .on('click.imsLedger', '#btnLedgerDownload', function () {

            var reportNos = getSelectedReportNos();

            if (!reportNos || reportNos.length === 0) {
                alert('다운로드할 항목을 선택해주세요.');
                return;
            }

            downloadLedgerReport(reportNos);
        });

    function downloadLedgerReport(reportNos) {
        var template = ($('#ledgerExportTemplate').val() || 'POTHOLE_LEDGER').toUpperCase();
        var format = ($('#ledgerExportFormat').val() || 'pdf').toLowerCase();
        var $form = $('<form>', {
            method: 'post',
            action: '/admin/reports/export'
        });

        $form.append($('<input>', {
            type: 'hidden',
            name: 'template',
            value: template
        }));

        $form.append($('<input>', {
            type: 'hidden',
            name: 'format',
            value: format
        }));

        for (var i = 0; i < reportNos.length; i++) {
            $form.append(
                $('<input>', {
                    type: 'hidden',
                    name: 'reportNos',
                    value: reportNos[i]
                })
            );
        }

        $('body').append($form);
        $form.trigger('submit');
        $form.remove();
    }

    function syncLedgerExportFormatOptions() {
        var template = ($('#ledgerExportTemplate').val() || 'POTHOLE_LEDGER').toUpperCase();
        var isLedger = template === 'POTHOLE_LEDGER';
        var $format = $('#ledgerExportFormat');
        var currentFormat = ($format.val() || 'pdf').toLowerCase();
        if (!isLedger && currentFormat === 'pdf') {
            $format.val('docx');
        }
        $('#ledgerExportFormat option[value="pdf"]').prop('disabled', !isLedger);
    }

    $(document)
        .off('change.imsLedgerTemplate', '#ledgerExportTemplate')
        .on('change.imsLedgerTemplate', '#ledgerExportTemplate', syncLedgerExportFormatOptions);

    syncLedgerExportFormatOptions();

    // 관리자 모달 삭제 버튼 클릭
    $(document)
        .off('click.imsDeleteOpen', '#btnDeleteTop, #btnDeleteBottom')
        .on('click.imsDeleteOpen', '#btnDeleteTop, #btnDeleteBottom', function (e) {

            e.preventDefault();
            e.stopPropagation();

            showConfirmSwal(
                '삭제하시겠습니까?',
                '삭제한 데이터는 복구가 어렵습니다.'
            ).then(function (result) {

                if (!result.isConfirmed) return;

                var reportNo = $('#insReportNo').val() || $('#imsReportNoHidden').val() || '';

                if (!reportNo) {
                    showSwal('warning', '확인 필요', '접수번호가 없습니다.');
                    return;
                }

                $.ajax({
                    url: '/admin/ims/delete',
                    type: 'POST',
                    dataType: 'json',
                    data: {
                        reportNo: reportNo
                    },

                    beforeSend: function () {
                        $('#btnDeleteTop, #btnDeleteBottom').prop('disabled', true);
                    },

                    success: function (res) {

                        if (res && res.code === '0000') {

                            $('#ims-add-modal').modal('hide');

                            showSuccessSwal('삭제되었습니다.')
                                .then(function () {
                                    doSearch(1);
                                });

                        } else {

                            showSwal(
                                'error',
                                '삭제 실패',
                                (res && res.message) || '삭제 실패'
                            );
                        }
                    },

                    error: function () {
                        showSwal(
                            'error',
                            '오류 발생',
                            '삭제 중 오류가 발생했습니다.'
                        );
                    },

                    complete: function () {
                        $('#btnDeleteTop, #btnDeleteBottom').prop('disabled', false);
                    }
                });

            });

        });

    // 이미지 드래그
    function initPhotoDragSort() {
        var beforeEl = document.getElementById('thumbnailContainerBefore');
        var afterEl  = document.getElementById('thumbnailContainerAfter');

        if (!beforeEl || !afterEl || typeof Sortable === 'undefined') return;

        [beforeEl, afterEl].forEach(function (el) {
            new Sortable(el, {
                group: 'imsPhotos',
                animation: 150,
                draggable: '.thumbnail-item-wrapper',
                filter: '#btnWrapBefore, #btnWrapAfter',
                onEnd: function () {
                    refreshPhotoGbByContainer();
                }
            });
        });
    }

    function refreshPhotoGbByContainer() {
        $('#thumbnailContainerBefore .thumbnail-item-wrapper').attr('data-photogb', 'BEFORE');
        $('#thumbnailContainerAfter .thumbnail-item-wrapper').attr('data-photogb', 'AFTER');

        setCount('BEFORE');
        setCount('AFTER');
    }
</script>

<link rel="stylesheet" href="/css/dashboard.css">
</body>
