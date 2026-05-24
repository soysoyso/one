<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%request.setAttribute("pageTitle", "마이페이지");%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<sec:authorize access="isAuthenticated()">
    <sec:authentication property="principal" var="me"/>
</sec:authorize>

<%@include file="../common/head.jsp" %>
<%@include file="../common/header.jsp" %>
<body class="sub">
<div class="container">
<div class="info-zone pt-2">
    <h2><b>${me.userName}</b></h2>
    <p>
        ${siteInfo.siteName}
        <span> ${me.deptNm} </span>
    </p>
</div>


    <form id="userForm">
        <div class="mb-2">
            <label for="userId" class="form-label">사용자 ID</label>
            <input type="text" class="form-control" id="userId" name="userId"
                   value="${me.userId}" readonly disabled>
            <input type="hidden" name="userId" value="${me.userId}">
        </div>

        <div class="mb-2">
            <label for="userNm" class="form-label">사용자 이름</label>
            <input type="text" class="form-control" id="userNm" name="userNm"
                   value="${adminUser.userNm}" readonly disabled>
        </div>

        <div class="password-change-box">
            <%--<div class="password-box-title">비밀번호 변경</div>--%>

            <div class="mb-2">
                <label for="currentPassword" class="form-label">기존 비밀번호</label>
                <input type="password" class="form-control" id="currentPassword" name="currentPassword" autocomplete="current-password">
            </div>

            <div class="mb-2">
                <label for="newPassword" class="form-label">변경할 비밀번호</label>
                <input type="password" class="form-control" id="newPassword" autocomplete="new-password">
            </div>

            <div class="mb-2">
                <label for="newPassword2" class="form-label">비밀번호 재입력</label>
                <input type="password" class="form-control" id="newPassword2" autocomplete="new-password">
                <input type="hidden" id="password" name="password" value="">
            </div>
            <div class="mb-2">
                <small class="text-danger d-block mt-1">
                    * 비밀번호는 영문, 숫자를 포함한 6자리 이상 20자리 이하입니다.<br>
                    * 특수문자는 ! @ # $ % ^ & * ( ) - + = < > ? / [ ] { } , . : ; 가능합니다.
                </small>
            </div>
        </div>

        <div class="mb-2">
            <label for="userTel" class="form-label">전화번호</label>
            <input type="tel" class="form-control" id="userTel" name="userTel" value="${adminUser.userTel}">
        </div>

        <div class="mb-2">
            <label for="userMail" class="form-label">이메일</label>
            <input type="email" class="form-control" id="userMail" name="userMail" value="${adminUser.userMail}">
        </div>

        <div class="">
            <button type="button" id="btnModify" class="btn btn-primary">수정</button>
        </div>
    </form>
  </div>
</body>

<!-- 로딩 -->
<div id="loadingBox" class="loading-box" style="display: none;">
  <div class="spinner"></div>
  <p>Loading...</p>
</div>

</html>
<script>
    $(document).ready(function () {
        let val = ($("#userTel").val() || '').replace(/[^0-9]/g, '');

        if (val.length === 11) {
            val = val.replace(/(\d{3})(\d{4})(\d{4})/, "$1-$2-$3");
        } else if (val.length === 10) {
            val = val.replace(/(\d{3})(\d{3})(\d{4})/, "$1-$2-$3");
        }

        $("#userTel").val(val);
    });

    $('#btnModify').on('click', function () {

        var currentPassword = $("#currentPassword").val();
        var newPassword = $("#newPassword").val();
        var newPassword2 = $("#newPassword2").val();

        var userTel = $("#userTel").val();
        var userMail = $("#userMail").val();
        var regExp = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d!@#$%^&*()\-+=<>?/[\]{},.:;]{6,20}$/;

        // 비번 변경 시: 기존비번 + 새비번 + 재입력 모두 필요
        if (newPassword || newPassword2 || currentPassword) {
            if (!currentPassword) {
                alert("기존 비밀번호를 입력해주세요.");
                return false;
            }
            if (!newPassword || !newPassword2) {
                alert("변경할 비밀번호를 두 칸 모두 입력해주세요.");
                return false;
            }
            if (newPassword != newPassword2) {
                alert("변경할 비밀번호가 일치하지 않습니다.");
                return false;
            }

            if (!regExp.test(newPassword)) {
                alert("비밀번호는 영문, 숫자를 포함한 6자리 이상 20자리 이하입니다.");
                return false;
            }

            $("#password").val(newPassword);
        } else {
            $("#password").val(""); // 변경 안 함
        }

        // 전화번호
        var cleanTel = (userTel || '').replace(/[^0-9]/g, '');

        if (cleanTel && !/^01[016789]\d{7,8}$/.test(cleanTel)) {
            alert("올바른 전화번호 형식이 아닙니다.");
            return false;
        }

        // 서버 전송용 포맷 맞추기 (하이픈)
        if (cleanTel.length === 11) {
            userTel = cleanTel.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
        } else if (cleanTel.length === 10) {
            userTel = cleanTel.replace(/(\d{3})(\d{3})(\d{4})/, '$1-$2-$3');
        }

        $("#userTel").val(cleanTel);

        // 이메일
        if (userMail && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(userMail)) {
            alert("올바른 이메일 형식이 아닙니다.");
            return false;
        }

        if (!confirm("수정하시겠습니까?")) return false;

        showLoading();

        $.ajax({
            url: '/user/personalInfoSave',
            type: "post",
            dataType: 'json',
            data: $('#userForm').serialize(),
            contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
            success: function (data) {
                if (data.result) {
                    alert("개인 정보가 수정 되었습니다.");
                    hideLoading();
                    location.reload();
                } else {
                    alert(data.message || "처리 실패");
                    hideLoading();
                }
            },
            error: function () {
                alert('개인 정보 수정 중 오류가 발생하였습니다.');
                hideLoading();
            }
        });
    });


    function showLoading() {
    $("#loadingBox").fadeIn();
    }

    function hideLoading() {
    $("#loadingBox").fadeOut();
    }

    $("#userTel").on("input", function () {
        let val = this.value.replace(/[^0-9]/g, '').slice(0, 11);

        if (val.length > 3 && val.length <= 7) {
            val = val.replace(/(\d{3})(\d+)/, "$1-$2");
        } else if (val.length > 7) {
            val = val.replace(/(\d{3})(\d{4})(\d{0,4})/, "$1-$2-$3");
        }

        this.value = val;
    });
</script>
<style>
.password-change-box {
    margin: 18px 0;
    padding: 16px;
    border: 1px solid #f3b6b6;
    background: #fff5f5;
    border-radius: 12px;
}

.password-box-title {
    font-weight: 700;
    color: #d63333;
    margin-bottom: 12px;
}

.password-change-box .form-label {
    color: #333;
    font-weight: 600;
}

.password-change-box .form-control {
    background-color: #fff;
}
</style>
