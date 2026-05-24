<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<div class="modal fade default" id="logout" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4>안내</h4>
            </div>
            <div class="modal-body">
                <p>로그아웃 하시겠습니까?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary"  onclick="location.href='/logout'">확인</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade default" id="sendUrlModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true" style="z-index:99999">
    <div class="modal-dialog  modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h4>안내</h4>
            </div>
            <div class="modal-body">
                <p id="sendUrlMessage">
                해당 전화번호(<strong id="sendUrlPhone"></strong>)로 URL을 전송하시겠습니까?
                </p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" id="sendUrlConfirmBtn">확인</button>
            </div>
        </div>
    </div>
</div>

<!-- 사고접수 등록/수정 모달 -->
<div class="modal fade default" id="insertSosModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true" style="z-index:99999">
    <div class="modal-dialog  modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h4>안내</h4>
            </div>
            <div class="modal-body">
                <p id="insertSosMessage"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" id="insertSosConfirmBtn">확인</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade default" id="toastAlertModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true" style="z-index:99999">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body" style="padding: 50px 0;">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-patch-exclamation-fill" viewBox="0 0 16 16">
                    <path d="M10.067.87a2.89 2.89 0 0 0-4.134 0l-.622.638-.89-.011a2.89 2.89 0 0 0-2.924 2.924l.01.89-.636.622a2.89 2.89 0 0 0 0 4.134l.637.622-.011.89a2.89 2.89 0 0 0 2.924 2.924l.89-.01.622.636a2.89 2.89 0 0 0 4.134 0l.622-.637.89.011a2.89 2.89 0 0 0 2.924-2.924l-.01-.89.636-.622a2.89 2.89 0 0 0 0-4.134l-.637-.622.011-.89a2.89 2.89 0 0 0-2.924-2.924l-.89.01zM8 4c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 4.995A.905.905 0 0 1 8 4m.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2"/>
                </svg>
                <div id="toastTxt" class="fw-bold" style="padding-top: 20px;"></div>
            </div>

        </div>
    </div>
</div>

<!-- 일반 modal -->
<div class="modal fade" id="noticeAlert" tabindex="-1" aria-labelledby="alert" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-patch-exclamation-fill" viewBox="0 0 16 16">
                    <path d="M10.067.87a2.89 2.89 0 0 0-4.134 0l-.622.638-.89-.011a2.89 2.89 0 0 0-2.924 2.924l.01.89-.636.622a2.89 2.89 0 0 0 0 4.134l.637.622-.011.89a2.89 2.89 0 0 0 2.924 2.924l.89-.01.622.636a2.89 2.89 0 0 0 4.134 0l.622-.637.89.011a2.89 2.89 0 0 0 2.924-2.924l-.01-.89.636-.622a2.89 2.89 0 0 0 0-4.134l-.637-.622.011-.89a2.89 2.89 0 0 0-2.924-2.924l-.89.01zM8 4c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 4.995A.905.905 0 0 1 8 4m.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2"/>
                </svg>
                <span id="noticeTxt2"></span>
                <div class="mt-4">
                    <button type="button" class="" data-bs-dismiss="modal">확인</button>
                </div>
            </div>
        </div>
    </div>
</div>


<div class="modal fade default" id="default" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h4>안내</h4>
            </div>
            <div class="modal-body">
                <p id="noticeTxt">해당 요청이 실패하였습니다.<br>다시 시도 부탁드립니다.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal">확인</button>
            </div>
        </div>
    </div>
</div>


<!-- 대시보드에 알림메세지 표출 -->
<div class="toast show" role="alert" id="incident-created-toast" aria-live="assertive" aria-atomic="true" style="display:none">
    <div class="d-flex">
        <div class="toast-body">
            <i class="bi bi-exclamation-triangle-fill"></i> 사고가 접수되었습니다.
        </div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
</div>

<!-- 전화 접수 사고 처리 모달 -->
<div class="modal fade" id="phoneApplication" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
<div class="modal-dialog modal-dialog-centered">
<div class="modal-content">
    <div class="modal-header bg-danger">
        <h5 class="modal-title">전화 접수 사고 처리</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
    </div>
    <div class="modal-body">
        <h5>전화 신고 등록</h5>
        <div class="box">
            <div class="row mb-3">
                <div class="col-12">
                    <label for="phoneNumber" class="form-label">전화번호<span class="danger">*</span></label>
                </div>
                <div class="col-auto pe-0">
                    <input type="tel" class="form-control" id="sendPhoneNumber"
                           inputmode="numeric" maxlength="13" autocomplete="tel">

                </div>
                <div class="col-auto">
                    <button type="button" class="btn btn-primary" id="btnSendUrl">URL 전송</button>
                </div>

                <div class="invalid-feedback" id="feedbackTel"></div>
            </div>
            <p class="danger">* 전화로 접수한 신고자에게 SMS 링크를 발송하여 위치 정보를 수집합니다.</p>
        </div>
        <h5>전화 접수 처리 과정</h5>
        <div class="box">
            <p>
                1. 사고자 전화 사고 접수<br>
                2. SMS로 신고 접수 링크 전송<br>
                3. 신고자가 모바일에서 위치 정보 전송<br>
                4. 위치 및 사고 접수 번호 생성<br>
                5. 사고자 유선 재연락 및 처리 안내<br>
                6. 관리자 CCTV 위치 확인 후 사고 처리
            </p>
        </div>
    </div>
</div>
</div>
</div>


<div class="modal fade" id="alertModal" tabindex="-1" aria-labelledby="alert" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-patch-exclamation-fill" viewBox="0 0 16 16">
                    <path d="M10.067.87a2.89 2.89 0 0 0-4.134 0l-.622.638-.89-.011a2.89 2.89 0 0 0-2.924 2.924l.01.89-.636.622a2.89 2.89 0 0 0 0 4.134l.637.622-.011.89a2.89 2.89 0 0 0 2.924 2.924l.89-.01.622.636a2.89 2.89 0 0 0 4.134 0l.622-.637.89.011a2.89 2.89 0 0 0 2.924-2.924l-.01-.89.636-.622a2.89 2.89 0 0 0 0-4.134l-.637-.622.011-.89a2.89 2.89 0 0 0-2.924-2.924l-.89.01zM8 4c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 4.995A.905.905 0 0 1 8 4m.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2"/>
                </svg>
                <span id="alertTxt">저장하시겠습니까?</span>
                <div class="mt-4">
                    <button type="button" class="btn bg-secondary" data-bs-dismiss="modal">취소</button>
                    <button type="button" class="btn btn-primary" id="alertBtn">확인</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>

    function showToastMsg(msg, hideMs) {
        var ms = hideMs || 1000;
        $('#toastTxt').text(msg);
        $('#toastAlertModal').modal('show');
        setTimeout(() => { $('#toastAlertModal').modal('hide'); }, ms);
    }

</script>