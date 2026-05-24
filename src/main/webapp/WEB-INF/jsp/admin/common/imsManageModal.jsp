<%@ page contentType="text/html;charset=UTF-8" language="java"  pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!-- 현장 관리 등록/수정 모달 -->
<div class="modal fade" id="ims-add-modal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1"
     aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="imsModalTitle">현장 접수 등록</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                        aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="insFileForm" action="fileUpload" method="post" enctype="multipart/form-data">
                    <!-- 위치/STA 계산값 -->
                    <input type="hidden" id="insLat" name="lat">
                    <input type="hidden" id="insLng" name="lng">
                    <input type="hidden" id="insStaText" name="staText">
                    <input type="hidden" id="insStaMeters" name="staMeters">
                    <input type="hidden" id="insStaKmDecimal" name="staKmDecimal">

                    <!-- 등록/수정 모드 및 접수번호 -->
                    <input type="hidden" id="imsMode" name="imsMode" value="INSERT">  <!-- INSERT | UPDATE -->
                    <input type="hidden" id="imsReportNoHidden" name="reportNo" value="">

                    <!-- 체크박스 선택값 CSV 저장용 -->
                    <input type="hidden" id="insPavementTypeCds" name="pavementTypeCds" value="">
                    <input type="hidden" id="insOccurPlaceCds"   name="occurPlaceCds"   value="">

                    <!-- 대표사진 정보(from=db/new, key=sortOrd 또는 신규 index) -->
                    <input type="hidden" id="mainBeforeFrom" name="mainBeforeFrom" value="">
                    <input type="hidden" id="mainBeforeKey"  name="mainBeforeKey"  value="">
                    <input type="hidden" id="mainAfterFrom"  name="mainAfterFrom"  value="">
                    <input type="hidden" id="mainAfterKey"   name="mainAfterKey"   value="">

                    <!-- 드래그로 변경된 작업 전/후 사진 이동정보 JSON -->
                    <input type="hidden" id="photoMoveJson" name="photoMoveJson" value="">

                    <div class="d-flex justify-content-end align-items-center gap-3 mb-2">

                        <div class="form-check mb-0">
                            <input class="form-check-input" type="checkbox" id="insAlarmSendYnTop" checked>
                            <label class="form-check-label" for="insAlarmSendYnTop">
                                알림톡 발송
                            </label>
                        </div>

                        <button type="button" class="btn btn-primary" id="btnEditTop" style="display:none;">수정</button>
                        <button type="button" class="btn btn-outline-danger" id="btnDeleteTop" style="display:none;">삭제</button>
                        <button type="button" class="btn btn-primary" id="btnSaveTop">저장</button>

                    </div>
                    <div class="accordion" id="accordion">
                        <div class="accordion-item">
                            <button class="accordion-button mt-0" type="button" data-bs-toggle="collapse" data-bs-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                                기본정보
                            </button>
                            <div id="collapseOne" class="box accordion-collapse collapse show">
                                <div class="row pt-3">

                                    <div class="col-3 mb-3" id="insReportNoWrap">
                                        <label class="form-label fw-semibold"><b class="danger">*</b>접수번호</label>
                                        <input type="text" class="form-control" id="insReportNo">
                                    </div>

                                </div>
                                <div class="row">
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold"><b class="danger">*</b>문서번호</label>
                                        <input type="text" class="form-control" id="insDocNo">
                                    </div>

                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold"><b class="danger">*</b>현장</label>
                                        <select class="form-select w-100" id="insSiteCd" name="siteCd" required>
                                            <option value="">선택</option>
                                            <c:forEach items="${siteList}" var="site">
                                                <option value="${site.siteCd}">${site.siteName}</option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold"><b class="danger">*</b>작업유형</label>

                                        <select class="form-select" id="insReceiptGbCd" name="receiptGbCd" required>
                                            <option value="">선택</option>
                                            <c:forEach items="${workTypeList}" var="workType" varStatus="status">
                                            <option value="${workType.cdCode}"
                                            <c:if test="${status.first}">selected</c:if>>
                                            ${workType.cdCodeNm}
                                            </option>
                                            </c:forEach>

                                        </select>
                                    </div>
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold"><b class="danger">*</b>작업상태</label>
                                        <select class="form-select" id="insStatusCd" name="statusCd" required>
                                            <option value="">선택</option>
                                            <c:forEach items="${workStatusList}" var="status">
                                                <option value="${status.cdCode}">${status.cdCodeNm}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold"><b class="danger">*</b>접수자</label>
                                        <select class="form-select" id="insReceiverId" name="receiverId" required>
                                            <option value="">선택</option>
                                        </select>
                                    </div>
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold"><b class="danger">*</b>날씨</label>
                                        <select class="form-select" id="insWeatherCd" name="weatherCd" required>
                                            <option value="">선택</option>
                                            <c:forEach items="${weatherList}" var="weather">
                                                <option value="${weather.cdCode}">${weather.cdCodeNm}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold"><b class="danger">*</b>기온(℃)</label>
                                        <input type="text" class="form-control" id="insTemp" name="temp" placeholder="예: 23" required>
                                    </div>
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold"><b class="danger">*</b>접수일시</label>
                                        <input type="text" id="insReportDt" name="reportDate" class="form-control form-control-a res_form" required>

                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold">작업자</label>
                                        <select class="form-select" id="insManagerId" name="managerId">
                                            <option value="">선택</option>
                                        </select>
                                    </div>
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold">날씨</label>
                                        <select class="form-select" id="insWorkweatherCd" name="workWeatherCd">
                                            <option value="">선택</option>
                                            <c:forEach items="${weatherList}" var="weather">
                                                <option value="${weather.cdCode}">${weather.cdCodeNm}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold">기온(℃)</label>
                                        <input type="text" class="form-control" id="insWorkTemp" name="workTemp" placeholder="예: 23">
                                    </div>
                                    <!-- 작업시작일시 -->
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold">작업시작일시</label>
                                        <input type="text" id="insWorkStartAt" name="workStartAt"
                                               class="form-control form-control-a res_form"
                                               placeholder="YYYY-MM-DD HH:mm">
                                    </div>

                                    <!-- 작업종료일시 -->
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold">작업종료일시</label>
                                        <input type="text" id="insWorkEndAt" name="workEndAt"
                                               class="form-control form-control-a res_form"
                                               placeholder="YYYY-MM-DD HH:mm">

                                    </div>

                                </div>
                                <div class="row">
                                    <div class="ims-choice-wrap">

                                        <!-- 포장형식 -->
                                        <div class="ims-choice-group">
                                            <div class="ims-choice-title">
                                                포장형식 및 시설물
                                            </div>

                                            <div class="ims-choice-list" id="pavementChoiceList">
                                                <c:forEach items="${pavementTypeList}" var="c">
                                                <label class="ims-chip">
                                                <input type="checkbox" class="choice-pavement" value="${c.cdCode}">
                                                <span>${c.cdCodeNm}</span>
                                                </label>
                                                </c:forEach>
                                            </div>
                                        </div>

                                        <!-- 발생장소 -->
                                        <div class="ims-choice-group">
                                            <div class="ims-choice-title">
                                                발생장소
                                            </div>

                                            <div class="ims-choice-list" id="occurPlaceChoiceList">
                                                <c:forEach items="${occurPlaceList}" var="c">
                                                <label class="ims-chip">
                                                <input type="checkbox" class="choice-occur" value="${c.cdCode}">
                                                <span>${c.cdCodeNm}</span>
                                                </label>
                                                </c:forEach>
                                            </div>
                                        </div>

                                    </div>

                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseTwo" aria-expanded="true" aria-controls="collapseOne">
                                위치정보
                            </button>
                            <div id="collapseTwo" class="box accordion-collapse collapse show">
                                <div class="row pt-3 g-3 align-items-start">

                                    <div class="col-md-2">
                                        <label class="form-label fw-semibold">위치정보</label>
                                        <select class="form-select w-100" id="inDirectionCd" name="directionCd">
                                            <option value="">선택</option>
                                            <c:forEach items="${roadDirList}" var="dir">
                                                <option value="${dir.cdCode}">${dir.cdCodeNm}</option>
                                            </c:forEach>
                                        </select>
                                    </div>

                                    <!-- GPS 좌표 + 지도 링크 -->
                                    <div class="col-md-7">
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

                                    <!-- 사고 위치(주소) -->
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold">입력주소</label>
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
                                        <div class="form-text text-muted mt-1 mb-3">
                                            주소 검색 시, 좌표는 자동 갱신됩니다. 직접 입력한 경우 “좌표 갱신”을 눌러주세요.
                                        </div>
                                    </div>

                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">STA 정보 (km)</label>

                                        <div class="input-group mb-1 sta-input-group">
                                            <span class="input-group-text sta-unit">km</span>
                                            <input type="text"
                                                   id="insStaKmView"
                                                   class="form-control"
                                                   placeholder="예: 2.7">
                                        </div>

                                        <div class="input-group sta-input-group">
                                            <span class="input-group-text sta-unit">m</span>
                                            <input type="text"
                                                   id="insStaMetersView"
                                                   class="form-control sta-readonly"
                                                   readonly
                                                   placeholder="자동계산">
                                        </div>

                                        <div class="form-text text-muted">
                                            km 단위로 입력해 주세요. 예: 2.7 → 2700m
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">위치상세정보</label>
                                        <div class="input-group">
                                            <input type="text" id="insDetailInfo" name="detailInfo"
                                                   class="form-control"
                                                   placeholder="램프, JC,기점 등을 직접 입력 가능">
                                        </div>
                                    </div>

                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseThree" aria-expanded="true" aria-controls="collapseOne">
                                접수정보
                            </button>
                            <div id="collapseThree" class="box accordion-collapse collapse show">
                                <div class="row pt-3">
                                    <!-- ================= 작업 전 ================= -->
                                    <div class="col-6">
                                        <h5 class="mb-2"><b>작업 전</b></h5>

                                        <input class="form-control" type="file" id="formFileBefore" name="formFileBefore" accept="image/*"
                                               style="display:none;" multiple>

                                        <div id="thumbnailContainerBefore" class="row">
                                            <div class="col-4 mb-3" id="btnWrapBefore">
                                                <button type="button" class="btn" id="selectFileBtnBefore">
                                                    <i class="bi bi-plus"></i>
                                                    <p>(<span id="photoCountBefore">0</span>/20)</p>
                                                </button>
                                            </div>
                                        </div>

                                        <div class="mb-3">
                                            <label class="form-label fw-semibold">접수내용</label>
                                            <textarea class="form-control" id="insDeliveryNote" name="deliveryNote" rows="5"></textarea>
                                        </div>
                                    </div>

                                    <!-- ================= 작업 후 ================= -->
                                    <div class="col-6">
                                        <h5 class="mb-2"><b>작업 후</b></h5>

                                        <input class="form-control" type="file" id="formFileAfter" name="formFileAfter" accept="image/*"
                                               style="display:none;" multiple>

                                        <div id="thumbnailContainerAfter" class="row">
                                            <div class="col-4 mb-3" id="btnWrapAfter">
                                                <button type="button" class="btn" id="selectFileBtnAfter">
                                                    <i class="bi bi-plus"></i>
                                                    <p>(<span id="photoCountAfter">0</span>/20)</p>
                                                </button>
                                            </div>
                                        </div>

                                        <div class="mb-3">
                                            <label class="form-label fw-semibold">작업내용</label>
                                            <textarea class="form-control" id="insProcessNote" name="processNote" rows="5"></textarea>
                                        </div>
                                    </div>

                                    <!-- 삭제 대상 사진 sort_ord CSV -->
                                    <input type="hidden" id="delBeforeSortOrds" name="delBeforeSortOrds" value="">
                                    <input type="hidden" id="delAfterSortOrds"  name="delAfterSortOrds"  value="">

                                </div>
                            </div>
                        </div>

                        <div class="accordion-item">
                            <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseFour" aria-expanded="true" aria-controls="collapseOne">
                                작업정보
                            </button>
                            <div id="collapseFour" class="box accordion-collapse collapse show">
                                <div class="row pt-3">
                                    <div class="col-6 mb-3">
                                        <h5 class="mb-2"><b>투입 장비</b></h5>
                                        <table class="table">
                                            <thead>
                                            <tr>
                                                <th>장비명</th>
                                                <th>보유수량</th>
                                                <th>사용수량</th>
                                                <th>비고</th>
                                                <th><button type="button" id="add-equipment" class="btn btn-primary">추가</button></th>
                                            </tr>
                                            </thead>
                                            <tbody id="body-equipment">
                                            <tr>
                                                <td><input type="text" class="form-control equip-name" placeholder="장비명"></td>
                                                <td><input type="number" class="form-control equip-own"  placeholder="0"></td>
                                                <td><input type="number" class="form-control equip-use"  placeholder="0"></td>
                                                <td><input type="text" class="form-control equip-remark" placeholder="비고"></td>
                                                <td><button type="button" class="btn btn-danger delete-row">삭제</button></td>
                                            </tr>
                                            </tbody>

                                        </table>
                                    </div>
                                    <div class="col-6 mb-3">
                                        <h5 class="mb-2"><b>투입 인력</b></h5>
                                        <table class="table">
                                            <thead>
                                            <tr>
                                                <th>이름</th>
                                                <th>부서</th>
                                                <th>인건비</th>
                                                <th><button type="button" id="add-personnel" class="btn btn-primary">추가</button></th>
                                            </tr>
                                            </thead>
                                            <tbody id="body-personnel">
                                            <tr>
                                                <td><input type="text" class="form-control person-name" placeholder="이름"></td>
                                                <td><input type="text" class="form-control person-dept" placeholder="부서"></td>
                                                <td><input type="text" class="form-control person-labor" placeholder="인건비"></td>
                                                <td><button type="button" class="btn btn-danger delete-row">삭제</button></td>
                                            </tr>
                                            </tbody>

                                        </table>
                                    </div>
                                    <div class="col-6 mb-3">
                                        <h5 class="mb-2"><b>투입 자재</b></h5>
                                        <table class="table">
                                            <thead>
                                            <tr>
                                                <th>자재명</th>
                                                <th>규격</th>
                                                <th>단위</th>
                                                <th>사용량</th>
                                                <th>잔량</th>
                                                <th>금액</th>
                                                <th><button type="button" id="add-material" class="btn btn-primary">추가</button></th>
                                            </tr>
                                            </thead>
                                            <tbody id="body-material">
                                            <tr>
                                                <td><input type="text" class="form-control mat-name" placeholder="자재명"></td>
                                                <td><input type="text" class="form-control mat-spec" placeholder="규격"></td>
                                                <td><input type="text" class="form-control mat-unit" placeholder="단위"></td>
                                                <td><input type="text" class="form-control mat-use"  placeholder="사용량"></td>
                                                <td><input type="text" class="form-control mat-remain" placeholder="잔량"></td>
                                                <td><input type="text" class="form-control mat-amount" placeholder="금액"></td>
                                                <td><button type="button" class="btn btn-danger delete-row">삭제</button></td>
                                            </tr>
                                            </tbody>

                                        </table>
                                    </div>
                                    <div class="col-6 mb-3">
                                        <h5 class="mb-2"><b>작업 범위</b></h5>
                                        <table class="table">
                                            <thead>
                                            <tr>
                                                <th>가로(m)</th>
                                                <th>세로(m)</th>
                                                <th>면적(㎡)</th>
                                                <th>깊이(cm)</th>
                                                <th>폭(m)</th>
                                                <th><button type="button" id="add-scope" class="btn btn-primary">추가</button></th>
                                            </tr>
                                            </thead>
                                            <tbody id="body-scope">
                                            <tr>
                                                <td><input type="text" class="form-control sc-width"  placeholder="가로(m)"></td>
                                                <td><input type="text" class="form-control sc-height" placeholder="세로(m)"></td>
                                                <td><input type="text" class="form-control sc-area"   placeholder="면적(㎡)"></td>
                                                <td><input type="text" class="form-control sc-depth"  placeholder="깊이(cm)"></td>
                                                <td><input type="text" class="form-control sc-span"   placeholder="폭(m)"></td>
                                                <td><button type="button" class="btn btn-danger delete-row">삭제</button></td>
                                            </tr>
                                            </tbody>

                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="accordion-item">
                            <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseReportExtra" aria-expanded="true" aria-controls="collapseReportExtra">
                                보고서 추가정보
                            </button>
                            <div id="collapseReportExtra" class="box accordion-collapse collapse show">
                                <div class="row pt-3">
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold">차선/위치 보조정보</label>
                                        <input type="text" class="form-control" id="insLaneInfo" name="laneInfo" placeholder="예: 1차로, Ramp-C">
                                    </div>
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold">실작업량</label>
                                        <input type="text" class="form-control" id="insWorkQty" name="workQty" placeholder="예: 2개소">
                                    </div>
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold">환산작업량계</label>
                                        <input type="text" class="form-control" id="insConvertWorkQty" name="convertWorkQty" placeholder="예: 2">
                                    </div>
                                    <div class="col-3 mb-3">
                                        <label class="form-label fw-semibold">작업량계상</label>
                                        <input type="text" class="form-control" id="insAccountWorkQty" name="accountWorkQty" placeholder="예: 2">
                                    </div>
                                    <div class="col-12 mb-3">
                                        <label class="form-label fw-semibold">보고서 비고</label>
                                        <textarea class="form-control" id="insReportRemark" name="reportRemark" rows="3" placeholder="보고서에 표시할 비고를 입력하세요."></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 이력정보 -->
                    <div class="accordion-item">
                        <button class="accordion-button" type="button"
                                data-bs-toggle="collapse"
                                data-bs-target="#collapseHistory"
                                aria-expanded="true"
                                aria-controls="collapseHistory">
                            이력정보
                        </button>

                        <div id="collapseHistory" class="box accordion-collapse collapse show">
                            <div class="row pt-3">
                                <div class="col-12">
                                    <div class="table-responsive">
                                        <table class="table table-sm table-bordered align-middle" id="historyTable">
                                            <thead>
                                            <tr>
                                                <th style="width: 160px;">변경일시</th>
                                                <th style="width: 110px;">행위</th>
                                                <th style="width: 120px;">작업자</th>
                                                <th>요약</th>
                                                <th style="width: 80px;">상세</th>
                                            </tr>
                                            </thead>
                                            <tbody id="historyTableBody">
                                            <tr>
                                                <td colspan="5" class="text-center text-muted">이력이 없습니다.</td>
                                            </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <%--
                    <div class="title">
                        <h5><b>히스토리</b></h5>
                    </div>--%>
                </form>
            </div>
            <div class="modal-footer d-flex justify-content-end align-items-center gap-1">

                <!-- 체크박스 -->
                <div class="form-check mb-0">
                    <input class="form-check-input" type="checkbox" id="insAlarmSendYn"
                           name="alarmSendYn" value="Y" checked>
                    <label class="form-check-label" for="insAlarmSendYn">
                        알림톡 발송
                    </label>
                </div>

                <button type="button" class="btn btn-primary" id="btnEdit" style="display:none;">수정</button>
                <button type="button" class="btn btn-primary" id="btnSave">저장</button>
                <button type="button" class="btn btn-outline-danger" id="btnDeleteBottom" style="display:none;">삭제</button>
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>

            </div>
        </div>
    </div>
