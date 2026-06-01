<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%request.setAttribute("pageTitle", "상황일지");%>
<%@include file="../common/head.jsp" %>
<%@include file="../common/header.jsp" %>

<body class="sub">
<div class="container situation-page">
    <div class="card mb-3">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="fw-bold mb-0">상황일지 작성</h5>
            <button type="button" id="btnExport" class="btn btn-success btn-sm">상황일지 출력</button>
        </div>

        <form id="situationForm">
            <input type="hidden" id="situationId" name="situationId">
            <input type="hidden" id="useYn" name="useYn" value="Y">

            <div class="row g-2">
                <div class="col-6">
                    <label class="form-label">일자</label>
                    <input type="date" id="logDate" name="logDate" class="form-control" value="${today}">
                </div>
                <div class="col-6">
                    <label class="form-label">시간</label>
                    <input type="time" id="eventTime" name="eventTime" class="form-control">
                </div>
                <div class="col-6">
                    <label class="form-label">근무구분</label>
                    <select id="shiftCd" name="shiftCd" class="form-select">
                        <c:forEach items="${shiftList}" var="shift">
                            <option value="${shift.cdCode}">${shift.cdCodeNm}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-6">
                    <label class="form-label">작성자</label>
                    <input type="text" class="form-control" value="${sessionScope.session.userName}" readonly>
                </div>
                <div class="col-12">
                    <label class="form-label">제목</label>
                    <input type="text" id="title" name="title" class="form-control" maxlength="200" placeholder="상황 제목을 입력하세요">
                </div>
                <div class="col-12">
                    <label class="form-label">조치내용</label>
                    <textarea id="content" name="content" class="form-control" rows="5" placeholder="상황실 운영, 민원 접수, 순찰 조치, TBM 등 일지 내용을 입력하세요"></textarea>
                </div>
            </div>

            <div class="d-flex gap-2 mt-3">
                <button type="button" id="btnReset" class="btn btn-outline-secondary flex-fill">신규 입력</button>
                <button type="button" id="btnSave" class="btn btn-primary flex-fill">수기 추가</button>
            </div>
        </form>
    </div>

    <div class="card mb-3">
        <div class="d-flex justify-content-between align-items-end gap-2">
            <div class="flex-fill">
                <label class="form-label">조회 일자</label>
                <input type="date" id="selectedDate" class="form-control" value="${today}">
            </div>
            <button type="button" id="btnToday" class="btn btn-outline-primary">오늘</button>
        </div>
    </div>

    <div class="card">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <div>
                <h6 class="fw-bold mb-0" id="ledgerTitle">${today} 상황일지</h6>
                <div class="small text-muted">${siteInfo.siteName}</div>
            </div>
            <span class="badge bg-primary" id="ledgerCount">0건</span>
        </div>
        <div id="situationList" class="situation-ledger"></div>
    </div>
</div>
</body>

<style>
    .situation-page .form-label {
        font-weight: 700;
        font-size: 0.9rem;
    }
    .situation-ledger .ledger-row {
        display: grid;
        grid-template-columns: 72px 1fr auto;
        gap: 10px;
        padding: 14px 0;
        border-top: 1px solid #edf0f4;
        align-items: start;
    }
    .situation-ledger .ledger-row:first-child {
        border-top: 0;
    }
    .situation-ledger .ledger-time {
        font-weight: 800;
        font-size: 1.05rem;
        line-height: 1.2;
    }
    .situation-ledger .ledger-shift {
        color: #2563eb;
        font-size: 0.85rem;
        margin-top: 4px;
    }
    .situation-ledger .ledger-title {
        font-weight: 800;
        margin-bottom: 4px;
        word-break: keep-all;
    }
    .situation-ledger .ledger-content {
        color: #556070;
        font-size: 0.92rem;
        white-space: pre-wrap;
    }
    .situation-ledger .ledger-writer {
        min-width: 52px;
        text-align: right;
        font-weight: 700;
        color: #334155;
    }
    .situation-ledger .ledger-actions {
        grid-column: 2 / 4;
        display: flex;
        justify-content: flex-end;
        gap: 6px;
    }
    @media (max-width: 420px) {
        .situation-ledger .ledger-row {
            grid-template-columns: 58px 1fr;
        }
        .situation-ledger .ledger-writer {
            grid-column: 2;
            text-align: left;
            font-size: 0.85rem;
        }
        .situation-ledger .ledger-actions {
            grid-column: 1 / 3;
        }
    }
</style>

