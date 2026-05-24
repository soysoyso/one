<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java"  pageEncoding="UTF-8"%>
<%@include file="../common/head.jsp" %>
<%@include file="../common/script.jsp" %>
<body class="user">
<div class="header">
    <h5>고속도로 사고 접수</h5>
</div>

<form id="fileForm" action="fileUpload" method="post" enctype="multipart/form-data">
    <div class="container">

        <div class="box location" id="errorMessage" style="background: none; color: red;display:none">
        </div>

        <!-- 테스트용: 좌표 버튼 (URL ?test=1 일 때만 노출) -->
        <div class="box location" id="testCoordBox"
             style="display:none; margin-top:10px; background-color:#9affac">
            <div class="row g-2" style="padding: 5px 10px;">
                <div class="col-6">
                    <button type="button" class="btn btn-sm btn-outline-secondary w-100" id="btnTest1">
                        test1
                    </button>
                </div>
                <div class="col-6">
                    <button type="button" class="btn btn-sm btn-outline-secondary w-100" id="btnTest2">
                        test2
                    </button>
                </div>
            </div>
        </div>



        <div class="box location" id="locAddress" style="display:none">
            <%-- 고속도로 이름 --%>
            <p id="siteName" style="display:none"><i class="bi bi-geo-alt-fill"></i><%-- 천안논산 고속도로 --%> </p>
            <%-- 위치정보로 획득한 주소 --%>
            <p id="locAddr" style="display:none;font-size:12px"></p>
        </div>

        <div class="process">
            <div class="bar">
                <div class="progress-fill" id="progressFill"></div>
            </div>
            <div class="row">
                <div class="col">
                    <span>1</span>
                    <p>위치 동의</p>
                </div>
                <div class="col-4">
                    <span>2</span>
                    <p>기점 표지판 촬영</p>
                </div>
                <div class="col">
                    <span>3</span>
                    <p class="is-basic">전화 접수</p>
                    <p class="is-unknown" style="display:none">온라인 접수</p>
                </div>
                <div class="col">
                    <span>4</span>
                    <p>갓길 대피</p>
                </div>
            </div>
        </div>
        <div class="">
            <div class="photo-box">
                <label for="photoInput" id="infoPhotoInput" role="button" tabindex="0" aria-label="사진 파일 선택" style="cursor:pointer;">
                    <h2 class="display-1 mb-1 text-danger"><i class="bi bi-camera"></i></h2>
                    <h5 class="text-danger"><b>사진 촬영하기</b></h5>
                    <p class="mt-2 fs-2 is-basic">위치 파악을 위해 기점 표지판 촬영 후 전화신고해주세요.</p>
                    <p class="fs-2 is-basic">(확인이 어려울 경우, 바로 전화신고도 가능합니다.)</p>

                    <p class="mt-2 fs-2 is-unknown" style="display:none">현재 위치를 알 수 있는 기점표지판 또는 큰 표지판을 촬영해주세요.</p>
                </label>
                <div id="imgEx">
                    <img src="/img/ex.jpg" class="w-100 img-ex">
                </div>
            </div>
            <div class="photopreview-box">

                <input id="photoInput" name="photo" type="file" accept="image/*" capture="environment" style="display:none;"/>
                <div id="imageContainer" style="position:relative; display:none; margin:0 auto; max-width:100%;">
                    <img id="photoPreview" alt="미리보기" style="display:block; max-width:100%; height:auto;"/>
                    <canvas id="selectionCanvas" style="position:absolute; top:0; left:0; cursor:crosshair;"></canvas>
                </div>
                <button type="button" id="manualOcr" class="btn btn-danger btn-delete mt-1" style="display:none;width: 150px !important; left: 5px !important; font-size: 18px !important;">
                    표지판 직접선택
                </button>
                <button type="button" id="deleteBtn" class="btn btn-danger btn-delete" style="display:none;">
                    <i class="bi bi-trash"></i>
                </button>
                <button type="button" id="cropAndOcrBtn" class="btn btn-primary mt-2" style="display:none;">
                    선택 영역 OCR 인식
                </button>
            </div>
        </div>
        <!-- 토글 스위치 영역 -->
        <div class="toggle-container">
            <!-- 디버그 모드 토글 -->
            <label class="toggle-switch" for="chkDebugMode">
                <input type="checkbox" id="chkDebugMode">
                <span class="slider debug"></span>
                <span class="toggle-label">🛠 디버그 모드</span>
            </label>

            <!-- 흑백 이진화 토글 -->
            <label class="toggle-switch" for="chkBinaryMode">
                <input type="checkbox" id="chkBinaryMode">
                <span class="slider binary"></span>
                <span class="toggle-label">⚫⚪ 흑백 모드</span>
            </label>
        </div>
        <div class="box" id="ocrResultBox" style="display:none; margin-top:10px;">
            <p style="margin-bottom:5px;">인식 결과</p>
            <div id="ocrText" style="font-size:18px; font-weight:bold; word-break:break-word;"></div>
        </div>

        <input type="hidden" id="siteCd" name="siteCd" value="">
        <input type="hidden" id="siteCdList" name="siteCdList" value="">
        <input type="hidden" id="lat" name="lat">
        <input type="hidden" id="lng" name="lng">
        <input type="hidden" id="accuracyM" name="accuracyM"> <%-- accuracyM:정확도 --%>
        <input type="hidden" id="capturedAt" name="capturedAt"> <%-- capturedAt:좌표취득시간(ISO8601 UTC) --%>
        <input type="hidden" id="coordAgeMs" name="coordAgeMs"> <%-- coordAgeMs:신선도 --%>
        <input type="hidden" id="capturedTs" name="capturedTs">
        <input type="hidden" id="addr" name="addr"> <%-- addr:위도, 경도 값으로 흭득한 주소 --%>
        <input type="hidden" id="intakeMethodCd" name="intakeMethodCd"> <%-- intakeMethodCd:접수방법 --%>
        <input type="hidden" id="statusCd" name="statusCd" value="STS001"> <%-- statusCd:처리상태 --%>
        <input type="hidden" id="ocrReadKm" name="ocrReadKm" value=""> <%-- 인식 km --%>
        <input type="hidden" id="matchedSectionId" name="matchedSectionId" value="">
        <input type="hidden" id="matchType" name="matchType" value="">
        <input type="hidden" id="matchDistanceM" name="matchDistanceM" value="">

    </div>

    <div class="footer">
        <button type="button" class="btn bg-danger mt-0" id="btnCall" data-tel="">
            <b id="txtCallMsg">전화신고하기 </b>
            <p class="fs-1 mt-2">사고 접수시 신속한 구조를 위해<br><b>개인정보 수집</b>에 동의한 것으로 간주합니다.</p>
        </button>
        <div class="btnOnline-box">
            <button type="button" class="btn" id="btnOnline">
                온라인 사고접수
            </button>
            <div id="onlineForm" style="display:none;">
                <p>연락받을 전화번호 <span class="text-danger">(*필수)</span></p>
                <div class="d-flex" style="gap: 5px;">

                    <input type="tel" class="form-control" id="cellPhone" name="cellPhone"
                           inputmode="numeric" pattern="[0-9]*" autocomplete="tel"
                           placeholder="전화번호(- 없이 숫자만)" maxlength="11" enterkeyhint="done"
                           oninput="this.value=this.value.replace(/\D/g,'');">
                    <button type="button" class="btn bg-danger mt-0" id="btnOn">
                        접수
                    </button>
                </div>
                <div class="invalid-feedback" id="feedbackTel"></div>
            </div>

        </div>
    </div>
    <!-- OpenCV 전처리 결과 확인용 모달 -->
    <div class="modal fade" id="debugImageModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">이미지 보정 결과 (OpenCV)</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body text-center">
                    <!-- 캔버스가 여기로 들어오거나 이미지가 표시됨 -->
                    <img id="debugResultImage" style="max-width: 100%; height: auto; border: 2px solid #ccc;"/>
                    <p class="mt-2 text-muted small">※ 표지판 영역이 올바르게 펴졌는지 확인하세요.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
                </div>
            </div>
        </div>
    </div>
