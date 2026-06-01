<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%request.setAttribute("pageTitle", "일상점검 이력");%>
<%@include file="../common/head.jsp" %>
<%@include file="../common/header.jsp" %>

<body class="sub">
<div class="container">
    <div class="card mb-3">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h5 class="fw-bold mb-1">일상점검 이력</h5>
                <div class="small text-muted">${siteInfo.siteName}</div>
            </div>
            <button type="button" class="btn btn-primary btn-sm" onclick="location.href='/manage/daily-checks/form'">점검 작성</button>
        </div>
        <div class="row g-2">
            <div class="col-6">
                <label class="form-label">시작일</label>
                <input type="date" id="startDate" class="form-control" value="${today}">
            </div>
            <div class="col-6">
                <label class="form-label">종료일</label>
                <input type="date" id="endDate" class="form-control" value="${today}">
            </div>
            <div class="col-12">
                <label class="form-label">검색어</label>
                <input type="text" id="keyword" class="form-control" placeholder="점검번호, 체크리스트명, 점검 대상">
            </div>
            <div class="col-12 d-grid">
                <button type="button" id="btnSearch" class="btn btn-outline-primary">조회</button>
            </div>
        </div>
    </div>

    <div id="historyList"></div>
    <div id="paginationZone" class="text-center my-3"></div>
</div>

<div class="modal fade" id="detailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">점검 상세</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
            </div>
            <div class="modal-body">
                <div id="detailInfo"></div>
                <h6 class="fw-bold mt-3">점검 항목</h6>
                <div id="detailItems"></div>
                <h6 class="fw-bold mt-3">사진</h6>
                <div id="detailPhotos" class="row g-2"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>
</body>

<script>
    var currentPage = 1;
    var detailModal = null;

    $(document).ready(function () {
        detailModal = new bootstrap.Modal(document.getElementById('detailModal'));
        loadDailyChecks(1);
        $('#btnSearch').on('click', function () { loadDailyChecks(1); });
        $('#keyword').on('keyup', function (e) { if (e.key === 'Enter') loadDailyChecks(1); });
    });

    function loadDailyChecks(page) {
        currentPage = page;
        $('#historyList').html('<div class="card text-muted">조회 중입니다...</div>');
        $.ajax({
            url: '/manage/daily-checks/data',
            type: 'GET',
            dataType: 'json',
            data: {
                page: page,
                startDate: $('#startDate').val(),
                endDate: $('#endDate').val(),
                keyword: $('#keyword').val()
            },
            success: function (res) {
                renderList(res.list || []);
                renderPagination(res.pageInfo || { currentPage: 1, totalPages: 1 });
            },
            error: function () {
                $('#historyList').html('<div class="card text-danger">일상점검 이력을 조회할 수 없습니다.</div>');
            }
        });
    }

    function renderList(list) {
        if (!list.length) {
            $('#historyList').html('<div class="card text-muted">조회된 일상점검 이력이 없습니다.</div>');
            return;
        }
        var html = '';
        list.forEach(function (row) {
            html += '<div class="card mb-2" onclick="loadDetail(' + row.checkId + ')">' +
                '<div class="d-flex justify-content-between gap-2">' +
                '<strong>' + escapeHtml(row.checkTitle || row.checklistName || '일상점검') + '</strong>' +
                '<span class="text-primary flex-shrink-0">' + escapeHtml(row.checkDate || '') + '</span>' +
                '</div>' +
                '<div class="small text-muted mt-1">' + escapeHtml(row.checklistName || '') + ' · ' + escapeHtml(row.checkNo || '') + '</div>' +
                '<div class="small mt-2">' + renderStatus(row.statusCd) + ' ' + escapeHtml(row.remark || '') + '</div>' +
                '</div>';
        });
        $('#historyList').html(html);
    }

    function renderStatus(statusCd) {
        if (statusCd === 'DONE') return '<span class="badge bg-success me-1">점검완료</span>';
        return '<span class="badge bg-secondary me-1">임시저장</span>';
    }

    function renderPagination(pageInfo) {
        var totalPages = pageInfo.totalPages || 1;
        var current = pageInfo.currentPage || 1;
        var html = '';
        for (var i = 1; i <= totalPages; i++) {
            var cls = i === current ? 'btn-primary' : 'btn-outline-primary';
            html += '<button type="button" class="btn ' + cls + ' btn-sm mx-1" onclick="loadDailyChecks(' + i + ')">' + i + '</button>';
        }
        $('#paginationZone').html(html);
    }

    function loadDetail(checkId) {
        $.ajax({
            url: '/manage/daily-checks/' + checkId,
            type: 'GET',
            dataType: 'json',
            success: function (res) {
                if (res.code !== '0000') {
                    alert(res.message || '상세 이력을 조회할 수 없습니다.');
                    return;
                }
                renderDetail(res.data || {});
                detailModal.show();
            },
            error: function () { alert('상세 이력 조회 중 오류가 발생했습니다.'); }
        });
    }

    function renderDetail(data) {
        $('#detailInfo').html(
            '<div class="border rounded p-2">' +
            '<div><strong>점검번호</strong> ' + escapeHtml(data.checkNo || '') + '</div>' +
            '<div><strong>점검일</strong> ' + escapeHtml(data.checkDate || '') + '</div>' +
            '<div><strong>점검대상</strong> ' + escapeHtml(data.checkTitle || '-') + '</div>' +
            '<div><strong>체크리스트</strong> ' + escapeHtml(data.checklistName || '') + '</div>' +
            '<div><strong>상태</strong> ' + (data.statusCd === 'DONE' ? '점검완료' : '임시저장') + '</div>' +
            '<div><strong>특이사항</strong> ' + escapeHtml(data.remark || '') + '</div>' +
            '</div>'
        );

        var items = data.items || [];
        if (!items.length) {
            $('#detailItems').html('<div class="text-muted">점검 항목이 없습니다.</div>');
        } else {
            var itemHtml = '';
            items.forEach(function (item) {
                itemHtml += '<div class="border rounded p-2 mb-2">' +
                    '<div class="fw-bold">' + escapeHtml(item.itemName || '') + '</div>' +
                    '<div class="text-primary">' + escapeHtml(item.checkValue || '-') + '</div>' +
                    (item.checkMemo ? '<div class="small text-muted mt-1">' + escapeHtml(item.checkMemo) + '</div>' : '') +
                    '</div>';
            });
            $('#detailItems').html(itemHtml);
        }

        var photos = data.photos || [];
        if (!photos.length) {
            $('#detailPhotos').html('<div class="col-12 text-muted">등록된 사진이 없습니다.</div>');
        } else {
            var photoHtml = '';
            photos.forEach(function (photo) {
                var label = photo.photoGb === 'AFTER' ? '점검 후' : '점검 전';
                photoHtml += '<div class="col-6"><div class="border rounded p-1">' +
                    '<div class="small fw-bold">' + label + '</div>' +
                    '<img src="/manage/daily-checks/photos/' + photo.photoId + '" style="width:100%;height:120px;object-fit:cover;">' +
                    '</div></div>';
            });
            $('#detailPhotos').html(photoHtml);
        }
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
