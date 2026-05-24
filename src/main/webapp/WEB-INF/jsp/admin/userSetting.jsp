<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
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
                <h4><b>관리자 설정</b></h4>
                <button type="button" class="btn btn-dark" style="margin-left:5px" onclick="showAddForm();">
                    관리자 추가
                </button>
            </div>
        </div>

        <div class="search-zone">
            <div class="row g-2 align-items-end">
                <div class="col-4">
                    <label class="form-label">키워드</label>
                    <input type="text" id="searchKeyword" class="form-control" placeholder="이름, 아이디">
                </div>

                <div class="col-2">
                    <label class="form-label">권한</label>
                    <select id="searchRole" class="form-select">
                        <option value="">전체</option>
                        <c:forEach items="${authList}" var="a">
                            <option value="${a.cdCode}">${a.cdCodeNm}</option>
                        </c:forEach>
                    </select>

                </div>

                <div class="col-3">
                    <label class="form-label">관리대상</label>
                    <select id="searchSiteCd" class="form-select">
                    <option value="">전체</option>
                    <c:forEach items="${siteList}" var="s">
                    <option value="${s.siteCd}">${s.siteName}</option>
                    </c:forEach>
                    </select>
                </div>

                <div class="col-1">
                    <button type="button" class="btn btn-primary w-100" id="searchBtn">조회</button>
                </div>
            </div>
        </div>

        <div class="" style="display: flex !important; justify-content: space-between; align-items: center;">
            <p id="userCount">총 <b>0</b>건</p>
        </div>

        <div class="data-zone">
            <table class="table">
                <thead>
                    <tr>
                        <th>이름</th>
                        <th>아이디</th>
                        <th>권한</th>
                        <th>관리대상</th>
                        <th>관리</th>
                    </tr>
                </thead>
                <tbody id="userTableBody">
                    <%-- 목록 --%>
                    <tr id="loadingMsgRow" style="display:none;">
                        <td colspan="5" style="text-align:center; color:gray;">조회 중입니다...</td>
                    </tr>
               </tbody>
            </table>
            <div id="paginationZone" class="text-center mt-3"></div>
        </div>

        <!-- 사용자 추가 입력 창 -->
        <div id="sidePanel" class="hidden">
        <form id="frmMember" name="frmMember">
            <input type="hidden" id="userAuthJoined" name="userAuth" />
            <input type="hidden" id="siteCodesJoined" name="siteCodesJoined" />
            <div class="offcanvas-header">
                <h4 id="panelTitle"><b>사용자 추가</b></h4>
                <div>
                    <button type="button" class="btn btn-primary" id="btnSave">저장</button>
                    <button type="button" class="btn btn-primary" id="btnEdit">수정</button>
                    <button type="button" class="btn bg-danger" id="btnDelete">삭제</button>
                    <button type="button" class="btn btn-secondary" id="closePanel">창닫기</button>
                </div>
            </div>
            <div class="offcanvas-body pb-5">
                <h5 class="mb-3 fw-bold">공통</h5>
                <div class="row my-2">
                    <div class="col-6 mb-3">
                        <label class="form-label">이름</label>
                        <input type="text" class="form-control form-control-a" id="insUserName" name="insUserName">
                    </div>
                    <div class="col-6 mb-3">
                        <label class="form-label">아이디</label>
                        <div class="d-flex" style="gap: 5px;">
                            <input type="text" class="form-control form-control-a" id="insUserId" name="insUserId">
                            <button type="button" class="btn btn-dark" id="btnCheckUserId" style="min-width: 200px;">중복확인</button>
                        </div>
                    </div>
                    <div class="col-6 mb-3">
                        <label class="form-label">전화번호</label>
                        <input type="tel" class="form-control form-control-a" id="insUserTel" name="userTel">
                    </div>

                    <div class="col-6 mb-3">
                        <label class="form-label">이메일</label>
                        <input type="email" class="form-control form-control-a" id="insUserMail" name="userMail">
                    </div>
                    <div class="col-6">
                        <label class="form-label">비밀번호</label>
                        <input type="password" class="form-control form-control-a" id="insUserPw" name="insUserPw">
                    </div>
                    <div class="col-6">
                        <label class="form-label">비밀번호 확인</label>
                        <input type="password" class="form-control form-control-a" id="insUserPwConfirm" name="insUserPwConfirm">
                    </div>
                    <div class="col-12 mb-1"><small class="text-danger d-block mt-1 ms-1">* 비밀번호는 영문, 숫자를 포함한 6자리 이상 20자리 이하입니다.<br>
                        * 특수문자는 ! @ # $ % ^ & * ( ) - + = < > ? / [ ] { } , . : ; 가능합니다.</small>
                    </div>
                </div>

                                <div class="mt-4" style="border-top: 1px dotted #9f9f9f; padding-top: 25px;">
                    <h5 class="mb-3 fw-bold">권한</h5>

                    <c:forEach items="${authList}" var="auth">

                        <input type="checkbox"
                               class="btn-check ${auth.cdCode ne 'ADMIN' ? 'role-sub' : ''}"
                               id="role-${auth.cdCode}"
                               name="userRole"
                               value="${auth.cdCode}"
                               autocomplete="off">

                        <label class="btn btn-outline-primary"
                               for="role-${auth.cdCode}">
                            ${auth.cdCodeNm}
                        </label>

                    </c:forEach>

                </div>

                <div id="bizDivZone" class="mt-3" style="display:none;">
                    <h5 class="mb-3 fw-bold">화면</h5>

                    <div class="btn-group" role="group">
                        <input type="radio" class="btn-check" name="bizDivCd" id="guardTeam-traffic" value="RECEIPT" autocomplete="off">
                        <label class="btn btn-outline-primary" for="guardTeam-traffic">접수</label>

                        <input type="radio" class="btn-check" name="bizDivCd" id="guardTeam-road" value="APPLY" autocomplete="off">
                        <label class="btn btn-outline-primary" for="guardTeam-road">처리</label>
                    </div>
                </div>

                <div id="deptZone" class="mt-3" style="display:none;">
                    <h5 class="mb-2 fw-bold">소속</h5>

                    <select id="deptCd" name="deptCd" class="form-select" style="max-width:300px;">
                        <option value="">소속 선택</option>
                        <c:forEach items="${deptList}" var="dept">
                            <option value="${dept.cdCode}">${dept.cdCodeNm}</option>
                        </c:forEach>
                    </select>

                    <small class="text-danger d-block mt-2 ms-1">
                        * 현장관리자/현장사용자 권한 선택 시, 소속을 반드시 선택해야 합니다.
                    </small>
                </div>

                <div class="mt-4" style="border-top: 1px dotted #9f9f9f; padding-top: 25px;">
                    <h5 class="mb-4 fw-bold">관리대상</h5>
                    <div class="form-check">
                        <input type="checkbox" id="checkAllCompany" name="checkAllCompany">
                        <label for="checkAllCompany" class="fw-bold">전체선택</label>
                    </div>
                    <div class="row">
                        <c:forEach items="${siteList}" var="site">
                            <div class="col-3">
                                <div class="form-check">
                                    <input type="checkbox"
                                           id="company_${site.siteCd}"
                                           name="companyCodes"
                                           value="${site.siteCd}" />
                                    <label for="company_${site.siteCd}">
                                        ${site.siteName}
                                    </label>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>


            </div>
        </form>
        </div>
    </div>
    </div>
