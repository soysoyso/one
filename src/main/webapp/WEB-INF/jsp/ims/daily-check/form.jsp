<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%request.setAttribute("pageTitle", "일상점검 작성");%>
<%@include file="../common/head.jsp" %>
<%@include file="../common/header.jsp" %>

<body class="sub">
<div class="container">
    <form id="dailyCheckForm">
        <div class="card mb-3">
            <h5 class="fw-bold mb-3">일상점검</h5>
            <div class="mb-3">
                <label class="form-label">현장</label>
                <input type="text" class="form-control" value="${siteInfo.siteName}" readonly>
            </div>
            <div class="mb-3">
                <label class="form-label">점검일자</label>
                <input type="date" id="checkDate" name="checkDate" class="form-control" value="${today}">
            </div>
            <div class="mb-3">
                <label class="form-label">체크리스트</label>
                <select id="checklistId" name="checklistId" class="form-select">
                    <option value="">선택</option>
                    <c:forEach items="${checklistList}" var="checklist">
                        <option value="${checklist.checklistId}">${checklist.checklistName}</option>
                    </c:forEach>
                </select>
            </div>
        </div>

        <div id="itemCard" class="card mb-3" style="display:none;">
            <h5 class="fw-bold mb-3">점검 항목</h5>
            <div id="itemList"></div>
        </div>

        <div class="card mb-3">
            <label class="form-label">비고</label>
            <textarea id="remark" name="remark" class="form-control" rows="4"></textarea>
        </div>

        <div class="card mb-3">
            <h5 class="fw-bold mb-3">사진</h5>
            <div class="mb-3">
                <label class="form-label">점검 전 사진</label>
                <input type="file" id="beforePhotos" name="beforePhotos" class="form-control" accept="image/*" capture="environment" multiple>
            </div>
            <div class="mb-3">
                <label class="form-label">점검 후 사진</label>
                <input type="file" id="afterPhotos" name="afterPhotos" class="form-control" accept="image/*" capture="environment" multiple>
            </div>
        </div>

        <div class="d-grid gap-2 mb-4">
            <button type="button" id="btnSaveDailyCheck" class="btn btn-primary btn-lg">저장</button>
        </div>
    </form>
</div>
</body>

<script>
    $(document).ready(function () {
        $('#checklistId').on('change', function () {
            loadChecklistItems($(this).val());
        });

        $('#btnSaveDailyCheck').on('click', saveDailyCheck);
    });

    function loadChecklistItems(checklistId) {
        $('#itemList').empty();
        $('#itemCard').hide();
        if (!checklistId) {
            return;
        }

        $.ajax({
            url: '/manage/daily-checks/checklists/' + checklistId,
            type: 'GET',
            success: function (res) {
                if (res.code !== '0000') {
                    alert(res.message || '체크리스트를 불러올 수 없습니다.');
                    return;
                }
                renderItems((res.data && res.data.items) || []);
            },
            error: function () {
                alert('체크리스트 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function renderItems(items) {
        if (!items.length) {
            $('#itemList').html('<p class="text-muted mb-0">등록된 점검 항목이 없습니다.</p>');
            $('#itemCard').show();
            return;
        }

        items.forEach(function (item) {
            if (item.useYn !== 'Y') {
                return;
            }
            const required = item.requiredYn === 'Y' ? '<span class="text-danger">*</span>' : '';
            const html =
                '<div class="mb-3">' +
                '<label class="form-label fw-bold">' + escapeHtml(item.itemName || '') + required + '</label>' +
                renderInput(item) +
                '</div>';
            $('#itemList').append(html);
        });
        $('#itemCard').show();
    }

    function renderInput(item) {
        const name = 'itemValue_' + item.itemId;
        if (item.inputType === 'TEXT') {
            return '<textarea class="form-control" name="' + name + '" rows="3"></textarea>';
        }
        if (item.inputType === 'NUMBER') {
            return '<input type="number" class="form-control" name="' + name + '">';
        }
        if (item.inputType === 'SELECT') {
            return '<select class="form-select" name="' + name + '"><option value="">선택</option><option value="양호">양호</option><option value="조치필요">조치필요</option></select>';
        }
        return '<select class="form-select" name="' + name + '"><option value="">선택</option><option value="Y">양호</option><option value="N">조치필요</option></select>';
    }

    function saveDailyCheck() {
        if (!$('#checkDate').val()) {
            alert('점검일자를 입력해주세요.');
            return;
        }
        if (!$('#checklistId').val()) {
            alert('체크리스트를 선택해주세요.');
            return;
        }

        const formData = new FormData(document.getElementById('dailyCheckForm'));

        $.ajax({
            url: '/manage/daily-checks/save-with-photos',
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            success: function (res) {
                if (res.code !== '0000') {
                    alert(res.message || '저장할 수 없습니다.');
                    return;
                }
                alert('저장되었습니다.');
                location.href = '/manage';
            },
            error: function () {
                alert('저장 중 오류가 발생했습니다.');
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
