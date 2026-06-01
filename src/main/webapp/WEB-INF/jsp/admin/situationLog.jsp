<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<html>
<%@include file="./common/head.jsp"%>

<body>
<%@include file="./common/top.jsp"%>
<div id="layout">
    <div id="mainContent">
        <div class="container situation-admin">
            <div class="title">
                <div>
                    <h4><b>상황일지 관리</b></h4>
                    <button type="button" class="btn btn-dark" id="btnNewLedger" style="margin-left:5px">상황일지 작성</button>
                </div>
            </div>

            <div class="search-zone">
                <div class="row g-2 align-items-end">
                    <div class="col-12 col-md-2">
                        <label class="form-label">시작일</label>
                        <input type="date" id="startDate" class="form-control" value="${today}">
                    </div>
                    <div class="col-12 col-md-2">
                        <label class="form-label">종료일</label>
                        <input type="date" id="endDate" class="form-control" value="${today}">
                    </div>
                    <div class="col-12 col-md-2">
                        <label class="form-label">근무구분</label>
                        <select id="searchShiftCd" class="form-select">
                            <option value="">전체</option>
                            <c:forEach items="${shiftList}" var="shift">
                                <option value="${shift.cdCode}">${shift.cdCodeNm}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-12 col-md-2">
                        <label class="form-label">현장</label>
                        <select id="searchSiteCd" class="form-select">
                            <option value="">전체</option>
                            <c:forEach items="${siteList}" var="site">
                                <option value="${site.siteCd}">${site.siteName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-12 col-md-3">
                        <label class="form-label">키워드</label>
                        <input type="text" id="keyword" class="form-control" placeholder="제목, 내용, 작성자">
                    </div>
                    <div class="col-12 col-md-1">
                        <button type="button" class="btn btn-primary w-100" id="btnSearch">조회</button>
                    </div>
                </div>
            </div>

            <p id="situationCount">총 <b>0</b>개 일지</p>

            <div class="data-zone">
                <table class="table situation-group-table">
                    <thead>
                    <tr>
                        <th>일자</th>
                        <th>현장</th>
                        <th>등록건수</th>
                        <th>근무구분</th>
                        <th>마지막 상황</th>
                        <th>최종 작성자</th>
                        <th>관리</th>
                    </tr>
                    </thead>
                    <tbody id="situationGroupBody">
                    <tr id="loadingMsgRow" style="display:none;">
                        <td colspan="7" style="text-align:center; color:gray;">조회 중입니다...</td>
                    </tr>
                    </tbody>
                </table>
            </div>

            <div id="sidePanel" class="hidden situation-ledger-panel">
                <div class="offcanvas-header">
                    <h4><b id="panelTitle">상황일지 작성</b></h4>
                    <div>
                        <button type="button" class="btn btn-success" id="btnExportSituationDocx">DOCX 출력</button>
                        <button type="button" class="btn btn-secondary" id="btnClosePanel">닫기</button>
                    </div>
                </div>
                <div class="offcanvas-body pb-5">
                    <form id="situationForm">
                        <input type="hidden" id="situationId" name="situationId">
                        <input type="hidden" id="useYn" name="useYn" value="Y">

                        <div class="ledger-form">
                            <div class="row g-3">
                                <div class="col-12 col-md-3">
                                    <label class="form-label">일자</label>
                                    <input type="date" id="logDate" name="logDate" class="form-control" value="${today}">
                                </div>
                                <div class="col-12 col-md-3">
                                    <label class="form-label">시간</label>
                                    <input type="time" id="eventTime" name="eventTime" class="form-control">
                                </div>
                                <div class="col-12 col-md-3">
                                    <label class="form-label">근무구분</label>
                                    <select id="shiftCd" name="shiftCd" class="form-select">
                                        <c:forEach items="${shiftList}" var="shift">
                                            <option value="${shift.cdCode}">${shift.cdCodeNm}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-12 col-md-3">
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
                                    <input type="text" id="title" name="title" class="form-control" maxlength="200" placeholder="상황 제목을 입력하세요">
                                </div>
                                <div class="col-12">
                                    <label class="form-label">조치내용</label>
                                    <textarea id="content" name="content" class="form-control" rows="6" placeholder="상황실 운영, 민원 접수, 순찰 조치, TBM 등 일지 내용을 입력하세요"></textarea>
                                </div>
                            </div>
                            <div class="d-flex justify-content-end gap-2 mt-3">
                                <button type="button" class="btn btn-outline-secondary" id="btnResetSituation">신규 입력</button>
                                <button type="button" class="btn btn-primary" id="btnSaveSituation">수기 추가</button>
                            </div>
                        </div>
                    </form>

                    <div class="ledger-list-header">
                        <div>
                            <h5 class="fw-bold mb-1" id="ledgerTitle">${today} 상황일지</h5>
                            <div class="text-muted" id="ledgerSiteName">현장을 선택하세요</div>
                        </div>
                        <span class="badge bg-primary" id="ledgerCount">0건</span>
                    </div>
                    <div id="ledgerList" class="situation-ledger-list"></div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
<%@include file="./common/modal.jsp"%>
<%@include file="./common/script.jsp"%>

<style>
    .situation-admin .form-label {
        font-weight: 700;
    }
    .situation-group-table tbody tr.group-row {
        cursor: pointer;
    }
    .situation-group-table tbody tr.group-row:hover {
        background: #f6f9ff;
    }
    .situation-group-table .group-date {
        font-weight: 800;
        color: #111827;
    }
    .situation-group-table .shift-chip {
        display: inline-block;
        padding: 3px 8px;
        margin: 2px;
        border-radius: 999px;
        background: #eef4ff;
        color: #2563eb;
        font-size: 12px;
        font-weight: 700;
    }
    .situation-ledger-panel .ledger-form {
        border: 1px solid #e5e7eb;
        border-radius: 8px;
        padding: 16px;
        background: #fff;
        margin-bottom: 18px;
    }
    .ledger-list-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        padding: 14px 4px;
        border-bottom: 1px solid #e5e7eb;
    }
    .situation-ledger-list .ledger-row {
        display: grid;
        grid-template-columns: 76px 1fr 88px 108px;
        gap: 12px;
        align-items: start;
        padding: 15px 4px;
        border-bottom: 1px solid #eef1f5;
    }
    .situation-ledger-list .ledger-time {
        font-weight: 800;
        font-size: 18px;
        line-height: 1.15;
    }
    .situation-ledger-list .ledger-shift {
        margin-top: 4px;
        color: #2563eb;
        font-size: 13px;
        font-weight: 700;
    }
    .situation-ledger-list .ledger-title {
        font-weight: 800;
        margin-bottom: 5px;
        color: #111827;
    }
    .situation-ledger-list .ledger-content {
        white-space: pre-wrap;
        color: #566174;
        line-height: 1.45;
    }
    .situation-ledger-list .ledger-writer {
        font-weight: 700;
        color: #334155;
    }
    .situation-ledger-list .ledger-actions {
        display: flex;
        gap: 6px;
        justify-content: flex-end;
    }
