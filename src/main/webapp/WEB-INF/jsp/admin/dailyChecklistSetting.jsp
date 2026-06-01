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
                    <h4><b>일상점검 체크리스트 설정</b></h4>
                    <button type="button" class="btn btn-dark" style="margin-left:5px" id="btnAddChecklist">체크리스트 추가</button>
                    <a href="/admin/user/setting" class="btn btn-secondary" style="margin-left:5px">관리자 설정</a>
                </div>
            </div>

            <div class="search-zone">
                <div class="row g-2 align-items-end">
                    <div class="col-12 col-md-4">
                        <label class="form-label">키워드</label>
                        <input type="text" id="keyword" class="form-control" placeholder="체크리스트명">
                    </div>
                    <div class="col-12 col-md-3">
                        <label class="form-label">관리현장</label>
                        <select id="siteCd" class="form-select">
                            <option value="">전체</option>
                            <c:forEach items="${siteList}" var="site">
                                <option value="${site.siteCd}">${site.siteName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-12 col-md-2">
                        <label class="form-label">사용 여부</label>
                        <select id="useYn" class="form-select">
                            <option value="Y">사용</option>
                            <option value="">전체</option>
                            <option value="N">미사용</option>
                        </select>
                    </div>
                    <div class="col-12 col-md-1">
                        <button type="button" class="btn btn-primary w-100" id="btnSearch">조회</button>
                    </div>
                </div>
            </div>

            <div style="display:flex!important; justify-content:space-between; align-items:center;">
                <p id="checklistCount">총 <b>0</b>건</p>
            </div>

            <div class="data-zone">
                <table class="table">
                    <thead>
                    <tr>
                        <th>체크리스트명</th>
                        <th>관리현장</th>
                        <th>공통</th>
                        <th>항목 수</th>
                        <th>사용 여부</th>
                        <th>정렬</th>
                        <th>관리</th>
                    </tr>
                    </thead>
                    <tbody id="checklistTableBody">
                    <tr id="loadingMsgRow" style="display:none;">
                        <td colspan="7" style="text-align:center; color:gray;">조회 중입니다...</td>
                    </tr>
                    </tbody>
                </table>
                <div id="paginationZone" class="text-center mt-3"></div>
            </div>

            <div id="sidePanel" class="hidden">
                <form id="checklistForm" name="checklistForm">
                    <input type="hidden" id="checklistId" name="checklistId">
                    <div class="offcanvas-header">
                        <h4 id="panelTitle"><b>체크리스트 추가</b></h4>
                        <div>
                            <button type="button" class="btn btn-primary" id="btnSave">저장</button>
                            <button type="button" class="btn bg-danger" id="btnDelete">삭제</button>
                            <button type="button" class="btn btn-secondary" id="btnClosePanel">닫기</button>
                        </div>
                    </div>
                    <div class="offcanvas-body pb-5">
                        <h5 class="mb-3 fw-bold">기본정보</h5>
                        <div class="row my-2">
                            <div class="col-12 col-md-6 mb-3">
                                <label class="form-label">체크리스트명</label>
                                <input type="text" class="form-control form-control-a" id="checklistName" name="checklistName">
                            </div>
                            <div class="col-12 col-md-6 mb-3">
                                <label class="form-label">관리현장</label>
                                <select id="formSiteCd" name="siteCd" class="form-select">
                                    <option value="">공통</option>
                                    <c:forEach items="${siteList}" var="site">
                                        <option value="${site.siteCd}">${site.siteName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-12 col-md-3 mb-3">
                                <label class="form-label">공통 여부</label>
                                <select id="commonYn" name="commonYn" class="form-select">
                                    <option value="Y">공통</option>
                                    <option value="N">현장별</option>
                                </select>
                            </div>
                            <div class="col-12 col-md-3 mb-3">
                                <label class="form-label">사용 여부</label>
                                <select id="formUseYn" name="useYn" class="form-select">
                                    <option value="Y">사용</option>
                                    <option value="N">미사용</option>
                                </select>
                            </div>
                            <div class="col-12 col-md-3 mb-3">
                                <label class="form-label">정렬 순서</label>
                                <input type="number" class="form-control form-control-a" id="sortOrd" name="sortOrd" value="0" min="0">
                            </div>
                        </div>

                        <div class="mt-4" style="border-top:1px dotted #9f9f9f; padding-top:25px;">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h5 class="fw-bold mb-0">점검 항목</h5>
                                <button type="button" class="btn btn-dark btn-sm" id="btnAddItem">항목 추가</button>
                            </div>
                            <table class="table">
                                <thead>
                                <tr>
                                    <th style="width:28%;">항목명</th>
                                    <th style="width:14%;">입력형식</th>
                                    <th style="width:26%;">답변 옵션</th>
                                    <th style="width:10%;">필수</th>
                                    <th style="width:10%;">사용</th>
                                    <th style="width:8%;">정렬</th>
                                    <th style="width:4%;"></th>
                                </tr>
                                </thead>
                                <tbody id="itemTableBody"></tbody>
                            </table>
                            <p class="text-muted small">답변 옵션은 쉼표로 구분해서 입력합니다. 예: 양호,주의,불량</p>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
</body>
<%@include file="./common/modal.jsp"%>
<%@include file="./common/script.jsp"%>

<script>
    var currentPage = 1;

    $(document).ready(function () {
        loadChecklists(1);
        $('#btnSearch').on('click', function () { loadChecklists(1); });
        $('#keyword').on('keyup', function (e) { if (e.key === 'Enter') loadChecklists(1); });
        $('#btnAddChecklist').on('click', openPanel);
        $('#btnClosePanel').on('click', closePanel);
        $('#btnAddItem').on('click', function () { addItemRow({}); });
        $('#btnSave').on('click', saveChecklist);
        $('#btnDelete').on('click', deleteChecklist);
    });

    function loadChecklists(page) {
        currentPage = page;
        $('#loadingMsgRow').show();
        $.ajax({
            url: '/admin/daily-checklists/data',
            type: 'GET',
            dataType: 'json',
            data: {
                page: page,
                keyword: $('#keyword').val(),
                siteCd: $('#siteCd').val(),
                useYn: $('#useYn').val()
            },
            success: function (res) {
                renderChecklistRows(res.list || []);
                renderPagination(res.pageInfo || { currentPage: 1, totalPages: 1 });
                $('#checklistCount').html('총 <b>' + (res.totalCount || 0) + '</b>건');
            },
            error: function () { showMsg('error', '오류', '체크리스트 목록 조회 중 오류가 발생했습니다.'); },
            complete: function () { $('#loadingMsgRow').hide(); }
        });
    }

    function renderChecklistRows(list) {
        var $body = $('#checklistTableBody');
        $body.find('tr:not(#loadingMsgRow)').remove();
        if (!list.length) {
            $body.append('<tr><td colspan="7" style="text-align:center; color:gray;">조회된 체크리스트가 없습니다.</td></tr>');
            return;
        }
        list.forEach(function (row) {
            $body.append(
                '<tr>' +
                '<td>' + escapeHtml(row.checklistName || '') + '</td>' +
                '<td>' + escapeHtml(row.siteName || '공통') + '</td>' +
                '<td>' + (row.commonYn === 'Y' ? '공통' : '현장별') + '</td>' +
                '<td>' + (row.itemCount || 0) + '</td>' +
                '<td>' + (row.useYn === 'Y' ? '사용' : '미사용') + '</td>' +
                '<td>' + (row.sortOrd || 0) + '</td>' +
                '<td><button type="button" class="btn btn-secondary btn-sm" onclick="loadChecklistDetail(' + row.checklistId + ')">상세</button></td>' +
                '</tr>'
            );
        });
    }

    function renderPagination(pageInfo) {
        var totalPages = pageInfo.totalPages || 1;
        var current = pageInfo.currentPage || 1;
        var html = '';
        for (var i = 1; i <= totalPages; i++) {
            var active = i === current ? 'btn-secondary' : 'btn-outline-secondary';
            html += '<button type="button" class="btn ' + active + ' btn-sm mx-1" onclick="loadChecklists(' + i + ')">' + i + '</button>';
        }
        $('#paginationZone').html(html);
    }

    function openPanel() {
        $('#checklistForm')[0].reset();
        $('#checklistId').val('');
        $('#commonYn').val('Y');
        $('#formUseYn').val('Y');
        $('#sortOrd').val('0');
        $('#itemTableBody').empty();
        addItemRow({ inputType: 'CHECK', requiredYn: 'N', useYn: 'Y', sortOrd: 1, optionValues: '양호,주의,불량' });
        $('#panelTitle').html('<b>체크리스트 추가</b>');
        $('#btnDelete').hide();
        $('#sidePanel').removeClass('hidden');
        $('#layout').addClass('panel-open');
    }

    function closePanel() {
        $('#sidePanel').addClass('hidden');
        $('#layout').removeClass('panel-open');
    }

    function loadChecklistDetail(checklistId) {
        $.ajax({
            url: '/admin/daily-checklists/' + checklistId,
            type: 'GET',
            dataType: 'json',
            success: function (res) {
                if (res.code !== '0000') {
                    showMsg('warning', '확인 필요', res.message || '체크리스트 정보를 찾을 수 없습니다.');
                    return;
                }
                var data = res.data || {};
                $('#checklistId').val(data.checklistId || '');
                $('#checklistName').val(data.checklistName || '');
                $('#formSiteCd').val(data.siteCd || '');
                $('#commonYn').val(data.commonYn || 'Y');
                $('#formUseYn').val(data.useYn || 'Y');
                $('#sortOrd').val(data.sortOrd || 0);
                $('#itemTableBody').empty();
                (data.items || []).forEach(function (item) { addItemRow(item); });
                if (!(data.items || []).length) {
                    addItemRow({ inputType: 'CHECK', requiredYn: 'N', useYn: 'Y', sortOrd: 1, optionValues: '양호,주의,불량' });
                }
                $('#panelTitle').html('<b>체크리스트 수정</b>');
                $('#btnDelete').show();
                $('#sidePanel').removeClass('hidden');
                $('#layout').addClass('panel-open');
            },
            error: function () { showMsg('error', '오류', '체크리스트 상세 조회 중 오류가 발생했습니다.'); }
        });
    }

    function addItemRow(item) {
        var index = $('#itemTableBody tr').length + 1;
        var row = item || {};
        var inputType = row.inputType || 'CHECK';
        var optionValues = row.optionValues || '';
        var requiredYn = row.requiredYn || 'N';
        var useYn = row.useYn || 'Y';
        var sortOrd = row.sortOrd || index;
        $('#itemTableBody').append(
            '<tr>' +
            '<td><input type="text" class="form-control form-control-a" name="itemName" value="' + escapeAttr(row.itemName || '') + '" placeholder="점검 항목명"></td>' +
            '<td>' + renderInputTypeSelect(inputType) + '</td>' +
            '<td><input type="text" class="form-control form-control-a" name="optionValues" value="' + escapeAttr(optionValues) + '" placeholder="예: 양호,주의,불량"></td>' +
            '<td><select name="requiredYn" class="form-select"><option value="N"' + selected(requiredYn, 'N') + '>선택</option><option value="Y"' + selected(requiredYn, 'Y') + '>필수</option></select></td>' +
            '<td><select name="itemUseYn" class="form-select"><option value="Y"' + selected(useYn, 'Y') + '>사용</option><option value="N"' + selected(useYn, 'N') + '>미사용</option></select></td>' +
            '<td><input type="number" class="form-control form-control-a" name="itemSortOrd" value="' + sortOrd + '" min="0"></td>' +
            '<td><button type="button" class="btn btn-secondary btn-sm" onclick="$(this).closest(\'tr\').remove();">삭제</button></td>' +
            '</tr>'
        );
    }

    function renderInputTypeSelect(value) {
        var html = '<select name="inputType" class="form-select">';
        html += '<option value="CHECK"' + selected(value, 'CHECK') + '>체크</option>';
        html += '<option value="TEXT"' + selected(value, 'TEXT') + '>텍스트</option>';
        html += '<option value="NUMBER"' + selected(value, 'NUMBER') + '>숫자</option>';
        html += '<option value="SELECT"' + selected(value, 'SELECT') + '>선택</option>';
        html += '</select>';
        return html;
    }

    function saveChecklist() {
        if (!$('#checklistName').val()) {
            showMsg('warning', '확인 필요', '체크리스트명을 입력해주세요.');
            return;
        }
        var hasItem = $('#itemTableBody input[name="itemName"]').filter(function () {
            return $(this).val().trim() !== '';
        }).length > 0;
        if (!hasItem) {
            showMsg('warning', '확인 필요', '점검 항목을 1개 이상 입력해주세요.');
            return;
        }
        $.ajax({
            url: '/admin/daily-checklists/save',
            type: 'POST',
            dataType: 'json',
            data: $('#checklistForm').serialize(),
            success: function (res) {
                if (res.code !== '0000') {
                    showMsg('warning', '확인 필요', res.message || '저장할 수 없습니다.');
                    return;
                }
                showSuccessSwal('저장되었습니다.');
                closePanel();
                loadChecklists(currentPage);
            },
            error: function () { showMsg('error', '오류', '체크리스트 저장 중 오류가 발생했습니다.'); }
        });
    }

    function deleteChecklist() {
        var checklistId = $('#checklistId').val();
        if (!checklistId) return;
        showConfirmSwal('삭제', '선택한 체크리스트를 미사용 처리할까요?').then(function (result) {
            if (!result.isConfirmed) return;
            $.ajax({
                url: '/admin/daily-checklists/delete',
                type: 'POST',
                dataType: 'json',
                data: { checklistId: checklistId },
                success: function (res) {
                    if (res.code !== '0000') {
                        showMsg('warning', '확인 필요', res.message || '삭제할 수 없습니다.');
                        return;
                    }
                    showSuccessSwal('삭제되었습니다.');
                    closePanel();
                    loadChecklists(currentPage);
                },
                error: function () { showMsg('error', '오류', '체크리스트 삭제 중 오류가 발생했습니다.'); }
            });
        });
    }

    function selected(current, expected) {
        return current === expected ? ' selected' : '';
    }

    function escapeHtml(value) {
        return String(value || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    function escapeAttr(value) {
        return escapeHtml(value).replace(/`/g, '&#096;');
    }
</script>
</html>
