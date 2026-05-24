<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@include file="../common/head.jsp"%>
<%@include file="../common/script.jsp"%>
<body class="user">
    <div class="container" id="errorMessage" style="display:none">
        존재하지 않는 현장코드입니다.
       </div>
    <div class="container" id="errorMessage2" style="display:none">
        <div style="margin-bottom:20px">존재하지 않는 주문번호입니다.</div>
        <button type="button" class="btn bg-primary" onclick="goMain()">사고접수 메인으로 이동</button>
       </div>
    <div class="container" id="errorMessage3" style="display:none">"
        오류가 발생했습니다.
    </div>

</body>
<script>

const params = new URLSearchParams(window.location.search);
const errorCode = params.get("errorCode");

if (errorCode === "01") $('#errorMessage').css('display','');
else if (errorCode === "02") $('#errorMessage2').css('display','');
else $('#errorMessage3').css('display','');

function goMain() {
    location.href="/sos/main";
}
</script>
</html>