</style>

<script>
    var currentGroups = [];
    var activeDate = '${today}';
    var activeSiteCd = '';
    var activeSiteName = '';

    $(document).ready(function () {
        setDefaultTime();
        loadSituationGroups();

        $('#btnSearch').on('click', loadSituationGroups);
        $('#keyword').on('keyup', function (e) {
            if (e.key === 'Enter') {
                loadSituationGroups();
            }
        });
        $('#btnNewLedger').on('click', function () {
            var siteCd = $('#searchSiteCd').val() || $('#siteCd option:eq(1)').val() || '';
            var siteName = $('#searchSiteCd option:selected').text();
            if (!siteCd) {
                siteName = $('#siteCd option:eq(1)').text() || '';
            }
            openLedger($('#startDate').val() || '${today}', siteCd, siteName);
        });
        $('#btnClosePanel').on('click', closePanel);
        $('#btnResetSituation').on('click', resetSituationForm);
        $('#btnSaveSituation').on('click', saveSituation);
        $('#btnExportSituationDocx').on('click', exportLedger);
        $('#logDate').on('change', function () {
            activeDate = $(this).val();
            loadLedger(activeDate, activeSiteCd);
        });
        $('#siteCd').on('change', function () {
            activeSiteCd = $(this).val();
            activeSiteName = $('#siteCd option:selected').text();
            loadLedger(activeDate, activeSiteCd);
        });
    });

    function loadSituationGroups() {
        $('#loadingMsgRow').show();
        $('#situationGroupBody').find('tr:not(#loadingMsgRow)').remove();
        $.ajax({
            url: '/admin/situation-logs/data',
            type: 'GET',
            dataType: 'json',
            data: {
                page: 1,
                pageSize: 100,
                startDate: $('#startDate').val(),
                endDate: $('#endDate').val(),
                shiftCd: $('#searchShiftCd').val(),
                siteCd: $('#searchSiteCd').val(),
                keyword: $('#keyword').val(),
                useYn: 'Y'
            },
            success: function (res) {
                currentGroups = groupByDateAndSite(res.list || []);
                renderGroups(currentGroups);
            },
            error: function () {
                alert('상황일지 목록 조회 중 오류가 발생했습니다.');
            },
            complete: function () {
                $('#loadingMsgRow').hide();
            }
        });
    }

    function groupByDateAndSite(list) {
        var map = {};
        list.forEach(function (row) {
            var key = (row.logDate || '') + '|' + (row.siteCd || '');
            if (!map[key]) {
                map[key] = {
                    logDate: row.logDate || '',
                    siteCd: row.siteCd || '',
                    siteName: row.siteName || row.siteCd || '',
                    count: 0,
                    shifts: {},
                    lastTime: '',
                    lastTitle: '',
                    lastWriter: '',
                    rows: []
                };
            }
            var group = map[key];
            group.count += 1;
            group.shifts[row.shiftNm || row.shiftCd || '구분없음'] = true;
            group.rows.push(row);
            if (!group.lastTime || String(row.eventTime || '') >= group.lastTime) {
                group.lastTime = row.eventTime || '';
                group.lastTitle = row.title || row.content || '';
                group.lastWriter = row.regNm || row.regId || '';
            }
        });
        return Object.keys(map).map(function (key) {
            var group = map[key];
            group.rows.sort(function (a, b) {
                return String(a.eventTime || '').localeCompare(String(b.eventTime || ''));
            });
            return group;
        }).sort(function (a, b) {
            if (a.logDate === b.logDate) return a.siteName.localeCompare(b.siteName);
            return b.logDate.localeCompare(a.logDate);
        });
    }

    function renderGroups(groups) {
        var $body = $('#situationGroupBody');
        $body.find('tr:not(#loadingMsgRow)').remove();
        $('#situationCount').html('총 <b>' + groups.length + '</b>개 일지');

        if (!groups.length) {
            $body.append('<tr><td colspan="7" style="text-align:center; color:gray;">조회된 상황일지가 없습니다.</td></tr>');
            return;
        }

        groups.forEach(function (group, index) {
            var shiftHtml = Object.keys(group.shifts).map(function (name) {
                return '<span class="shift-chip">' + escapeHtml(name) + '</span>';
            }).join('');
            $body.append(
                '<tr class="group-row" onclick="openGroup(' + index + ')">' +
                '<td><span class="group-date">' + escapeHtml(group.logDate) + '</span></td>' +
                '<td>' + escapeHtml(group.siteName) + '</td>' +
                '<td><b>' + group.count + '</b>건</td>' +
                '<td>' + shiftHtml + '</td>' +
                '<td style="text-align:left;">' + escapeHtml(group.lastTime + ' ' + group.lastTitle) + '</td>' +
                '<td>' + escapeHtml(group.lastWriter) + '</td>' +
                '<td>' +
                '<button type="button" class="btn btn-secondary btn-sm" onclick="event.stopPropagation(); openGroup(' + index + ')">상세</button> ' +
                '<button type="button" class="btn btn-success btn-sm" onclick="event.stopPropagation(); exportGroup(' + index + ')">출력</button>' +
                '</td>' +
                '</tr>'
            );
        });
    }

    function openGroup(index) {
        var group = currentGroups[index];
        if (!group) return;
        openLedger(group.logDate, group.siteCd, group.siteName);
    }

    function openLedger(logDate, siteCd, siteName) {
        activeDate = logDate || '${today}';
        activeSiteCd = siteCd || '';
        activeSiteName = siteName || '';
        $('#logDate').val(activeDate);
        $('#siteCd').val(activeSiteCd);
        $('#panelTitle').text(activeDate + ' 상황일지');
        $('#ledgerSiteName').text(activeSiteName || '현장을 선택하세요');
        resetSituationForm(false);
        $('#sidePanel').removeClass('hidden');
        $('#layout').addClass('panel-open');
        loadLedger(activeDate, activeSiteCd);
    }

    function closePanel() {
        $('#sidePanel').addClass('hidden');
        $('#layout').removeClass('panel-open');
        loadSituationGroups();
    }

    function loadLedger(logDate, siteCd) {
        activeDate = logDate || activeDate;
        activeSiteCd = siteCd || '';
        activeSiteName = $('#siteCd option:selected').text() || activeSiteName;
        $('#panelTitle').text(activeDate + ' 상황일지');
        $('#ledgerTitle').text(activeDate + ' 상황일지');
        $('#ledgerSiteName').text(activeSiteName || '현장을 선택하세요');
        $('#ledgerList').html('<div class="text-muted py-3">조회 중입니다...</div>');

        if (!activeSiteCd) {
            $('#ledgerCount').text('0건');
            $('#ledgerList').html('<div class="text-muted py-3">현장을 선택하면 해당 날짜의 상황일지가 표시됩니다.</div>');
            return;
        }

        $.ajax({
            url: '/admin/situation-logs/data',
            type: 'GET',
            dataType: 'json',
            data: {
                page: 1,
                pageSize: 100,
                startDate: activeDate,
                endDate: activeDate,
                siteCd: activeSiteCd,
                useYn: 'Y'
            },
            success: function (res) {
                var list = res.list || [];
                list.sort(function (a, b) {
                    return String(a.eventTime || '').localeCompare(String(b.eventTime || ''));
                });
                renderLedger(list);
            },
            error: function () {
                $('#ledgerList').html('<div class="text-danger py-3">상황일지를 조회할 수 없습니다.</div>');
            }
        });
    }

    function renderLedger(list) {
        $('#ledgerCount').text(list.length + '건');
        if (!list.length) {
            $('#ledgerList').html('<div class="text-muted py-3">해당 날짜에 등록된 상황이 없습니다. 상단에서 바로 추가할 수 있습니다.</div>');
            return;
        }

        var html = '';
        list.forEach(function (row) {
            html += '<div class="ledger-row">' +
                '<div><div class="ledger-time">' + escapeHtml(row.eventTime || '') + '</div><div class="ledger-shift">' + escapeHtml(row.shiftNm || row.shiftCd || '') + '</div></div>' +
                '<div><div class="ledger-title">' + escapeHtml(row.title || '제목 없음') + '</div><div class="ledger-content">' + escapeHtml(row.content || '') + '</div></div>' +
                '<div class="ledger-writer">' + escapeHtml(row.regNm || row.regId || '') + '</div>' +
                '<div class="ledger-actions">' +
                '<button type="button" class="btn btn-outline-secondary btn-sm" onclick="loadSituationDetail(' + row.situationId + ')">수정</button>' +
                '<button type="button" class="btn btn-outline-danger btn-sm" onclick="deleteSituation(' + row.situationId + ')">삭제</button>' +
                '</div>' +
                '</div>';
        });
        $('#ledgerList').html(html);
    }

    function setDefaultTime() {
        var now = new Date();
        $('#eventTime').val(String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0'));
    }

    function resetSituationForm(clearText) {
        $('#situationId').val('');
        $('#useYn').val('Y');
        $('#logDate').val(activeDate || '${today}');
        $('#siteCd').val(activeSiteCd || '');
        $('#shiftCd').val($('#shiftCd option:first').val());
        setDefaultTime();
        if (clearText !== false) {
            $('#title').val('');
            $('#content').val('');
        } else {
            $('#title').val('');
            $('#content').val('');
        }
        $('#btnSaveSituation').text('수기 추가');
    }

    function loadSituationDetail(situationId) {
        $.ajax({
            url: '/admin/situation-logs/' + situationId,
            type: 'GET',
            dataType: 'json',
            success: function (res) {
                if (res.code !== '0000') {
                    alert(res.message || '상황일지를 찾을 수 없습니다.');
                    return;
                }
                var data = res.data || {};
                $('#situationId').val(data.situationId || '');
                $('#logDate').val(data.logDate || activeDate);
                $('#shiftCd').val(data.shiftCd || $('#shiftCd option:first').val());
                $('#eventTime').val(data.eventTime || '');
                $('#siteCd').val(data.siteCd || activeSiteCd);
                $('#title').val(data.title || '');
                $('#content').val(data.content || '');
                $('#btnSaveSituation').text('수정 저장');
                activeDate = data.logDate || activeDate;
                activeSiteCd = data.siteCd || activeSiteCd;
            },
            error: function () {
                alert('상황일지 상세 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function saveSituation() {
        if (!$('#logDate').val()) {
            alert('일자를 입력하세요.');
            return;
        }
        if (!$('#siteCd').val()) {
            alert('현장을 선택하세요.');
            return;
        }
        if (!$('#eventTime').val()) {
            alert('시간을 입력하세요.');
            return;
        }
        if (!$('#content').val().trim()) {
            alert('조치내용을 입력하세요.');
            return;
        }

        $.ajax({
            url: '/admin/situation-logs/save',
            type: 'POST',
            dataType: 'json',
            data: $('#situationForm').serialize(),
            success: function (res) {
                if (res.code !== '0000') {
                    alert(res.message || '저장할 수 없습니다.');
                    return;
                }
                activeDate = $('#logDate').val();
                activeSiteCd = $('#siteCd').val();
                activeSiteName = $('#siteCd option:selected').text();
                resetSituationForm();
                loadLedger(activeDate, activeSiteCd);
            },
            error: function () {
                alert('상황일지 저장 중 오류가 발생했습니다.');
            }
        });
    }

    function deleteSituation(situationId) {
        if (!confirm('상황일지를 삭제하시겠습니까?')) return;
        $.ajax({
            url: '/admin/situation-logs/delete',
            type: 'POST',
            dataType: 'json',
            data: { situationId: situationId },
            success: function (res) {
                if (res.code !== '0000') {
                    alert(res.message || '삭제할 수 없습니다.');
                    return;
                }
                resetSituationForm();
                loadLedger(activeDate, activeSiteCd);
            },
            error: function () {
                alert('상황일지 삭제 중 오류가 발생했습니다.');
            }
        });
    }

    function exportGroup(index) {
        var group = currentGroups[index];
        if (!group) return;
        location.href = buildExportUrl(group.logDate, group.siteCd);
    }

    function exportLedger() {
        if (!activeDate || !activeSiteCd) {
            alert('출력할 일자와 현장을 선택하세요.');
            return;
        }
        location.href = buildExportUrl(activeDate, activeSiteCd);
    }

    function buildExportUrl(logDate, siteCd) {
        return '/admin/situation-logs/export?' + $.param({
            startDate: logDate,
            endDate: logDate,
            siteCd: siteCd,
            format: 'docx'
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
