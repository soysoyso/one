<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<sec:authorize access="isAuthenticated()">
    <sec:authentication property="principal" var="me"/>
    <c:set var="loginUserId" value="${me.userId}" scope="request"/>
</sec:authorize>

<div class="offcanvas offcanvas-end" tabindex="-1" id="offcanvasRight" aria-labelledby="offcanvasRightLabel">
    <div class="offcanvas-header" data-bs-dismiss="offcanvas" aria-label="Close">
        <button type="button" class="btn-close"></button>
    </div>
    <div class="offcanvas-body pt-0">
        <div class="info-zone">
            <div>
                <h2><b>${me.userName}</b>님, <span>감사합니다.</span></h2>
                <p>
                    ${siteInfo.siteName}
                    <span> ${me.deptNm} </span>
                </p>
            </div>
        </div>
        <div class="card mb-2" onclick="location.href='/manage'">
            홈으로 가기
        </div>
        <div class="card mb-2" onclick="location.href='/pothole/report'">
            접수하기
        </div>
        <div class="card mb-2" onclick="location.href='/pothole/list'">
            접수내역 확인하기
        </div>
        <div class="card mb-2" onclick="location.href='/manage/daily-checks/form'">
            일상점검 작성
        </div>
        <div class="card mb-2" onclick="location.href='/ims/auth/mypage'">
            마이페이지
        </div>
        <c:if test="${loginUserId eq 'ims14a'}">
            <div class="card mb-2" id="install-btn">
                홈 화면에 추가
            </div>
        </c:if>
        <%--<div class="card" onclick="location.href='/ims/auth/setting'">
            설정
        </div>--%>
        <div class="logout" onclick="location.href='/logout'">
            로그아웃
        </div>
    </div>
</div>

<div class="modal fade" id="ios-guide-modal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body">
                <div>
                    <div class="text-center">
                        <h2 class="display-2"><i class="bi bi-apple"></i></h2>
                        <p>
                            ios는 바로가기를 지원하지 않습니다.<br>
                            아래 방법에 따라 진행해주세요!
                        </p>
                    </div>
                    <div class="border rounded p-3 mb-3">
                        <h5><strong>Safari</strong></h5>
                        <p class="mb-0">
                            1. 우측 하단 '<strong class="text-primary"><i class="bi bi-three-dots"></i></strong>' 클릭<br>
                            2. '<strong class="text-primary"><i class="bi bi-box-arrow-up"></i> 공유</strong>' 클릭<br>
                            3. '<strong class="text-primary">홈 화면에 추가</strong>' 클릭
                        </p>
                    </div>
                    <div class="border rounded p-3">
                        <h5><strong>Chrome</strong></h5>
                        <p class="mb-0">
                            1. 우측 상단 '<strong class="text-primary"><i class="bi bi-box-arrow-up"></i></strong>' 클릭<br>
                            2. '<strong class="text-primary">홈 화면에 추가</strong>' 클릭
                        </p>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-primary" data-bs-dismiss="modal">확인</button>
            </div>
        </div>
    </div>
</div>
