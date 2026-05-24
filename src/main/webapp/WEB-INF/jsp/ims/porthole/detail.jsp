<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java"  pageEncoding="UTF-8"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%request.setAttribute("pageTitle", "접수내역");%>
<jsp:useBean id="now" class="java.util.Date" />
<%@include file="../common/head.jsp" %>
<%@include file="../common/header.jsp" %>

<body class="sub">
<div class="container">
    <div class="ims-detail">
        <input type="hidden" id="reportNo" value="${detail.reportNo}">
        <input type="hidden" id="siteCd" name="siteCd" value="${detail.siteCd}">
        <input type="hidden" id="locationUpdated" name="locationUpdated" value="N">
        <input type="hidden" id="workStartAtRaw" value="${detail.workStartAt}">

        <%-- geo-utils.js가 채우는 hidden 값들 --%>
        <input type="hidden" id="lat" name="lat" value="">
        <input type="hidden" id="lng" name="lng" value="">
        <input type="hidden" id="accuracyM" name="accuracyM" value="">
        <input type="hidden" id="capturedTs" name="capturedTs">
        <input type="hidden" id="addr" name="addr" value="">
        <input type="hidden" id="staMeters" name="staMeters" value="${detail.staMeters}">
        <input type="hidden" id="staKmDecimal" name="staKmDecimal" value="${detail.staKmDecimal}">
        <input type="hidden" id="staText" name="staText" value="${detail.staText}">
        <input type="hidden" id="weatherCd" name="weatherCd" value=""> <%-- 날씨 코드값 --%>

<h2 id="weatherIcon" style="display:none">-</h2>
<p id="weatherText" style="display:none">확인중...</p>

<c:choose>
    <c:when test="${detail.statusCd == 'WORKING'}">
        <div class="detail-title" id="working">
            <span class="state">작업중</span>
            <h2>${detail.reportDateFmt}-${detail.receiptGbNm}</h2>
        </div>
    </c:when>

    <c:when test="${detail.statusCd == 'DONE'}">
        <div class="detail-title" id="completed">
            <span class="state">완료</span>
            <h2>${detail.reportDateFmt}-${detail.receiptGbNm}</h2>
        </div>

        <div class="success-zone mb-3">
            <!-- 완료일 때만 보이는 요약 영역 -->
            <div class="card">
                <div class="accordion" id="accordion">
                    <div class="accordion-item">
                        <div class="card-header accordion-button" type="button"
                             data-bs-toggle="collapse" data-bs-target="#collapseOne"
                             aria-expanded="true" aria-controls="collapseOne">
                            <h2>작업 완료 요약</h2>
                        </div>

                        <div id="collapseOne" class="pt-2 accordion-collapse collapse show">
                            <p class="mb-0"><b>접수일시</b>&nbsp;&nbsp;<span>${detail.reportDateTimeFmt}</span></p>
                            <p class="mb-0"><b>완료일시</b>&nbsp;&nbsp;<span>${detail.workEndDateTimeFmt}</span></p>
                            <p class="mb-0"><b>접수자</b>&nbsp;&nbsp;<span>${detail.userNm}</span></p>
                            <p class="mb-0"><b>작업자</b>&nbsp;&nbsp;<span>${detail.managerNm}</span></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </c:when>

    <c:when test="${detail.statusCd == 'HOLD'}">
        <div class="detail-title" id="hold">
            <span class="state">보류</span>
            <h2>${detail.reportDateFmt}-${detail.receiptGbNm}</h2>
        </div>
    </c:when>

    <c:otherwise>
        <div class="detail-title" id="received">
            <span class="state">접수</span>
            <h2>${detail.reportDateFmt}-${detail.receiptGbNm}</h2>
        </div>
    </c:otherwise>
