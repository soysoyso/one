<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<html>
<%@include file="./common/head.jsp"%>

<style>
    .noti-page {
        background: #f4f7fb;
        min-height: calc(100vh - 70px);
        padding-bottom: 32px;
    }
    .noti-shell {
        max-width: 1440px;
        margin: 0 auto;
        padding: 22px 20px 40px;
    }
    .noti-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        margin-bottom: 16px;
    }
    .noti-header h4 {
        margin: 0;
        font-size: 22px;
        font-weight: 800;
    }
    .noti-header p {
        margin: 5px 0 0;
        color: #64748b;
        font-size: 13px;
    }
    .noti-actions {
        display: flex;
        gap: 8px;
        flex-wrap: wrap;
    }
    .policy-box {
        background: #fff;
        border: 1px solid #dbe3ef;
        border-radius: 8px;
        margin-bottom: 16px;
        padding: 16px;
    }
    .policy-head {
        display: flex;
        justify-content: space-between;
        gap: 12px;
        align-items: center;
        margin-bottom: 12px;
    }
    .policy-head strong {
        font-size: 15px;
    }
    .policy-badge {
        display: inline-flex;
        align-items: center;
        border-radius: 999px;
        padding: 4px 10px;
        background: #eaf2ff;
        color: #1d4ed8;
        font-size: 12px;
        font-weight: 700;
    }
    .policy-lines {
        display: grid;
        gap: 8px;
    }
    .policy-line {
        border-radius: 6px;
        padding: 10px 12px;
        font-size: 13px;
    }
    .policy-line.info {
        background: #eff6ff;
        border: 1px solid #bfdbfe;
        color: #1e40af;
    }
    .policy-line.success {
        background: #ecfdf5;
        border: 1px solid #bbf7d0;
        color: #166534;
    }
    .noti-grid {
        display: grid;
        grid-template-columns: 320px 1fr;
        gap: 16px;
        align-items: start;
    }
    .template-setting {
        background: #fff;
        border: 1px solid #dbe3ef;
        border-radius: 8px;
        margin-bottom: 16px;
        padding: 16px;
    }
    .template-form-grid {
        display: grid;
        grid-template-columns: 180px 1fr 160px;
        gap: 10px;
        align-items: end;
    }
    .dept-check-grid {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-top: 10px;
    }
    .dept-check {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        border: 1px solid #dbe3ef;
        border-radius: 999px;
        padding: 7px 10px;
        background: #f8fafc;
        font-size: 12px;
        font-weight: 700;
    }
    .template-help {
        color: #64748b;
        font-size: 12px;
        margin-top: 8px;
    }
    .noti-panel {
        background: #fff;
        border: 1px solid #dbe3ef;
        border-radius: 8px;
        padding: 14px;
    }
    .panel-title {
        margin: 0 0 12px;
        font-size: 15px;
        font-weight: 800;
    }
    .type-list {
        display: grid;
        gap: 10px;
    }
    .type-card {
        width: 100%;
        border: 1px solid #dbe3ef;
        border-radius: 8px;
        background: #fff;
        padding: 12px;
        text-align: left;
        cursor: pointer;
        transition: border-color .15s, box-shadow .15s, background .15s;
    }
    .type-card.active {
        border-color: #14b8a6;
        background: #f0fdfa;
        box-shadow: 0 0 0 2px rgba(20, 184, 166, .12);
    }
    .type-card strong {
        display: block;
        margin-bottom: 4px;
        font-size: 14px;
    }
    .type-card p {
        min-height: 34px;
        margin: 0 0 8px;
        color: #64748b;
        font-size: 12px;
    }
    .type-meta {
        display: flex;
        gap: 6px;
        flex-wrap: wrap;
        align-items: center;
    }
    .tag {
        display: inline-flex;
        align-items: center;
        border-radius: 999px;
        padding: 3px 7px;
        font-size: 11px;
        font-weight: 700;
    }
    .tag.code { background: #fff7ed; color: #c2410c; }
    .tag.ready { background: #ecfdf5; color: #047857; }
    .tag.count { background: #fee2e2; color: #b91c1c; }
    .setting-head {
        display: flex;
        justify-content: space-between;
        align-items: flex-start;
        gap: 14px;
        margin-bottom: 14px;
    }
    .setting-head h5 {
        margin: 0 0 5px;
        font-size: 18px;
        font-weight: 800;
    }
    .setting-head p {
        margin: 0;
        color: #64748b;
        font-size: 13px;
    }
    .info-grid {
        display: grid;
        grid-template-columns: repeat(3, minmax(0, 1fr));
        gap: 10px;
        margin-bottom: 14px;
    }
    .info-item {
        border: 1px solid #dbe3ef;
        border-radius: 8px;
        padding: 10px;
        background: #f8fafc;
    }
    .info-item label {
        display: block;
        margin-bottom: 4px;
        color: #64748b;
        font-size: 12px;
        font-weight: 700;
    }
    .info-item span {
        font-weight: 800;
        color: #0f172a;
    }
    .filter-bar {
        display: grid;
        grid-template-columns: 1.3fr 1fr 120px;
        gap: 8px;
        margin-bottom: 12px;
    }
    .transfer-grid {
        display: grid;
        grid-template-columns: 1fr 76px 1fr;
        gap: 12px;
        align-items: center;
    }
    .recipient-box {
        border: 1px solid #dbe3ef;
        border-radius: 8px;
        min-height: 390px;
        background: #fff;
        display: flex;
        flex-direction: column;
    }
    .recipient-box-head {
        display: flex;
        justify-content: space-between;
        gap: 8px;
        align-items: center;
        padding: 10px 12px;
        border-bottom: 1px solid #e5eaf2;
        background: #f8fafc;
        border-radius: 8px 8px 0 0;
    }
    .recipient-box-head strong {
        font-size: 14px;
    }
    .recipient-list {
        padding: 10px;
        overflow: auto;
        height: 338px;
    }
    .recipient-card {
        display: grid;
        grid-template-columns: 22px 1fr;
        gap: 8px;
        align-items: flex-start;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 10px;
        margin-bottom: 8px;
        background: #fff;
    }
    .recipient-card.disabled {
        opacity: .55;
    }
    .recipient-card b {
        display: block;
        font-size: 13px;
    }
    .recipient-card span {
        display: block;
        color: #64748b;
        font-size: 12px;
        margin-top: 2px;
    }
    .move-actions {
        display: grid;
        gap: 8px;
    }
    .empty-state {
        color: #94a3b8;
        text-align: center;
        padding: 70px 8px;
        font-size: 13px;
    }
    .manual-panel {
        margin-top: 14px;
        border-top: 1px solid #e5eaf2;
        padding-top: 14px;
    }
    #sidePanel {
        width: 420px;
    }
    @media (max-width: 1100px) {
        .noti-grid,
        .transfer-grid {
            grid-template-columns: 1fr;
        }
        .move-actions {
            grid-template-columns: 1fr 1fr;
        }
        .info-grid,
        .filter-bar,
        .template-form-grid {
            grid-template-columns: 1fr;
        }
    }
</style>

<body>
<%@include file="./common/top.jsp"%>
<div id="layout">
    <div id="mainContent" class="noti-page">
        <div class="noti-shell">
            <div class="noti-header">
                <div>
                    <h4>알림톡 수신자 관리</h4>
                    <p>기본 발송은 유형별로 관리하고, 운영자는 수신 대상을 직접 등록하거나 사용자 목록에서 배정할 수 있습니다.</p>
                </div>
                <div class="noti-actions">
                    <a href="/admin/user/setting" class="btn btn-outline-secondary">기본 회원 관리 보기</a>
                    <button type="button" class="btn btn-dark" id="btnAddRecipient">알림톡 등록</button>
                </div>
            </div>

            <div class="policy-box">
                <div class="policy-head">
                    <strong>운영 기준</strong>
                    <span class="policy-badge">운영정책</span>
                </div>
                <div class="policy-lines">
                    <div class="policy-line info">사용자 등록 시에는 알림톡 목적과 수신 범위를 명확히 설정합니다. 알림 유형, 관리대상, 사용 여부가 실제 발송 대상 판단 기준입니다.</div>
                    <div class="policy-line success">알림톡 수신자 목록은 유형별로 관리하며, 동일한 사용자를 여러 알림 유형에 별도로 등록할 수 있습니다.</div>
                </div>
            </div>

            <div class="template-setting">
                <div class="policy-head">
                    <strong>외부 알림톡 템플릿 설정</strong>
                    <span class="policy-badge">기본 팀 복수 선택</span>
                </div>
                <form id="templateSettingForm">
                    <input type="hidden" id="templateNotificationType" name="notificationType">
                    <input type="hidden" id="defaultDeptCds" name="defaultDeptCds">
                    <div class="template-form-grid">
                        <div>
                            <label class="form-label">템플릿 코드</label>
                            <input type="text" class="form-control" id="templateCode" name="templateCode" placeholder="예: ATK_DONE">
                        </div>
                        <div>
                            <label class="form-label">알림톡 타이틀</label>
                            <input type="text" class="form-control" id="templateTitle" name="templateTitle" placeholder="외부 솔루션에 등록한 알림톡 제목">
                        </div>
                        <div>
                            <label class="form-label">사용 여부</label>
                            <select class="form-select" id="templateUseYn" name="useYn">
                                <option value="Y">사용</option>
                                <option value="N">미사용</option>
                            </select>
                        </div>
                    </div>
                    <div class="dept-check-grid" id="defaultDeptZone">
                        <c:forEach items="${deptList}" var="dept">
                            <label class="dept-check">
                                <input type="checkbox" class="default-dept-check" value="${dept.cdCode}">
                                <span>${dept.cdCodeNm}</span>
                            </label>
                        </c:forEach>
                    </div>
                    <div class="template-help">
                        기본 매칭 팀을 저장하면 선택한 팀 소속의 관리자 사용자만 알림톡 기본 수신자로 자동 배정할 수 있습니다.
                    </div>
                    <div class="d-flex justify-content-between align-items-center mt-3 gap-2">
                        <label class="dept-check mb-0">
                            <input type="checkbox" id="autoApplyYn" value="Y" checked>
                            <span>저장 시 기본 팀 사용자 자동 배정</span>
                        </label>
                        <button type="button" class="btn btn-primary" id="btnSaveTemplateSetting">템플릿 설정 저장</button>
                    </div>
                </form>
            </div>

            <div class="noti-grid">
                <div class="noti-panel">
                    <h5 class="panel-title">접수/운영 알림 유형</h5>
                    <div class="type-list" id="typeList">
                        <c:forEach items="${notificationTypeList}" var="type" varStatus="status">
                            <button type="button"
                                    class="type-card ${status.first ? 'active' : ''}"
                                    data-type="${type.cdCode}"
                                    data-name="${type.cdCodeNm}">
                                <strong>${type.cdCodeNm}</strong>
                                <p class="type-desc"></p>
                                <div class="type-meta">
                                    <span class="tag code">${type.cdCode}</span>
                                    <span class="tag ready">운영중</span>
                                    <span class="tag count" data-count-for="${type.cdCode}">0명</span>
                                </div>
                            </button>
                        </c:forEach>
                    </div>
                </div>

                <div class="noti-panel">
                    <div class="setting-head">
                        <div>
                            <h5 id="selectedTypeName">알림톡 설정</h5>
                            <p id="selectedTypeDesc">알림 유형을 선택하면 수신자 배정 현황을 확인할 수 있습니다.</p>
                        </div>
                        <div class="noti-actions">
                            <button type="button" class="btn btn-outline-primary btn-sm" id="btnReload">새로고침</button>
                            <button type="button" class="btn btn-success btn-sm" id="btnOpenManual">개별 수신자 추가</button>
                        </div>
                    </div>

                    <div class="info-grid">
                        <div class="info-item">
                            <label>알림톡 이벤트</label>
                            <span id="infoEvent">-</span>
                        </div>
                        <div class="info-item">
                            <label>발송 코드</label>
                            <span id="infoCode">-</span>
                        </div>
                        <div class="info-item">
                            <label>활성 수신자</label>
                            <span id="infoCount">0명</span>
                        </div>
                        <div class="info-item">
                            <label>관리대상</label>
                            <span id="infoSite">전체</span>
                        </div>
                        <div class="info-item">
                            <label>상태</label>
                            <span>사용</span>
                        </div>
                        <div class="info-item">
                            <label>정렬 기준</label>
                            <span>정렬순서, 등록순</span>
                        </div>
                    </div>

                    <div class="filter-bar">
                        <input type="text" class="form-control" id="keyword" placeholder="이름, 전화번호, 아이디 검색">
                        <select class="form-select" id="siteCd">
                            <option value="">전체 관리대상</option>
                            <c:forEach items="${siteList}" var="site">
                                <option value="${site.siteCd}">${site.siteName}</option>
                            </c:forEach>
                        </select>
                        <button type="button" class="btn btn-primary" id="btnSearch">조회</button>
                    </div>

                    <div class="transfer-grid">
                        <div class="recipient-box">
                            <div class="recipient-box-head">
                                <strong>미등록 사용자</strong>
                                <span class="small" id="availableCount">0명</span>
                            </div>
                            <div class="recipient-list" id="availableList"></div>
                        </div>

                        <div class="move-actions">
                            <button type="button" class="btn btn-success" id="btnAssign">알림 &gt;</button>
                            <button type="button" class="btn btn-outline-secondary" id="btnUnassign">&lt; 해제</button>
                        </div>

                        <div class="recipient-box">
                            <div class="recipient-box-head">
                                <strong>등록 수신자</strong>
                                <span class="small" id="assignedCount">0명</span>
                            </div>
                            <div class="recipient-list" id="assignedList"></div>
                        </div>
                    </div>

                    <div class="manual-panel">
                        <button type="button" class="btn btn-outline-dark btn-sm" id="btnBulkSave">현재 배정 상태 새로고침</button>
                        <span class="small ms-2">사용자 목록에 없는 외부 수신자는 우측 상단 개별 수신자 추가로 등록합니다.</span>
                    </div>
                </div>
            </div>

            <div id="sidePanel" class="hidden">
                <form id="recipientForm" name="recipientForm">
                    <input type="hidden" id="recipientId" name="recipientId">
                    <div class="offcanvas-header">
                        <h4 id="panelTitle"><b>알림톡 등록</b></h4>
                        <div>
                            <button type="button" class="btn btn-primary" id="btnSave">저장</button>
                            <button type="button" class="btn bg-danger" id="btnDelete">삭제</button>
                            <button type="button" class="btn btn-secondary" id="btnClosePanel">닫기</button>
                        </div>
                    </div>
                    <div class="offcanvas-body pb-5">
                        <h5 class="mb-3 fw-bold">수신자 정보</h5>
                        <div class="row my-2">
                            <div class="col-12 mb-3">
                                <label class="form-label">알림 유형</label>
                                <select id="formNotificationType" name="notificationType" class="form-select">
                                    <option value="">선택</option>
                                    <c:forEach items="${notificationTypeList}" var="type">
                                        <option value="${type.cdCode}">${type.cdCodeNm}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-12 mb-3">
                                <label class="form-label">관리대상</label>
                                <select id="formSiteCd" name="siteCd" class="form-select">
                                    <option value="">공통</option>
                                    <c:forEach items="${siteList}" var="site">
                                        <option value="${site.siteCd}">${site.siteName}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-12 mb-3">
                                <label class="form-label">수신자명</label>
                                <input type="text" class="form-control form-control-a" id="recipientNm" name="recipientNm">
                            </div>
                            <div class="col-12 mb-3">
                                <label class="form-label">휴대폰 번호</label>
                                <input type="tel" class="form-control form-control-a" id="phoneNo" name="phoneNo" placeholder="010-0000-0000">
                            </div>
                            <div class="col-12 mb-3">
                                <label class="form-label">연결 아이디</label>
                                <input type="text" class="form-control form-control-a" id="linkedUserId" name="userId" placeholder="사용자 아이디">
                            </div>
                            <div class="col-6 mb-3">
                                <label class="form-label">사용 여부</label>
                                <select id="formUseYn" name="useYn" class="form-select">
                                    <option value="Y">사용</option>
                                    <option value="N">미사용</option>
                                </select>
                            </div>
                            <div class="col-6 mb-3">
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
    var activeType = '';
    var activeTypeName = '';
    var availableUsers = [];
    var assignedRecipients = [];
    var typeMeta = {
        POTHOLE_RECEIPT: {
            desc: '포트홀 신고가 신규 접수될 때 운영 담당자에게 즉시 알림을 발송합니다.',
            event: '작업접수 관리자 알림'
        },
        POTHOLE_COMPLETE: {
            desc: '포트홀 보수 또는 유지보수 작업이 완료되었을 때 결과 알림을 발송합니다.',
            event: '작업완료 관리자 알림'
        },
        DAILY_CHECK: {
            desc: '일상점검 제출 또는 이상 항목 발생 시 관리 담당자에게 알림을 발송합니다.',
            event: '일상점검 제출/이상 알림'
        },
        SITUATION_LOG: {
            desc: '상황일지 등록 및 주요 상황 공유가 필요할 때 알림을 발송합니다.',
            event: '상황일지 등록 알림'
        }
    };

    $(document).ready(function () {
        hydrateTypeDescriptions();
        var $first = $('.type-card').first();
        if ($first.length) {
            selectType($first.data('type'), $first.data('name'));
        }

        $('.type-card').on('click', function () {
            selectType($(this).data('type'), $(this).data('name'));
        });
        $('#btnSearch, #btnReload, #btnBulkSave').on('click', function () {
            loadAssignmentData();
        });
        $('#keyword').on('keyup', function (e) {
            if (e.key === 'Enter') {
                loadAssignmentData();
            }
        });
        $('#siteCd').on('change', loadAssignmentData);
        $('#btnAssign').on('click', assignSelectedUsers);
        $('#btnUnassign').on('click', unassignSelectedRecipients);
        $('#btnSaveTemplateSetting').on('click', saveTemplateSetting);
        $('#btnAddRecipient, #btnOpenManual').on('click', openPanel);
        $('#btnClosePanel').on('click', closePanel);
        $('#btnSave').on('click', saveRecipient);
        $('#btnDelete').on('click', deleteRecipient);
    });

    function hydrateTypeDescriptions() {
        $('.type-card').each(function () {
            var code = $(this).data('type');
            var meta = typeMeta[code] || {};
            $(this).find('.type-desc').text(meta.desc || '알림톡 발송 대상을 관리합니다.');
        });
    }

    function selectType(code, name) {
        activeType = code || '';
        activeTypeName = name || '알림톡';
        $('.type-card').removeClass('active');
        $('.type-card[data-type="' + activeType + '"]').addClass('active');
        $('#selectedTypeName').text(activeTypeName + ' 수신자 관리');
        $('#selectedTypeDesc').text((typeMeta[activeType] || {}).desc || '선택한 알림 유형의 수신자를 관리합니다.');
        $('#infoEvent').text((typeMeta[activeType] || {}).event || activeTypeName);
        $('#infoCode').text(activeType || '-');
        $('#formNotificationType').val(activeType);
        $('#templateNotificationType').val(activeType);
        loadTemplateSetting();
        loadAssignmentData();
    }

    function loadTemplateSetting() {
        if (!activeType) return;
        $('#templateCode').val('');
        $('#templateTitle').val('');
        $('#templateUseYn').val('Y');
        $('.default-dept-check').prop('checked', false);
        $.ajax({
            url: '/admin/notification/template/' + activeType,
            type: 'GET',
            dataType: 'json',
            success: function (res) {
                var data = res.data || {};
                $('#templateCode').val(data.templateCode || '');
                $('#templateTitle').val(data.templateTitle || '');
                $('#templateUseYn').val(data.useYn || 'Y');
                String(data.defaultDeptCds || '').split(',').forEach(function (deptCd) {
                    $('.default-dept-check[value="' + deptCd + '"]').prop('checked', true);
                });
            }
        });
    }

    function saveTemplateSetting() {
        if (!activeType) {
            showMsg('warning', '확인 필요', '알림 유형을 먼저 선택하세요.');
            return;
        }
        var deptCds = $('.default-dept-check:checked').map(function () { return $(this).val(); }).get();
        $('#defaultDeptCds').val(deptCds.join(','));
        if (!$('#templateCode').val()) {
            showMsg('warning', '확인 필요', '외부 솔루션 템플릿 코드를 입력하세요.');
            return;
        }
        if (!$('#templateTitle').val()) {
            showMsg('warning', '확인 필요', '알림톡 타이틀을 입력하세요.');
            return;
        }
        var formData = $('#templateSettingForm').serializeArray();
        formData.push({ name: 'autoApplyYn', value: $('#autoApplyYn').is(':checked') ? 'Y' : 'N' });
        $.ajax({
            url: '/admin/notification/template/save',
            type: 'POST',
            dataType: 'json',
            data: $.param(formData),
            success: function (res) {
                if (res.code !== '0000') {
                    showMsg('warning', '확인 필요', res.message || '템플릿 설정을 저장할 수 없습니다.');
                    return;
                }
                showSuccessSwal('템플릿 설정이 저장되었습니다.');
                loadAssignmentData();
            },
            error: function () {
                showMsg('error', '오류', '템플릿 설정 저장 중 오류가 발생했습니다.');
            }
        });
    }

    function loadAssignmentData() {
        if (!activeType) {
            return;
        }
        var siteCd = $('#siteCd').val();
        var keyword = $('#keyword').val();
        $('#infoSite').text($('#siteCd option:selected').text() || '전체');
        $.when(
            $.ajax({
                url: '/admin/notification/recipients/data',
                type: 'GET',
                dataType: 'json',
                data: { page: 1, pageSize: 500, notificationType: activeType, siteCd: siteCd, useYn: 'Y', keyword: keyword }
            }),
            $.ajax({
                url: '/admin/user/data',
                type: 'GET',
                dataType: 'json',
                data: { page: 1, pageSize: 500, searchSiteCd: siteCd, searchKeyword: keyword }
            })
        ).done(function (recipientRes, userRes) {
            assignedRecipients = (recipientRes[0].list || []);
            availableUsers = filterAvailableUsers(userRes[0].list || [], assignedRecipients);
            renderTypeCounts();
            renderAssignmentLists();
        }).fail(function () {
            showMsg('error', '오류', '알림톡 수신자 정보를 조회하는 중 오류가 발생했습니다.');
        });
    }

    function filterAvailableUsers(users, assigned) {
        var assignedUserIds = {};
        assigned.forEach(function (row) {
            if (row.userId) {
                assignedUserIds[row.userId] = true;
            }
        });
        return users.filter(function (user) {
            return !assignedUserIds[user.userId];
        });
    }

    function renderTypeCounts() {
        $('#assignedCount').text(assignedRecipients.length + '명');
        $('#availableCount').text(availableUsers.length + '명');
        $('#infoCount').text(assignedRecipients.length + '명');
        $('[data-count-for="' + activeType + '"]').text(assignedRecipients.length + '명');
    }

    function renderAssignmentLists() {
        renderAvailableList();
        renderAssignedList();
    }

    function renderAvailableList() {
        var $list = $('#availableList');
        $list.empty();
        if (!availableUsers.length) {
            $list.html('<div class="empty-state">배정 가능한 사용자가 없습니다.</div>');
            return;
        }
        availableUsers.forEach(function (user) {
            var phone = user.userTel || '';
            var disabledClass = phone ? '' : ' disabled';
            $list.append(
                '<label class="recipient-card' + disabledClass + '">' +
                '<input type="checkbox" class="available-check" value="' + escapeHtml(user.userId || '') + '"' + (phone ? '' : ' disabled') + '>' +
                '<span>' +
                '<b>' + escapeHtml(user.userNm || user.userId || '') + '</b>' +
                '<span>' + escapeHtml(user.userAuthNm || '권한 미지정') + '</span>' +
                '<span>' + escapeHtml(maskPhone(phone) || '휴대폰 번호 없음') + '</span>' +
                '<span>' + escapeHtml(user.siteCdListNm || '공통') + '</span>' +
                '</span>' +
                '</label>'
            );
        });
    }

    function renderAssignedList() {
        var $list = $('#assignedList');
        $list.empty();
        if (!assignedRecipients.length) {
            $list.html('<div class="empty-state">등록된 수신자가 없습니다.</div>');
            return;
        }
        assignedRecipients.forEach(function (row) {
            $list.append(
                '<label class="recipient-card">' +
                '<input type="checkbox" class="assigned-check" value="' + escapeHtml(row.recipientId || '') + '">' +
                '<span>' +
                '<b>' + escapeHtml(row.recipientNm || '') + '</b>' +
                '<span>' + escapeHtml(row.userId || '외부 수신자') + ' / ' + escapeHtml(row.siteName || '공통') + '</span>' +
                '<span>' + escapeHtml(maskPhone(row.phoneNo || '')) + '</span>' +
                '<span><button type="button" class="btn btn-link btn-sm p-0" onclick="loadRecipientDetail(' + row.recipientId + ')">상세 수정</button></span>' +
                '</span>' +
                '</label>'
            );
        });
    }

    function assignSelectedUsers() {
        var checked = $('.available-check:checked').map(function () { return $(this).val(); }).get();
        if (!checked.length) {
            showMsg('warning', '확인 필요', '알림 수신자로 등록할 사용자를 선택해주세요.');
            return;
        }
        var siteCd = $('#siteCd').val();
        var requests = checked.map(function (userId, index) {
            var user = availableUsers.find(function (item) { return item.userId === userId; }) || {};
            return $.ajax({
                url: '/admin/notification/recipients/save',
                type: 'POST',
                dataType: 'json',
                data: {
                    notificationType: activeType,
                    recipientNm: user.userNm || user.userId,
                    phoneNo: user.userTel || '',
                    userId: user.userId || '',
                    siteCd: siteCd,
                    useYn: 'Y',
                    sortOrd: assignedRecipients.length + index + 1,
                    remark: activeTypeName + ' 자동 배정'
                }
            });
        });

        $.when.apply($, requests).done(function () {
            showSuccessSwal('알림 수신자를 등록했습니다.');
            loadAssignmentData();
        }).fail(function () {
            showMsg('error', '오류', '알림 수신자 등록 중 오류가 발생했습니다.');
        });
    }

    function unassignSelectedRecipients() {
        var checked = $('.assigned-check:checked').map(function () { return $(this).val(); }).get();
        if (!checked.length) {
            showMsg('warning', '확인 필요', '해제할 수신자를 선택해주세요.');
            return;
        }
        var requests = checked.map(function (recipientId) {
            return $.ajax({
                url: '/admin/notification/recipients/delete',
                type: 'POST',
                dataType: 'json',
                data: { recipientId: recipientId }
            });
        });
        $.when.apply($, requests).done(function () {
            showSuccessSwal('알림 수신자를 해제했습니다.');
            loadAssignmentData();
        }).fail(function () {
            showMsg('error', '오류', '알림 수신자 해제 중 오류가 발생했습니다.');
        });
    }

    function openPanel() {
        $('#recipientForm')[0].reset();
        $('#recipientId').val('');
        $('#formNotificationType').val(activeType);
        $('#formSiteCd').val($('#siteCd').val());
        $('#sortOrd').val(assignedRecipients.length + 1);
        $('#formUseYn').val('Y');
        $('#panelTitle').html('<b>알림톡 등록</b>');
        $('#btnDelete').hide();
        $('#sidePanel').removeClass('hidden');
        $('#layout').addClass('panel-open');
    }

    function closePanel() {
        $('#sidePanel').addClass('hidden');
        $('#layout').removeClass('panel-open');
    }

    function loadRecipientDetail(recipientId) {
        $.ajax({
            url: '/admin/notification/recipients/' + recipientId,
            type: 'GET',
            dataType: 'json',
            success: function (res) {
                if (res.code !== '0000') {
                    showMsg('warning', '확인 필요', res.message || '수신자 정보를 찾을 수 없습니다.');
                    return;
                }
                var data = res.data || {};
                $('#recipientId').val(data.recipientId || '');
                $('#formNotificationType').val(data.notificationType || activeType);
                $('#formSiteCd').val(data.siteCd || '');
                $('#recipientNm').val(data.recipientNm || '');
                $('#phoneNo').val(data.phoneNo || '');
                $('#linkedUserId').val(data.userId || '');
                $('#formUseYn').val(data.useYn || 'Y');
                $('#sortOrd').val(data.sortOrd || 0);
                $('#remark').val(data.remark || '');
                $('#panelTitle').html('<b>알림톡 수정</b>');
                $('#btnDelete').show();
                $('#sidePanel').removeClass('hidden');
                $('#layout').addClass('panel-open');
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
            dataType: 'json',
            data: $('#recipientForm').serialize(),
            success: function (res) {
                if (res.code !== '0000') {
                    showMsg('warning', '확인 필요', res.message || '저장할 수 없습니다.');
                    return;
                }
                showSuccessSwal('저장되었습니다.');
                closePanel();
                loadAssignmentData();
            },
            error: function () {
                showMsg('error', '오류', '수신자 저장 중 오류가 발생했습니다.');
            }
        });
    }

    function deleteRecipient() {
        var recipientId = $('#recipientId').val();
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
                dataType: 'json',
                data: { recipientId: recipientId },
                success: function (res) {
                    if (res.code !== '0000') {
                        showMsg('warning', '확인 필요', res.message || '삭제할 수 없습니다.');
                        return;
                    }
                    showSuccessSwal('삭제되었습니다.');
                    closePanel();
                    loadAssignmentData();
                },
                error: function () {
                    showMsg('error', '오류', '수신자 삭제 중 오류가 발생했습니다.');
                }
            });
        });
    }

    function maskPhone(phoneNo) {
        var value = (phoneNo || '').trim();
        var digits = value.replace(/[^0-9]/g, '');
        if (digits.length === 11) {
            return digits.replace(/(\d{3})(\d{4})(\d{4})/, '$1-****-$3');
        }
        if (digits.length === 10) {
            return digits.replace(/(\d{3})(\d{3})(\d{4})/, '$1-***-$3');
        }
        return value;
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