<script>
    $(document).ready(function () {
        setDefaultTime();
        loadDay();

        $('#selectedDate').on('change', function () {
            $('#logDate').val(this.value);
            loadDay();
        });
        $('#logDate').on('change', function () {
            $('#selectedDate').val(this.value);
            loadDay();
        });
        $('#btnToday').on('click', function () {
            $('#selectedDate').val('${today}');
            $('#logDate').val('${today}');
            loadDay();
        });
        $('#btnReset').on('click', resetForm);
        $('#btnSave').on('click', saveSituation);
        $('#btnExport').on('click', exportDay);
    });

    function setDefaultTime() {
        var now = new Date();
        var hh = String(now.getHours()).padStart(2, '0');
        var mm = String(now.getMinutes()).padStart(2, '0');
        $('#eventTime').val(hh + ':' + mm);
    }

    function loadDay() {
        var day = $('#selectedDate').val();
        $('#ledgerTitle').text(day + ' 상황일지');
        $('#situationList').html('<div class="text-muted py-3">조회 중입니다...</div>');
        $.ajax({
            url: '/manage/situation-logs/data',
            type: 'GET',
            dataType: 'json',
            data: {
                page: 1,
                pageSize: 100,
                startDate: day,
                endDate: day
            },
            success: function (res) {
                var list = res.list || [];
                list.sort(function (a, b) {
                    return String(a.eventTime || '').localeCompare(String(b.eventTime || ''));
                });
                renderLedger(list);
            },
            error: function () {
                $('#situationList').html('<div class="text-danger py-3">상황일지를 조회할 수 없습니다.</div>');
            }
        });
    }

    function renderLedger(list) {
        $('#ledgerCount').text(list.length + '건');
        if (!list.length) {
            $('#situationList').html('<div class="text-muted py-3">해당 일자의 상황일지가 없습니다.</div>');
            return;
        }
        var html = '';
        list.forEach(function (row) {
            html += '<div class="ledger-row">' +
                '<div><div class="ledger-time">' + escapeHtml(row.eventTime || '') + '</div><div class="ledger-shift">' + escapeHtml(row.shiftNm || row.shiftCd || '') + '</div></div>' +
                '<div><div class="ledger-title">' + escapeHtml(row.title || '제목 없음') + '</div><div class="ledger-content">' + escapeHtml(row.content || '') + '</div></div>' +
                '<div class="ledger-writer">' + escapeHtml(row.regNm || row.regId || '') + '</div>' +
                '<div class="ledger-actions">' +
                '<button type="button" class="btn btn-outline-secondary btn-sm" onclick="loadDetail(' + row.situationId + ')">수정</button>' +
                '<button type="button" class="btn btn-outline-danger btn-sm" onclick="deleteSituation(' + row.situationId + ')">삭제</button>' +
                '</div>' +
                '</div>';
        });
        $('#situationList').html(html);
    }

    function resetForm() {
        $('#situationId').val('');
        $('#title').val('');
        $('#content').val('');
        $('#shiftCd').val($('#shiftCd option:first').val());
        $('#logDate').val($('#selectedDate').val());
        setDefaultTime();
        $('#btnSave').text('수기 추가');
    }

    function loadDetail(situationId) {
        $.ajax({
            url: '/manage/situation-logs/' + situationId,
            type: 'GET',
            dataType: 'json',
            success: function (res) {
                if (res.code !== '0000') {
                    alert(res.message || '상황일지를 찾을 수 없습니다.');
                    return;
                }
                var data = res.data || {};
                $('#situationId').val(data.situationId || '');
                $('#logDate').val(data.logDate || $('#selectedDate').val());
                $('#selectedDate').val(data.logDate || $('#selectedDate').val());
                $('#shiftCd').val(data.shiftCd || $('#shiftCd option:first').val());
                $('#eventTime').val(data.eventTime || '');
                $('#title').val(data.title || '');
                $('#content').val(data.content || '');
                $('#btnSave').text('수정 저장');
                window.scrollTo({ top: 0, behavior: 'smooth' });
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
        if (!$('#eventTime').val()) {
            alert('시간을 입력하세요.');
            return;
        }
        if (!$('#content').val().trim()) {
            alert('조치내용을 입력하세요.');
            return;
        }
        $.ajax({
            url: '/manage/situation-logs/save',
            type: 'POST',
            dataType: 'json',
            data: $('#situationForm').serialize(),
            success: function (res) {
                if (res.code !== '0000') {
                    alert(res.message || '저장할 수 없습니다.');
                    return;
                }
                $('#selectedDate').val($('#logDate').val());
                resetForm();
                loadDay();
            },
            error: function () {
                alert('상황일지 저장 중 오류가 발생했습니다.');
            }
        });
    }

    function deleteSituation(situationId) {
        if (!confirm('상황일지를 삭제하시겠습니까?')) return;
        $.ajax({
            url: '/manage/situation-logs/delete',
            type: 'POST',
            dataType: 'json',
            data: { situationId: situationId },
            success: function (res) {
                if (res.code !== '0000') {
                    alert(res.message || '삭제할 수 없습니다.');
                    return;
                }
                resetForm();
                loadDay();
            },
            error: function () {
                alert('상황일지 삭제 중 오류가 발생했습니다.');
            }
        });
    }

    function exportDay() {
        var day = $('#selectedDate').val();
        location.href = '/manage/situation-logs/export?' + $.param({
            startDate: day,
            endDate: day,
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
