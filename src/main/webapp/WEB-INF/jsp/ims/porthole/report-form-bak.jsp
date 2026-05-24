<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java"  pageEncoding="UTF-8"%>

<script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoMapKey}&autoload=false"></script>
<%@include file="../common/map.jsp" %>

<form id="potholeForm">
    <input type="hidden" id="siteCd" name="siteCd" value="${siteInfo.siteCd}">
    <input type="hidden" id="adminSiteCd" name="adminSiteCd" value="${siteInfo.siteCd}">
    <input type="hidden" id="receiptGbCd" name="receiptGbCd" value="${receiptGb.cdCode}">

    <input type="hidden" id="staMeters" name="staMeters" value="">
    <input type="hidden" id="staKmDecimal" name="staKmDecimal" value="">
    <input type="hidden" id="staText" name="staText" value="">
    <input type="hidden" id="weatherCd" name="weatherCd" value=""> <%-- 날씨 코드값 --%>
    <h5 class="mb-3 fw-bold">${receiptGb.cdCodeNm}<%--포트홀 접수--%></h5>

    <%-- STEP 1 : 정보입력 --%>
    <div class="step step-1">

        <input type="date"
               id="todayDate"
               aria-label="접수날짜"
               class="form-control text-center mb-3">

        <div class="btn-group w-100 mb-3">
            <c:forEach var="item" items="${roadDirList}" varStatus="status">

                <input type="radio"
                       class="btn-check"
                       name="directionCd"
                       id="dir_${status.index}"
                       value="${item.cdCode}"
                       <c:if test="${status.first}">checked</c:if>>

                <label class="btn btn-outline-primary" for="dir_${status.index}">
                    ${item.cdCodeNm}
                </label>

            </c:forEach>
        </div>

        <%-- 위치 영역 --%>
        <button type="button" id="btn-get-location" class="btn btn-primary mb-3">
            현재 위치 가져오기(클릭)
        </button>

        <%-- 위치 안내/에러 문구 --%>
        <div id="errorMessage" style="display:none;" class="mb-2"></div>

        <div id="location-result" style="display:none;">

            <div class="form-control text-center mb-2 bg-light" style="min-height:80px;">

                <%-- 주소 표시 --%>
                <div id="locAddress" style="display:none;">
                    <p id="locAddr" style="margin:0;">주소 확인 전</p>
                </div>

                <button type="button" id="btn-re-location" class="btn btn-outline-secondary mt-2">
                    위치 다시 불러오기
                </button>

                <div class="text-end">
                    <button type="button" data-bs-toggle="modal" data-bs-target="#map" class="btn btn-reset pb-0">
                        지도보기
                    </button>
                </div>
            </div>

            <input type="text" id="locDesc" aria-label="위치" class="form-control text-center mb-3"
                   placeholder="터널, 기점표기판 작성" value="">
        </div>



        <input type="hidden" id="draftId" name="draftId" value="">
        <input type="hidden" id="reportNo" name="reportNo" value="">

        <textarea id="content" class="form-control mb-3" placeholder="내용을 입력하세요."></textarea>

        <button type="button" id="btn-next" class="btn btn-warning mb-4">사진 등록하기</button>
        <button type="button" id="btn-cancel-1" class="btn btn-reset pb-0">입력취소</button>
    </div>

    <%-- STEP 2 : 사진첨부 --%>
    <div class="step step-2 text-center" style="display:none;">

        <div id="upload-area">
            <p class="pt-5">사진을 첨부해주세요!</p>

            <div class="d-flex gap-3 mb-5 justify-content-center">
                <label for="gallery-upload" class="upload-box" style="cursor: pointer;">
                    <img src="/img/icon/icon-gallery.png" class="img-fluid p-4">
                    <p>사진</p>
                    <input type="file" id="gallery-upload" accept="image/*" class="d-none" multiple>
                </label>

                <label for="camera-upload" class="upload-box" style="cursor: pointer;">
                    <img src="/img/icon/icon-camera.png" class="img-fluid p-4">
                    <p>카메라</p>
                    <input type="file" id="camera-upload" accept="image/*" capture="environment" class="d-none">
                </label>
            </div>
        </div>

        <%-- 사진이 보이는 영역 --%>
        <div id="preview-box" class="form-control" style="display:none;">
            <div id="preview-container" class="row m-0"></div>
        </div>


        <div class="my-3">
            <span class="fs-6 text-danger">※ 최대 5장 등록 가능</span><br>
            <span class="fs-6 text-danger">※ 가로 촬영 필수</span>
        </div>

        <button type="button" id="btn-add-photo" class="btn btn-secondary mb-4" style="display:none;">
            사진추가
        </button>

        <button type="button" id="btn-submit" class="btn btn-primary mb-4">
            접수완료
        </button>

        <button type="button" id="btn-cancel-2" class="btn btn-reset pb-0">
            입력취소
        </button>
    </div>

    <%-- STEP 3 : 접수 완료 --%>
    <div class="step step-3" style="display:none;">
        <div class="text-center mg-5">
            <img src="/img/icon/icon-check.png" class="img-fluid p-4">
            <h2 class="fw-bold display-5">감사합니다</h2>
            <p>포트홀 접수가 완료되었습니다</p>
        </div>

        <button type="button" id="btn-again" class="btn btn-primary my-4">
            추가 포트홀 접수하기
        </button>

        <button type="button" class="btn btn-reset pb-0" id="btn-detail">
            접수확인하기
        </button>
    </div>
