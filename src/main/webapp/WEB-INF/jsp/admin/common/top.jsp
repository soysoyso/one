<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<sec:authorize access="isAuthenticated()">
    <sec:authentication property="principal" var="me"/>
</sec:authorize>
<header>
    <div class="header">
        <div class="container">
            <div class="d-flex">
                <div class="logo">YIDO 인프라 운영관리 시스템</div>
                <div class="menu">
                  <!-- 사고접수: ATH100(최고) or ATH400(사고접수)만 -->
                  <sec:authorize access="hasAnyAuthority('ATH100','ATH400')">
                    <a href="/admin/dashboard">사고접수</a>
                  </sec:authorize>

                  <!-- 현장관리: ATH100(최고) or ATH200(현장)만 -->
                  <sec:authorize access="hasAnyAuthority('ATH100','ATH200')">
                    <a href="/admin/ims/dashboard">현장관리</a>
                    <a href="/admin/daily-checks">일상점검</a>
                    <a href="/admin/situation-logs">상황일지</a>
                  </sec:authorize>

                  <!-- 관리자설정: ATH100(최고)만 -->
                  <sec:authorize access="hasAuthority('ATH100')">
                    <a href="/admin/user/setting">관리자설정</a>
                  </sec:authorize>
                </div>
            </div>
            <div class="d-flex" style="align-items: center;">
                <div class="me-3"><i class="bi bi-person-circle me-1"></i>${me.userName}님</div>
                <div class="me-3" data-bs-toggle="modal" data-bs-target="#myPage" style="cursor: pointer;">회원정보수정</div>
                <div id="logoutBtn" data-bs-toggle="modal" data-bs-target="#logout">logout <i class="bi bi-box-arrow-right ms-1"></i></div>
            </div>
        </div>
    </div>
</header>

<!-- Modal -->
<div class="modal fade" id="myPage" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title fs-5" id="staticBackdropLabel">회원 정보 수정</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">

                <form id="userForm">
                <div class="mb-3">
                    <label class="form-label">아이디</label>
                    <div class="d-flex" style="gap: 5px;">
                        <input type="text" class="form-control form-control-a"
                            id="userId" name="userId" readonly="readonly" value="${me.userId}"
                            style="background-color: rgb(233, 236, 239); color: rgb(108, 117, 125);">

                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label">이름</label>
                    <input type="text" class="form-control form-control-a"
                        id="userNm" name="userNm" value="${me.userName}">
                </div>
                <div class="mb-3">
                    <label class="form-label">전화번호</label>
                    <input type="tel" class="form-control form-control-a"
                        id="userTel" name="userTel" value="${me.userTel}">
                </div>
                <div class="mb-3">
                    <label class="form-label">이메일</label>
                    <input type="email" class="form-control form-control-a"
                        id="userMail" name="userMail" value="${me.userMail}">
                </div>
                <div class="password-change-box">
                    <%--<div class="password-box-title">비밀번호 변경</div>--%>

                    <div class="mb-3">
                        <label class="form-label">기존 비밀번호</label>
                        <input type="password" class="form-control form-control-a"
                            id="currentPassword" name="currentPassword" autocomplete="current-password">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">변경할 비밀번호</label>
                        <input type="password" class="form-control form-control-a"
                            id="newPassword" autocomplete="new-password" autocomplete="new-password">
                    </div>

                    <div class="mb-2">
                        <label class="form-label">비밀번호 확인</label>
                        <input type="password" class="form-control form-control-a"
                            id="newPassword2" autocomplete="new-password">
                        <input type="hidden" id="password" name="password" value="">
                    </div>
                    <div class="mb-2">
                        <small class="text-danger d-block mt-1 ms-1">
                            * 비밀번호는 영문, 숫자를 포함한 6자리 이상 20자리 이하입니다.<br>
                            * 특수문자는 ! @ # $ % ^ & * ( ) - + = < > ? / [ ] { } , . : ; 가능합니다.
                        </small>
                    </div>
                </div>
                </form>
            </div>
            <div class="modal-footer" style="justify-content: space-between;">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">창닫기</button>
                <button type="button" id="btnModify" class="btn btn-primary">수정</button>
            </div>
        </div>
    </div>
</div>