</form>
</body>


<%@include file="../common/modal.jsp" %>
<script>

    let intakeMethodCd = "";                        // 접수방법 (MTD001=전화, MTD002=온라인문의)


    document.getElementById("btnOnline").addEventListener("click", function () {

        const form = document.getElementById("onlineForm");
        const box = document.querySelector(".btnOnline-box");

        if (form.style.display === "none") {
            form.style.display = "block";
            box.classList.add("active");
        } else {
            form.style.display = "none";
            box.classList.remove("active");
        }
    });

    // ?test=1 일 때만 테스트 버튼 노출
    (function initTestCoordBox(){
        var sp = new URLSearchParams(location.search);
        if (sp.get('test') === '1') {
            $('#testCoordBox').show();
        }
    })();

    (function () {
        function dialNow(rawTel) {
            var tel = String(rawTel || '').replace(/[^\d+]/g, '');
            if (!tel) {
                alert('전화번호를 찾을 수 없습니다.');
                return;
            }
            // 사용자 제스처 내에서 즉시 전화
            window.location.href = 'tel:' + tel;
        }

        window.addEventListener('DOMContentLoaded', requestPositionOnLoad);

        window.addEventListener('DOMContentLoaded', function () {

            const btn = document.getElementById('btnCall');
            if (!btn) return;
            const btn2 = document.getElementById('btnOn');
            if (!btn2) return;

            // ★ 전화신고 클릭
            btn.addEventListener('click', async function (e) {
                intakeMethodCd = "MTD001";
                e.preventDefault();
                e.stopPropagation();

                const latEl = document.getElementById('lat');
                const lngEl = document.getElementById('lng');
                const hasLatLng = !!(latEl && lngEl && latEl.value && lngEl.value);

                // ★ 신뢰도 체크 준비
                let accuracyM = parseFloat(document.getElementById('accuracyM')?.value || '1e9');
                let ageMs = parseInt(document.getElementById('coordAgeMs')?.value || '0', 10);
                if (!ageMs) {
                    const ts = parseInt(document.getElementById('capturedTs')?.value || '0', 10);
                    if (ts) ageMs = Date.now() - ts;
                }

                // ✅ 모달에서 이미 고속도로/구간을 사용자가 선택했다면 다시 추천/재탐색 안 함
                const pickedSectionId = String($('#matchedSectionId').val() || '');
                const pickedMatchType = String($('#matchType').val() || '');
                const pickedSiteCd = String($('#siteCd').val() || '');

                const isUserPicked =
                    pickedMatchType === 'USER_SELECT' ||
                    pickedMatchType === 'MANUAL' ||
                    (pickedSectionId !== '' && pickedSectionId !== '0') ||
                    (pickedSiteCd !== '');

                if (isUserPicked) {
                    $('#btnCallConfirm')
                        .attr('data-tel', callCenterNo)
                        .attr('href', 'tel:' + callCenterNo)
                        .text('전화연결 ' + callCenterNo)
                        .show();
                    $('#callModal').modal('show');
                    return;
                }


                // ★ 좌표가 없거나, 신뢰 불가하면 한 번 더 시도
                if (!hasLatLng || !isReliable(accuracyM, ageMs)) {
                    const pos = await ensureLocation({
                        maxAgeMs : 0,
                        targetAcc: ACC_OK,
                        timeoutMs: 20000
                    });
                    if (pos) {
                        fillHiddenFromPos(pos);
                        await ensureAddress(); // 주소도 갱신

                        // 근처 고속도로 추천
                        loadNearbyHighways(pos.coords.latitude, pos.coords.longitude);

                        // 값 다시 계산
                        accuracyM = parseFloat(document.getElementById('accuracyM')?.value || '1e9');
                        const ts = parseInt(document.getElementById('capturedTs')?.value || '0', 10);
                        ageMs = ts ? (Date.now() - ts) : 1e9;
                    }
                }

                if (!hasLatLng) {
                    // ★ 여전히 위치정보를 얻을 수 없다면
                    $('#notLocModal').modal('show');
                    return;
                }

                // 전화연결 동의 팝업 표출
                $('#callModal').modal('show');

            }, true);

            // ★ 온라인신고 클릭
            btn2.addEventListener('click', async function (e) {
                intakeMethodCd = "MTD002";
                e.preventDefault();
                e.stopPropagation();

                // ─ 0) 위치 먼저 확인(맨 위) ─
                let latEl = document.getElementById('lat');
                let lngEl = document.getElementById('lng');
                let hasLatLng = !!(latEl && lngEl && latEl.value && lngEl.value);

                // 신뢰도 계산
                let accuracyM = parseFloat(document.getElementById('accuracyM')?.value || '1e9');
                let ageMs = parseInt(document.getElementById('coordAgeMs')?.value || '0', 10);
                if (!ageMs) {
                    const ts = parseInt(document.getElementById('capturedTs')?.value || '0', 10);
                    if (ts) ageMs = Date.now() - ts;
                }

                // 없거나 불신이면 한 번 더 시도
                if (!hasLatLng || !isReliable(accuracyM, ageMs)) {
                    const pos = await ensureLocation({
                        maxAgeMs : 0,
                        targetAcc: ACC_OK,
                        timeoutMs: 20000
                    });
                    if (pos) {
                        fillHiddenFromPos(pos);
                        await ensureAddress();
                        // 갱신된 값 재확인
                        latEl = document.getElementById('lat');
                        lngEl = document.getElementById('lng');
                        hasLatLng = !!(latEl && lngEl && latEl.value && lngEl.value);
                        accuracyM = parseFloat(document.getElementById('accuracyM')?.value || '1e9');
                        const ts = parseInt(document.getElementById('capturedTs')?.value || '0', 10);
                        ageMs = ts ? (Date.now() - ts) : 1e9;
                    }
                }

                // 최종적으로 위치 없으면 바로 모달 띄우고 종료
                if (!hasLatLng) {
                    $('#notLocModal').modal('show');
                    return;
                }

                // ─ 1) 휴대폰 유효성 검사 ─
                let passFlag = true;
                const regTel = /^01[016789]\d{7,8}$/;
                const phoneInput = $("#cellPhone");

                if (phoneInput.val().trim() === "") {
                    $('#toastTxt').text('휴대폰 번호를 입력해주세요.');
                    $('#toastAlertModal').modal('show');
                    setTimeout(() => {
                        $('#toastAlertModal').modal('hide');
                    }, 1000);

                    passFlag = false;
                } else if (!regTel.test(phoneInput.val().trim())) {
                    $('#toastTxt').text('올바른 휴대폰 번호를 입력해주세요.');
                    $('#toastAlertModal').modal('show');
                    setTimeout(() => {
                        $('#toastAlertModal').modal('hide');
                    }, 1000);

                    passFlag = false;
                } else {
                    $('#feedbackTel').text('').hide();
                    $('#feedbackTel').removeClass('is-invalid').addClass('is-valid');
                }
                if (!passFlag) return;

                // ─ 2) 사진 필수 체크 ─
                const photoInput = document.getElementById('photoInput');
                if (!photoInput || !photoInput.files || photoInput.files.length === 0) {
                    $('#toastTxt').text('사진을 필수로 첨부해주세요.');
                    $('#toastAlertModal').modal('show');
                    setTimeout(() => {
                        $('#toastAlertModal').modal('hide');
                    }, 700);
                    return;
                }

                // ─ 3) 신뢰 OK → 접수 ─
                await submitIncidentReport();
            }, true);

        });

        $("#btnCloseModal").click(function () {
            intakeMethodCd = "";
            $("#locModal").modal("hide");
        });

        // ★ 모달의 "전화연결" 버튼: 접수 + 전화
        $(document).on('click', '#btnCallConfirm', function (e) {
            e.preventDefault();

            // 접수방법: 전화
            intakeMethodCd = "MTD001";

            // 신고 접수는 "기다리지 않고" 바로 발사 (성공/실패 여부에 상관없이 전화)
            try {
                // 기존 함수 재사용 (AJAX 비동기) — 대기하지 않음
                submitIncidentReport();
            } catch (ignore) {}

            // 즉시 전화걸기 (사용자 클릭 제스처 안에서)
            var tel = $(this).data('tel') || $(this).attr('href') || '';
            dialNow(tel);

            // 모달 닫기 (전화 앱으로 전환되더라도 안정적으로 닫아둠)
            $('#callModal').modal('hide');
        });

    })();

    const input = document.getElementById('photoInput');
    const infoPhotoInput = document.getElementById('infoPhotoInput');
    const imgEx = document.getElementById('imgEx');
    const preview = document.getElementById('photoPreview');
    const imageContainer = document.getElementById('imageContainer');
    const selectionCanvas = document.getElementById('selectionCanvas');
    const cropAndOcrBtn = document.getElementById('cropAndOcrBtn');
    const deleteBtn = document.getElementById('deleteBtn');
    const manualOcr = document.getElementById('manualOcr');
    const out = document.getElementById('ocrText');
    const ocrResultBox = document.getElementById('ocrResultBox');

    input.addEventListener('change', () => {
        const file = input.files?.[0];
        if (!file) {
            imageContainer.style.display = 'none';
            deleteBtn.style.display = 'none';
            manualOcr.style.display = 'none';
            cropAndOcrBtn.style.display = 'none';
            ocrResultBox.style.display = 'none';
            if (imgEx) imgEx.style.display = 'block';
            return;
        }
        const url = URL.createObjectURL(file);
        preview.src = url;
        preview.onload = () => {
            imageContainer.style.display = 'block';
            deleteBtn.style.display = 'block';
            manualOcr.style.display = 'block';
            cropAndOcrBtn.style.display = 'block';
            infoPhotoInput.style.display = 'none';
            imgEx.style.display = 'none';
            ocrResultBox.style.display = 'block';
            // out.textContent = '';

            // 캔버스 크기와 위치를 이미지 표시 크기에 맞춤
            const rect = preview.getBoundingClientRect();
            const containerRect = imageContainer.getBoundingClientRect();
            selectionCanvas.width = preview.offsetWidth;
            selectionCanvas.height = preview.offsetHeight;
            selectionCanvas.style.width = preview.offsetWidth + 'px';
            selectionCanvas.style.height = preview.offsetHeight + 'px';
            // 이미지가 가운데 정렬되어 있으므로 캔버스도 같은 위치에 배치
            selectionCanvas.style.left = ((containerRect.width - preview.offsetWidth) / 2) + 'px';

            // 선택 박스 초기화
            // initSelectionBox();

            URL.revokeObjectURL(url);
        };
    });

    // 선택 박스 관련 변수
    let selectionBox = {
        x     : 50,
        y     : 50,
        width : 200,
        height: 150
    };
    let isDragging = false;
    let isResizing = false;
    let resizeHandle = null;
    let startX = 0,
        startY = 0;
    let startBox = {};

    // 선택 박스 초기화 및 그리기
    function initSelectionBox() {
        const canvas = selectionCanvas;
        const ctx = canvas.getContext('2d');

        // 초기 선택 박스를 캔버스 중앙에 배치
        selectionBox = {
            x     : (canvas.width - 200) / 2,
            y     : (canvas.height - 150) / 2,
            width : 200,
            height: 150
        };

        // 최소 크기 보장
        if (selectionBox.x < 0) selectionBox.x = 20;
        if (selectionBox.y < 0) selectionBox.y = 20;
        if (selectionBox.width > canvas.width - 40) selectionBox.width = canvas.width - 40;
        if (selectionBox.height > canvas.height - 40) selectionBox.height = canvas.height - 40;

        drawSelectionBox();
    }

    // 선택 박스 그리기
    function drawSelectionBox() {
        const canvas = selectionCanvas;
        const ctx = canvas.getContext('2d');
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        // 반투명 오버레이 (선택 영역 외부)
        ctx.fillStyle = 'rgba(0, 0, 0, 0.5)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // 선택 영역 지우기 (투명하게)
        ctx.clearRect(selectionBox.x, selectionBox.y, selectionBox.width, selectionBox.height);

        // 선택 박스 테두리
        ctx.strokeStyle = '#00ff00';
        ctx.lineWidth = 3;
        ctx.strokeRect(selectionBox.x, selectionBox.y, selectionBox.width, selectionBox.height);

        // 크기 조절 핸들 (4개 모서리) - 모바일 터치를 위해 크기 증가
        const handleSize = 20;
        ctx.fillStyle = '#00ff00';
        ctx.strokeStyle = '#ffffff';
        ctx.lineWidth = 2;
        const handles = [
            {
                x: selectionBox.x,
                y: selectionBox.y
            }, // 좌상
            {
                x: selectionBox.x + selectionBox.width,
                y: selectionBox.y
            }, // 우상
            {
                x: selectionBox.x,
                y: selectionBox.y + selectionBox.height
            }, // 좌하
            {
                x: selectionBox.x + selectionBox.width,
                y: selectionBox.y + selectionBox.height
            } // 우하
        ];

        handles.forEach(handle => {
            ctx.fillRect(handle.x - handleSize / 2, handle.y - handleSize / 2, handleSize, handleSize);
            ctx.strokeRect(handle.x - handleSize / 2, handle.y - handleSize / 2, handleSize, handleSize);
        });
    }

    // 핸들 감지 함수
    function getResizeHandle(x, y) {
        const handleSize = 20;
        const handles = [
            {
                pos: 'tl',
                x  : selectionBox.x,
                y  : selectionBox.y
            },
            {
                pos: 'tr',
                x  : selectionBox.x + selectionBox.width,
                y  : selectionBox.y
            },
            {
                pos: 'bl',
                x  : selectionBox.x,
                y  : selectionBox.y + selectionBox.height
            },
            {
                pos: 'br',
                x  : selectionBox.x + selectionBox.width,
                y  : selectionBox.y + selectionBox.height
            }
        ];

        for (let handle of handles) {
            if (Math.abs(x - handle.x) <= handleSize && Math.abs(y - handle.y) <= handleSize) {
                return handle.pos;
            }
        }
        return null;
    }

    // 선택 박스 내부 감지
    function isInsideBox(x, y) {
        return x > selectionBox.x && x < selectionBox.x + selectionBox.width &&
            y > selectionBox.y && y < selectionBox.y + selectionBox.height;
    }

    // 마우스 이벤트
    selectionCanvas.addEventListener('mousedown', (e) => {
        const rect = selectionCanvas.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        const handle = getResizeHandle(x, y);
        if (handle) {
            isResizing = true;
            resizeHandle = handle;
            startX = x;
            startY = y;
            startBox = {...selectionBox};
        } else if (isInsideBox(x, y)) {
            isDragging = true;
            startX = x;
            startY = y;
            startBox = {...selectionBox};
        }
    });

    selectionCanvas.addEventListener('mousemove', (e) => {
        const rect = selectionCanvas.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        if (isResizing && resizeHandle) {
            const dx = x - startX;
            const dy = y - startY;

            switch (resizeHandle) {
                case 'tl':
                    selectionBox.x = Math.min(startBox.x + dx, startBox.x + startBox.width - 30);
                    selectionBox.y = Math.min(startBox.y + dy, startBox.y + startBox.height - 30);
                    selectionBox.width = Math.max(30, startBox.width - dx);
                    selectionBox.height = Math.max(30, startBox.height - dy);
                    break;
                case 'tr':
                    selectionBox.y = Math.min(startBox.y + dy, startBox.y + startBox.height - 30);
                    selectionBox.width = Math.max(30, startBox.width + dx);
                    selectionBox.height = Math.max(30, startBox.height - dy);
                    break;
                case 'bl':
                    selectionBox.x = Math.min(startBox.x + dx, startBox.x + startBox.width - 30);
                    selectionBox.width = Math.max(30, startBox.width - dx);
                    selectionBox.height = Math.max(30, startBox.height + dy);
                    break;
                case 'br':
                    selectionBox.width = Math.max(30, startBox.width + dx);
                    selectionBox.height = Math.max(30, startBox.height + dy);
                    break;
            }

            // 경계 제한
            selectionBox.x = Math.max(0, Math.min(selectionBox.x, selectionCanvas.width - selectionBox.width));
            selectionBox.y = Math.max(0, Math.min(selectionBox.y, selectionCanvas.height - selectionBox.height));

            drawSelectionBox();
        } else if (isDragging) {
            const dx = x - startX;
            const dy = y - startY;

            selectionBox.x = startBox.x + dx;
            selectionBox.y = startBox.y + dy;

            // 경계 제한
            selectionBox.x = Math.max(0, Math.min(selectionBox.x, selectionCanvas.width - selectionBox.width));
            selectionBox.y = Math.max(0, Math.min(selectionBox.y, selectionCanvas.height - selectionBox.height));

            drawSelectionBox();
        } else {
            // 커서 변경
            const handle = getResizeHandle(x, y);
            if (handle) {
                selectionCanvas.style.cursor = handle.includes('t') && handle.includes('l') ? 'nwse-resize' :
                    handle.includes('t') && handle.includes('r') ? 'nesw-resize' :
                        handle.includes('b') && handle.includes('l') ? 'nesw-resize' : 'nwse-resize';
            } else if (isInsideBox(x, y)) {
                selectionCanvas.style.cursor = 'move';
            } else {
                selectionCanvas.style.cursor = 'crosshair';
            }
        }
    });

    selectionCanvas.addEventListener('mouseup', () => {
        isDragging = false;
        isResizing = false;
        resizeHandle = null;
    });

    selectionCanvas.addEventListener('mouseleave', () => {
        isDragging = false;
        isResizing = false;
        resizeHandle = null;
    });

    // 터치 이벤트 (모바일 지원)
    selectionCanvas.addEventListener('touchstart', (e) => {
        e.preventDefault();
        const touch = e.touches[0];
        const rect = selectionCanvas.getBoundingClientRect();
        const x = touch.clientX - rect.left;
        const y = touch.clientY - rect.top;

        const handle = getResizeHandle(x, y);
        if (handle) {
            isResizing = true;
            resizeHandle = handle;
            startX = x;
            startY = y;
            startBox = {...selectionBox};
        } else if (isInsideBox(x, y)) {
            isDragging = true;
            startX = x;
            startY = y;
            startBox = {...selectionBox};
        }
    });

    selectionCanvas.addEventListener('touchmove', (e) => {
        e.preventDefault();
        const touch = e.touches[0];
        const rect = selectionCanvas.getBoundingClientRect();
        const x = touch.clientX - rect.left;
        const y = touch.clientY - rect.top;

        if (isResizing && resizeHandle) {
            const dx = x - startX;
            const dy = y - startY;

            switch (resizeHandle) {
                case 'tl':
                    selectionBox.x = Math.min(startBox.x + dx, startBox.x + startBox.width - 30);
                    selectionBox.y = Math.min(startBox.y + dy, startBox.y + startBox.height - 30);
                    selectionBox.width = Math.max(30, startBox.width - dx);
                    selectionBox.height = Math.max(30, startBox.height - dy);
                    break;
                case 'tr':
                    selectionBox.y = Math.min(startBox.y + dy, startBox.y + startBox.height - 30);
                    selectionBox.width = Math.max(30, startBox.width + dx);
                    selectionBox.height = Math.max(30, startBox.height - dy);
                    break;
                case 'bl':
                    selectionBox.x = Math.min(startBox.x + dx, startBox.x + startBox.width - 30);
                    selectionBox.width = Math.max(30, startBox.width - dx);
                    selectionBox.height = Math.max(30, startBox.height + dy);
                    break;
                case 'br':
                    selectionBox.width = Math.max(30, startBox.width + dx);
                    selectionBox.height = Math.max(30, startBox.height + dy);
                    break;
            }

            // 경계 제한
            selectionBox.x = Math.max(0, Math.min(selectionBox.x, selectionCanvas.width - selectionBox.width));
            selectionBox.y = Math.max(0, Math.min(selectionBox.y, selectionCanvas.height - selectionBox.height));

            drawSelectionBox();
        } else if (isDragging) {
            const dx = x - startX;
            const dy = y - startY;

            selectionBox.x = startBox.x + dx;
            selectionBox.y = startBox.y + dy;

            // 경계 제한
            selectionBox.x = Math.max(0, Math.min(selectionBox.x, selectionCanvas.width - selectionBox.width));
            selectionBox.y = Math.max(0, Math.min(selectionBox.y, selectionCanvas.height - selectionBox.height));

            drawSelectionBox();
        }
    });

    selectionCanvas.addEventListener('touchend', (e) => {
        e.preventDefault();
        isDragging = false;
        isResizing = false;
        resizeHandle = null;
    });

    // 선택 영역 캡처 함수
    function cropSelectedArea() {
        const img = preview;
        const canvas = selectionCanvas;

        // 원본 이미지의 실제 크기와 표시 크기의 비율 계산
        const scaleX = img.naturalWidth / img.offsetWidth;
        const scaleY = img.naturalHeight / img.offsetHeight;

        // 10% 여백 추가
        const margin = 0.1;
        const marginX = selectionBox.width * margin * scaleX;
        const marginY = selectionBox.height * margin * scaleY;

        // 선택 영역을 원본 이미지 좌표로 변환 (여백 포함)
        const cropX = Math.max(0, (selectionBox.x * scaleX) - marginX);
        const cropY = Math.max(0, (selectionBox.y * scaleY) - marginY);
        const cropWidth = Math.min(img.naturalWidth - cropX, (selectionBox.width * scaleX) + (marginX * 2));
        const cropHeight = Math.min(img.naturalHeight - cropY, (selectionBox.height * scaleY) + (marginY * 2));

        // 임시 캔버스에 원본 해상도로 크롭
        const tempCanvas = document.createElement('canvas');
        tempCanvas.width = cropWidth;
        tempCanvas.height = cropHeight;
        const tempCtx = tempCanvas.getContext('2d');
        tempCtx.drawImage(img, cropX, cropY, cropWidth, cropHeight, 0, 0, cropWidth, cropHeight);

        // 1200px로 리사이즈 (전체 이미지 방식과 동일)
        const targetW = 1200;
        const scale = targetW / cropWidth;
        const finalW = targetW;
        const finalH = Math.max(1, Math.round(cropHeight * scale));

        const finalCanvas = document.createElement('canvas');
        finalCanvas.width = finalW;
        finalCanvas.height = finalH;
        const finalCtx = finalCanvas.getContext('2d');
        finalCtx.imageSmoothingEnabled = true;
        finalCtx.imageSmoothingQuality = 'high';
        finalCtx.drawImage(tempCanvas, 0, 0, finalW, finalH);

        return finalCanvas;
    }

    // 삭제 버튼 클릭
    deleteBtn.addEventListener('click', () => {
        input.value = '';
        preview.src = '';
        imageContainer.style.display = 'none';
        deleteBtn.style.display = 'none';
        manualOcr.style.display = 'none';
        cropAndOcrBtn.style.display = 'none';
        infoPhotoInput.style.display = 'block';
        imgEx.style.display = 'block';
        out.textContent = '';
        ocrResultBox.style.display = 'none';
    });

    // 사고접수
    async function submitIncidentReport() {
        $('#intakeMethodCd').val(intakeMethodCd);

        // 주소가 비동기로 채워지도록 대기
        await ensureAddress();

        const formElement = document.getElementById('fileForm');
        const formData = new FormData(formElement);

        $.ajax({
            url        : "/sos/insert",
            type       : "post",
            data       : formData,
            processData: false,
            contentType: false,
            dataType   : "json",
            success    : function (data) {

                if (intakeMethodCd === "MTD002") {
                    // 온라인접수
                    if (data.code == '0000') {
                        const reportNo = data.data.reportNo;
                        location.href = "/sos/success/" + reportNo;
                    } else if (data.code == '9999') {
                        alert(data.message);
                    }
                }
            },
            error      : function (data) {
                alert(validationMessages.errorMsg);
            }
        });
    }

    async function checkGeoPermissionAndGuide() {
        if (!navigator.permissions || !navigator.permissions.query) return 'unknown';
        try {
            const s = await navigator.permissions.query({name: 'geolocation'});
            // 'granted' | 'prompt' | 'denied'
            return s.state;
        } catch {
            return 'unknown';
        }
    }

    // 위치 기능 켜기
    $('#btnEnableLocation').on('click', async function () {
        const state = await checkGeoPermissionAndGuide();
        if (state === 'denied') {
            alert(
                '브라우저에서 위치가 차단되어 있어요.\n' +
                '주소창의 🔒 아이콘 → 사이트 설정 → "위치: 허용"으로 바꿔주세요.'
            );
            return;
        }

        // HTTPS가 아닌 경우 사용자에게 명확히 알림
        if (location.protocol !== 'https:' && location.hostname !== 'localhost') {
            alert('이 페이지가 HTTPS가 아니라서 Chrome에서 위치를 사용할 수 없어요.\nHTTPS 주소로 접속해 주세요.');
            return;
        }

        const pos =
                  await ensureLocation({
                      maxAgeMs : 0,
                      targetAcc: ACC_OK,
                      timeoutMs: 20000
                  }) ||
                  await ensureLocation({
                      maxAgeMs : 60000,
                      targetAcc: 500,
                      timeoutMs: 20000
                  });

        if (pos) {
            fillHiddenFromPos(pos);
            await ensureAddress();
            $('#locModal').modal('hide');
        } else {
            const e = window.__lastGeoError || {};
            if (e.code === 1) {
                console.error('브라우저 권한이 거부되어 위치를 가져올 수 없습니다.\n사이트 권한에서 "위치 허용" 후 다시 시도해 주세요.');
            } else if (e.code === 3) {
                console.error('시간 초과로 정확한 위치를 가져오지 못했습니다.\nWi-Fi를 켜고(실내라면 창가 근처) 다시 시도해 주세요.');
            } else {
                console.error('정확한 위치를 가져오지 못했습니다.\nHTTPS 접속/사이트 권한/Wi-Fi 상태를 확인해 주세요.');
            }
        }
    });

