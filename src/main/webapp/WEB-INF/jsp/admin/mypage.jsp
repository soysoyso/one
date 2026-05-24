<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@include file="./common/head.jsp"%>
<%@include file="./common/script.jsp"%>
<body>
    <%@include file="./common/top.jsp"%>
<div class="container content">
  <div><h3>마이페이지</h3></div>
  <div class="search-zone">
    <form id="userForm">
      <div class="row mb-3">
        <label for="userId" class="col-sm-3 control-label">사용자 ID</label>
        <div class="col-sm-3">
          <input type="text" class="form-control" id="userId" placeholder="" name="userId" required=""
                 value="${user.userId}" readonly disabled>
          <input type="hidden" name="userId" value="">
        </div>
      </div>
      <div class="row mb-3">
        <label for="userNm" class="col-sm-3 control-label">사용자 이름</label>
        <div class="col-sm-3">
          <input type="text" class="form-control" id="userNm" placeholder="" name="userNm" required=""
                 value="" readonly disabled>
        </div>
      </div>
      <div class="row mb-3">
        <label for="password1" class="col-sm-3 control-label">변경할 패스워드</label>
        <div class="col-sm-3">
          <input type="password" class="form-control" id="password1" placeholder="" name="password1"
                 required="" autocomplete="new-password">
        </div>
      </div>
      <div class="row mb-3">
        <label for="password2" class="col-sm-3 control-label">패스워드 재입력</label>
        <div class="col-sm-3">
          <input type="password" class="form-control" id="password2" placeholder="" name="password2"
                 required="" autocomplete="new-password">
        </div>
        <input type="hidden" class="form-control" id="password" placeholder="" name="password" value=""
               required="">
      </div>
      <div class="row mb-3">
        <label for="userTel" class="col-sm-3 control-label">전화번호 (선택)</label>
        <div class="col-sm-5">
          <input type="tel" class="form-control" id="userTel" placeholder="" name="userTel" required=""
                 value="">
        </div>
      </div>
      <div class="row mb-3">
        <label for="userMail" class="col-sm-3 control-label">이메일 (선택)</label>
        <div class="col-sm-5">
          <input type="email" class="form-control" id="userMail" placeholder="" name="userMail" required=""
                 value="">
        </div>
      </div>
      <div class="row mb-3">
        <div class="col">
          <button type="button" id="btnModify" class="btn">수정</button>
        </div>
      </div>
    </form>
  </div>
</div>
</body>
</html>

<!-- 로딩 -->
<div id="loadingBox" class="loading-box" style="display: none;">
  <div class="spinner"></div>
  <p>Loading...</p>
</div>

<script>

  function showLoading() {
    $("#loadingBox").fadeIn();
  }

  function hideLoading() {
    $("#loadingBox").fadeOut();
  }

  $("#password1").on("click", function () {
    $("#password1").val("");
    $("#password2").val("");
  });

  $('#userTel').on('input', function () {
    this.value = this.value.replace(/[^0-9]/g, '');
  });


  $('#btnModify').on('click', function () {
    var pass1 = $("#password1").val();
    var pass2 = $("#password2").val();
    var userTel = $("#userTel").val();
    var userMail = $("#userMail").val();

    if (pass1 == pass2) {
      $("#password").val(pass1);
    } else {
      alert("비밀번호가 일치 하지 않습니다.");
      return false;
    }

    // 전화번호 정규식 체크 (값이 있을 경우만)
    if (userTel && !/^01[016789]-?\d{3,4}-?\d{4}$/.test(userTel)) {
      alert("올바른 전화번호 형식이 아닙니다.");
      return false;
    }

    // 이메일 정규식 체크 (값이 있을 경우만)
    if (userMail && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(userMail)) {
      alert("올바른 이메일 형식이 아닙니다.");
      return false;
    }


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
          alert(data.message);
          hideLoading();
        }
      },
      error: function (data) {
        alert('개인 정보 수정 중 오류가 발생하였습니다.');
        hideLoading();
      }
    });
  });
</script>

</html>