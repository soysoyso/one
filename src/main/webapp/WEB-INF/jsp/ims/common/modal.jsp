<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="modal fade" id="staticBackdrop" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body">
                <div id="message">
                    <h2>저장하지 않고<br>작성을 취소하시겠습니까?</h2>
                    <p>저장을 원하시면 '저장 후 페이지 나가기'를 클릭해주세요.</p>
                </div>
                <div><img src="/img/icon/icon-modal.png" class="img-fluid mt-2"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal">그냥 페이지 나가기</button>
                <button type="button" class="btn btn-outline-primary">저장 후 페이지 나가기</button>
                <%--<button type="button" class="btn btn-cancel" data-bs-dismiss="modal">취소</button>--%>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="imsConfirmModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body"  style="text-align:center">
                <div>
                    <p id="imsConfirmMessage">작업 내용을 저장하시겠습니까?<br/>
                        완료처리시 관리자화면에서만 수정 가능합니다.</p>
                </div>
                <div><img src="/img/icon/icon-modal.png" class="img-fluid mt-2"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-primary" id="btnWorkConfirm">확인</button>
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal">취소</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="imsDeleteModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body"  style="text-align:center">
                <div>
                    <p id="imsConfirmMessage">삭제하시겠습니까?<br/>
                        삭제한 데이터는 복구가 어렵습니다.</p>
                </div>
                <div><img src="/img/icon/icon-modal.png" class="img-fluid mt-2"></div>
            </div>
            <div class="modal-footer">
                <button type="button" id="btn-delete-confirm" class="btn btn-outline-danger">
                    삭제
                </button>
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
            </div>
        </div>
    </div>
</div>

<div id="loadingOverlay" class="loading-overlay d-none">
    <div class="spinner"></div>
    <p style="margin-top: 10px !important;">처리 중입니다. 잠시만 기다려주세요.</p>
</div>

<div class="modal fade" id="toastAlertModal" tabindex="-1" aria-labelledby="alert" aria-hidden="true" data-bs-backdrop="true">
	<div class="modal-dialog modal-dialog-centered">
		<div class="modal-content">
			<div class="modal-body" style="padding: 50px 0;">
				<svg xmlns="http://www.w3.org/2000/svg" width="30" height="30" fill="currentColor" class="bi bi-patch-exclamation-fill" viewBox="0 0 16 16">
					<path d="M10.067.87a2.89 2.89 0 0 0-4.134 0l-.622.638-.89-.011a2.89 2.89 0 0 0-2.924 2.924l.01.89-.636.622a2.89 2.89 0 0 0 0 4.134l.637.622-.011.89a2.89 2.89 0 0 0 2.924 2.924l.89-.01.622.636a2.89 2.89 0 0 0 4.134 0l.622-.637.89.011a2.89 2.89 0 0 0 2.924-2.924l-.01-.89.636-.622a2.89 2.89 0 0 0 0-4.134l-.637-.622.011-.89a2.89 2.89 0 0 0-2.924-2.924l-.89.01zM8 4c.535 0 .954.462.9.995l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 4.995A.905.905 0 0 1 8 4m.002 6a1 1 0 1 1 0 2 1 1 0 0 1 0-2"/>
				</svg>
				<div id="toastTxt" class="fw-bold" style="padding-top: 20px;"></div>
			</div>
		</div>
	</div>
</div>


<div class="modal fade" id="locModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body" style="word-break: keep-all;">
                <div id="message">
                    <h2>위치동의를 해도<br>계속 위치동의를 요청한다면?</h2>
                    <p>Safari/Chrome/삼성인터넷 의 위치 권한을 켜주세요!</p>
                    <div class="border rounded p-3">
                        <ul class="mb-0 ps-3">
                            <li>iOS : 설정 > 개인정보 > 위치서비스 > 켜기</li>
                            <li>Android : 설정 > 위치 > 켜기 > 앱 > 크롬or삼성인터넷 ‘허용’</li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal" id="btnCloseModal">닫기</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="notLocModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body">
               <p style="margin-bottom: 30px;">위치정보를 얻을 수 없습니다.<br>다시 시도해주세요.</p>
               <a href="tel:${siteInfo.callCenterNo}" class="btn bg-danger" id="btnCall" role="button">
                 전화연결 ${siteInfo.callCenterNo}
               </a>
                <button type="button" class="btn bg-secondary-subtle mt-2" data-bs-dismiss="modal" id="btnCloseModal">닫기</button>
            </div>
        </div>
    </div>
</div>


<!-- STA 중복 도로 선택 모달 -->
<div class="modal fade" id="staRoadChoiceModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title">도로 선택</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <div class="modal-body" style="padding:1em 1em">
                <div class="mb-2" id="staRoadChoiceMsg" style="font-size:13px;">
                    중복되는 도로가 있어 선택이 필요합니다.
                </div>
                <div id="staRoadChoiceList"></div>

                <div class="mt-3">
                    <button type="button" class="btn btn-outline-secondary w-100" data-bs-dismiss="modal">
                        취소
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="imsImgModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body" style="text-align:center; padding: 0; position: relative;">
                <button type="button" class="btn-close position-absolute top-0 end-0 m-2"
                        data-bs-dismiss="modal" style="z-index:10; background-color:rgba(255,255,255,0.8);"></button>
                <img id="imsImgModalSrc" src="" class="img-fluid rounded" style="max-height:80vh; width:100%; object-fit:contain;">
            </div>
        </div>
    </div>
</div>