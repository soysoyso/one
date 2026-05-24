<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@include file="./common/head.jsp"%>
<%@include file="./common/script.jsp"%>

<body>
  <div class="login">
    <div class="container">
            <div class="logo">
                <img src="../img/logo-yido.svg" class="img-fluid mb-5" style="width: 150px;">
            </div>
            <div class="login-form">
                <h5 class="mb-3"><b>도로 운영 관리 시스템</b></h5>
                <form id="fmrLogin" action="/auth/checkLogin" method="post" novalidate="novalidate">
                    <input type="hidden" name="loginType" value="admin">
                    <div class="mb-3">
                        <input type="text" class="form-control" placeholder="Id" name="userId" id="userId" required="" aria-required="true" value="${userId}" autofocus>
                    </div>
                    <div class="mb-3">
                        <input type="password" class="form-control" placeholder="password" name="userPwd" id="userPwd" required="" aria-required="true" value="${userPw}">
                    </div>
                    <div class="form-check mb-3">
                        <input type="checkbox" name="rememberMe" id="rememberMe">
                        <label for="rememberMe">자동로그인</label>
                    </div>
                    <div>
                        <button type="submit" class="btn btn-primary auth-form-btn" >Login</button>
                    </div>
                </form>
            </div>
        </div>
        <button type="button" data-bs-toggle="modal" data-bs-target="#noticeAlert" style="display:none"></button>
    </div>
</body>

<script>
$(document).ready(function(){

	if('${errorMessage}' != ''){
        alert('${errorMessage}');
	}

	//$('#fmrLogin').validate();
});

// 로그인 버튼 클릭
$(".auth-form-btn").on("click", function(){
	var userId = $('#userId').val().trim();
	var password = $('#userPwd').val().trim();

	if (userId == "") {
		alert('아이디를 입력해주세요.');
		return;
	}
	if (password == "") {
		alert('비밀번호를 입력해주세요.');
		return;
	}

	$("#fmrLogin").submit();
})

$('#userPwd').on('keyup', function(e){
    if(e.keyCode == 13) $('.auth-form-btn').trigger('click');
});

</script>

</html>