</div>

<div id="imsImgViewer" style="display:none;">
    <div class="position-relative">
        <button onclick="document.getElementById('imsImgViewer').style.display='none';"><i class="bi bi-x-lg"></i></button>
        <img id="imsImgViewerSrc" src="">
    </div>
</div>

<script>
    function renderHistoryList(histories) {
        var $tbody = $("#historyTableBody");
        $tbody.empty();

        if (!histories || histories.length === 0) {
            $tbody.append(
                '<tr><td colspan="5" class="text-center text-muted">이력이 없습니다.</td></tr>'
            );
            return;
        }

        for (var i = 0; i < histories.length; i++) {
            var h = histories[i];

            var actionType = nvl(h.actionType);
            var actionNm = getHistoryActionName(actionType);
            var badgeClass = getHistoryBadgeClass(actionType);

            var summary = buildHistorySummary(h);

            var row = ''
                + '<tr>'
                + '  <td>' + escapeHtml(nvl(h.actionDatetime)) + '</td>'
                + '  <td><span class="badge ' + badgeClass + '">' + escapeHtml(actionNm) + '</span></td>'
                + '  <td>' + escapeHtml(nvl(h.actionUserNm)) + '</td>'
                + '  <td>' + escapeHtml(summary) + '</td>'
                + '  <td>'
                + '      <button type="button" class="btn btn-sm btn-outline-secondary" onclick="toggleHistoryDetail(' + i + ')">보기</button>'
                + '  </td>'
                + '</tr>'
                + '<tr id="historyDetailRow_' + i + '" style="display:none;">'
                + '  <td colspan="5">'
                +        buildHistoryDetailTable(h)
                + '  </td>'
                + '</tr>';

            $tbody.append(row);
        }
    }

    function getHistoryActionName(actionType) {
        if (actionType === 'CREATE') return '등록';
        if (actionType === 'UPDATE') return '수정';
        if (actionType === 'STATUS_CHANGE') return '상태변경';
        if (actionType === 'ASSIGN') return '담당자변경';
        if (actionType === 'WORK_START') return '작업시작';
        if (actionType === 'WORK_END') return '작업종료';
        return actionType || '-';
    }

    function getHistoryBadgeClass(actionType) {
        if (actionType === 'CREATE') return 'bg-primary';
        if (actionType === 'UPDATE') return 'bg-secondary';
        if (actionType === 'STATUS_CHANGE') return 'bg-warning text-dark';
        if (actionType === 'ASSIGN') return 'bg-info text-dark';
        if (actionType === 'WORK_START') return 'bg-success';
        if (actionType === 'WORK_END') return 'bg-dark';
        return 'bg-light text-dark';
    }

    function buildHistorySummary(h) {
        if (h.actionMemo && h.actionMemo !== '') {
            return h.actionMemo;
        }

        if (h.changedFields && h.changedFields !== '') {
            return h.changedFields;
        }

        return '-';
    }

    function buildHistoryDetailTable(h) {
        var beforeObj = parseJsonSafe(h.beforeData);
        var afterObj = parseJsonSafe(h.afterData);

        var keys = {};
        var k;

        if (beforeObj) {
            for (k in beforeObj) {
                keys[k] = true;
            }
        }
        if (afterObj) {
            for (k in afterObj) {
                keys[k] = true;
            }
        }

        var rows = '';
        for (k in keys) {
            rows += ''
                + '<tr>'
                + '  <th style="width:180px;">' + escapeHtml(getHistoryFieldName(k)) + '</th>'
                + '  <td>' + escapeHtml(formatHistoryValue(k, beforeObj ? beforeObj[k] : '')) + '</td>'
                + '  <td>' + escapeHtml(formatHistoryValue(k, afterObj ? afterObj[k] : '')) + '</td>'
                + '</tr>';
        }

        if (rows === '') {
            rows = '<tr><td colspan="3" class="text-center text-muted">상세 변경내역이 없습니다.</td></tr>';
        }

        return ''
            + '<div class="p-2 bg-light border rounded">'
            + '  <div class="mb-2"></div>'
            + '  <table class="table table-sm table-bordered mb-0 history-detail-table">'
            + '      <thead>'
            + '          <tr>'
            + '              <th>항목</th>'
            + '              <th>변경 전</th>'
            + '              <th>변경 후</th>'
            + '          </tr>'
            + '      </thead>'
            + '      <tbody>'
            +            rows
            + '      </tbody>'
            + '  </table>'
            + '</div>';
    }

    function toggleHistoryDetail(idx) {
        $("#historyDetailRow_" + idx).toggle();
    }

    function getHistoryFieldName(field) {
        if (field === 'reportNo') return '접수번호';
        if (field === 'reportDate') return '접수일시';
        if (field === 'statusCd') return '작업상태';
        if (field === 'siteCd') return '현장';
        if (field === 'adminSiteCd') return '관할현장';

        if (field === 'lat') return '위도';
        if (field === 'lng') return '경도';
        if (field === 'accuracyM') return 'GPS 정확도(m)';
        if (field === 'capturedAt') return '좌표취득시간';
        if (field === 'capturedTs') return '측정시각(epoch ms)';

        if (field === 'directionCd') return '방향';
        if (field === 'addr') return '입력주소';
        if (field === 'detailInfo') return '위치상세정보';
        if (field === 'deliveryNote') return '전달사항';

        if (field === 'receiverId') return '접수자';
        if (field === 'managerId') return '작업자';

        if (field === 'processNote') return '작업내용';
        if (field === 'workStartAt') return '작업시작일시';
        if (field === 'workEndAt') return '작업종료일시';

        if (field === 'weatherCd') return '접수 시 날씨';
        if (field === 'workWeatherCd') return '작업 시 날씨';
        if (field === 'receiptGbCd') return '작업유형';

        if (field === 'staMeters') return 'STA meters';
        if (field === 'staKmDecimal') return 'STA';
        if (field === 'staText') return 'STA 정보';

        if (field === 'pavementTypeCds') return '포장형식 및 시설물';
        if (field === 'occurPlaceCds') return '발생장소';

        if (field === 'docNo') return '문서번호';

        return field;
    }

    function formatHistoryValue(field, value) {
        var v = nvl(value);

        if (v === '') return '-';

        if (field === 'statusCd') {
            if (v === 'RECEIVED') return '접수';
            if (v === 'WORKING') return '작업중';
            if (v === 'DONE') return '완료';
            if (v === 'COMPLETE') return '완료';
            if (v === 'HOLD') return '보류';
        }

        if (field === 'directionCd') {
            return roadDirMap[v] || v;
        }

        if (field === 'receiptGbCd') {
            if (v === 'POTHOLE') return '포트홀';
        }

        if (field === 'weatherCd' || field === 'workWeatherCd') {
            if (v === 'W001') return '맑음';
            if (v === 'W002') return '구름많음';
            if (v === 'W003') return '흐림';
            if (v === 'W004') return '비';
            if (v === 'W005') return '눈';
            if (v === 'W999') return '기타';
        }

        if (field === 'pavementTypeCds') {
            return formatCsvCode(v, {
                'ASP': '아스팔트',
                'CONC': '콘크리트'
            });
        }

        if (field === 'occurPlaceCds') {
            return formatCsvCode(v, {
                'EARTH': '토공부',
                'BRIDGE': '교량부',
                'TUNNEL': '터널부'
            });
        }
        if (field === 'reportDate' ||
            field === 'capturedAt' ||
            field === 'workStartAt' ||
            field === 'workEndAt') {

            return String(v).replace('T', ' ');
        }
        return v;
    }

    function formatCsvCode(csv, codeMap) {
        var s = nvl(csv);
        if (s === '') return '-';

        var arr = s.split(',');
        var out = [];

        for (var i = 0; i < arr.length; i++) {
            var code = $.trim(arr[i]);
            if (!code) continue;
            out.push(codeMap[code] || code);
        }

        return out.length > 0 ? out.join(', ') : '-';
    }

    document.addEventListener('click', function(e) {
        if (e.target.tagName === 'IMG' && e.target.closest('.thumbnail-item')) {
            var modal = document.getElementById('ims-add-modal');
            var scrollTop = modal.scrollTop; // ← modal-body 아니라 modal 자체

            document.getElementById('imsImgViewerSrc').src = e.target.src;
            document.getElementById('imsImgViewer').style.display = 'flex';

            document.querySelector('#imsImgViewer button').onclick = function() {
                document.getElementById('imsImgViewer').style.display = 'none';
                modal.scrollTop = scrollTop; // ← 복원
            };
        }
    });
</script>
