<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java"  pageEncoding="UTF-8"%>

<script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoMapKey}&autoload=false"></script>
<%@include file="../common/map.jsp" %>

<form id="potholeForm">
    <input type="hidden" id="siteCd" name="siteCd" value="${siteInfo.siteCd}">
    <input type="hidden" id="adminSiteCd" name="adminSiteCd" value="${siteInfo.siteCd}">
    <input type="hidden" id="staMeters" name="staMeters" value="">
    <input type="hidden" id="staKmDecimal" name="staKmDecimal" value="">
    <input type="hidden" id="staText" name="staText" value="">
    <input type="hidden" id="weatherCd" name="weatherCd" value=""> <%-- 날씨 코드값 --%>
    <input type="hidden" id="temp" name="temp" value=""> <%-- 기온 --%>
    <h5 class="mb-3 fw-bold">${receiptGb.cdCodeNm}<%--포트홀 접수--%></h5>

    <%-- STEP 1 : 정보입력 --%>
    <div class="step step-1">

        <input type="datetime-local" id="todayDate" aria-label="접수날짜" class="form-control mb-3">

        <%-- 접수 유형 셀렉트박스 --%>
        <select id="receiptTypeCd" class="form-select mb-3">
            <c:forEach var="item" items="${receiptGbList}" varStatus="status">
            <option value="${item.cdCode}"
            <c:if test="${item.cdCode eq lastReceiptGbCd or (empty lastReceiptGbCd and status.first)}">selected</c:if>>
            ${item.cdCodeNm}
            </option>
            </c:forEach>
        </select>

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

        <div id="location-result" style="display:none; margin-bottom: 10px;">
            <div
                    style="
                        display: flex !important;
                        justify-content: space-between;
                        gap: 10px;
                        align-items: stretch;">

                <div class="form-control bg-light">
                    <%-- 주소 표시 --%>
                    <div id="locAddress" style="display:none;">
                        <p id="locAddr" style="margin:0;">주소 확인 전</p>
                    </div>
                </div>
                <div class="d-flex">
                    <button type="button" id="btn-re-location" class="btn btn-secondary"
                        style="
                            width: 45px;
                            border: 0;
                            font-weight: bold;
                            font-size: 24px;">
                        <i class="bi bi-arrow-clockwise"></i>
                    </button>
                </div>
            </div>

                <%--<div class="text-end">
                    <button type="button" data-bs-toggle="modal" data-bs-target="#map" class="btn btn-reset pb-0">
                        지도보기
                    </button>
                </div>--%>
            </div>

            <input type="text" id="locDesc" aria-label="위치" class="form-control text-center mb-2"
                   placeholder="램프, JC,기점 등을 직접 입력 가능" value="">


        <input type="hidden" id="reportNo" name="reportNo" value="">

        <textarea id="content" class="form-control mb-3" placeholder="내용을 입력하세요."></textarea>

        <%-- 사진이 보이는 영역 --%>
        <div id="preview-box" class="form-control" style="display:none;">
            <div id="preview-container" class="row m-0"></div>
        </div>

        <div id="upload-area" class="">
            <div class="d-flex gap-3 justify-content-center text-center">
                <label for="gallery-upload" class="upload-box" style="cursor: pointer;">
                    <img src="/img/icon/icon-gallery.png" class="img-fluid p-4">
                    <p>갤러리</p>
                    <input type="file" id="gallery-upload" accept="image/*" class="d-none" multiple>
                </label>

                <label for="camera-upload" class="upload-box" style="cursor: pointer;">
                    <img src="/img/icon/icon-camera.png" class="img-fluid p-4">
                    <p>사진</p>
                    <input type="file" id="camera-upload" accept="image/*" capture="environment" class="d-none">
                </label>
            </div>
        </div>



        <div class="my-3 text-center">
            <span class="fs-6 text-danger">※ 최대 20장 등록 가능, 가로 촬영 필수</span>
        </div>
