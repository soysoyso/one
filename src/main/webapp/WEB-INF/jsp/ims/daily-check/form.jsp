<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%request.setAttribute("pageTitle", "일상점검 작성");%>
<%@include file="../common/head.jsp" %>
<%@include file="../common/header.jsp" %>

<style>
    .daily-check-shell { padding-bottom: 92px; }
    .check-card { border: 1px solid #e6eaf2; border-radius: 8px; padding: 14px; background: #fff; }
    .quick-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; }
    .quick-option {
        border: 1px solid #d9e2f1;
        border-radius: 8px;
        background: #fff;
        color: #2563eb;
        font-weight: 700;
        min-height: 42px;
    }
    .quick-option.active[data-value="정상"], .quick-option.active[data-value="양호"] {
        border-color: #22c55e;
        background: #dcfce7;
        color: #15803d;
    }
    .quick-option.active[data-value="이상"], .quick-option.active[data-value="불량"] {
        border-color: #fb7185;
        background: #ffe4e6;
        color: #be123c;
    }
    .quick-option.active[data-value="확인 필요"], .quick-option.active[data-value="주의"], .quick-option.active[data-value="조치필요"] {
        border-color: #f59e0b;
        background: #fef3c7;
        color: #b45309;
    }
    .item-memo { display: none; margin-top: 10px; }
    .item-memo.active { display: block; }
    .sticky-actions {
        position: fixed;
        left: 0;
        right: 0;
        bottom: 0;
        z-index: 50;
        background: rgba(255,255,255,.96);
        border-top: 1px solid #e5e7eb;
        padding: 10px 14px max(10px, env(safe-area-inset-bottom));
    }
</style>

<body class="sub">
<div class="container daily-check-shell">
    <form id="dailyCheckForm">
        <input type="hidden" id="statusCd" name="statusCd" value="SAVED">

        <div class="card mb-3">
            <div class="d-flex justify-content-between align-items-start gap-2 mb-3">
                <div>
                    <h5 class="fw-bold mb-1">일상점검</h5>
                    <div class="small text-muted">${siteInfo.siteName}</div>
                </div>
                <button type="button" class="btn btn-outline-primary btn-sm" onclick="location.href='/manage/daily-checks'">점검이력</button>
            </div>

            <div class="mb-3">
                <label class="form-label">점검일</label>
                <input type="date" id="checkDate" name="checkDate" class="form-control" value="${today}">
            </div>

            <div class="mb-3">
                <label class="form-label">체크리스트 유형</label>
                <select id="checklistId" name="checklistId" class="form-select">
                    <option value="">선택</option>
                    <c:forEach items="${checklistList}" var="checklist">
                        <option value="${checklist.checklistId}">${checklist.checklistName}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="mb-0">
                <label class="form-label">점검 대상/타이틀</label>
                <input type="text" id="checkTitle" name="checkTitle" class="form-control"
                       placeholder="예: 1교량 상행, 지하차도 A구간, 3번 교량">
                <div class="form-text">동일한 체크리스트를 하루에 여러 번 사용할 때 구분되는 이름입니다.</div>
            </div>
        </div>

        <div id="itemCard" class="card mb-3" style="display:none;">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold mb-0">점검 항목</h5>
                <span id="itemCount" class="badge bg-primary"></span>
            </div>
            <div id="itemList" class="d-grid gap-2"></div>
        </div>

        <div class="card mb-3">
            <label class="form-label">특이사항</label>
            <textarea id="remark" name="remark" class="form-control" rows="4" placeholder="현장 특이사항이 있으면 입력하세요"></textarea>
        </div>

        <div class="card mb-3">
            <h5 class="fw-bold mb-3">사진</h5>
            <div class="mb-3">
                <label class="form-label">점검 전 사진</label>
                <input type="file" id="beforePhotos" name="beforePhotos" class="form-control" accept="image/*" capture="environment" multiple>
            </div>
            <div class="mb-0">
                <label class="form-label">점검 후 사진</label>
                <input type="file" id="afterPhotos" name="afterPhotos" class="form-control" accept="image/*" capture="environment" multiple>
            </div>
        </div>
    </form>
</div>

<div class="sticky-actions">
    <div class="container p-0">
        <div class="d-grid gap-2" style="grid-template-columns: 1fr 1fr;">
            <button type="button" id="btnDraftDailyCheck" class="btn btn-outline-primary btn-lg">임시저장</button>
            <button type="button" id="btnDoneDailyCheck" class="btn btn-primary btn-lg">점검 완료</button>
        </div>
    </div>
</div>
</body>

