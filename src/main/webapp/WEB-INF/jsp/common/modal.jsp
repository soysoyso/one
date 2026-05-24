<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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
            <div class="modal-body">
                <h4 class="text-primary">빠른 사고 처리를 위해<br>위치 동의를 켜주세요</h4>
                <p id="locHelp">현재 사고 위치를 확인하기 위해<br>위치 권한이 필요합니다.</p>

                <div class="box mt-3" style="text-align: left;">
                <p class="fs-2 mb-2"><b>위치동의를 해도 계속 위치동의를 요청한다면?</b></p>
                <p class="fs-1">
                    Safari/Chrome/삼성인터넷 의 위치 권한을 켜주세요!<br>
                    * iOS : 설정 > 개인정보 > 위치서비스 > 켜기<br>
                    * Android : 설정 > 위치 > 켜기 > 앱 > 크롬or삼성인터넷 ‘허용’
                </p>
                </div>

                <!--<button type="button" class="btn bg-primary mt-4" id="btnEnableLocation">위치 기능 켜기</button>-->
                <button type="button" class="btn bg-secondary-subtle mt-2" data-bs-dismiss="modal" id="btnCloseModal">닫기</button>
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

<div class="modal fade" id="callModal" data-bs-backdrop="static" data-bs-keyboard="false"
    tabindex="-1" aria-labelledby="callModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h5 class="modal-title" id="callModalLabel">전화 연결 안내</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>
            </div>

            <div class="modal-body" style="padding: 20px 10px;">
                <p class="mb-3">
                    버튼을 눌러 사고를 접수해 주세요.<br/>
                    <small class="text-muted">사고가 신속히 처리되려면 전화 연결이 필요합니다.<br/>
                                              연락처는 전화 연결 후에만 전달됩니다.</small>
                </p>

                <div class="d-grid gap-2">
                    <a id="btnCallConfirm"
                        class="btn bg-danger text-white"
                        role="button"
                        href="tel:${fn:escapeXml(siteInfo.callCenterNo)}"
                        data-tel="${fn:escapeXml(siteInfo.callCenterNo)}">
                        전화연결 ${fn:escapeXml(siteInfo.callCenterNo)}
                    </a>
                    <button type="button" class="btn bg-secondary-subtle" data-bs-dismiss="modal" id="btnCloseModal">
                        취소
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>


<div class="modal fade" id="nearbyHighwaysModal" data-bs-backdrop="static" data-bs-keyboard="false"
     tabindex="-1" aria-labelledby="callModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header py-2">
                <h5 class="modal-title" id="callModalLabel">고속도로 선택</h5>
                <!--
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="닫기"></button>-->
            </div>

            <div class="modal-body" style="padding: 20px 10px;">
                <p class="mb-3" id="nearbyMessage">
                    현재 위치 주변 여러 고속도로가 확인되었습니다.<br/>사고발생 고속도로를 선택해 주세요.<br/>
                    <small class="text-muted">(네비에서 정보를 확인할 수 있습니다.)</small>
                </p>

                <div class="d-grid gap-2" id="nearbyHighways">
                    <a id="btnCallConfirm"
                       class="btn bg-danger text-white"
                       role="button"
                       href="tel:${fn:escapeXml(siteInfo.callCenterNo)}"
                       data-tel="${fn:escapeXml(siteInfo.callCenterNo)}">
                        전화연결 ${fn:escapeXml(siteInfo.callCenterNo)}
                    </a>
                    <button type="button" class="btn bg-secondary-subtle" data-bs-dismiss="modal" id="btnCloseModal">
                        취소
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>
