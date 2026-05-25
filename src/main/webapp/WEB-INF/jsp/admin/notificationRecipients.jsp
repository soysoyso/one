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
                    <h4><b>알림톡 수신자 설정</b></h4>
                    <button type="button" class="btn btn-dark" style="margin-left:5px" id="btnAddRecipient">수신자 추가</button>
                    <a href="/admin/user/setting" class="btn btn-secondary" style="margin-left:5px">관리자 설정</a>
                </div>
            </div>

            <div class="search-zone">
                <div class="row g-2 align-items-end">
                    <div class="col-3">
                        <label class="form-label">키워드</label>
                        <input type="text" id="keyword" class="form-control" placeholder="이름, 전화번호, 아이디">
                    </div>
                    <div class="col-2">
                        <label class="form-label">알림 유형</label>
                        <select id="notificationType" class="form-select">
                            <option value="">전체</option>
                            <c:forEach items="${notificationTypeList}" var="type">
                                <option value="${type.cdCode}">${type.cdCodeNm}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-3">
                        <label class="form-label">관리대상</label>
                        <select id="siteCd" class="form-select">
                            <option value="">전체</option>
                            <c:forEach items="${siteList}" var="site">
                                <option value="${site.siteCd}">${site.siteName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-2">
                        <label class="form-label">사용 여부</label>
                        <select id="useYn" class="form-select">
                            <option value="Y">사용</option>
                            <option value="">전체</option>
                            <option value="N">미사용</option>
                        </select>
                    </div>
                    <div class="col-1">
                        <button type="button" class="btn btn-primary w-100" id="btnSearch">조회</button>
                    </div>
                </div>
            </div>

            <div style="display:flex!important; justify-content:space-between; align-items:center;">
                <p id="recipientCount">총 <b>0</b>건</p>
            </div>

            <div class="data-zone">
                <table class="table">
                    <thead>
                    <tr>
                        <th>알림 유형</th>
                        <th>수신자</th>
                        <th>전화번호</th>
                        <th>관리대상</th>
                        <th>사용 여부</th>
                        <th>순서</th>
                        <th>관리</th>
                    </tr>
                    </thead>
                    <tbody id="recipientTableBody">
                    <tr id="loadingMsgRow" style="display:none;">
                        <td colspan="7" style="text-align:center; color:gray;">조회 중입니다...</td>
                    </tr>
                    </tbody>
                </table>
                <div id="paginationZone" class="text-center mt-3"></div>
            </div>

            <div id="sidePanel" class="hidden">
                <form id="recipientForm" name="recipientForm">
                    <input type="hidden" id="recipientId" name="recipientId">
                    <div class="offcanvas-header">
                        <h4 id="panelTitle"><b>수신자 추가</b></h4>
                        <div>
                            <button type="button" class="btn btn-primary" id="btnSave">저장</button>
                            <button type="button" class="btn bg-danger" id="btnDelete">삭제</button>
                            <button type="button" class="btn btn-secondary" id="btnClosePanel">창닫기</button>
                        </div>
                    </div>
                    <div class="offcanvas-body pb-5">
                        <h5 class="mb-3 fw-bold">공통</h5>
                        <div class="row my-2">
                            <div class="col-6 mb-3">
                                <label class="form-label">알림 유형</label>
                                <select id="formNotificationType" name="notificationType" class="form-select">
                                    <option value="">선택</option>
                                    <c:forEach items="${notificationTypeList}" var="type">
                                        <option value="${type.cdCode}">${type.cdCodeNm}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-6 mb-3">
                                <label class="form-label">관리대상</label>
                                <select id="formSiteCd" name="siteCd" class="form-select">
                                    <option value="">공통</option>
                                    <c:forEach items="${siteList}" var="site">
                                        <option value="${site.siteCd}">${site.siteName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-6 mb-3">
                                <label class="form-label">수신자명</label>
                                <input type="text" class="form-control form-control-a" id="recipientNm" name="recipientNm">
                            </div>
                            <div class="col-6 mb-3">
                                <label class="form-label">휴대폰 번호</label>
                                <input type="tel" class="form-control form-control-a" id="phoneNo" name="phoneNo" placeholder="010-0000-0000">
                            </div>
                            <div class="col-6 mb-3">
                                <label class="form-label">연결 아이디</label>
                                <input type="text" class="form-control form-control-a" id="linkedUserId" name="userId" placeholder="선택 입력">
                            </div>
                            <div class="col-3 mb-3">
                                <label class="form-label">사용 여부</label>
                                <select id="formUseYn" name="useYn" class="form-select">
                                    <option value="Y">사용</option>
                                    <option value="N">미사용</option>
                                </select>
                            </div>
                            <div class="col-3 mb-3">
                                <label class="form-label">정렬 순서</label>
                                <input type="number" class="form-control form-control-a" id="sortOrd" name="sortOrd" value="0" min="0">
                            </div>
                            <div class="col-12 mb-3">
                                <label class="form-label">비고</label>
                                <textarea class="form-control form-control-a" id="remark" name="remark" rows="4"></textarea>
                            </div>
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
    let currentPage = 1;

    $(document).ready(function () {
        loadRecipients(1);

        $('#btnSearch').on('click', function () {
            loadRecipients(1);
        });

        $('#keyword').on('keyup', function (e) {
            if (e.key === 'Enter') {
                loadRecipients(1);
            }
        });

        $('#btnAddRecipient').on('click', openPanel);
        $('#btnClosePanel').on('click', closePanel);
        $('#btnSave').on('click', saveRecipient);
        $('#btnDelete').on('click', deleteRecipient);
    });

    function loadRecipients(page) {
        currentPage = page;
        $('#loadingMsgRow').show();

        $.ajax({
            url: '/admin/notification/recipients/data',
            type: 'GET',
            data: {
                page: page,
                keyword: $('#keyword').val(),
                notificationType: $('#notificationType').val(),
                siteCd: $('#siteCd').val(),
                useYn: $('#useYn').val()
            },
            success: function (res) {
                renderRecipientRows(res.list || []);
                renderPagination(res.pageInfo || { currentPage: 1, totalPages: 1 });
                $('#recipientCount').html('총 <b>' + (res.totalCount || 0) + '</b>건');
            },
            error: function () {
                showMsg('error', '오류', '수신자 목록 조회 중 오류가 발생했습니다.');
            },
            complete: function () {
                $('#loadingMsgRow').hide();
            }
        });
    }

    function renderRecipientRows(list) {
        const $body = $('#recipientTableBody');
        $body.find('tr:not(#loadingMsgRow)').remove();

        if (!list.length) {
            $body.append('<tr><td colspan="7" style="text-align:center; color:gray;">조회된 수신자가 없습니다.</td></tr>');
            return;
        }

        list.forEach(function (row) {
            const useText = row.useYn === 'Y' ? '사용' : '미사용';
            const siteName = row.siteName || '공통';
            $body.append(
                '<tr>' +
                '<td>' + escapeHtml(row.notificationTypeNm || row.notificationType || '') + '</td>' +
                '<td>' + escapeHtml(row.recipientNm || '') + '</td>' +
                '<td>' + escapeHtml(maskPhone(row.phoneNo || '')) + '</td>' +
                '<td>' + escapeHtml(siteName) + '</td>' +
                '<td>' + useText + '</td>' +
                '<td>' + (row.sortOrd || 0) + '</td>' +
                '<td><button type="button" class="btn btn-secondary btn-sm" onclick="loadRecipientDetail(' + row.recipientId + ')">상세</button></td>' +
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
            html += '<button type="button" class="btn ' + active + ' btn-sm mx-1" onclick="loadRecipients(' + i + ')">' + i + '</button>';
        }
        $('#paginationZone').html(html);
    }

    function maskPhone(phoneNo) {
        const value = (phoneNo || '').trim();
        const digits = value.replace(/[^0-9]/g, '');
        if (digits.length === 11) {
            return digits.replace(/(\d{3})(\d{4})(\d{4})/, '$1-****-$3');
        }
        if (digits.length === 10) {
            return digits.replace(/(\d{3})(\d{3})(\d{4})/, '$1-***-$3');
        }
        if (value.length > 4) {
            return value.substring(0, 3) + '****' + value.substring(value.length - 4);
        }
        return value;
    }

    function openPanel() {
        $('#recipientForm')[0].reset();
        $('#recipientId').val('');
        $('#sortOrd').val('0');
        $('#formUseYn').val('Y');
        $('#panelTitle').html('<b>수신자 추가</b>');
        $('#btnDelete').hide();
        $('#sidePanel').removeClass('hidden');
    }

    function closePanel() {
        $('#sidePanel').addClass('hidden');
    }

    function loadRecipientDetail(recipientId) {
        $.ajax({
            url: '/admin/notification/recipients/' + recipientId,
            type: 'GET',
            success: function (res) {
                if (res.code !== '0000') {
                    showMsg('warning', '확인 필요', res.message || '수신자 정보를 찾을 수 없습니다.');
                    return;
                }
                const data = res.data || {};
                $('#recipientId').val(data.recipientId || '');
                $('#formNotificationType').val(data.notificationType || '');
                $('#formSiteCd').val(data.siteCd || '');
                $('#recipientNm').val(data.recipientNm || '');
                $('#phoneNo').val(data.phoneNo || '');
                $('#linkedUserId').val(data.userId || '');
                $('#formUseYn').val(data.useYn || 'Y');
                $('#sortOrd').val(data.sortOrd || 0);
                $('#remark').val(data.remark || '');
                $('#panelTitle').html('<b>수신자 수정</b>');
                $('#btnDelete').show();
                $('#sidePanel').removeClass('hidden');
            },
            error: function () {
                showMsg('error', '오류', '수신자 상세 조회 중 오류가 발생했습니다.');
            }
        });
    }

    function saveRecipient() {
        if (!$('#formNotificationType').val()) {
            showMsg('warning', '확인 필요', '알림 유형을 선택해주세요.');
            return;
        }
        if (!$('#recipientNm').val()) {
            showMsg('warning', '확인 필요', '수신자명을 입력해주세요.');
            return;
        }
        if (!$('#phoneNo').val()) {
            showMsg('warning', '확인 필요', '휴대폰 번호를 입력해주세요.');
            return;
        }

        $.ajax({
            url: '/admin/notification/recipients/save',
            type: 'POST',
            data: $('#recipientForm').serialize(),
            success: function (res) {
                if (res.code !== '0000') {
                    showMsg('warning', '확인 필요', res.message || '저장할 수 없습니다.');
                    return;
                }
                showSuccessSwal('저장되었습니다.');
                closePanel();
                loadRecipients(currentPage);
            },
            error: function () {
                showMsg('error', '오류', '수신자 저장 중 오류가 발생했습니다.');
            }
        });
    }

    function deleteRecipient() {
        const recipientId = $('#recipientId').val();
        if (!recipientId) {
            return;
        }

        showConfirmSwal('삭제', '선택한 수신자를 미사용 처리할까요?').then(function (result) {
            if (!result.isConfirmed) {
                return;
            }

            $.ajax({
                url: '/admin/notification/recipients/delete',
                type: 'POST',
                data: { recipientId: recipientId },
                success: function (res) {
                    if (res.code !== '0000') {
                        showMsg('warning', '확인 필요', res.message || '삭제할 수 없습니다.');
                        return;
                    }
                    showSuccessSwal('삭제되었습니다.');
                    closePanel();
                    loadRecipients(currentPage);
                },
                error: function () {
                    showMsg('error', '오류', '수신자 삭제 중 오류가 발생했습니다.');
                }
            });
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
