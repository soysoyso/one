<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@include file="../common/head.jsp"%>
<script src="/js/jquery-3.7.1.min.js"></script>
<body class="login">
    <div class="container">
        <div class="login-form">
            <div class="logo">
                <img src="../img/logo.png?v=1.0" class="img-fluid">
            </div>
            <%--<h2 class="mb-4"><b>인프라 운영관리 시스템</b></h2>--%>
            <form id="fmrLogin" action="/auth/checkLogin" method="post" novalidate="novalidate">
                <input type="hidden" name="loginType" value="manage">
                <div class="mb-3">
                    <input type="text" class="card" placeholder="아이디를 입력하세요." name="userId" id="userId"
                           required="" aria-required="true" value="${userId}" autofocus>
                </div>
                <div class="mb-3">
                    <input type="password" class="card" placeholder="비밀번호를 입력하세요." name="userPwd" id="userPwd"
                           required="" aria-required="true" value="${userPw}">
                </div>
                <div class="form-check mb-3 p-0">
                    <input type="checkbox" name="rememberMe" id="rememberMe" checked="checked">
                    <label for="rememberMe">자동로그인</label>
                </div>
                <div>
                    <button type="submit" class="btn btn-primary auth-form-btn">로그인</button>
                </div>
            </form>
        </div>
    </div>
    <div class="footer-logo">
        <img src="../img/logo-yido.svg" class="w-100">
    </div>
    <button type="button" data-bs-toggle="modal" data-bs-target="#noticeAlert" style="display:none"></button>
</body>
<script>
$(document).ready(function(){

	if('${errorMessage}' != ''){
        alert('${errorMessage}');
	}

	//$('#fmrLogin').validate();
});

// 로그인 버튼 클릭
$(".auth-form-btn").on("click", function(e){
    e.preventDefault();

    var userId = $('#userId').val().trim();
    var password = $('#userPwd').val().trim();

    if (userId == "") {
        alert('아이디를 입력해주세요.');
        return false;
    }

    if (password == "") {
        alert('비밀번호를 입력해주세요.');
        return false;
    }

    $("#fmrLogin")[0].submit();
});

</script>
</html>