</form>

<script>
    $(function () {
        // 접수날짜 오늘로 세팅 (YYYY-MM-DD)
        (function setTodayDate() {
            const today = new Date();
            const yyyy = today.getFullYear();
            const mm = String(today.getMonth() + 1).padStart(2, '0');
            const dd = String(today.getDate()).padStart(2, '0');

            $('#todayDate').val(yyyy + '-' + mm + '-' + dd);
        })();

        // =========================
        // STEP 제어
        // =========================
        function showStep(n) {
            $('.step').hide();
            $('.step-' + n).show();
        }

        showStep(1);

        // 다음 버튼 클릭
        $('#btn-next').on('click', function () {

            var directionCd = $('input[name="directionCd"]:checked').val();
            var formData = new FormData();

            formData.append('reportDate'    , $('#todayDate').val() || '');
            formData.append('directionCd'   , directionCd);             // 상행/하행
            formData.append('lat'           , $('#lat').val() || '');   // 위도
            formData.append('lng'           , $('#lng').val() || '');   // 경도
            formData.append('accuracyM'     , $('#accuracyM').val() || '');
            formData.append('capturedTs'    , $('#capturedTs').val() || '');
            formData.append('addr'          , $('#addr').val() || '');
            formData.append('detailInfo'    , $('#locDesc').val() || '');
            formData.append('deliveryNote'  , $('#content').val() || '');
            formData.append('siteCd'        , $('#siteCd').val());
            formData.append('receiptGbCd'  , $('#receiptGbCd').val());
            formData.append('weatherCd'  , $('#weatherCd').val() || '');
            formData.append('staMeters'   , $('#staMeters').val() || '');
            formData.append('staKmDecimal', $('#staKmDecimal').val() || '');
            formData.append('staText'     , $('#staText').val() || '');
            var adminSiteCdVal = $('#adminSiteCd').val();

            if (adminSiteCdVal && adminSiteCdVal.trim() !== '') {
                formData.append('adminSiteCd', adminSiteCdVal);
            }

            $.ajax({
                url        : "/pothole/draft/insert",
                type       : "post",
                data       : formData,
                processData: false,
                contentType: false,
                dataType   : "json",
                success    : function (data) {

                    if (data && data.code == '0000') {
                        var draftId = data.data && data.data.draftId ? data.data.draftId : '';

                        $('#draftId').val(draftId);
                        showStep(2);
                        syncUploadArea(); // ✅ step2 진입 직후 상태 반영
                    } else {
                        alert(data && data.message ? data.message : '임시저장 실패');
                    }
                },
                error      : function () {
                    alert('서버 통신 중 오류가 발생했습니다.');
                }
            });
        });

        // 접수완료 버튼 클릭
        $('#btn-submit').on('click', function () {

            var formData = new FormData();
            var draftIdVal = $('#draftId').val() || '';
            formData.append('draftId', draftIdVal);

            // ✅ 대표 index (active 버튼을 가진 preview-item의 index)
            var mainIndex = '';
            var $mainItem = $('#preview-container .before-main-btn.active').first().closest('.preview-item');
            if ($mainItem.length) {
                mainIndex = String($mainItem.index());
            }
            formData.append('mainIndex', mainIndex);

            // 사진 + 인덱스
            if (uploadedFiles && uploadedFiles.length > 0) {
                uploadedFiles.forEach(function (file, idx) {
                    formData.append('photos', file);
                    formData.append('photoIndexes', String(idx));
                });
            }

            $.ajax({
                url        : "/pothole/draft/complete",
                type       : "post",
                data       : formData,
                processData: false,
                contentType: false,
                dataType   : "json",
                success    : function (data) {
                    if (data && data.code == '0000') {
                        $('#reportNo').val(data.data.reportNo);
                        showStep(3);
                    } else {
                        alert(data && data.message ? data.message : '접수 실패');
                    }
                },
                error      : function (xhr) {
                    console.log('xhr.status=', xhr.status);
                    console.log('xhr.responseText=', xhr.responseText);
                    alert('서버 통신 중 오류가 발생했습니다.');
                }
            });
        });

        $('#btn-again').on('click', function () {
            // 처음부터 다시
            location.reload();
        });

        $('#btn-cancel-1, #btn-cancel-2').on('click', function () {
            // 취소 정책에 맞게 처리 (예: 메인으로)
            location.href = '/manage';
        });

        // 접수내역 확인하기
        $('#btn-detail').on('click', function () {
            location.href="/pothole/detail/"+$('#reportNo').val();
        });

        // =========================
        // 위치 가져오기
        // =========================
        $('#btn-get-location').on('click', function () {
            $('#location-result').fadeIn();
            $(this).hide();

            if (typeof requestPositionForPothole === 'function') {
                requestPositionForPothole();
            } else {
                console.log('requestPositionForPothole() 함수가 없습니다. location-service.js 로딩 확인');
            }
        });

        // 위치 다시 불러오기
        $('#btn-re-location').on('click', function () {
            if (typeof requestPositionForPothole === 'function') {
                requestPositionForPothole();
            }
        });

        // =========================
        // 사진 업로드/미리보기
        // =========================
        const previewContainer = document.getElementById('preview-container');
        const galleryInput = document.getElementById('gallery-upload');
        const cameraInput = document.getElementById('camera-upload');

        let uploadedFiles = [];

        function updateGridLayout() {
            const items = previewContainer.querySelectorAll('.preview-item');
            const total = items.length;
            const btnAddPhoto = document.getElementById('btn-add-photo');

            items.forEach((item, index) => {
                item.classList.remove('col-12', 'col-6');

                if (total === 1) {
                    item.classList.add('col-12');
                } else if (total === 2) {
                    item.classList.add('col-6');
                } else if (total === 3) {
                    if (index < 2) item.classList.add('col-6');
                    else item.classList.add('col-12');
                } else if (total === 4) {
                    item.classList.add('col-6');
                } else if (total === 5) {
                    if (index === 0) item.classList.add('col-12');
                    else item.classList.add('col-6');
                }
            });

            if (total > 0 && total < 5) {
                btnAddPhoto.style.display = 'block';
            } else {
                btnAddPhoto.style.display = 'none';
            }
        }

        function syncUploadArea() {
            if (uploadedFiles.length > 0) {
                document.getElementById('upload-area').style.display = 'none';
                $('#preview-box').show();   // ✅ 사진 있을 때만 박스 보이기
            } else {
                document.getElementById('upload-area').style.display = 'block';
                $('#preview-box').hide();   // ✅ 사진 없으면 박스 숨기기
            }
        }


        function addPreview(file, dataUrl) {
            const div = document.createElement('div');
            div.className = 'preview-item col-6';

            div.innerHTML =
                '<div class="position-relative p-1">' +
                '<img src="' + dataUrl + '" class="img-fluid rounded w-100">' +

                '<button type="button" class="main-thumbnail-btn before-main-btn">대표사진</button>' +
                '<button type="button" class="delete-btn">&times;</button>' +
                '</div>';

            // 삭제
            div.querySelector('.delete-btn').onclick = function () {
                uploadedFiles = uploadedFiles.filter(function (f) { return f !== file; });
                div.remove();

                syncUploadArea();
                updateGridLayout();
                ensureDraftBeforeMain();
            };

            previewContainer.appendChild(div);
            uploadedFiles.push(file);

            syncUploadArea();
            updateGridLayout();
            ensureDraftBeforeMain(); // 첫 사진 자동 대표
        }

        function setBeforeMain($item) {
            $('#preview-container .before-main-btn').removeClass('active');
            $item.find('.before-main-btn').addClass('active');

            $('#preview-container .before-main-badge').hide();
            $item.find('.before-main-badge').show();
        }

        function ensureDraftBeforeMain() {
            var $items = $('#preview-container .preview-item');
            if ($items.length === 0) return;

            if ($('#preview-container .before-main-btn.active').length === 0) {
                setBeforeMain($items.first());
            }
        }

        $(document).on('click', '#preview-container .before-main-btn', function () {
            setBeforeMain($(this).closest('.preview-item'));
        });

        function setMainPreview(itemDiv) {
            // active 초기화
            previewContainer.querySelectorAll('.preview-item').forEach(function (it) {
                it.classList.remove('main');
                const badge = it.querySelector('.main-badge');
                if (badge) badge.style.display = 'none';
            });

            // 선택한 것만 main
            itemDiv.classList.add('main');
            const badge = itemDiv.querySelector('.main-badge');
            if (badge) badge.style.display = 'inline-block';
        }

        function ensureMainPreview() {
            // 대표가 없으면 첫번째를 대표로
            const hasMain = previewContainer.querySelector('.preview-item.main');
            if (!hasMain) {
                const first = previewContainer.querySelector('.preview-item');
                if (first) setMainPreview(first);
            }
        }

        function handleFiles(files) {

            const fileArray = Array.from(files);

            if (uploadedFiles.length + fileArray.length > 5) {
                alert('사진은 최대 5장까지만 등록할 수 있습니다.');
                return;
            }

            fileArray.forEach(function (file) {
                const reader = new FileReader();
                reader.onload = function (e) {
                    addPreview(file, e.target.result);
                };
                reader.readAsDataURL(file);
            });
        }

        [galleryInput, cameraInput].forEach(function (input) {
            if (!input) return;

            input.addEventListener('change', function (e) {
                handleFiles(e.target.files);
                e.target.value = '';
            });
        });

        $('#btn-add-photo').on('click', function () {
            $('#gallery-upload').trigger('click');
        });

    });

    var _kMap = null;
    var _kMarker = null;
    var _kInfo = null;

    function showKakaoMapByHidden() {
        var lat = $('#lat').val();
        var lng = $('#lng').val();
        var addr = $('#addr').val() || $('#locAddr').text() || '';

        if (!lat || !lng) return;

        var latNum = Number(lat);
        var lngNum = Number(lng);

        kakao.maps.load(function () {

            var container = document.getElementById('kakaoMap');
            var center = new kakao.maps.LatLng(latNum, lngNum);

            if (!_kMap) {
                _kMap = new kakao.maps.Map(container, {
                    center: center,
                    level: 3
                });

                _kMarker = new kakao.maps.Marker({ position: center });
                _kMarker.setMap(_kMap);

                _kInfo = new kakao.maps.InfoWindow({
                    content: '<div style="padding:6px 8px; font-size:12px;">' + (addr || '현재 위치') + '</div>'
                });
                _kInfo.open(_kMap, _kMarker);

            } else {
                _kMap.setCenter(center);
                _kMarker.setPosition(center);

                if (_kInfo) _kInfo.setContent('<div style="padding:6px 8px; font-size:12px;">' + (addr || '현재 위치') + '</div>');
                if (_kInfo) _kInfo.open(_kMap, _kMarker);
            }

            // 모달 안에서 지도는 리사이즈 이슈가 생기므로 relayout 필수
            setTimeout(function () {
                _kMap.relayout();
                _kMap.setCenter(center);
            }, 200);

            $('#mapAddrText').text(addr);
        });
    }

    $('#map').on('shown.bs.modal', function () {
        showKakaoMapByHidden();
    });

</script>
