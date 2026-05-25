<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<html>
<%@include file="./common/head.jsp"%>

<body>
<%@include file="./common/top.jsp"%>
<div id="layout">
    <div id="mainContent">
        <div class="container">
            <div class="title">
                <div>
                    <h4><b>상황일지 관리</b></h4>
                    <button type="button" class="btn btn-dark" id="btnNewSituation" style="margin-left:5px">상황 등록</button>
                    <button type="button" class="btn btn-success" id="btnExportSituationDocx" style="margin-left:5px">DOCX 출력</button>
                    <button type="button" class="btn btn-outline-success" id="btnExportSituationHwpx" style="margin-left:5px">HWPX 출력</button>
                </div>
            </div>

            <div class="search-zone">
                <div class="row g-2 align-items-end">
                    <div class="col-2">
                        <label class="form-label">시작일</label>
                        <input type="date" id="startDate" class="form-control" value="${today}">
                    </div>
                    <div class="col-2">
                        <label class="form-label">종료일</label>
                        <input type="date" id="endDate" class="form-control" value="${today}">
                    </div>
                    <div class="col-2">
                        <label class="form-label">주/야간</label>
                        <select id="searchShiftCd" class="form-select">
                            <option value="">전체</option>
                            <c:forEach items="${shiftList}" var="shift">
                                <option value="${shift.cdCode}">${shift.cdCodeNm}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-2">
                        <label class="form-label">현장</label>
                        <select id="searchSiteCd" class="form-select">
                            <option value="">전체</option>
                            <c:forEach items="${siteList}" var="site">
                                <option value="${site.siteCd}">${site.siteName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-3">
                        <label class="form-label">키워드</label>
                        <input type="text" id="keyword" class="form-control" placeholder="제목, 내용, 작성자">
                    </div>
                    <div class="col-1">
                        <button type="button" class="btn btn-primary w-100" id="btnSearch">조회</button>
                    </div>
                </div>
            </div>

            <p id="situationCount">총 <b>0</b>건</p>

            <div class="data-zone">
                <table class="table">
                    <thead>
                    <tr>
                        <th>일자</th>
                        <th>구분</th>
                        <th>시간</th>
                        <th>제목</th>
                        <th>현장</th>
                        <th>작성자</th>
                        <th>관리</th>
                    </tr>
                    </thead>
                    <tbody id="situationTableBody">
                    <tr id="loadingMsgRow" style="display:none;">
                        <td colspan="7" style="text-align:center; color:gray;">조회 중입니다...</td>
                    </tr>
                    </tbody>
                </table>
                <div id="paginationZone" class="text-center mt-3"></div>
            </div>

            <div id="sidePanel" class="hidden">
                <div class="offcanvas-header">
                    <h4><b id="panelTitle">상황 등록</b></h4>
                    <div>
                        <button type="button" class="btn btn-primary" id="btnSaveSituation">저장</button>
                        <button type="button" class="btn btn-danger" id="btnDeleteSituation" style="display:none;">삭제</button>
                        <button type="button" class="btn btn-secondary" id="btnClosePanel">창닫기</button>
                    </div>
                </div>
                <div class="offcanvas-body pb-5">
                    <form id="situationForm">
                        <input type="hidden" id="situationId" name="situationId">
                        <input type="hidden" id="useYn" name="useYn" value="Y">

                        <h5 class="mb-3 fw-bold">기본 정보</h5>
                        <div class="row g-3">
                            <div class="col-3">
                                <label class="form-label">일자</label>
                                <input type="date" id="logDate" name="logDate" class="form-control" value="${today}">
                            </div>
                            <div class="col-3">
                                <label class="form-label">주/야간</label>
                                <select id="shiftCd" name="shiftCd" class="form-select">
                                    <c:forEach items="${shiftList}" var="shift">
                                        <option value="${shift.cdCode}">${shift.cdCodeNm}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-3">
                                <label class="form-label">시간</label>
                                <input type="time" id="eventTime" name="eventTime" class="form-control">
                            </div>
                            <div class="col-3">
                                <label class="form-label">현장</label>
                                <select id="siteCd" name="siteCd" class="form-select">
                                    <option value="">선택</option>
                                    <c:forEach items="${siteList}" var="site">
                                        <option value="${site.siteCd}">${site.siteName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label">제목</label>
                                <input type="text" id="title" name="title" class="form-control" maxlength="200" placeholder="상황 제목">
                            </div>
                            <div class="col-12">
                                <label class="form-label">상황 내용</label>
                                <textarea id="content" name="content" class="form-control" rows="8" placeholder="상황 발생 내용과 조치 사항을 입력하세요."></textarea>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
<%@include file="./common/modal.jsp"%>
<%@include file="./common/script.jsp"%>

<script>
    let currentPage = 1;

    $(document).ready(function () {
        loadSituations(1);

        $('#btnSearch').on('click', function () {
            loadSituations(1);
        });
        $('#keyword').on('keyup', function (e) {
            if (e.key === 'Enter') {
                loadSituations(1);
            }
        });
        $('#btnNewSituation').on('click', function () {
            openNewPanel();
        });
        $('#btnExportSituationDocx').on('click', function () {
            exportSituations('docx');
        });
        $('#btnExportSituationHwpx').on('click', function () {
            exportSituations('hwpx');
        });
        $('#btnClosePanel').on('click', function () {
            $('#sidePanel').addClass('hidden');
        });
        $('#btnSaveSituation').on('click', function () {
            saveSituation();
        });
        $('#btnDeleteSituation').on('click', function () {
            deleteSituation();
        });
    });

    function loadSituations(page) {
        currentPage = page;
        $('#loadingMsgRow').show();

        $.ajax({
            url: '/admin/situation-logs/data',
            type: 'GET',
            data: {
                page: page,
                startDate: $('#startDate').val(),
                endDate: $('#endDate').val(),
                shiftCd: $('#searchShiftCd').val(),
                siteCd: $('#searchSiteCd').val(),
                keyword: $('#keyword').val(),
                useYn: 'Y'
            },
            success: function (res) {
                renderRows(res.list || []);
                renderPagination(res.pageInfo || { currentPage: 1, totalPages: 1 });
                $('#situationCount').html('총 <b>' + (res.totalCount || 0) + '</b>건');
            },
            error: function () {
                showMsg('error', '오류', '상황일지 목록 조회 중 오류가 발생했습니다.');
            },
            complete: function () {
                $('#loadingMsgRow').hide();
            }
        });
    }

    function renderRows(list) {
        const $body = $('#situationTableBody');
        $body.find('tr:not(#loadingMsgRow)').remove();

        if (!list.length) {
            $body.append('<tr><td colspan="7" style="text-align:center; color:gray;">조회된 상황일지가 없습니다.</td></tr>');
            return;
        }

        list.forEach(function (row) {
            $body.append(
                '<tr>' +
                '<td>' + escapeHtml(row.logDate || '') + '</td>' +
                '<td>' + escapeHtml(row.shiftNm || row.shiftCd || '') + '</td>' +
                '<td>' + escapeHtml(row.eventTime || '') + '</td>' +
                '<td style="text-align:left;">' + escapeHtml(row.title || row.content || '') + '</td>' +
                '<td>' + escapeHtml(row.siteName || row.siteCd || '') + '</td>' +
                '<td>' + escapeHtml(row.regNm || row.regId || '') + '</td>' +
                '<td><button type="button" class="btn btn-secondary btn-sm" onclick="loadSituationDetail(' + row.situationId + ')">상세</button></td>' +
                '</tr>'
            );
        });
    }

    function renderPagination(pageInfo) {
        const totalPages = pageInfo.totalPages || 1;
        const current = pageInfo.currentPage || 1;
        let html = '';
        for (let i = 1; i <= totalPages; i++) {
            const active = i === current ? 'btn-secondary' : 'btn-outline-secondary';
            html += '<button type="button" class="btn ' + active + ' btn-sm mx-1" onclick="loadSituations(' + i + ')">' + i + '</button>';
        }
        $('#paginationZone').html(html);
    }

    function openNewPanel() {
        $('#panelTitle').text('상황 등록');
        $('#situationForm')[0].reset();
        $('#situationId').val('');
        $('#logDate').val('${today}');
        $('#useYn').val('Y');
        $('#btnDeleteSituation').hide();
        $('#sidePanel').removeClass('hidden');
    }

    function loadSituationDetail(situationId) {
        $.ajax({
            url: '/admin/situation-logs/' + situationId,
            type: 'GET',
            success: function (res) {
                if (res.code !== '0000') {
                    showMsg('warning', '확인 필요', res.message || '상황일지 정보를 찾을 수 없습니다.');
                    return;
                }
                fillForm(res.data || {});
                $('#sidePanel').removeClass('hidden');
            },
            error: function () {
                showMsg('error', '오류', '상황일지 상세 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function exportSituations(format) {
        const params = $.param({
            startDate: $('#startDate').val(),
            endDate: $('#endDate').val(),
            shiftCd: $('#searchShiftCd').val(),
            siteCd: $('#searchSiteCd').val(),
            keyword: $('#keyword').val(),
            format: format
        });
        location.href = '/admin/situation-logs/export?' + params;
    }

    function fillForm(data) {
        $('#panelTitle').text('상황 수정');
        $('#situationId').val(data.situationId || '');
        $('#logDate').val(data.logDate || '${today}');
        $('#shiftCd').val(data.shiftCd || 'DAY');
        $('#eventTime').val(data.eventTime || '');
        $('#siteCd').val(data.siteCd || '');
        $('#title').val(data.title || '');
        $('#content').val(data.content || '');
        $('#useYn').val(data.useYn || 'Y');
        $('#btnDeleteSituation').show();
    }

    function saveSituation() {
        $.ajax({
            url: '/admin/situation-logs/save',
            type: 'POST',
            data: $('#situationForm').serialize(),
            success: function (res) {
                if (res.code !== '0000') {
                    showMsg('warning', '확인 필요', res.message || '입력값을 확인하세요.');
                    return;
                }
                showMsg('success', '완료', res.message || '저장되었습니다.');
                $('#sidePanel').addClass('hidden');
                loadSituations(currentPage);
            },
            error: function () {
                showMsg('error', '오류', '상황일지 저장 중 오류가 발생했습니다.');
            }
        });
    }

    function deleteSituation() {
        const situationId = $('#situationId').val();
        if (!situationId) {
            return;
        }
        if (!confirm('상황일지를 삭제하시겠습니까?')) {
            return;
        }

        $.ajax({
            url: '/admin/situation-logs/delete',
            type: 'POST',
            data: { situationId: situationId },
            success: function (res) {
                if (res.code !== '0000') {
                    showMsg('warning', '확인 필요', res.message || '삭제할 수 없습니다.');
                    return;
                }
                showMsg('success', '완료', res.message || '삭제되었습니다.');
                $('#sidePanel').addClass('hidden');
                loadSituations(1);
            },
            error: function () {
                showMsg('error', '오류', '상황일지 삭제 중 오류가 발생했습니다.');
            }
        });
    }

    function escapeHtml(value) {
        return String(value || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }
</script>
</html>
