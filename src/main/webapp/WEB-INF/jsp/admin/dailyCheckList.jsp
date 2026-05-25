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
                    <h4><b>일상점검 관리</b></h4>
                    <a href="/admin/daily-checklists/setting" class="btn btn-dark" style="margin-left:5px">체크리스트 설정</a>
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
                    <div class="col-3">
                        <label class="form-label">현장</label>
                        <select id="siteCd" class="form-select">
                            <option value="">전체</option>
                            <c:forEach items="${siteList}" var="site">
                                <option value="${site.siteCd}">${site.siteName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-3">
                        <label class="form-label">키워드</label>
                        <input type="text" id="keyword" class="form-control" placeholder="점검번호, 체크리스트, 작성자">
                    </div>
                    <div class="col-1">
                        <button type="button" class="btn btn-primary w-100" id="btnSearch">조회</button>
                    </div>
                </div>
            </div>

            <div style="display:flex!important; justify-content:space-between; align-items:center;">
                <p id="dailyCheckCount">총 <b>0</b>건</p>
            </div>

            <div class="data-zone">
                <table class="table">
                    <thead>
                    <tr>
                        <th>점검일자</th>
                        <th>점검번호</th>
                        <th>체크리스트</th>
                        <th>현장</th>
                        <th>작성자</th>
                        <th>등록일시</th>
                        <th>관리</th>
                    </tr>
                    </thead>
                    <tbody id="dailyCheckTableBody">
                    <tr id="loadingMsgRow" style="display:none;">
                        <td colspan="7" style="text-align:center; color:gray;">조회 중입니다...</td>
                    </tr>
                    </tbody>
                </table>
                <div id="paginationZone" class="text-center mt-3"></div>
            </div>

            <div id="sidePanel" class="hidden">
                <div class="offcanvas-header">
                    <h4><b>일상점검 상세</b></h4>
                    <div>
                        <button type="button" class="btn btn-secondary" id="btnClosePanel">창닫기</button>
                    </div>
                </div>
                <div class="offcanvas-body pb-5">
                    <h5 class="mb-3 fw-bold">기본정보</h5>
                    <table class="table">
                        <tbody id="detailInfoBody"></tbody>
                    </table>

                    <div class="mt-4" style="border-top:1px dotted #9f9f9f; padding-top:25px;">
                        <h5 class="mb-3 fw-bold">점검 항목</h5>
                        <table class="table">
                            <thead>
                            <tr>
                                <th>항목</th>
                                <th>입력값</th>
                                <th>필수</th>
                            </tr>
                            </thead>
                            <tbody id="detailItemBody"></tbody>
                        </table>
                    </div>
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
        loadDailyChecks(1);

        $('#btnSearch').on('click', function () {
            loadDailyChecks(1);
        });

        $('#keyword').on('keyup', function (e) {
            if (e.key === 'Enter') {
                loadDailyChecks(1);
            }
        });

        $('#btnClosePanel').on('click', function () {
            $('#sidePanel').addClass('hidden');
        });
    });

    function loadDailyChecks(page) {
        currentPage = page;
        $('#loadingMsgRow').show();

        $.ajax({
            url: '/admin/daily-checks/data',
            type: 'GET',
            data: {
                page: page,
                startDate: $('#startDate').val(),
                endDate: $('#endDate').val(),
                siteCd: $('#siteCd').val(),
                keyword: $('#keyword').val()
            },
            success: function (res) {
                renderDailyCheckRows(res.list || []);
                renderPagination(res.pageInfo || { currentPage: 1, totalPages: 1 });
                $('#dailyCheckCount').html('총 <b>' + (res.totalCount || 0) + '</b>건');
            },
            error: function () {
                showMsg('error', '오류', '일상점검 목록 조회 중 오류가 발생했습니다.');
            },
            complete: function () {
                $('#loadingMsgRow').hide();
            }
        });
    }

    function renderDailyCheckRows(list) {
        const $body = $('#dailyCheckTableBody');
        $body.find('tr:not(#loadingMsgRow)').remove();

        if (!list.length) {
            $body.append('<tr><td colspan="7" style="text-align:center; color:gray;">조회된 일상점검이 없습니다.</td></tr>');
            return;
        }

        list.forEach(function (row) {
            $body.append(
                '<tr>' +
                '<td>' + escapeHtml(row.checkDate || '') + '</td>' +
                '<td>' + escapeHtml(row.checkNo || '') + '</td>' +
                '<td>' + escapeHtml(row.checklistName || '') + '</td>' +
                '<td>' + escapeHtml(row.siteName || row.siteCd || '') + '</td>' +
                '<td>' + escapeHtml(row.writerNm || row.writerId || '') + '</td>' +
                '<td>' + escapeHtml(row.regDt || '') + '</td>' +
                '<td><button type="button" class="btn btn-secondary btn-sm" onclick="loadDailyCheckDetail(' + row.checkId + ')">상세</button></td>' +
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
            html += '<button type="button" class="btn ' + active + ' btn-sm mx-1" onclick="loadDailyChecks(' + i + ')">' + i + '</button>';
        }
        $('#paginationZone').html(html);
    }

    function loadDailyCheckDetail(checkId) {
        $.ajax({
            url: '/admin/daily-checks/' + checkId,
            type: 'GET',
            success: function (res) {
                if (res.code !== '0000') {
                    showMsg('warning', '확인 필요', res.message || '일상점검 정보를 찾을 수 없습니다.');
                    return;
                }
                renderDetail(res.data || {});
                $('#sidePanel').removeClass('hidden');
            },
            error: function () {
                showMsg('error', '오류', '일상점검 상세 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function renderDetail(data) {
        $('#detailInfoBody').html(
            '<tr><th>점검번호</th><td>' + escapeHtml(data.checkNo || '') + '</td></tr>' +
            '<tr><th>점검일자</th><td>' + escapeHtml(data.checkDate || '') + '</td></tr>' +
            '<tr><th>체크리스트</th><td>' + escapeHtml(data.checklistName || '') + '</td></tr>' +
            '<tr><th>현장</th><td>' + escapeHtml(data.siteName || data.siteCd || '') + '</td></tr>' +
            '<tr><th>작성자</th><td>' + escapeHtml(data.writerNm || data.writerId || '') + '</td></tr>' +
            '<tr><th>비고</th><td>' + escapeHtml(data.remark || '') + '</td></tr>'
        );

        const items = data.items || [];
        $('#detailItemBody').empty();
        if (!items.length) {
            $('#detailItemBody').append('<tr><td colspan="3" style="text-align:center; color:gray;">점검 항목이 없습니다.</td></tr>');
            return;
        }
        items.forEach(function (item) {
            $('#detailItemBody').append(
                '<tr>' +
                '<td>' + escapeHtml(item.itemName || '') + '</td>' +
                '<td>' + formatValue(item) + '</td>' +
                '<td>' + (item.requiredYn === 'Y' ? '필수' : '선택') + '</td>' +
                '</tr>'
            );
        });
    }

    function formatValue(item) {
        const value = item.checkValue || '';
        if (item.inputType === 'CHECK') {
            if (value === 'Y') return '양호';
            if (value === 'N') return '조치필요';
        }
        return escapeHtml(value);
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
