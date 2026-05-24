<%@ page contentType="text/html;charset=UTF-8" language="java"  pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 사고 접수 상세 모달 -->
<div class="modal fade" id="incident-modal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1"
     aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="incident-title">사고 접수 상세</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                        aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="fileForm" action="fileUpload" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="imageChanged" id="imageChanged" value="N">
                    <h5>접수내용</h5>
                    <div class="box">
                        <div class="row">
                            <div class="col-4 mb-3">
                                <label class="form-label fw-semibold">접수 번호</label>
                                <input type="text" class="form-control" id="popReportNo" value="" disabled>
                                <input type="hidden" id="hiddenReportNo" name="reportNo">
                            </div>

                            <div class="col-4 mb-3">
                                <label class="form-label fw-semibold">담당자</label>
                                <input type="text" class="form-control" id="popManager"
                                       value="${sessionScope.session.userName}" disabled>
                            </div>

                            <div class="col-4 mb-3">
                                <label class="form-label fw-semibold">접수일시</label>
                                <input type="text" id="popReportDt" class="form-control form-control-a res_form"
                                       disabled>
                            </div>

                            <div class="col-4 mb-3">
                                <label class="form-label fw-semibold">처리상태</label>
                                <select class="form-select" id="popStatus" name="statusCd">
                                    <option value="">전체</option>
                                    <c:forEach items="${statusList}" var="status">
                                        <option value="${status.cdCode}">${status.cdCodeNm}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-4 mb-3">
                                <label class="form-label fw-semibold">접수 방법</label>
                                <select class="form-select" id="popIntakeMethodCd" name="intakeMethodCd">
                                    <c:forEach items="${methodList}" var="method">
                                        <option value="${method.cdCode}">${method.cdCodeNm}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="col-4 mb-3">
                                <label class="form-label fw-semibold">전화 번호</label>
                                <input type="text" class="form-control" id="popTel" name="cellPhone">
                            </div>

                            <div class="col-12 popUpdDt" style="text-align:right">
                                * 최종 수정 :
                                <span id="popUpdDt"></span>
                            </div>

                        </div>
                    </div>

                    <h5 class="mb-2">사고 위치</h5>
                    <div class="box">
                        <div class="row g-3 align-items-start">

                            <!-- 좌측: 폼 -->
                            <div class="col-md-8">
                                <div class="row g-3">

                                    <div class="col-sm-6">
                                        <label class="form-label fw-semibold">고속도로</label>
                                        <select class="form-select w-100" id="popSite" name="siteCd">
                                            <option value="">선택</option>
                                            <c:forEach items="${siteList}" var="site">
                                                <option value="${site.siteCd}">${site.siteName}</option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <div class="col-sm-6">

                                        <label class="form-label fw-semibold">기점 지점</label>
                                        <div class="input-group">
                                            <input type="text" id="popOcrReadKm" name="ocrReadKm"
                                                   class="form-control"
                                                   inputmode="decimal">
                                        </div>

                                        <div class="form-text text-muted mt-1">예)12.3</div>
                                    </div>

                                    <div class="col-sm-12">
                                        <label class="form-label fw-semibold">사고 위치(주소)</label>
                                        <div class="input-group">
                                            <input type="text" id="popAddr" name="addr" class="form-control"
                                                   placeholder="주소를 검색하거나 직접 입력해 주세요.">
                                            <button type="button" class="btn btn-outline-secondary" onclick="doSearchAddr()">주소 검색</button>
                                            <button type="button" class="btn btn-outline-primary" id="btnPopGeocode">좌표 갱신</button>
                                        </div>

                                        <div class="form-text text-muted mt-1">
                                            주소 검색 시, 좌표는 자동 갱신됩니다. 직접 입력한 경우 “좌표 갱신”을 눌러주세요.
                                        </div>

                                    </div>

                                    <div class="col-sm-12 mapLink">
                                        <label class="form-label fw-semibold">GPS 좌표</label>

                                        <div id="coordRow" class="coord-row">
                                            <div class="input-group input-group-sm coord-input">
                                                <span class="input-group-text"><i class="bi bi-geo-alt"></i></span>
                                                <input id="coordText" name="latLng" class="form-control" readonly
                                                       placeholder="위도,경도">
                                            </div>

                                            <div class="btn-group btn-group-sm" role="group" aria-label="지도 열기">
                                                <a id="linkGoogle" class="btn btn-outline-primary" target="_blank"
                                                   rel="noopener">구글</a>
                                                <a id="linkKakao" class="btn btn-outline-primary" target="_blank"
                                                   rel="noopener">카카오</a>
                                                <a id="linkNaver" class="btn btn-outline-primary" target="_blank"
                                                   rel="noopener">네이버</a>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 메시지(필요하면 전체폭) -->
                                    <div class="col-12">
                                        <div id="locAlert" class="alert py-2 mb-0 d-none">
                                            <div id="locMessage"></div>
                                        </div>
                                    </div>

                                </div>
                            </div>

                            <!-- 우측: 사진 -->
                            <div class="col-md-4">
                                <div class="photo-card">
                                    <img id="popRptImgUrl" class="img-fluid rounded d-none" alt="현장 사진">
                                    <div id="noPhoto" class="text-muted small py-4">등록된 사진이 없습니다.</div>
                                </div>
                            </div>

                        </div>
                    </div>


                    <h5>처리내용</h5>
                    <div class="box">

                        <div class="mb-3">
                            <div class="mb-2">
                                <label for="formFile" class="form-label  fw-semibold">현장사진</label>
                                <input class="form-control" type="file" name="photo" accept="image/*" id="formFile"
                                       style="display: none;">
                                <button type="button" class="btn btn-secondary" id="selectFileBtn">파일 선택</button>
                                <button type="button" class="btn btn-primary" id="addPhotoBtn" style="display: none;">+
                                    사진 추가
                                </button>
                            </div>
                            <div id="thumbnailContainer" class="row g-2"></div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label  fw-semibold">처리내용</label>
                            <textarea class="form-control" id="popContent" name="processNote" rows="5"></textarea>
                        </div>
                    </div>

                    <div style="text-align: right;">
                        <button type="button" class="btn btn-primary" id="btnEdit">저장</button>
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
                    </div>
                    <h5>히스토리</h5>
                    <div class="box" id="popTimeline"></div>
                </form>
            </div>

        </div>
    </div>