<script>
    $(document).ready(function () {
        $('#checklistId').on('change', function () {
            loadChecklistItems($(this).val());
        });
        $('#btnDraftDailyCheck').on('click', function () { saveDailyCheck('SAVED'); });
        $('#btnDoneDailyCheck').on('click', function () { saveDailyCheck('DONE'); });
    });

    function loadChecklistItems(checklistId) {
        $('#itemList').empty();
        $('#itemCount').text('');
        $('#itemCard').hide();
        if (!checklistId) return;

        $.ajax({
            url: '/manage/daily-checks/checklists/' + checklistId,
            type: 'GET',
            dataType: 'json',
            success: function (res) {
                if (res.code !== '0000') {
                    alert(res.message || '체크리스트를 불러올 수 없습니다.');
                    return;
                }
                renderItems((res.data && res.data.items) || []);
            },
            error: function () { alert('체크리스트 조회 중 오류가 발생했습니다.'); }
        });
    }

    function renderItems(items) {
        var visibleItems = items.filter(function (item) { return item.useYn === 'Y'; });
        if (!visibleItems.length) {
            $('#itemList').html('<p class="text-muted mb-0">등록된 점검 항목이 없습니다.</p>');
            $('#itemCard').show();
            return;
        }

        visibleItems.forEach(function (item) {
            $('#itemList').append(renderItemCard(item));
        });
        $('#itemCount').text(visibleItems.length + '개');
        $('#itemCard').show();
    }

    function renderItemCard(item) {
        var name = 'itemValue_' + item.itemId;
        var memoName = 'itemMemo_' + item.itemId;
        var required = item.requiredYn === 'Y' ? '<span class="text-danger">*</span>' : '';
        var input = renderInput(item, name);

        return '<div class="check-card" data-item-id="' + item.itemId + '">' +
            '<div class="fw-bold mb-2">' + escapeHtml(item.itemName || '') + required + '</div>' +
            input +
            '<textarea class="form-control item-memo" name="' + memoName + '" rows="2" placeholder="확인 필요 또는 이상 사유를 입력하세요"></textarea>' +
            '</div>';
    }

    function renderInput(item, name) {
        if (item.inputType === 'TEXT') {
            return '<textarea class="form-control" name="' + name + '" rows="3" placeholder="내용을 입력하세요"></textarea>';
        }
        if (item.inputType === 'NUMBER') {
            return '<input type="number" class="form-control" name="' + name + '" placeholder="숫자를 입력하세요">';
        }
        return renderQuickOptions(name, item.optionValues);
    }

    function renderQuickOptions(name, optionValues) {
        var options = normalizeStatusOptions(parseOptions(optionValues));
        var html = '<input type="hidden" name="' + name + '" value="">' +
            '<div class="quick-grid">';
        options.forEach(function (option) {
            html += '<button type="button" class="quick-option" data-name="' + name + '" data-value="' + escapeAttr(option) + '">' + escapeHtml(option) + '</button>';
        });
        html += '</div>';
        return html;
    }

    function normalizeStatusOptions(options) {
        if (!options.length) return ['정상', '이상', '확인 필요'];
        var mapped = options.map(function (option) {
            if (option === '양호') return '정상';
            if (option === '불량') return '이상';
            if (option === '주의' || option === '조치필요' || option === '점검필요' || option === '고장') return '확인 필요';
            return option;
        });
        var result = ['정상', '이상', '확인 필요'];
        mapped.forEach(function (option) {
            if (result.indexOf(option) < 0) result.push(option);
        });
        return result.slice(0, 4);
    }

    $(document).on('click', '.quick-option', function () {
        var $button = $(this);
        var name = $button.data('name');
        var value = String($button.data('value') || '');
        var $card = $button.closest('.check-card');
        $card.find('input[name="' + name + '"]').val(value);
        $card.find('.quick-option[data-name="' + name + '"]').removeClass('active');
        $button.addClass('active');
        $card.find('.item-memo').toggleClass('active', value !== '정상' && value !== '양호');
    });

    function parseOptions(optionValues) {
        return String(optionValues || '')
            .split(/[,|\n]/)
            .map(function (value) { return value.trim(); })
            .filter(function (value) { return value !== ''; });
    }

    function saveDailyCheck(statusCd) {
        if (!$('#checkDate').val()) {
            alert('점검일을 입력하세요.');
            return;
        }
        if (!$('#checklistId').val()) {
            alert('체크리스트 유형을 선택하세요.');
            return;
        }
        if (!$('#checkTitle').val().trim()) {
            alert('점검 대상/타이틀을 입력하세요.');
            $('#checkTitle').focus();
            return;
        }

        $('#statusCd').val(statusCd);
        var formData = new FormData(document.getElementById('dailyCheckForm'));
        $.ajax({
            url: '/manage/daily-checks/save-with-photos',
            type: 'POST',
            dataType: 'json',
            data: formData,
            processData: false,
            contentType: false,
            success: function (res) {
                if (res.code !== '0000') {
                    alert(res.message || '저장할 수 없습니다.');
                    return;
                }
                alert(statusCd === 'DONE' ? '점검 완료되었습니다.' : '임시저장되었습니다.');
                location.href = '/manage/daily-checks';
            },
            error: function () { alert('저장 중 오류가 발생했습니다.'); }
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

    function escapeAttr(value) {
        return escapeHtml(value).replace(/`/g, '&#096;');
    }
</script>
</html>