<%--
        <button type="button" id="btn-add-photo" class="btn btn-secondary mb-4" style="display:none;">
            사진추가
        </button>--%>

        <div id="submitStatus" class="text-center text-muted mb-2" style="display:none;"></div>
        <div class="d-flex gap-2">
            <button type="button" id="btn-submit" class="btn btn-outline-primary mb-3">
                접수완료
            </button>
            <button type="button" id="btn-work-complete" class="btn btn-primary mb-3">
                작업완료
            </button>
        </div>
        <button type="button" id="btn-cancel-2" class="btn btn-reset pb-0">
            입력취소
        </button>
    </div>

    <%-- STEP 3 : 접수 완료 --%>
    <div class="step step-3" style="display:none;">
        <div class="text-center mg-5">
            <img src="/img/icon/icon-check.png" class="img-fluid p-4">
            <h2 class="fw-bold display-5">감사합니다</h2>
            <p id="completeMessage"></p>
        </div>

        <button type="button" id="btn-again" class="btn btn-primary my-4">
            추가 접수하기
        </button>

        <button type="button" class="btn btn-reset pb-0" id="btn-detail">
            접수확인하기
        </button>
    </div>
</form>

<script>
    const MAX_PHOTO_COUNT = 20; // 업로그 최대 갯수

    function showStep(n) {
        $('#potholeForm .step').hide();
        $('#potholeForm .step-' + n).show();
    }

    // 접수일시 세팅
    $(function () {
        (function setTodayDate() {
            const now = new Date();
            const local = new Date(now.getTime() - (now.getTimezoneOffset() * 60 * 1000))
                .toISOString()
                .slice(0, 16);

            $('#todayDate').val(local);
        })();

        showStep(1);

        // 접수완료 버튼 클릭
        $('#btn-submit').on('click', function () {

            var formData = new FormData();
            var directionCd = $('input[name="directionCd"]:checked').val();
            var raw = $('#todayDate').val(); // 2026-03-27T09:48

            var reportDate = '';
            if (raw) {
                reportDate = raw.replace('T', ' ') + ':00'; // 2026-03-27 09:48:00
            }

            formData.append('reportDate', reportDate);
            formData.append('directionCd', directionCd || '');
            formData.append('lat', $('#lat').val() || '');
            formData.append('lng', $('#lng').val() || '');
            formData.append('accuracyM', $('#accuracyM').val() || '');
            formData.append('capturedTs', $('#capturedTs').val() || '');
            formData.append('addr', $('#addr').val() || '');
            formData.append('detailInfo', $('#locDesc').val() || '');
            formData.append('deliveryNote', $('#content').val() || '');
            formData.append('siteCd', $('#siteCd').val() || '');
            formData.append('receiptGbCd', $('#receiptTypeCd').val() || '');
            formData.append('weatherCd', $('#weatherCd').val() || '');
            formData.append('temp', $('#temp').val() || '');
            formData.append('staMeters', $('#staMeters').val() || '');
            formData.append('staKmDecimal', $('#staKmDecimal').val() || '');
            formData.append('staText', $('#staText').val() || '');

            var adminSiteCdVal = $('#adminSiteCd').val();
            if (adminSiteCdVal && adminSiteCdVal.trim() !== '') {
                formData.append('adminSiteCd', adminSiteCdVal);
            }

            // 대표사진 index
            var mainIndex = '';
            var $mainItem = $('#preview-container .before-main-btn.active').first().closest('.preview-item');
            if ($mainItem.length) {
                mainIndex = String($mainItem.index());
            }
            formData.append('mainIndex', mainIndex);

            // 사진 + 원본 index
            if (uploadedFiles && uploadedFiles.length > 0) {
                uploadedFiles.forEach(function (file, idx) {
                    formData.append('photos', file);
                    formData.append('photoIndexes', String(idx));
                });
            }

            $.ajax({
                url: "/pothole/insert",
                type: "post",
                data: formData,
                processData: false,
                contentType: false,
                dataType: "json",

                beforeSend: function () {
                    $('#btn-submit').prop('disabled', true).text('업로드 중...');
                    $('#submitStatus').text('사진 업로드 중입니다. 잠시만 기다려 주세요.').show();
                },

                success: function (data) {

                    if (data && data.code == '0000') {
                        $('#reportNo').val(data.data.reportNo);
                        var text = $('#receiptTypeCd option:selected').text();

                        $('#completeMessage').text(
                            text + ' 접수가 완료되었습니다'
                        );
                        $('#submitStatus').hide();
                        showStep(3);
                    } else {
                        $('#submitStatus').hide();
                        alert(data && data.message ? data.message : '접수 실패');
                    }
                },

                error: function (xhr) {
                    console.log('xhr.status=', xhr.status);
                    console.log('xhr.responseText=', xhr.responseText);
                    $('#submitStatus').text('업로드 중 오류가 발생했습니다. 다시 시도해 주세요.').show();
                    alert('서버 통신 중 오류가 발생했습니다.');
                },

                complete: function () {
                    $('#btn-submit').prop('disabled', false).text('접수완료');
                }
            });
        });

        // 작업완료 버튼 클릭
        $('#btn-work-complete').on('click', function () {

            var formData = new FormData();
            var directionCd = $('input[name="directionCd"]:checked').val();
            var raw = $('#todayDate').val();

            var reportDate = '';
            if (raw) {
                reportDate = raw.replace('T', ' ') + ':00';
            }

            formData.append('reportDate', reportDate);
            formData.append('directionCd', directionCd || '');
            formData.append('lat', $('#lat').val() || '');
            formData.append('lng', $('#lng').val() || '');
            formData.append('accuracyM', $('#accuracyM').val() || '');
            formData.append('capturedTs', $('#capturedTs').val() || '');
            formData.append('addr', $('#addr').val() || '');
            formData.append('detailInfo', $('#locDesc').val() || '');

            // 작업내용은 process_note로 저장
            formData.append('processNote', $('#content').val() || '');

            formData.append('siteCd', $('#siteCd').val() || '');
            formData.append('receiptGbCd', $('#receiptTypeCd').val() || '');
            formData.append('weatherCd', $('#weatherCd').val() || '');
            formData.append('temp', $('#temp').val() || '');
            formData.append('staMeters', $('#staMeters').val() || '');
            formData.append('staKmDecimal', $('#staKmDecimal').val() || '');
            formData.append('staText', $('#staText').val() || '');

            formData.append('statusCd', 'DONE');

            var adminSiteCdVal = $('#adminSiteCd').val();
            if (adminSiteCdVal && adminSiteCdVal.trim() !== '') {
                formData.append('adminSiteCd', adminSiteCdVal);
            }

            var mainIndex = '';
            var $mainItem = $('#preview-container .before-main-btn.active').first().closest('.preview-item');
            if ($mainItem.length) {
                mainIndex = String($mainItem.index());
            }
            formData.append('mainIndex', mainIndex);

            if (uploadedFiles && uploadedFiles.length > 0) {
                uploadedFiles.forEach(function (file, idx) {
                    formData.append('photos', file);
                    formData.append('photoIndexes', String(idx));
                });
            }

            $.ajax({
                url: "/pothole/insert-work-complete",
                type: "post",
                data: formData,
                processData: false,
                contentType: false,
                dataType: "json",

                beforeSend: function () {
                    $('#btn-work-complete').prop('disabled', true).text('업로드 중...');
                    $('#submitStatus').text('작업완료 처리 중입니다. 잠시만 기다려 주세요.').show();
                },

                success: function (data) {
                    if (data && data.code == '0000') {
                        $('#reportNo').val(data.data.reportNo);
                        var text = $('#receiptTypeCd option:selected').text();

                        $('#completeMessage').text(
                            text + ' 작업이 완료되었습니다'
                        );
                        $('#submitStatus').hide();
                        showStep(3);
                    } else {
                        $('#submitStatus').hide();
                        alert(data && data.message ? data.message : '작업완료 실패');
                    }
                },

                error: function () {
                    $('#submitStatus').text('업로드 중 오류가 발생했습니다. 다시 시도해 주세요.').show();
                    alert('서버 통신 중 오류가 발생했습니다.');
                },

                complete: function () {
                    $('#btn-work-complete').prop('disabled', false).text('작업완료');
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

            if (total > 0 && total < MAX_PHOTO_COUNT) {
                btnAddPhoto.style.display = 'block';
            } else {
                btnAddPhoto.style.display = 'none';
            }
        }
/*
        function syncUploadArea() {
            if (uploadedFiles.length > 0) {
                document.getElementById('upload-area').style.display = 'none';
                $('#preview-box').show();   // ✅ 사진 있을 때만 박스 보이기
            } else {
                document.getElementById('upload-area').style.display = 'block';
                $('#preview-box').hide();   // ✅ 사진 없으면 박스 숨기기
            }
        }*/

        function syncUploadArea() {

            // 업로드 버튼은 항상 유지
            document.getElementById('upload-area').style.display = 'block';

            // 사진 있을 때만 preview 영역 노출
            if (uploadedFiles.length > 0) {
                $('#preview-box').show();
            } else {
                $('#preview-box').hide();
            }

            // 최대 갯수면 업로드 버튼 숨김
            if (uploadedFiles.length >= MAX_PHOTO_COUNT) {
                $('#upload-area').hide();
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

        async function handleFiles(files) {
            var fileArray = Array.from(files);

            if (uploadedFiles.length + fileArray.length > MAX_PHOTO_COUNT) {
                alert('사진은 최대 ' + MAX_PHOTO_COUNT + '장까지만 등록할 수 있습니다.');
                return;
            }

            for (var i = 0; i < fileArray.length; i++) {
                var originalFile = fileArray[i];
                var compressedFile = await compressImage(originalFile, 1600, 0.75);

                var reader = new FileReader();
                reader.onload = function(e) {
                    addPreview(compressedFile, e.target.result);
                };
                reader.readAsDataURL(compressedFile);
            }
        }

        [galleryInput, cameraInput].forEach(function (input) {
            if (!input) return;

            input.addEventListener('change', function (e) {
                handleFiles(e.target.files);
                e.target.value = '';
            });
        });
/*
        $('#btn-add-photo').on('click', function () {
            $('#gallery-upload').trigger('click');
        });
*/
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

    function compressImage(file, maxWidth, quality) {
        return new Promise(function(resolve, reject) {
            if (!file.type || file.type.indexOf('image/') !== 0) {
                resolve(file);
                return;
            }

            var reader = new FileReader();

            reader.onload = function(e) {
                var img = new Image();

                img.onload = function() {
                    var width = img.width;
                    var height = img.height;

                    if (width > maxWidth) {
                        height = Math.round(height * (maxWidth / width));
                        width = maxWidth;
                    }

                    var canvas = document.createElement('canvas');
                    var ctx = canvas.getContext('2d');

                    canvas.width = width;
                    canvas.height = height;
                    ctx.drawImage(img, 0, 0, width, height);

                    canvas.toBlob(function(blob) {
                        if (!blob) {
                            reject(new Error('이미지 압축 실패'));
                            return;
                        }

                        var newName = file.name.replace(/\.[^.]+$/, '') + '.jpg';
                        var compressedFile = new File([blob], newName, {
                            type: 'image/jpeg',
                            lastModified: Date.now()
                        });

                        resolve(compressedFile);
                    }, 'image/jpeg', quality);
                };

                img.onerror = reject;
                img.src = e.target.result;
            };

            reader.onerror = reject;
            reader.readAsDataURL(file);
        });
    }

</script>