</div>
<script>

    let photo = null;

    const formFile = document.getElementById('formFile');
    const selectFileBtn = document.getElementById('selectFileBtn');
    const thumbnailContainer = document.getElementById('thumbnailContainer');

    selectFileBtn.addEventListener('click', function () {
        formFile.value = '';
        formFile.click();
    });

    formFile.addEventListener('change', function (e) {
        const file = e.target.files && e.target.files[0];
        if (!file) return;

        if (!file.type || !file.type.startsWith('image/')) {
            alert('이미지 파일만 선택할 수 있습니다.');
            formFile.value = '';
            return;
        }

        addPhoto(file);
    });

    function addPhoto(file) {
        photo = file;

        const reader = new FileReader();
        reader.onload = function (ev) {
            thumbnailContainer.innerHTML = '';

            var col = document.createElement('div');
            col.className = 'col-auto'; // ✅ row 안에서 썸네일 사이즈만큼만

            col.innerHTML =
                '<div class="thumb-item">' +
                '<img src="' + ev.target.result + '" alt="현장사진">' +
                '<button type="button" class="thumb-remove" aria-label="삭제">&times;</button>' +
                '</div>';

            col.querySelector('.thumb-remove').addEventListener('click', function () {
                removePhoto('show');
            });

            thumbnailContainer.appendChild(col);
        };

        reader.readAsDataURL(file);
    }


    // 사고접수 상세 모달 초기화
    function popInit() {

        const $m = $('#incident-modal');

        $('#popReportNo, #hiddenReportNo, #popSiteName, #popAddr, #popLat, #popLng, #popTel, #popUpdDt')
            .val('');

        $('#popStatus').prop('selectedIndex', 0);          // <select>라면 기본값으로
        $('#popIntakeMethodCd').val('');                   // <input/select> 어느 쪽이든 안전
        // $('#popIntakeMethodCd').trigger('change');      // 필요하면 주석 해제

        // 타임라인
        $('#popTimeline').empty().html('<p>이력없음</p>');

        // 이미지 영역 리셋
        $('#popRptImgUrl').attr('src', '').addClass('d-none'); // 기존 저장된 이미지
        $('.popImgUrl').hide();                                // 업로드 미리보기 컨테이너
        $('#popImgUrl').attr('src', '').addClass('d-none');    // 업로드 미리보기 이미지
        $('#fileForm input[name="photo"]').val('');            // 파일 인풋 비우기
        // 썸네일 컨테이너 완전 비우기
        var tc = document.getElementById('thumbnailContainer');
        if (tc) tc.innerHTML = '';
        // 최종수정일시
        $('.popUpdDt').hide();
        $('#popUpdDt').val('');

        // 좌표/지도 링크
        $('#coordText').val('');
        $('#coordRow').hide();
        $('#linkGoogle, #linkKakao, #linkNaver, #linkApple, #linkRoute').attr('href', '#');

        // 위치 신뢰도 메시지(두 가지 케이스 모두 처리)
        $m.find('#locMessage').empty().removeClass('text-danger text-success');
        $m.find('.locMessage').hide();
        $m.find('#locAlert').addClass('d-none').removeClass('alert-danger alert-success alert-warning');

        $('#imageChanged').val('N');
    }

    // 수정(UPDATE) AJAX
    function saveIncidentUpdate() {
        const formEl = document.getElementById('fileForm'); // ← 수정 폼
        return postForm('/admin/sos/update', formEl)
            .done(function (data) {
                if (data && data.code === '0000') {
                    $('#toastTxt').text('수정이 완료되었습니다.');
                    $('#imageChanged').val('N');
                    $('#toastAlertModal').modal('show');
                    setTimeout(() => {
                        $('#toastAlertModal').modal('hide');
                    }, 1000);

                    doSearch(1);
                } else {
                    alert((data && data.message) || '처리 중 오류가 발생했습니다.');
                    throw new Error('update failed');
                }
            })
            .fail(function () {
                alert('서버 통신 중 오류가 발생했습니다.');
                throw new Error('ajax error');
            });
    }

    // 파일 선택(change) 시
    document.getElementById('formFile').addEventListener('change', function () {
        $('#imageChanged').val('Y');   // 새 파일 선택됨
    });


    // 주소 검색
    function doSearchAddr() {
        new daum.Postcode({
            oncomplete: function (data) {
                var addr = data.address;

                document.getElementById("popAddr").value = addr;


                // 주소 검색 이후, 좌표값 획득
                $.ajax({
                    url: '/admin/sos/geocode',
                    type: 'get',
                    dataType: 'json',
                    data: {addr: addr},
                    success: function (res) {
                        if (!res || !res.lat || !res.lng) {
                            showToastMsg('좌표를 찾지 못했습니다. 주소를 더 구체적으로 입력해주세요.');
                            return;
                        }

                        // 기존에 있는 지도 링크/좌표 영역 갱신도 같이
                        setMapLinks(res.lat, res.lng, addr,'update');

                    },
                    error: function () {
                        alert('좌표 조회 중 오류가 발생했어요.');
                    }
                });

            }
        }).open();
    }

    // 좌표 갱신
    function geocodePopAddr() {
        var addr = ($('#popAddr').val() || '').trim();
        if (!addr) {
            showToastMsg('주소를 먼저 입력해주세요.');
            return;
        }

        $.ajax({
            url: '/admin/sos/geocode',
            type: 'get',
            dataType: 'json',
            data: { addr: addr },
            success: function (res) {
                if (!res || !res.lat || !res.lng) {
                    showToastMsg('좌표를 찾지 못했습니다. 주소를 더 구체적으로 입력해주세요.');
                    return;
                }

                // 지도 링크/좌표 영역 갱신
                setMapLinks(res.lat, res.lng, addr, 'update');
                showToastMsg('GPS 좌표를 갱신했어요.');

            },
            error: function () {
                alert('좌표 조회 중 오류가 발생했어요.');
            }
        });
    }
</script>