</script>
<script async src="/js/opencv.js" type="text/javascript"></script><%--해당 페이지에서만 로딩이 되어야함. 각 파일 모델 용량이 좀 커서 통신 안좋으면 로딩 오래걸릴 확률 증가--%>
<script src="/js/ocr-processor.js?v=1"></script>
<script src="https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/ort.min.js"></script>
<script type="module">
    import 'https://cdn.jsdelivr.net/npm/onnxruntime-web/dist/ort.webgpu.min.js';

    ort.env.wasm.numThreads = Math.max(1, navigator.hardwareConcurrency ?? 4);
    ort.env.wasm.simd = true;

    import * as ocrModule from 'https://cdn.jsdelivr.net/npm/esearch-ocr@8.5.0/+esm'

    const decodeDic = await fetch("https://cdn.jsdelivr.net/npm/paddleocr-browser/dist/dict_korean.txt").then(r => r.text());


    const localOCR = await ocrModule.init({
        det: {
            input: "https://cdn.jsdelivr.net/npm/paddleocr-browser/dist/ppocr_det.onnx",
        },
        rec: {
            input    : "https://cdn.jsdelivr.net/npm/paddleocr-browser/dist/rec_korean_PP-OCRv3_infer.onnx",
            decodeDic: decodeDic,
        },
        ort,
    });

    // OCR 버튼 클릭 이벤트
    const cropAndOcrButton = document.getElementById('cropAndOcrBtn');
    cropAndOcrButton.addEventListener('click', async () => {
        const options = {
            debugMode: document.getElementById('chkDebugMode').checked,
            binaryMode: document.getElementById('chkBinaryMode').checked
        };
        // 옵션 객체 전달
        await processOcr(localOCR, 'crop', infoPhotoInput, options);
    });

    photoInput.addEventListener('change', async () => {
          const options = {
            debugMode: document.getElementById('chkDebugMode').checked,
            binaryMode: document.getElementById('chkBinaryMode').checked
        };
        // 옵션 객체 전달
        await processOcr(localOCR, 'full', photoInput, options);
    });

    const manualOcrButton = document.getElementById('manualOcr');
    manualOcrButton.addEventListener('click', () => {
        initSelectionBox();
    })

    // ---------------------- 테스트용 JS ------------------- //
    // 운영 테스트용 좌표 세트
    const TEST_COORDS = {
        TEST1: {
            lat: 37.24869,
            lng: 126.928034,
            acc: 30,
            label: '인접 고속도로 1개 (비봉매송)'
        },
        TEST2: {
            lat: 37.177627,
            lng: 127.000095,
            acc: 30,
            label: '인접 고속도로 2개'
        }
    };

    // 좌표 세팅 + 화면 표시 + 추천 호출
    function applyTestPosition(lat, lng, acc, label) {

        // hidden 값 채우기 (optional chaining 없이)
        var latEl = document.getElementById('lat');
        var lngEl = document.getElementById('lng');
        var accEl = document.getElementById('accuracyM');

        if (latEl) latEl.value = lat;
        if (lngEl) lngEl.value = lng;
        if (accEl) accEl.value = acc;

        // 위치 표시 박스 보여주기 (중요: display:none이면 주소확인중이 안 보임)
        $('#locAddress').show();

        // 주소 표시 p도 보여주고 로딩 문구
        var viewEl = document.getElementById('locAddr');
        if (viewEl) {
            viewEl.style.display = '';
            viewEl.textContent = '주소 확인 중…' + (label ? (' (' + label + ')') : '');
        }

        // 기존 로직 재사용
        try { ensureAddress(); } catch(e) { console.warn(e); }
        try {
            // fillCaptureTime이 Position 객체를 기대하면 모의 객체로 전달
            if (typeof fillCaptureTime === 'function') {
                fillCaptureTime({
                    coords: { latitude: Number(lat), longitude: Number(lng), accuracy: Number(acc) },
                    timestamp: Date.now()
                });
            }
        } catch(e) { console.warn(e); }

        try {
            if (typeof loadNearbyHighways === 'function') {
                loadNearbyHighways(Number(lat), Number(lng));
            }
        } catch(e) { console.warn(e); }
    }

    document.getElementById('btnTest1')?.addEventListener('click', function () {
        const t = TEST_COORDS.TEST1;
        applyTestPosition(t.lat, t.lng, t.acc, t.label);
    });

    document.getElementById('btnTest2')?.addEventListener('click', function () {
        const t = TEST_COORDS.TEST2;
        applyTestPosition(t.lat, t.lng, t.acc, t.label);
    });


</script>

</html>