</div>


<button type="button" id="openPanel" style="display:none"></button>
</body>
<%@include file="./common/modal.jsp"%>
<%@include file="./common/script.jsp"%>


<script>
    let isUserIdChecked = false; // 아이디 중복확인

    const ROLE_FIELD_USER   = 'ATH300'; // 현장사용자 권한 코드값
    const ROLE_GUARD        = 'ATH200'; // 현장관리자 권한 코드값

    // ✅ 숫자 콤마 포맷 (toLocaleString() 안씀)
    function formatNumberWithComma(num) {
        if (num == null) return '0';
        return ('' + num).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
    }

    function isGuardSelected() {
        return $('input[name="userRole"][value="' + ROLE_GUARD + '"]').is(':checked');
    }

    function isGuardSelected() {
        return $('input[name="userRole"][value="' + ROLE_GUARD + '"]').is(':checked');
    }

    function isFieldUserSelected() {
        return $('input[name="userRole"][value="' + ROLE_FIELD_USER + '"]').is(':checked');
    }

    /**
     * ✅ 현장관리자 권한 포함 시:
     * - 전체선택 비활성화 + 체크 해제
     * - 관리대상(companyCodes) 1개만 유지
     */
    function syncCompanySelectRule() {
        const guard = isGuardSelected();

        if (guard) {
            // 전체선택 금지
            $('#checkAllCompany').prop('checked', false).prop('disabled', true);

            // 2개 이상 선택되어 있으면 1개만 남김(첫번째만 유지)
            const $checked = $('input[name="companyCodes"]:checked');
            if ($checked.length > 1) {
                $checked.not(':first').prop('checked', false);
            }
        } else {
            // GUARD 아니면 전체선택 다시 허용
            $('#checkAllCompany').prop('disabled', false);
        }
        // ✅ 현장관리자 소속 영역 토글
        toggleUserOptionZone();
    }

    /**
     * ✅ 권한 체크박스 초기화(추가/수정 열 때)
     * - 기존 role-admin / role-sub 규칙 유지
     */
    function bindRoleEvents() {

        // ✅ 최고관리자 체크박스 (동적 id: role-ADMIN)
        $('#role-ADMIN').off('change').on('change', function () {
            const isChecked = $(this).is(':checked');
            $('.role-sub').prop('checked', isChecked);

            syncCompanySelectRule();
        });

        // ✅ 하위 권한 변경 시 최고관리자 상태 동기화
        $('.role-sub').off('change').on('change', function () {
            const totalSub = $('.role-sub').length;
            const checkedSub = $('.role-sub:checked').length;

            if (totalSub !== checkedSub) {
                $('#role-ADMIN').prop('checked', false);
            } else {
                $('#role-ADMIN').prop('checked', true);
            }

            syncCompanySelectRule();
        });
    }

    /**
     * ✅ 회사(관리대상) 체크박스 이벤트
     * - GUARD면 1개만 선택 가능
     */
    function bindCompanyEvents() {

        // 전체선택 체크박스 클릭 시
        $('#checkAllCompany').off('change').on('change', function () {

            if (isGuardSelected()) {
                $(this).prop('checked', false);
                return;
            }

            const isChecked = $(this).is(':checked');
            $('input[name="companyCodes"]').prop('checked', isChecked);
        });

        // 개별 체크박스 클릭 시 전체선택 상태 자동 반영 + GUARD 제한
        $('input[name="companyCodes"]').off('change').on('change', function () {

            if (isGuardSelected()) {
                const checked = $('input[name="companyCodes"]:checked');

                // 2개 이상이면 방금 체크한 것만 남기고 나머지 해제
                if (checked.length > 1) {
                    $('input[name="companyCodes"]').not(this).prop('checked', false);
                }

                // GUARD면 전체선택은 항상 false
                $('#checkAllCompany').prop('checked', false);
                return;
            }

            const total = $('input[name="companyCodes"]').length;
            const checkedCnt = $('input[name="companyCodes"]:checked').length;
            $('#checkAllCompany').prop('checked', total === checkedCnt);
        });
    }

    $(document).ready(function () {
        doSearch();

        // ✅ 조회 버튼 id는 searchBtn인데 기존에 btnSearch로 걸려있어서 정리
        $('#searchBtn').off('click').on('click', function () {
            doSearch(1);
        });

        $('#searchKeyword').off('keypress').on('keypress', function (e) {
            if (e.which === 13) {
                doSearch(1);
            }
        });

        bindRoleEvents();
        bindCompanyEvents();

        // 최초 1회 룰 동기화
        syncCompanySelectRule();
    });


    const layout = document.getElementById('layout');
    const panel = document.getElementById('sidePanel');
    const closePanelBtn = document.getElementById('closePanel');

    // 직원 추가 패널 오픈
    document.getElementById('openPanel')?.addEventListener('click', () => {
        panel.classList.remove('hidden');
        requestAnimationFrame(() => {
            layout.classList.add('panel-open');
        });
    });

    // 직원 수정 패널 오픈(혹시 다른 곳에서 btn-edit를 쓰는 경우)
    document.querySelectorAll('.btn-edit').forEach(btn => {
        btn.addEventListener('click', () => {
            panel.classList.remove('hidden');
            requestAnimationFrame(() => {
                layout.classList.add('panel-open');
            });
        });
    });

    // 닫기
    closePanelBtn?.addEventListener('click', () => {
        layout.classList.remove('panel-open');
        setTimeout(() => {
            panel.classList.add('hidden');
        }, 300);
    });


    //조회
    function doSearch(page = 1) {

        const searchKeyword = $('#searchKeyword').val();

        // 로딩 메시지 표시
        $('#loadingMsgRow').show();

        $.ajax({
            url: "/admin/user/data",
            type: "get",
            dataType: 'json',
            data: {
                "page": page,
                "searchKeyword": $('#searchKeyword').val() || '',
                "searchRole": $('#searchRole').val() || '',
                "searchSiteCd": $('#searchSiteCd').val() || ''
            },
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            success: function (data) {
console.log(data);
                const tbody = document.querySelector("#userTableBody");
                let rowHtml = '';

                if (data && data.list && data.list.length > 0) {
                    for (let i = 0; i < data.list.length; i++) {
                        const adminUser = data.list[i];

                        rowHtml += '<tr>';
                        rowHtml += '<td>' + (adminUser.userNm || '') + '</td>';
                        rowHtml += '<td>' + (adminUser.userId || '') + '</td>';
                        rowHtml += '<td>' + (adminUser.userAuthNm || '') + '</td>';
                        rowHtml += '<td>' + (adminUser.siteCdListNm || '전체') + '</td>';
                        rowHtml += '<td><button type="button" class="btn btn-secondary" onclick="showEditForm(\'' + adminUser.userId + '\')">상세</button></td>';
                        rowHtml += '</tr>';
                    }
                } else {
                    rowHtml += '<tr><td colspan="5" style="text-align:center;">정보가 없습니다.</td></tr>';
                }

                tbody.innerHTML = rowHtml;

                // 총 인원수 및 페이징
                const totalCount = (data && data.totalCount != null) ? data.totalCount : 0;
                document.querySelector("#userCount").innerHTML = '<p>총 <b>' + formatNumberWithComma(totalCount) + '</b>건</p>';
                document.querySelector("#paginationZone").innerHTML = renderPagination(data.pageInfo);

            },
            error: function () {
                $('#userTableBody').html('<tr><td colspan="5" style="text-align:center; color:red;">조회 중 오류가 발생했습니다.</td></tr>');
            },
            complete: function () {
                $('#loadingMsgRow').hide();
            }
        });
    }


    /* 등록 및 수정 입력 폼 초기화 */
    function init() {

        $('#insAuthCode').val('');
        $('#insUserName').val('');
        $('#insUserId').val('');
        $('#insUserTel').val('');
        $('#insUserMail').val('');
        $('#insUserPw').val('');
        $('#insUserPwConfirm').val('');
        $('#siteCodesJoined').val('');

        $('input[name="companyCodes"]').prop('checked', false);
        $('input[name="checkAllCompany"]').prop('checked', false);

        // ✅ 권한 체크박스 초기화(동적 생성이므로 name 기준으로 싹 해제)
        $('input[name="userRole"]').prop('checked', false);

        $('#insUserId')
            .removeAttr('readonly')
            .css({
                'background-color': '',
                'color': ''
            });

        $('#btnCheckUserId').removeClass('btn-secondary');
        $('#btnCheckUserId').addClass('btn-dark');
        $('#btnCheckUserId').text('중복확인');

        isUserIdChecked = false;

        $('input[name="bizDivCd"]').prop('checked', false);
        $('#guardTeamZone').hide();
        $('#deptCd').val('');

        syncCompanySelectRule();
    }


    // 관리자추가 버튼 클릭
    function showAddForm() {
        init();

        $('#panelTitle').html('<b>관리자 추가</b>');

        $('#btnCheckUserId').css('display', '');
        $('#btnSave').css('display', '');
        $('#btnEdit').css('display', 'none');
        $('#btnDelete').css('display', 'none');

        // ✅ 이벤트가 동적으로 추가될 수 있어서 한번 더 바인딩/동기화
        bindRoleEvents();
        bindCompanyEvents();
        syncCompanySelectRule();

        document.getElementById("openPanel").click();
    }


    // 상세 버튼 클릭
    function showEditForm(userId) {

        $('#panelTitle').html('<b>관리자 수정</b>');

        init();

        $('#btnCheckUserId').css('display', 'none');

        $('#insUserId')
            .attr('readonly', true)
            .css({
                'background-color': '#e9ecef',
                'color': '#6c757d'
            });

        $('#btnSave').css('display', 'none');
        $('#btnEdit').css('display', '');
        $('#btnDelete').css('display', '');

        $.ajax({
            url: '/admin/user/detail/' + userId,
            type: 'get',
            dataType: 'json',
            success: function (res) {

                if (!res || res.code === '9999') {
                    showMsg('error', '오류', (res && res.message) ? res.message : '오류가 발생했습니다.');
                    return;
                }

                const mData = res.data || {};

                $('#insUserName').val(mData.userNm || '');
                $('#insUserId').val(mData.userId || '');
                let userTel = (mData.userTel || '').replace(/[^0-9]/g, '');

                if (userTel.length === 11) {
                    userTel = userTel.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
                } else if (userTel.length === 10) {
                    userTel = userTel.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3');
                }

                $('#insUserTel').val(userTel);
                $('#insUserMail').val(mData.userMail || '');

                // 권한 체크 세팅 (mData.userAuth 기준)
                $('input[name="userRole"]').prop('checked', false);

                let rolesStr = (mData.userAuth || '').trim(); // ex) "ATH200,ATH300"
                if (rolesStr !== '') {
                    let roles = rolesStr.split(',').map(function (r) { return ('' + r).trim(); });
                    for (let i = 0; i < roles.length; i++) {
                        let role = roles[i];
                        $('input[name="userRole"][value="' + role + '"]').prop('checked', true);
                    }
                }

                // 권한 hidden도 같이 세팅(수정 시 서버로 userAuth 보내기)
                $('#userAuthJoined').val(rolesStr);

                // 권한 체크 후 오케이로드 영역 토글
                toggleUserOptionZone();

                //  소속(bizDivCd) 세팅
                $('input[name="bizDivCd"]').prop('checked', false);

                let biz = (mData.bizDivCd || '').trim(); // ex) "APPLY"
                if (biz !== '') {
                    $('input[name="bizDivCd"][value="' + biz + '"]').prop('checked', true);
                }
                $('#deptCd').val(mData.deptCd || '');

                // 회사코드(siteCdList) 체크 세팅
                $('input[name="companyCodes"]').prop('checked', false);

                let siteStr = (mData.siteCdList || '').trim(); // ex) "0003"
                if (siteStr !== '') {
                    let codes = siteStr.split(',').map(function (c) { return ('' + c).trim(); });

                    for (let i = 0; i < codes.length; i++) {
                        let code = codes[i];
                        $('input[name="companyCodes"][value="' + code + '"]').prop('checked', true);
                    }

                    let total = $('input[name="companyCodes"]').length;
                    let checked = $('input[name="companyCodes"]:checked').length;
                    $('#checkAllCompany').prop('checked', total === checked);

                } else {
                    // ✅ siteCdList가 비어있으면 "전체" 컨셉
                    // 단, GUARD면 전체 개념 없음(1개만 허용) → 모두 해제해서 사용자가 고르게
                    if (isGuardSelected()) {
                        $('input[name="companyCodes"]').prop('checked', false);
                        $('#checkAllCompany').prop('checked', false);
                    } else {
                        $('input[name="companyCodes"]').prop('checked', true);
                        $('#checkAllCompany').prop('checked', true);
                    }
                }

                //  GUARD 룰 적용(1개 제한/전체선택 disabled)
                syncCompanySelectRule();

                // 이벤트 재바인딩(동적 렌더링 대비)
                bindRoleEvents();
                bindCompanyEvents();

                document.getElementById("openPanel").click();
            },
            error: function () {
                showMsg('error', '오류', '오류가 발생했습니다.');
            }
        });
    }


    $('#btnSave').off('click').on('click', function () {
        if (validateForm('add')) {
            showConfirmSwal('', '추가하시겠습니까?').then(function (result) {
                if (result.isConfirmed) doSave();
            });
        }
    });

    // 수정
    $('#btnEdit').off('click').on('click', function () {
        if (validateForm('edit')) {
            showConfirmSwal('', '수정하시겠습니까?').then(function (result) {
                if (result.isConfirmed) doEdit();
            });
        }
    });

    // 삭제
    $('#btnDelete').off('click').on('click', function () {
        showConfirmSwal('', '삭제하시겠습니까?').then(function (result) {
            if (result.isConfirmed) doDelete();
        });
    });

    //추가 validate
    function validateForm(formMode) {

        const checkedRoleCount = $('input[name="userRole"]:checked').length;
        const userName = ($('#insUserName').val() || '').trim();
        const insUserId = ($('#insUserId').val() || '').trim();
        const insUserPw = ($('#insUserPw').val() || '').trim();
        const insUserPwConfirm = ($('#insUserPwConfirm').val() || '').trim();
        const userTel = ($('#insUserTel').val() || '').trim();
        const userMail = ($('#insUserMail').val() || '').trim();

        const regExp = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d!@#$%^&*()\-+=<>?/[\]{},.:;]{6,20}$/;

        if (checkedRoleCount === 0) {
            return showValidationError('권한을 하나 이상 선택하세요.');
        }

        // 현장관리자 소속 선택 필수
        const guard = isGuardSelected();
        const fieldUser = isFieldUserSelected();

        // ✅ 소속: 현장관리자 + 현장사용자 둘 다 필수
        if (guard || fieldUser) {

            const deptCd = $('#deptCd').val() || '';

            if (!deptCd) {
                return showValidationError('소속을 선택하세요.', '#deptCd');
            }
        }

        // ✅ 화면 선택: 현장사용자만 필수
        if (fieldUser) {

            const bizDivCd = $('input[name="bizDivCd"]:checked').val() || '';

            if (!bizDivCd) {
                return showValidationError('현장사용자 화면(접수/처리)을 선택하세요.');
            }
        }

        if (!userName) {
            return showValidationError('이름을 입력하세요.', '#insUserName');
        }

        if (formMode == 'add') {
            if (!insUserId) {
                return showValidationError('아이디를 입력하세요.', '#insUserId');
            }
            if (!insUserPw) {
                return showValidationError('비밀번호를 입력하세요.', '#insUserPw');
            }
            if (!insUserPwConfirm) {
                return showValidationError('비밀번호 확인을 입력하세요.', '#insUserPwConfirm');
            }
            if (insUserPw != insUserPwConfirm) {
                return showValidationError('비밀번호가 맞지 않습니다.', '#insUserPw');
            }
            if (!regExp.test(insUserPw)) {
                return showValidationError('비밀번호는 영문, 숫자를 포함한 6자리이상 20자리 이하입니다.', '#insUserPw');
            }
        } else {
            if (insUserPw || insUserPwConfirm) {
                if (insUserPw !== insUserPwConfirm) {
                    return showValidationError('비밀번호가 맞지 않습니다.', '#insUserPw');
                }
                if (!regExp.test(insUserPw)) {
                    return showValidationError('비밀번호는 영문, 숫자를 포함한 6자리이상 20자리 이하입니다.', '#insUserPw');
                }
            }
        }

        const checkedCompanyCount = $('input[name="companyCodes"]:checked').length;
        if (checkedCompanyCount === 0) {
            return showValidationError('관리대상을 하나 이상 선택하세요.');
        }

        // GUARD 권한 포함이면 관리대상 1개만 허용
        if (isGuardSelected() && checkedCompanyCount > 1) {
            return showValidationError('현장관리자는 관리대상을 1개만 선택할 수 있어요.');
        }

        if (formMode == 'add' && isUserIdChecked == false) {
            return showValidationError('아이디 중복확인을 해주세요.', '#insUserId');
        }

        const cleanTel = userTel.replace(/[^0-9]/g, '').slice(0, 11);

        if (cleanTel && !/^01[016789]\d{7,8}$/.test(cleanTel)) {
            return showValidationError('올바른 전화번호 형식이 아닙니다.', '#insUserTel');
        }

        if (userMail && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(userMail)) {
            return showValidationError('올바른 이메일 형식이 아닙니다.', '#insUserMail');
        }

        return true;
    }

    function showValidationError(message, focusSelector) {
        showSwal('warning', '확인', message).then(function () {
            if (focusSelector) {
                $(focusSelector).focus();
            }
        });
        return false;
    }


    // 신규등록
    function doSave() {
        handleMemberAction("/admin/insertAdminUser", "추가 완료되었습니다.", () => {
            init();
            doSearch(1);
        });
    }

    // 수정
    function doEdit() {
        handleMemberAction("/admin/updateAdminUser", "수정이 완료되었습니다.", () => {
            doSearch(1);
        });
    }

    // 삭제
    function doDelete() {
        handleMemberAction("/admin/deleteAdminUser", "삭제 완료되었습니다.", () => {
            init();
            document.getElementById("closePanel").click();
            doSearch(1);
        });
    }

    function handleMemberAction(url, successMessage, afterSuccessFn = null) {

        $('#alertModal').modal('hide');

        let selectedCodes = '';

        if ($('#checkAllCompany').is(':checked')) {
            // ✅ 전체면 아예 파라미터 안 보냄
            $('#siteCodesJoined').val('');
            $('#siteCodesJoined').removeAttr('name');
        } else {
            selectedCodes = $('input[name="companyCodes"]:checked')
                .map(function () { return this.value; })
                .get()
                .join(',');

            $('#siteCodesJoined').attr('name', 'siteCodesJoined');
            $('#siteCodesJoined').val(selectedCodes);
        }

        // ✅ 권한(userAuth) 콤마로 합쳐서 hidden에 세팅
        let userAuthJoined = $('input[name="userRole"]:checked')
            .map(function(){ return this.value; })
            .get()
            .join(',');

        $('#userAuthJoined').val(userAuthJoined);

        const cleanTel = ($('#insUserTel').val() || '').replace(/[^0-9]/g, '').slice(0, 11);
        let formData = $('#frmMember').serialize();
        formData = formData.replace(/userTel=[^&]*/g, 'userTel=' + encodeURIComponent(cleanTel));

        $.ajax({
            url: url,
            type: "post",
            dataType: 'json',
            data: formData,
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            success: function (data) {

                const msg = (data.code === '0000')
                    ? successMessage
                    : (data.message || '처리 중 오류가 발생했습니다.');

                if (data.code === '0000') {

                    showSuccessSwal(msg).then(function () {

                        if (afterSuccessFn) {
                            afterSuccessFn();
                        }

                    });

                } else {

                    showMsg('error', '오류', msg);

                }
            },
            error: function () {

                showMsg('error', '오류', '오류가 발생했습니다.');

            }
        });
    }

    // 아이디 중복확인
    $('#btnCheckUserId').off('click').on('click', function () {

        const userId = ($('#insUserId').val() || '').trim();

        if (!userId) {
            showValidationError('아이디를 입력해주세요.', '#insUserId');
            return;
        }

        $.ajax({
            url: '/admin/checkUserId',
            type: 'get',
            data: { insUserId: userId },
            success: function (res) {

                if (res.code === '9999') {
                    showMsg('error', '오류', res.message || '사용할 수 없는 아이디입니다.');
                    isUserIdChecked = false;
                } else {
                    showSuccessSwal('사용 가능한 아이디입니다.').then(function () {
                        $('#btnCheckUserId').removeClass('btn-dark');
                        $('#btnCheckUserId').addClass('btn-secondary');
                        $('#btnCheckUserId').text('확인완료');
                        isUserIdChecked = true;
                    });
                }
            },
            error: function () {
                showMsg('error', '오류', '중복 확인 중 오류가 발생했습니다.');
                isUserIdChecked = false;
            }
        });
    });

    function toggleUserOptionZone() {

        const guard = isGuardSelected();
        const fieldUser = isFieldUserSelected();

        // ✅ 소속: 현장관리자 + 현장사용자 둘 다 노출
        if (guard || fieldUser) {
            $('#deptZone').show();
        } else {
            $('#deptZone').hide();
            $('#deptCd').val('');
        }

        // ✅ 화면: 현장사용자만 노출
        if (fieldUser) {
            $('#bizDivZone').show();
        } else {
            $('#bizDivZone').hide();
            $('input[name="bizDivCd"]').prop('checked', false);
        }
    }
    $("#insUserTel").on("input", function () {
        let val = this.value.replace(/[^0-9]/g, '').slice(0, 11);

        if (val.length > 3 && val.length <= 7) {
            val = val.replace(/(\d{3})(\d+)/, "$1-$2");
        } else if (val.length > 7) {
            val = val.replace(/(\d{3})(\d{4})(\d{0,4})/, "$1-$2-$3");
        }

        this.value = val;
    });
</script>

</html>