</c:choose>

        <label for="receiverId" class="form-label">접수자</label>
        <select id="receiverId" name="receiverId" aria-label="접수자" class="form-control text-center mb-3" disabled>
            <option value="">선택</option>
            <c:forEach var="u" items="${adminUsers}">
                <option value="${u.userId}"
                        <c:if test="${u.userId == detail.receiverId}">selected</c:if>>
                    <c:out value="${u.userNm}"/>
                </option>
            </c:forEach>
        </select>


        <label for="todayDate" class="form-label">접수일시</label>
        <input type="datetime-local" id="todayDate" aria-label="접수일시" class="form-control text-center mb-3"
               value="${detail.reportDateTimeFmt}" disabled>

        <label for="receiptGb" class="form-label">접수유형</label>
        <select id="receiptGb" name="receiptGb" class="form-select mb-3" disabled>
            <c:forEach var="item" items="${receiptGbList}">
                <option value="${item.cdCode}"
                    <c:if test="${item.cdCode eq detail.receiptGbCd}">selected</c:if>>
                    ${item.cdCodeNm}
                </option>
            </c:forEach>
        </select>

        <label class="form-label">위치</label>
        <div class="btn-group w-100 mb-2">
            <c:forEach var="item" items="${roadDirList}" varStatus="status">
                <input type="radio"
                       class="btn-check"
                       name="directionCd"
                       id="dir_${status.index}"
                       value="${item.cdCode}"
                       <c:if test="${item.cdCode == detail.directionCd}">checked</c:if>
                       disabled>

                <label class="btn btn-outline-primary" for="dir_${status.index}">
                    ${item.cdCodeNm}
                </label>
            </c:forEach>
        </div>

        <div id="location-result">
            <div id="map" class="form-control text-center mb-2 bg-light">
                <p class="mb-0" id="locAddr"><c:out value="${detail.addr}"/></p>
                <c:if test="${not empty detail.staText}">
                     <p class="mb-0" id="locSta">STA <c:out value="${detail.staText}"/></p>
                </c:if>
                <button type="button" id="btn-re-location" class="btn btn-secondary mt-2" style="display: none;">
                    위치 다시 불러오기
                </button>
            </div>

            <input type="text" id="detailInfo" aria-label="위치" class="form-control text-center mb-3"
                   placeholder="터널, 기점표기판 작성" value="${detail.detailInfo}" disabled>
        </div>

        <label for="potholeTextarea" class="form-label">내용</label>
        <textarea class="form-control mb-3"
                  id="potholeTextarea"
                  placeholder="내용을 입력하세요."
                  disabled><c:out value="${detail.deliveryNote}"/></textarea>


        <label class="form-label">
        첨부사진
        <c:if test="${detail.statusCd ne 'DONE'}">
            <span class="fs-6 text-danger">※ 최대 20장 등록 가능, 가로 촬영 필수</span>
        </c:if>

        </label>
        <div class="form-control">
            <div id="preview-container" class="row g-2 mb-2">
                <c:choose>
                    <c:when test="${not empty photos}">
                        <c:forEach var="p" items="${photos}">
                            <div class="preview-item">
                                <div class="position-relative p-1">
                                    <img src="/pothole/img/before/${detail.reportNo}/${p.sortOrd}?v=${p.imgName}&t=${now.time}"
                                         data-sortord="${p.sortOrd}"
                                         data-is-main="${p.isMain}"
                                         class="img-fluid rounded w-100"
                                         style="min-height:100px; object-fit:cover;">

                                        <button type="button"
                                                class="main-thumbnail-btn before-main-btn <c:if test='${p.isMain eq "Y"}'>active</c:if>"
                                                <c:if test="${p.isMain ne 'Y'}">style="display:none;"</c:if>>
                                            대표사진
                                        </button>

                                        <button type="button" class="delete-btn" style="display: none;">&times;</button>
                                </div>

                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center text-muted py-3">첨부된 사진이 없습니다.</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <input type="file" id="edit-gallery-upload" accept="image/*" class="d-none" multiple>
            <button type="button" id="btn-edit-add-photo" class="btn btn-outline-primary w-100 my-2"
                    style="display: none;">
                사진추가
            </button>
        </div>


        <!-- 도로팀 버튼 -->
        <button type="button" id="btn-start-work" class="btn btn-primary mt-4"
                <c:if test="${not empty detail.workStartAt}">style="display:none;"</c:if>>
            작업 시작하기
        </button>

        <!-- 도로팀 작업 섹션  -->
        <div id="work-section" class="mt-3"
            <c:if test="${empty detail.workStartAt}">style="display:none;"</c:if>>
            <%-- ✅ 작업자 (최초 작업이면 로그인 사용자로 기본 선택) --%>
            <label for="worker" class="form-label">작업자</label>
            <select id="managerId" name="managerId" aria-label="작업자" class="form-control text-center mb-3" disabled>
                <option value="">선택</option>
                <c:forEach var="u" items="${adminUsers}">
                    <option value="${u.userId}"
                        <c:choose>
                            <%-- 1) 기존 작업자(managerId)가 있으면 그 사람 선택 --%>
                            <c:when test="${not empty detail.managerId and u.userId == detail.managerId}">
                                selected="selected"
                            </c:when>

                            <%-- 2) 최초 작업(= managerId 없음)이면 로그인 사용자 선택 --%>
                            <c:when test="${empty detail.managerId and u.userId == loginUserId}">
                                selected="selected"
                            </c:when>
                        </c:choose>
                    >
                        <c:out value="${u.userNm}"/>
                    </option>
                </c:forEach>
            </select>

            <label for="workStartAt" class="form-label">작업시작 일시</label>
            <input type="datetime-local" id="workStartAt" aria-label="작업시작 일시"
                   class="form-control text-center mb-3"
                   value="${fn:replace(detail.workStartDateTimeFmt, ' ', 'T')}" disabled>

            <label for="potholeTextarea2" class="form-label">작업내용</label>
            <textarea class="form-control mb-3 p-2" id="potholeTextarea2" placeholder="내용을 입력하세요." disabled><c:out
                    value="${detail.processNote}"/></textarea>

            <label class="form-label">진행상태</label>
            <div class="btn-group w-100 mb-3" role="group">

                <c:forEach var="st" items="${statusList}">
                    <!-- RECEIVED(접수)는 제외 -->
                    <c:if test="${st.cdCode ne 'RECEIVED'}">

                        <input type="radio" class="btn-check" name="statusCd" id="status-${st.cdCode}"
                               value="${st.cdCode}" disabled
                            <c:if test="${st.cdCode eq detail.statusCd}">checked</c:if>/>

                        <label class="btn btn-outline-primary" for="status-${st.cdCode}">
                                ${st.cdCodeNm}
                        </label>

                    </c:if>
                </c:forEach>

            </div>

            <label class="form-label">
                진행 사진 첨부
                <c:if test="${detail.statusCd ne 'DONE'}">
                    <span class="fs-6 text-danger">※ 최대 20장 등록 가능, 가로 촬영 필수</span>
                </c:if>
                </label>
            <div class="form-control">

                <c:choose>
                    <c:when test="${not empty afterPhotos}">
                        <!-- ✅ 기존 AFTER 사진 표시 -->
                        <div id="work-preview-container" class="row g-2 mb-2">
                            <c:forEach var="p" items="${afterPhotos}">
                                <div class="work-preview-item col-6" data-sortord="${p.sortOrd}">
                                    <div class="position-relative p-1">
                                        <img src="/pothole/img/after/${detail.reportNo}/${p.sortOrd}?v=${p.imgName}&t=${now.time}"
                                             data-is-main="${p.isMain}"
                                             class="img-fluid rounded w-100">

                                        <button type="button"
                                                class="main-thumbnail-btn work-main-btn <c:if test='${p.isMain eq "Y"}'>active</c:if>"
                                                <c:if test="${p.isMain ne 'Y'}">style="display:none;"</c:if>>
                                            대표사진
                                        </button>
                                        <button type="button" class="work-delete-btn" style="display:none;">&times;</button>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div id="work-empty-text" class="text-center text-muted py-3">
                            첨부된 사진이 없습니다.
                        </div>
                        <div id="work-preview-container" class="row g-2 mb-2" style="display:none;"></div>
                    </c:otherwise>
                </c:choose>

                <input type="file" id="work-gallery-upload" accept="image/*" class="d-none" multiple>
                <button type="button" id="btn-work-add-photo" class="btn btn-outline-primary w-100" style="display:none;">
                    사진추가
                </button>
            </div>


            <button type="button" id="btn-work-save" class="btn btn-primary mt-4" style="display:none;">작업 저장</button>
            <%--<button type="submit" class="btn btn-primary mt-4">저장</button>
            <button type="button" class="btn btn-reset pb-0" data-bs-toggle="modal" data-bs-target="#staticBackdrop">
                취소
            </button>--%>

        </div>
        <div id="saveStatus" class="text-center text-muted mb-2" style="display:none;"></div>
        <div class="" id="edit-action-bar">
            <c:if test="${detail.statusCd ne 'DONE'}">
                <c:choose>
                    <%-- 1) RECEIVED일 때: 접수자(receiverId)만 수정 가능 --%>
                    <c:when test="${detail.statusCd eq 'RECEIVED' and loginUserId == detail.receiverId}">
                        <button type="button" id="btn-edit" class="btn btn-secondary my-4">수정하기</button>
                    </c:when>

                    <%-- 2) RECEIVED가 아닐 때(= WORKING/HOLD 등): 작업자(managerId)만 수정 가능 --%>
                    <c:when test="${detail.statusCd ne 'RECEIVED' and loginUserId == detail.managerId}">
                        <button type="button" id="btn-edit" class="btn btn-secondary my-4">수정하기</button>
                    </c:when>
                </c:choose>
            </c:if>

            <button type="button" id="btn-save" class="btn btn-primary my-4" style="display: none;">저장</button>

            <%-- 접수내용&작업내용을 동시에 수정하는 저장버튼 --%>
            <button type="button" id="btn-save-all" class="btn btn-primary my-4" style="display:none;">
                저장
            </button>

            <c:if test="${loginUserId == detail.receiverId}">
                <button type="button"
                        id="btn-delete-open"
                        class="btn btn-reset text-danger"
                        data-bs-toggle="modal"
                        data-bs-target="#imsDeleteModal">
                    삭제
                </button>
            </c:if>
        </div>
    </div>
</div>
</body>

<script>
    const MAX_PHOTO_COUNT = 20;
    let editNewFiles = [];     // 새로 추가한 파일들
    let deleteSortOrds = [];   // 삭제할 기존 사진 sortOrd들
    let workFiles = []; // 하단 도로팀 작업 사진 저장용
    var _originReportDate = '';

    $(document).ready(function () {
        (function setTodayDate() {
            var raw = ($('#workStartAtRaw').val() || '').trim();
            var v = ($('#workStartAt').val() || '').trim();

            if (v === '' && raw !== '') {
                $('#workStartAt').val(raw.substring(0, 16).replace(' ', 'T')); // yyyy-MM-ddTHH:mm
                return;
            }

            if (v !== '') return;

            var now = new Date();
            var yyyy = now.getFullYear();
            var mm = String(now.getMonth() + 1).padStart(2, '0');
            var dd = String(now.getDate()).padStart(2, '0');
            var hh = String(now.getHours()).padStart(2, '0');
            var mi = String(now.getMinutes()).padStart(2, '0');

            $('#workStartAt').val(yyyy + '-' + mm + '-' + dd + 'T' + hh + ':' + mi);
        })();
        // 원래 날짜 저장
        _originReportDate = ($('#todayDate').val() || '').trim();

        // ==========================================
        // 1. [상단: 접수 수정 로직]
        // ==========================================

        // 상단 그리드 레이아웃 및 사진추가 버튼 상태 업데이트
        function updatePhotoUI() {
            const items = $('#preview-container .preview-item');
            const count = items.length;

            items.each(function (index) {
                // 1. 기존 그리드 클래스 싹 비우기 (매우 중요)
                $(this).removeClass('col-12 col-6 col-4');

                // 2. 개수별 그리드 로직 적용 (수정 모드 상관없이 사진 배치는 동일하게 적용)
                if (count === 1) {
                    $(this).addClass('col-12');
                } else if (count === 2 || count === 4) {
                    $(this).addClass('col-6');
                } else if (count === 3) {
                    // 1, 2번은 반씩(col-6), 3번은 전체(col-12)
                    if (index < 2) $(this).addClass('col-6');
                    else $(this).addClass('col-12');
                } else if (count === 5) {
                    // ★ 추가된 로직: 1번은 전체(col-12), 나머지는 반씩(col-6)
                    if (index === 0) $(this).addClass('col-12');
                    else $(this).addClass('col-6');
                }
            });

            // 3. 사진추가 버튼 노출 여부 (저장 버튼들이 보일 때만 사진 추가 노출)
            var isEditMode = $('#btn-save').is(':visible') || $('#btn-save-all').is(':visible');
            if (isEditMode && count < MAX_PHOTO_COUNT) {
                $('#btn-edit-add-photo').show();
            } else {
                $('#btn-edit-add-photo').hide();
            }
        }

        // 위치 다시 불러오기
        $('#btn-re-location').on('click', function () {
            if (typeof requestPositionForPothole === 'function') {
                requestPositionForPothole();
            }
        });

        // 삭제하기
        $('#btn-delete-confirm').off('click').on('click', function () {

            $.ajax({
                url: '/pothole/delete',
                type: 'POST',
                dataType: 'json',
                data: {
                    reportNo: $('#reportNo').val()
                },

                beforeSend: function () {
                    $('#btn-delete-confirm').prop('disabled', true);
                },

                success: function (data) {

                    if (data && data.code === '0000') {

                        $('#imsDeleteModal').modal('hide');

                        alert('삭제되었습니다.');

                        location.href = '/pothole/list';

                    } else {

                        alert(data.message || '삭제 실패');

                        $('#btn-delete-confirm').prop('disabled', false);
                    }
                },

                error: function () {

                    alert('삭제 중 오류가 발생했습니다.');

                    $('#btn-delete-confirm').prop('disabled', false);
                }
            });

        });

        // 수정하기 버튼 클릭
        $('#btn-edit').click(function (e) {
            e.preventDefault();

            // 1. 상태 변경 (활성화/보이기)
            $('#receiverId, #todayDate, #detailInfo, #potholeTextarea, #receiptGb').removeAttr('disabled');
            $('input[name="directionCd"]').removeAttr('disabled');
            $('.delete-btn, .before-main-btn, #btn-re-location').show();
            $('#btn-edit').hide();

            // ✅ 기본 저장 버튼은 숨김
            $('#btn-save').hide();
            $('#btn-work-save').hide();

            // ✅ 작업 시작 버튼도 숨김 (수정모드 들어왔으니)
            $('#btn-start-work').hide();

            // 사진 UI
            $('.delete-btn').show();
            $('.before-main-btn').show();
            updatePhotoUI();
            ensureBeforeMain();

            // ✅ 작업정보 존재 여부
            var hasWork = ($('#workStartAtRaw').val() || '').trim() !== '';

            if (hasWork) {
                // ✅ 기존 작업사진 대표 버튼 show
                $('#work-preview-container .work-main-btn').show();
                $('#work-preview-container .work-delete-btn').show();
                // 하단도 수정 가능
                $('#work-section').show();
                $('#work-section').find('input, textarea, select, .btn-check').removeAttr('disabled');

            updatePhotoUI();
            ensureBeforeMain();

            $('#btn-work-add-photo').show();
                $('#btn-work-add-photo').show();

                $('#btn-save-all').show();
                updatePhotoUI();
            } else {
            $('#btn-save').show();
            $('#btn-save-all').hide();
              updatePhotoUI();
            }
        });

        // 상단 사진추가 버튼 클릭 -> 파일 선택창 열기
        $('#btn-edit-add-photo').click(function () {
            $('#edit-gallery-upload').click();
        });

        // 상단 파일 선택 이벤트
        $('#edit-gallery-upload').on('change', function (e) {
            handleEditFiles(e.target.files);
            $(this).val(''); // 같은 파일 재선택 가능하도록 초기화
        });

        // 상단 사진 처리 함수
        async function handleEditFiles(files) {
            const fileArray = Array.from(files);
            const currentCount = $('#preview-container .preview-item').length;

            if (currentCount + fileArray.length > 20) {
                alert("사진은 최대 20장까지만 등록 가능합니다.");
                return;
            }

            for (var i = 0; i < fileArray.length; i++) {
                try {
                    var compressedFile = await compressImage(fileArray[i], 1600, 0.75);
                    var previewUrl = await readFileAsDataUrl(compressedFile);

                    const newIndex = editNewFiles.length;
                    editNewFiles.push(compressedFile);

                    const div = document.createElement('div');
                    div.className = 'preview-item col-6';
                    div.setAttribute('data-new-index', String(newIndex));

                    div.innerHTML =
                        '<div class="position-relative">' +
                            '<img src="' + previewUrl + '" class="img-fluid rounded w-100" style="min-height:100px; object-fit:cover;">' +
                            '<span class="badge bg-primary position-absolute top-0 start-0 m-1 before-main-badge" style="display:none;">대표</span>' +
                            '<button type="button" class="main-thumbnail-btn before-main-btn">대표사진</button>' +
                            '<button type="button" class="delete-btn">&times;</button>' +
                        '</div>';

                    $('#preview-container').append(div);
                    updatePhotoUI();
                    ensureBeforeMain();

                } catch (e) {
                    console.log(e);
                    alert('사진 처리 중 오류가 발생했습니다.');
                }
            }
        }

        // [상단 삭제 버튼] - 범위를 #preview-container로 한정
        $('#preview-container').on('click', '.delete-btn', function (e) {
            e.stopPropagation(); // 이벤트 전파 방지
            if (!confirm("사진을 삭제하시겠습니까?")) return;

            const $item = $(this).closest('.preview-item');
            const $img = $item.find('img');

            const sortOrd = $img.attr('data-sortord');
            const newIndex = $item.attr('data-new-index');

            if (sortOrd) {
                if (deleteSortOrds.indexOf(sortOrd) < 0) deleteSortOrds.push(sortOrd);
            }
            if (newIndex !== undefined && newIndex !== null && newIndex !== '') {
                editNewFiles[Number(newIndex)] = null;
            }

            $item.remove();
            updatePhotoUI();
            ensureBeforeMain();
        });


        // 저장하기 버튼 클릭시
        $('#btn-save').on('click', function (e) {
            e.preventDefault();

            var directionCd = $('input[name="directionCd"]:checked').val() || '';
            var formData = new FormData();

            formData.append('reportNo', $('#reportNo').val() || '');
            formData.append('receiverId', $('#receiverId').val() || '');
            formData.append('receiptGbCd', $('#receiptGb').val() || '');

            var raw = ($('#todayDate').val() || '').trim(); // 2026-03-27T10:30
            var reportDate = '';

            if (raw && raw !== _originReportDate) {
                reportDate = raw.replace('T', ' ') + ':00';
                formData.append('reportDate', reportDate);
            }

            formData.append('directionCd', directionCd);

            formData.append('detailInfo', $('#detailInfo').val() || '');
            formData.append('deliveryNote', $('#potholeTextarea').val() || '');

            // 위치를 다시 불러온 경우에만 위치/주소 정보 전송
            if ($('#locationUpdated').val() === 'Y') {
                formData.append('lat', $('#lat').val() || '');
                formData.append('lng', $('#lng').val() || '');
                formData.append('accuracyM', $('#accuracyM').val() || '');

                formData.append('capturedAt', $('#capturedAt').val() || '');
                formData.append('capturedTs', $('#capturedTs').val() || '');

                formData.append('addr', $('#addr').val() || '');
                formData.append('weatherCd', $('#weatherCd').text() || '');
            }

            // 삭제할 기존 사진 sortOrd들
            for (var i = 0; i < deleteSortOrds.length; i++) {
                formData.append('deleteSortOrds', deleteSortOrds[i]);
            }

            // BEFORE 대표사진 식별값 보내기
            var beforeMainSortOrd = '';
            var beforeMainNewIndex = '';

            var $mainItem = $('#preview-container .main-thumbnail-btn.active').first().closest('.preview-item');

            if ($mainItem.length) {
                var $img = $mainItem.find('img');
                beforeMainSortOrd = $img.attr('data-sortord') || '';         // 기존 사진이면 값 있음
                beforeMainNewIndex = $mainItem.attr('data-new-index') || ''; // 신규 사진이면 값 있음
            }

            formData.append('beforeMainSortOrd', beforeMainSortOrd);
            formData.append('beforeMainNewIndex', beforeMainNewIndex);

            // 새로 추가한 사진들
            for (var j = 0; j < editNewFiles.length; j++) {
                if (editNewFiles[j]) {
                formData.append('photos', editNewFiles[j]);
                formData.append('photoIndexes', String(j)); // ✅ 추가
                }
            }

            $.ajax({
                url: '/pothole/pothole-update',
                type: 'post',
                data: formData,
                processData: false,
                contentType: false,
                dataType: 'json',

                beforeSend: function () {
                    $('#btn-save').prop('disabled', true).text('저장 중...');
                    setSaveStatus('사진과 접수 내용을 저장 중입니다. 잠시만 기다려 주세요.');
                },

                success: function (data) {
                    if (data && data.code == '0000') {
                        clearSaveStatus();
                        showToastModal('저장되었습니다.', function () {
                            location.reload();
                        });
                    } else {
                        setSaveStatus('저장에 실패했습니다.');
                        alert(data && data.message ? data.message : '저장 실패');
                    }
                },

                error: function () {
                    setSaveStatus('서버 통신 중 오류가 발생했습니다.');
                    alert('서버 통신 중 오류가 발생했습니다.');
                },

                complete: function () {
                    $('#btn-save').prop('disabled', false).text('저장');
                }
            });
        });


        // ==========================================
        // 2. [하단: 도로팀 작업 로직]
        // ==========================================

        // 작업 시작하기 버튼 클릭
        $('#btn-start-work').click(function (e) {
            e.preventDefault();

            $('#work-section').fadeIn();
            $(this).hide();

            $('#btn-edit').hide(); // 수정하기 버튼 숨기기

            // ✅ 작업 입력 시작 -> 하단 enable
            $('#work-section').find('input, textarea, select, .btn-check').removeAttr('disabled');

            // ✅ 하단 버튼 노출
            $('#btn-work-add-photo').show();
            $('#btn-work-save').show();

            $('#managerId').focus();
        });



        // 하단 사진추가 버튼 클릭 -> 파일 선택창 열기
        $('#btn-work-add-photo').click(function () {
            $('#work-gallery-upload').click();
        });

        // 하단 파일 선택 이벤트
        $('#work-gallery-upload').on('change', function (e) {
            handleWorkFiles(e.target.files);
            $(this).val('');
        });

        // 하단 작업용 사진 처리 함수
        async function handleWorkFiles(files) {
            var fileArray = Array.from(files);

            var currentCount = workFiles.filter(function (f) { return !!f; }).length;
            if (currentCount + fileArray.length > MAX_PHOTO_COUNT) {
                alert('사진은 최대 ' + MAX_PHOTO_COUNT + '장까지만 등록할 수 있습니다.');
                return;
            }

            for (var i = 0; i < fileArray.length; i++) {
                try {
                    var compressedFile = await compressImage(fileArray[i], 1600, 0.75);
                    var previewUrl = await readFileAsDataUrl(compressedFile);

                    $('#work-empty-text').hide();
                    $('#work-preview-container').show();

                    var fileIdx = workFiles.length;

                    var div = document.createElement('div');
                    div.className = 'work-preview-item';
                    div.setAttribute('data-file-idx', String(fileIdx));

                    div.innerHTML =
                        '<div class="position-relative p-1">' +
                            '<img src="' + previewUrl + '" class="img-fluid rounded w-100">' +
                            '<button type="button" class="work-delete-btn">&times;</button>' +
                            '<button type="button" class="main-thumbnail-btn work-main-btn">대표사진</button>' +
                        '</div>';

                    $('#work-preview-container').append(div);

                    workFiles.push(compressedFile);

                    var mainBtn = div.querySelector('.main-thumbnail-btn');

                    if ($('#work-preview-container .work-preview-item').length === 1 && mainBtn) {
                        mainBtn.classList.add('active');
                    }

                    if (mainBtn) {
                        mainBtn.onclick = function () {
                            $('#work-preview-container .main-thumbnail-btn').removeClass('active');
                            $(div).find('.main-thumbnail-btn').addClass('active');
                        };
                    }

                    div.querySelector('.work-delete-btn').onclick = function () {
                        var idx = div.getAttribute('data-file-idx');
                        if (idx !== null && idx !== '') {
                            workFiles[Number(idx)] = null;
                        }

                        $(div).remove();

                        if ($('#work-preview-container .work-preview-item').length === 0) {
                            $('#work-preview-container').hide();
                            $('#work-empty-text').show();
                        }

                        if ($('#work-preview-container .main-thumbnail-btn.active').length === 0) {
                            var firstBtn = $('#work-preview-container .work-preview-item').first().find('.main-thumbnail-btn');
                            if (firstBtn.length) firstBtn.addClass('active');
                        }

                        updateWorkGridLayout();
                    };

                    updateWorkGridLayout();

                } catch (e) {
                    console.log(e);
                    alert('작업 사진 처리 중 오류가 발생했습니다.');
                }
            }
        }


        // 하단 진행 사진 전용 그리드 레이아웃 업데이트 함수
        function updateWorkGridLayout() {
            const items = $('#work-preview-container .work-preview-item');
            const count = items.length;

            items.each(function (index) {
                // 기존 클래스 초기화
                $(this).removeClass('col-12 col-6');

                // 상단과 동일한 5장 레이아웃 규칙 적용
                if (count === 1) {
                    $(this).addClass('col-12');
                } else if (count === 2 || count === 4) {
                    $(this).addClass('col-6');
                } else if (count === 3) {
                    if (index < 2) $(this).addClass('col-6');
                    else $(this).addClass('col-12');
                } else if (count === 5) {
                    if (index === 0) $(this).addClass('col-12');
                    else $(this).addClass('col-6');
                }
            });
        }

        // 기존 진행사진 삭제
        $(document).on('click', '.work-delete-btn', function () {

            if (!confirm("사진을 삭제하시겠습니까?")) return;

            var $item = $(this).closest('.work-preview-item');
            var sortOrd = Number($item.data('sortord'));

            // 삭제 목록 배열 (상단 deleteSortOrds처럼 별도 관리)
            if (!window.workDeleteSortOrds) {
                window.workDeleteSortOrds = [];
            }

            if (sortOrd && !isNaN(sortOrd)) {
                window.workDeleteSortOrds.push(sortOrd);
            }

            $item.remove();

            // 대표사진 없으면 첫번째 자동 지정
            if ($('#work-preview-container .main-thumbnail-btn.active').length === 0) {
                var firstBtn = $('#work-preview-container .work-preview-item').first().find('.main-thumbnail-btn');
                if (firstBtn.length) firstBtn.addClass('active');
            }

            updateWorkGridLayout();
        });

        // 취소 버튼 클릭
        $('#btn-work-cancel').click(function () {
            if (confirm("작업 입력을 취소하시겠습니까?")) {
                $('#work-section').hide();
                $('#btn-start-work').show();
                $('#potholeTextarea2').val('');
                // 추가된 작업 사진 초기화 (선택사항)
                $('#work-preview-container').empty().hide();
                workFiles = [];
            }
        });


        // 작업 저장 버튼 클릭
        $('#btn-work-save').on('click', function (e) {
            e.preventDefault();

            // 필수값 체크
            var reportNo = $('#reportNo').val() || '';
            var managerId = $('#managerId').val() || '';
            var workStartAt = $('#workStartAt').val() || '';
            var workMemo = $('#potholeTextarea2').val() || '';
            var statusCd = $('input[name="statusCd"]:checked').val() || '';

            if (!managerId) {
                alert('작업자를 선택해주세요.');
                return false;
            }
            if (!statusCd) {
                alert('진행상태를 선택해주세요.');
                return false;
            }

            setImsConfirmMessage();
            $('#imsConfirmModal').modal('show');
        });
        updatePhotoUI();
        updateWorkGridLayout();
    });

    $('#imsConfirmModal').off('shown.bs.modal').on('shown.bs.modal', function () {
        $('#btnWorkConfirm').prop('disabled', false);
    });

    // 확인 모달에서 어떤 저장을 실행할지 구분
    let confirmAction = '';

    // 작업 저장 버튼 클릭
    $('#btn-work-save').on('click', function (e) {
        e.preventDefault();

        confirmAction = 'WORK';

        // 저장 확인 모달 오픈
        $('#imsConfirmModal').modal('show');
    });

    // 접수+작업 통합 저장 버튼 클릭
    $('#btn-save-all').on('click', function (e) {
        e.preventDefault();

        confirmAction = 'ALL';

        // 저장 확인 모달 오픈
        $('#imsConfirmModal').modal('show');
    });

    // 저장 확인 모달의 확인 버튼 클릭
    $('#btnWorkConfirm').off('click').on('click', function () {

        $('#imsConfirmModal').modal('hide');

        // 작업 저장
        if (confirmAction === 'WORK') {
            doWorkSaveAjax();
        }

        // 접수+작업 통합 저장
        if (confirmAction === 'ALL') {
            doSaveAllAjax();
        }
    });

    $('#btn-work-save').off('click').on('click', function (e) {
        e.preventDefault();

        confirmAction = 'WORK';

        var managerId = $('#managerId').val() || '';
        var statusCd = $('input[name="statusCd"]:checked').val() || '';

        if (!managerId) {
            alert('작업자를 선택해주세요.');
            return;
        }

        if (!statusCd) {
            alert('진행상태를 선택해주세요.');
            return;
        }

        setImsConfirmMessage();
        $('#imsConfirmModal').modal('show');
    });

    function doWorkSaveAjax() {

        // 필수값 체크
        var reportNo = $('#reportNo').val() || '';
        var managerId = $('#managerId').val() || '';
        var workMemo = $('#potholeTextarea2').val() || '';
        var statusCd = $('input[name="statusCd"]:checked').val() || '';

        if (!managerId) {
            alert('작업자를 선택해주세요.');
            return;
        }
        if (!statusCd) {
            alert('진행상태를 선택해주세요.');
            return;
        }

        var formData = new FormData();
        formData.append('reportNo', reportNo);
        formData.append('managerId', managerId);

        var ws = $('#workStartAt').val() || '';
        ws = normalizeYmdWithNowTime(ws);
        formData.append('workStartAt', ws);

        formData.append('processNote', workMemo);
        formData.append('statusCd', statusCd);

        // 대표사진 인덱스
        var mainIndex = '';
        var $activeBtn = $('#work-preview-container .main-thumbnail-btn.active').first();
        if ($activeBtn.length) {
            mainIndex = $activeBtn.closest('.work-preview-item').attr('data-file-idx') || '';
        }
        formData.append('mainIndex', mainIndex);

        // 기존 진행사진 삭제 목록
        if (window.workDeleteSortOrds) {
            for (var i = 0; i < window.workDeleteSortOrds.length; i++) {
                formData.append('deleteSortOrds', window.workDeleteSortOrds[i]);
            }
        }
        // 작업(After) 사진들
        for (var i = 0; i < workFiles.length; i++) {
            if (workFiles[i]) {
                formData.append('photos', workFiles[i]);
                formData.append('photoIndexes', String(i));
            }
        }

        // ✅ 중복 클릭 방지 (모달 확인 버튼 잠시 비활성)
        $('#btnWorkConfirm').prop('disabled', true);

        $.ajax({
            url: '/pothole/work-update',
            type: 'post',
            data: formData,
            processData: false,
            contentType: false,
            dataType: 'json',

            beforeSend: function () {
                $('#btnWorkConfirm').prop('disabled', true);
                $('#btn-work-save').prop('disabled', true).text('저장 중...');
                setSaveStatus('작업 내용과 사진을 저장 중입니다. 잠시만 기다려 주세요.');
            },

            success: function (data) {
                if (data && data.code == '0000') {
                    clearSaveStatus();
                    showToastModal('저장되었습니다.', function () {
                        location.reload();
                    });
                } else {
                    setSaveStatus('저장에 실패했습니다.');
                    alert(data && data.message ? data.message : '저장 실패');
                    $('#btnWorkConfirm').prop('disabled', false);
                }
            },

            error: function (xhr) {
                console.log('xhr.status=', xhr.status);
                console.log('xhr.responseText=', xhr.responseText);
                setSaveStatus('서버 통신 중 오류가 발생했습니다.');
                alert('서버 통신 중 오류가 발생했습니다.');
                $('#btnWorkConfirm').prop('disabled', false);
            },

            complete: function () {
                $('#btn-work-save').prop('disabled', false).text('작업 저장');
            }
        });
    }

    // 접수+작업내용 저장
    // ✅ 기존 "#btn-save-all" click AJAX 통째로 교체
    // (바로 저장하지 말고 모달 띄운 뒤 confirm에서 doSaveAllAjax() 실행)

    $('#btn-save-all').off('click').on('click', function (e) {
        e.preventDefault();

        confirmAction = 'ALL';

        setImsConfirmMessage();
        $('#imsConfirmModal').modal('show');
    });

    // 모달 열릴 때 확인버튼 활성화
    $('#imsConfirmModal').off('shown.bs.modal').on('shown.bs.modal', function () {
        $('#btnWorkConfirm').prop('disabled', false);
    });



    // 저장
    function doSaveAllAjax() {

        var formData = new FormData();

        formData.append('reportNo', $('#reportNo').val() || '');
        formData.append('receiverId', $('#receiverId').val() || '');
        formData.append('receiptGbCd', $('#receiptGb').val() || '');

        var raw = ($('#todayDate').val() || '').trim();
        var reportDate = '';

        if (raw && raw !== _originReportDate) {
            reportDate = raw.replace('T', ' ') + ':00';
            formData.append('reportDate', reportDate);
        }

        var directionCd = $('input[name="directionCd"]:checked').val() || '';
        formData.append('directionCd', directionCd);

        formData.append('detailInfo', $('#detailInfo').val() || '');
        formData.append('deliveryNote', $('#potholeTextarea').val() || '');

        // 위치 다시불러온 경우만
        if ($('#locationUpdated').val() === 'Y') {
            formData.append('lat', $('#lat').val() || '');
            formData.append('lng', $('#lng').val() || '');
            formData.append('accuracyM', $('#accuracyM').val() || '');
            formData.append('capturedAt', $('#capturedAt').val() || '');
            formData.append('capturedTs', $('#capturedTs').val() || '');
            formData.append('addr', $('#addr').val() || '');
            formData.append('weatherCd', $('#weatherCd').text() || '');
        }

        // 접수사진 삭제/신규/대표
        for (var i = 0; i < deleteSortOrds.length; i++) {
            formData.append('deleteSortOrds', deleteSortOrds[i]);
        }

        var beforeMainSortOrd = '';
        var beforeMainNewIndex = '';
        var $mainItem = $('#preview-container .main-thumbnail-btn.active').first().closest('.preview-item');
        if ($mainItem.length) {
            var $img = $mainItem.find('img');
            beforeMainSortOrd = $img.attr('data-sortord') || '';
            beforeMainNewIndex = $mainItem.attr('data-new-index') || '';
        }
        formData.append('beforeMainSortOrd', beforeMainSortOrd);
        formData.append('beforeMainNewIndex', beforeMainNewIndex);

        for (var j = 0; j < editNewFiles.length; j++) {
            if (editNewFiles[j]) {
                formData.append('photos', editNewFiles[j]);
                formData.append('photoIndexes', String(j));
            }
        }

        // --- 작업(하단) ---
        formData.append('managerId', $('#managerId').val() || '');

        var ws = ($('#workStartAt').val() || '').trim();
        ws = normalizeYmdWithNowTime(ws);
        formData.append('workStartAt', ws);

        formData.append('processNote', $('#potholeTextarea2').val() || '');
        formData.append('statusCd', $('input[name="statusCd"]:checked').val() || '');

        var workMainIndex = '';
        var workMainSortOrd = '';

        var $wActive = $('#work-preview-container .main-thumbnail-btn.active').first();

        if ($wActive.length) {

            var $wItem = $wActive.closest('.work-preview-item');

            // 신규사진이면 fileIdx 사용
            if ($wItem.attr('data-file-idx') !== undefined) {
                workMainIndex = $wItem.attr('data-file-idx');
            }

            // 기존사진이면 sortOrd 사용
            if ($wItem.attr('data-sortord') !== undefined) {
                workMainSortOrd = $wItem.attr('data-sortord');
            }
        }

        formData.append('workMainIndex', workMainIndex);
        formData.append('workMainSortOrd', workMainSortOrd);

        // 기존 진행사진 삭제 목록
        if (window.workDeleteSortOrds) {
            for (var i = 0; i < window.workDeleteSortOrds.length; i++) {
                formData.append('deleteWorkSortOrds', window.workDeleteSortOrds[i]);
            }
        }

        for (var k = 0; k < workFiles.length; k++) {
            if (workFiles[k]) {
                formData.append('workPhotos', workFiles[k]);
                formData.append('workPhotoIndexes', String(k));
            }
        }

        // ✅ 중복 클릭 방지
        $('#btnWorkConfirm').prop('disabled', true);

       $.ajax({
            url: '/pothole/pothole-update-all',
            type: 'post',
            data: formData,
            processData: false,
            contentType: false,
            dataType: 'json',

            beforeSend: function () {
                $('#btnWorkConfirm').prop('disabled', true);
                $('#btn-save-all').prop('disabled', true).text('저장 중...');
                setSaveStatus('접수 내용과 작업 내용을 함께 저장 중입니다. 잠시만 기다려 주세요.');
            },

            success: function (data) {
                if (data && data.code == '0000') {
                    clearSaveStatus();
                    showToastModal('저장되었습니다.', function () {
                        location.reload();
                    });
                } else {
                    setSaveStatus('저장에 실패했습니다.');
                    alert(data && data.message ? data.message : '저장 실패');
                    $('#btnWorkConfirm').prop('disabled', false);
                }
            },

            error: function () {
                setSaveStatus('서버 통신 중 오류가 발생했습니다.');
                alert('서버 통신 중 오류가 발생했습니다.');
                $('#btnWorkConfirm').prop('disabled', false);
            },

            complete: function () {
                $('#btn-save-all').prop('disabled', false).text('저장');
            }
        });
    }

    // ✅ BEFORE 대표 지정: AFTER처럼 active 1개만 유지
    function setBeforeMain($item) {
        // 버튼 active 초기화
        $('#preview-container .main-thumbnail-btn').removeClass('active');

        // 선택한 아이템 버튼만 active
        $item.find('.main-thumbnail-btn').addClass('active');

        // (선택) 뱃지도 같이 쓰고 싶으면 같이 토글
        $('#preview-container .before-main-badge').hide();
        $item.find('.before-main-badge').show();
    }

    // ✅ 대표가 없으면 첫번째를 대표로 자동 지정
    function ensureBeforeMain() {
        var $items = $('#preview-container .preview-item');
        if ($items.length === 0) return;

        if ($('#preview-container .main-thumbnail-btn.active').length === 0) {
            setBeforeMain($items.first());
        }
    }


    $(document).on('click', '#preview-container .before-main-btn', function () {
        var $item = $(this).closest('.preview-item');
        setBeforeMain($item);
    });

    // ✅ AFTER 대표 지정
    $(document).on('click', '#work-preview-container .work-main-btn', function () {

        var $item = $(this).closest('.work-preview-item');

        // 버튼 active 초기화 (work 영역만)
        $('#work-preview-container .main-thumbnail-btn').removeClass('active');

        $(this).addClass('active');

        // 뱃지 처리
        $('#work-preview-container .work-main-badge').hide();
        $item.find('.work-main-badge').show();
    });

    function pad2(v){ return String(v).padStart(2, '0'); }

    // 현재 "시:분:초"만
    function nowHms(){
        var d = new Date();
        return pad2(d.getHours()) + ':' + pad2(d.getMinutes()) + ':' + pad2(d.getSeconds());
    }

    function normalizeYmdWithNowTime(v){
        v = (v || '').trim();
        if (!v) return '';

        v = v.replace('T', ' ');

        if (v.length === 10) return v + ' ' + nowHms();
        if (v.length === 16) return v + ':00';
        if (v.length >= 16) return v.substring(0, 16);

        return v;
    }

    // 토스트모달
    function showToastModal(msg, cb){
        $('#toastTxt').text(msg || '');
        $('#toastAlertModal').modal('show');

        // 기존 타이머/이벤트 정리
        var $m = $('#toastAlertModal');
        var t = $m.data('autoHideTimer');
        if (t) clearTimeout(t);

        $m.off('hidden.bs.modal.toastcb');

        // 1초 후 자동 닫기
        var timer = setTimeout(function () {
            $m.modal('hide');
        }, 1000);

        $m.data('autoHideTimer', timer);

        // 닫힌 뒤 콜백(리로드 등)
        if (cb) {
            $m.on('hidden.bs.modal.toastcb', function () {
                cb();
            });
        }
    }

    function setImsConfirmMessage() {
        var statusCd = $('input[name="statusCd"]:checked').val() || '';

        var msg = '작업 내용을 저장하시겠습니까?';
        if (statusCd === 'DONE' || statusCd === 'COMPLETE') {
            msg = msg + '<br/>완료처리시 관리자화면에서만 수정 가능합니다.';
        }

        $('#imsConfirmMessage').html(msg);
    }

    function compressImage(file, maxWidth, quality) {
        return new Promise(function (resolve, reject) {
            if (!file || !file.type || file.type.indexOf('image/') !== 0) {
                resolve(file);
                return;
            }

            var reader = new FileReader();

            reader.onload = function (e) {
                var img = new Image();

                img.onload = function () {
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

                    canvas.toBlob(function (blob) {
                        if (!blob) {
                            reject(new Error('이미지 압축 실패'));
                            return;
                        }

                        var originalName = file.name || 'image.jpg';
                        var newName = originalName.replace(/\.[^.]+$/, '') + '.jpg';

                        var compressedFile = new File(
                            [blob],
                            newName,
                            {
                                type: 'image/jpeg',
                                lastModified: Date.now()
                            }
                        );

                        resolve(compressedFile);
                    }, 'image/jpeg', quality);
                };

                img.onerror = function () {
                    reject(new Error('이미지 로드 실패'));
                };

                img.src = e.target.result;
            };

            reader.onerror = function () {
                reject(new Error('파일 읽기 실패'));
            };

            reader.readAsDataURL(file);
        });
    }

    function readFileAsDataUrl(file) {
        return new Promise(function (resolve, reject) {
            var reader = new FileReader();

            reader.onload = function (e) {
                resolve(e.target.result);
            };

            reader.onerror = function () {
                reject(new Error('미리보기 생성 실패'));
            };

            reader.readAsDataURL(file);
        });
    }

    function setSaveStatus(msg) {
        $('#saveStatus').text(msg).show();
    }

    function clearSaveStatus() {
        $('#saveStatus').hide().text('');
    }

    $(document).on('click', '#preview-container img, #work-preview-container img', function () {
        var src = $(this).attr('src');
        $('#imsImgModalSrc').attr('src', src);
        $('#imsImgModal').modal('show');
    });
</script>