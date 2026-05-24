<%@ page contentType="text/html;charset=UTF-8" language="java"  pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 사고 접수 등록 모달 -->
<div class="modal fade" id="incident-insert-modal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1"
     aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-danger">
                <h5 class="modal-title">사고 접수 등록</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                        aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="insFileForm" action="fileUpload" method="post" enctype="multipart/form-data">

                    <h5>접수내용</h5>
                    <div class="box">
                        <div class="row">
                            <div class="col-4 mb-3">
                                <label class="form-label fw-semibold">담당자</label>
                                <input type="text" class="form-control" id="insManager"
                                       value="${sessionScope.session.userName}" disabled>
                                <input type="hidden" name="managerId" value="${sessionScope.session.userId}">
                            </div>

                            <div class="col-4 mb-3">
                                <label class="form-label fw-semibold">접수일시</label>
                                <input type="text" id="insReportDt" class="form-control form-control-a res_form"
                                       disabled>
                            </div>

                            <div class="col-4 mb-3"></div>

                            <div class="col-4 mb-3">
                                <label class="form-label fw-semibold">처리상태</label>
                                <select class="form-select" id="insStatus" name="statusCd">
                                    <option value="">전체</option>
                                    <c:forEach items="${statusList}" var="status">
                                        <option value="${status.cdCode}">${status.cdCodeNm}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-4 mb-3">
                                <label class="form-label fw-semibold">접수 방법</label>
                                <select class="form-select" id="insIntakeMethodCd" name="intakeMethodCd">
                                    <c:forEach items="${methodList}" var="method">
                                        <option value="${method.cdCode}">${method.cdCodeNm}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="col-4 mb-3">
                                <label class="form-label fw-semibold">전화 번호</label>
                                <input class="form-control" type="tel" id="insTel" name="cellPhone"
                                       inputmode="numeric" maxlength="13" autocomplete="tel">
                            </div>
                        </div>
                    </div>

                    <h5 class="mb-2">사고 위치</h5>
                    <div class="box">
                        <div class="row g-3 align-items-start">

                            <!-- 고속도로 -->
                            <div class="col-md-3">
                                <label class="form-label fw-semibold">고속도로</label>
                                <select class="form-select w-100" id="insertSiteCd" name="siteCd">
                                    <option value="">선택</option>
                                    <c:forEach items="${siteList}" var="site">
                                        <option value="${site.siteCd}">${site.siteName}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- 사고 위치(주소) -->
                            <div class="col-md-9">
                                <label class="form-label fw-semibold">사고 위치(주소)</label>
                                <div class="input-group">
                                    <input type="text" id="insAddr" name="addr"
                                           class="form-control"
                                           placeholder="주소를 검색해 주세요.">
                                    <button type="button" class="btn btn-outline-secondary" onclick="doSearchInsAddr()">
                                        주소 검색
                                    </button>
                                    <button type="button" class="btn btn-outline-primary" id="btnInsGeocode">
                                        좌표 갱신
                                    </button>
                                </div>
                                <div class="form-text text-muted mt-1">
                                    주소 검색 시, 좌표는 자동 갱신됩니다. 직접 입력한 경우 “좌표 갱신”을 눌러주세요.
                                </div>
                            </div>

                            <!-- 기점 지점 -->
                            <div class="col-md-3">
                                <label class="form-label fw-semibold">기점 지점</label>
                                <div class="input-group">
                                    <input type="text"
                                           id="insOcrReadKm"
                                           name="ocrReadKm"
                                           class="form-control"
                                           inputmode="decimal">
                                </div>

                                <div class="form-text text-muted mt-1">예)12.3</div>
                            </div>

                            <!-- GPS 좌표 + 지도 링크 -->
                            <div class="col-md-9">
                                <label class="form-label fw-semibold">GPS 좌표</label>

                                <div id="ins-coordRow" class="coord-row">
                                    <div class="input-group input-group-sm coord-input">
                                        <span class="input-group-text"><i class="bi bi-geo-alt"></i></span>
                                        <input id="ins-coordText" name="latLng" class="form-control" readonly
                                               placeholder="위도,경도">
                                    </div>

                                    <div class="btn-group btn-group-sm" role="group" aria-label="지도 열기">
                                        <a id="ins-linkGoogle" class="btn btn-outline-primary" target="_blank"
                                           rel="noopener">구글</a>
                                        <a id="ins-linkKakao" class="btn btn-outline-primary" target="_blank"
                                           rel="noopener">카카오</a>
                                        <a id="ins-linkNaver" class="btn btn-outline-primary" target="_blank"
                                           rel="noopener">네이버</a>
                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>


                    <h5>처리내용</h5>
                    <div class="box">
                        <div class="mb-3">
                            <div class="mb-2">
                                <label for="formFile" class="form-label fw-semibold">현장사진</label>
                                <input class="form-control" type="file" name="photo" accept="image/*" id="formFile2"
                                       style="display: none;">
                                <button type="button" class="btn btn-secondary" id="selectFileBtn2">파일 선택</button>
                                <button type="button" class="btn btn-primary" id="addPhotoBtn" style="display: none;">+
                                    사진 추가
                                </button>
                            </div>
                            <div id="thumbnailContainer2" class="row"></div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-semibold">접수내용</label>
                            <textarea class="form-control" id="insContent" name="processNote" rows="5"></textarea>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary" id="btnSave">저장</button>
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
            </div>
        </div>
    </div>
