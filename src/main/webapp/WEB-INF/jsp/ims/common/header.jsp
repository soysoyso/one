<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<div class="header">
    <div class="back fs-3" onclick="history.back();"><i class="bi bi-arrow-left-short"></i></div>
    <div class="title">${not empty pageTitle ? pageTitle : "기본 제목"}</div>
    <div class="menu fs-3" data-bs-toggle="offcanvas" data-bs-target="#offcanvasRight" aria-controls="offcanvasRight"><i class="bi bi-list"></i></div>
</div>
<jsp:include page="../common/menu.jsp" />
<%@include file="../common/modal.jsp" %>