</div>

<script>

    let photo2 = null;

    const formFile2 = document.getElementById('formFile2');
    const selectFileBtn2 = document.getElementById('selectFileBtn2'); // 파일 선택 버튼
    const thumbnailContainer2 = document.getElementById('thumbnailContainer2'); // 썸네일 넣을 곳

    //  파일 선택 버튼 클릭
    selectFileBtn2.addEventListener('click', function () {
        // 같은 파일로도 다시 선택 가능하게 input 초기화
        formFile2.value = '';
        formFile2.click();
    });

    // 파일 선택 시
    formFile2.addEventListener('change', function (e) {

        const file = e.target.files && e.target.files[0];
        if (!file) return;

        if (!file.type || !file.type.startsWith('image/')) {
            alert('이미지 파일만 선택할 수 있습니다.');
            this.value = '';
            return;
        }

        // 단일 파일로 고정
        addPhoto2(file);
    });

    // 단일 사진 추가/변경
    function addPhoto2(file) {

        photo2 = file;

        const reader = new FileReader();
        reader.onload = function (ev) {

            thumbnailContainer2.innerHTML = '';

            var col = document.createElement('div');
            // ✅ col-auto로 해야 한 줄 전체 폭을 안 먹고, 내용 크기만큼만 차지함
            col.className = 'col-auto';

            col.innerHTML = ''
                + '<div class="thumbnail-wrapper thumb-fixed">'
                +   '<img src="' + ev.target.result + '" alt="현장사진">'
                +   '<button type="button" class="thumbnail-remove2" aria-label="삭제">×</button>'
                + '</div>';

            col.querySelector('.thumbnail-remove2').addEventListener('click', function () {
                removePhoto('insert');
            });

            thumbnailContainer2.appendChild(col);
        };

        reader.readAsDataURL(file);
    }



    // 사고접수 등록 모달 초기화
    function popInsertInit() {

        const $m = $('#incident-insert-modal');

        $('#insAddr, #insLat, #insLng, #insTel, #insUpdDt, #insContent, #insOcrReadKm, #ins-coordText').val('');

        thumbnailContainer2.innerHTML = '';

        $('#insertSiteCd').prop('selectedIndex', 0);     // 고속도로
        $('#insStatus').prop('selectedIndex', 1);       // 처리상태 '접수'로 기본 세팅
        $('#insIntakeMethodCd').prop('selectedIndex', 0);

    }

    // 등록(INSERT) AJAX
    function saveIncidentInsert() {

        const formEl2 = document.getElementById('insFileForm'); // ← 등록 폼
        return postForm('/admin/sos/insert', formEl2)
            .done(function (data) {
                if (data && data.code === '0000') {
                    showToastMsg('등록이 완료되었습니다.');
                    $('#incident-insert-modal').modal('hide');

                    doSearch(1);
                } else {
                    alert((data && data.message) || '처리 중 오류가 발생했습니다.');
                    throw new Error('insert failed');
                }
            })
            .fail(function () {
                alert('서버 통신 중 오류가 발생했습니다.');
                throw new Error('ajax error');
            });
    }

    // 주소 검색
    function doSearchInsAddr() {
        new daum.Postcode({
            oncomplete: function (data) {
                var addr = data.address;

                document.getElementById("insAddr").value = addr;

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
                        setMapLinks(res.lat, res.lng, addr, 'insert');

                    },
                    error: function () {
                        alert('좌표 조회 중 오류가 발생했어요.');
                    }
                });
            }
        }).open();
    }


    // 좌표 갱신
    function geocodeInsAddr() {
        var addr = ($('#insAddr').val() || '').trim();
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
                setMapLinks(res.lat, res.lng, addr, 'insert');
                showToastMsg('GPS 좌표를 갱신했어요.');

            },
            error: function () {
                alert('좌표 조회 중 오류가 발생했어요.');
            }
        });
    }

</script>
