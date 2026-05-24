<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java"  pageEncoding="UTF-8"%>
<%request.setAttribute("pageTitle", "접수내역");%>
<%@include file="../common/head.jsp" %>
<%@include file="../common/header.jsp" %>

<body class="sub">
<div class="container">

    <div class="list-filter btn-group w-100">
        <input type="radio" class="btn-check" name="status" id="status-all" checked>
        <label class="btn btn-outline-primary" for="status-all">전체</label>

        <input type="radio" class="btn-check" name="status" id="status-received">
        <label class="btn btn-outline-primary" for="status-received">접수</label>

        <input type="radio" class="btn-check" name="status" id="status-working">
        <label class="btn btn-outline-primary" for="status-working">작업중</label>

        <input type="radio" class="btn-check" name="status" id="status-completed">
        <label class="btn btn-outline-primary" for="status-completed">완료</label>

        <input type="radio" class="btn-check" name="status" id="status-hold">
        <label class="btn btn-outline-primary" for="status-hold">보류</label>
    </div>

    <div class="detail-search-zone">
        <div class="btn-group">
            <div class="">
                <a class="collapse-btn" data-bs-toggle="collapse" href="#detailsearch" role="button" aria-expanded="false" aria-controls="detailsearch">
                    #상세검색
                </a>
            </div>
            <div class="filter-type">
                <a id="view-list" class="active"><i class="bi bi-view-list"></i></a>
                <a id="view-photo"><i class="bi bi-images"></i></a>
            </div>
        </div>

        <div class="collapse" id="detailsearch">
            <div class="row g-1">
                <div class="col-12">
                    <select class="form-select" id="receiptTypeCd">
                        <option value="">접수유형 전체</option>
                        <c:forEach var="item" items="${workTypeList}">
                            <option value="${item.cdCode}">${item.cdCodeNm}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-6"><input class="form-control" type="date" id="srchStrtDt"></div>
                <div class="col-6"><input class="form-control" type="date" id="srchEndDt"></div>

                <div class="col-9"><input type="text" class="form-control" id="keyword" placeholder="담당자, 작업명" name="keyword" value=""></div>
                <div class="col-3"><button type="button" class="btn btn-primary" id="btn-search">검색</button></div>
            </div>
        </div>
    </div>

    <div class="view-type">
        <a id="view-newest" class="active me-1" href="javascript:void(0)">최신순</a>
        <a id="view-oldest" href="javascript:void(0)">과거순</a>
    </div>

    <%-- 접수내역 --%>
    <div id="list-container"></div>

    <div class="text-center mt-2">
        <button type="button" id="btn-more" class="btn btn-outline-secondary w-100" style="display:none;">
            더보기
        </button>
    </div>

</div>
</body>

<script>
    const roadDirMap = {};
    <c:forEach var="item" items="${roadDirList}">
    roadDirMap["${item.cdCode}"] = "${item.cdCodeNm}";
    </c:forEach>

    let currentOrder = 'newest'; // newest/oldest

    // =========================
    // 상태/페이징/뷰 상태
    // =========================
    let offset = 0;
    const limit = 5;

    let currentStatus = 'all'; // all/received/working/completed/hold
    let currentView = 'list';  // list/photo


    // =========================
    // 초기 진입
    // =========================
    $(document).ready(function() {

        // 1) URL에 있는 조건 먼저 UI에 복원
        const q = readQueryFromUrl();
        applyQueryToUI(q);

        // 2) 날짜 기본값은 "URL/복원값이 없을 때만" 오늘로
        const today = getToday();
        if (!$('#srchStrtDt').val()) $('#srchStrtDt').val(today);
        if (!$('#srchEndDt').val())  $('#srchEndDt').val(today);

        // 3) 뷰 토글 초기값 (applyQueryToUI에서 이미 적용했어도 안전하게)
        applyView(currentView || 'list');

        // 4) 탭(상태) 변경
        document.querySelectorAll('input[name="status"]').forEach((radio) => {
            radio.addEventListener('change', (e) => {
                currentStatus = e.target.id.replace('status-', '');
                offset = 0;

                // ✅ 조건 저장 (뒤로가기/새로고침 유지)
                saveQueryToUrl(true);

                loadList(false);
            });
        });

        // 5) 검색 클릭
        $('#btn-search').on('click', function() {
            offset = 0;

            // ✅ 조건 저장
            saveQueryToUrl(true);

            loadList(false);
        });

        // 6) 더보기
        $('#btn-more').on('click', function() {
            loadList(true);
        });

        // 7) 뷰 토글
        $('#view-list').click(function() {
            $('.filter-type a').removeClass('active');
            $(this).addClass('active');
            applyView('list');

            // ✅ 조건 저장
            saveQueryToUrl(true);
        });

        $('#view-photo').click(function() {
            $('.filter-type a').removeClass('active');
            $(this).addClass('active');
            applyView('photo');

            // ✅ 조건 저장
            saveQueryToUrl(true);
        });

        // 8) 첫 조회 전에도 현재 조건을 URL에 박아두기(처음 진입시 북마크도 됨)
        saveQueryToUrl(true);

        offset = 0;
        loadList(false);

        // 9) 최신순/과거순
        $('#view-newest').on('click', function() {
            $('.view-type a').removeClass('active');
            $(this).addClass('active');

            currentOrder = 'newest';
            offset = 0;

            saveQueryToUrl(true);
            loadList(false);
        });

        $('#view-oldest').on('click', function() {
            $('.view-type a').removeClass('active');
            $(this).addClass('active');

            currentOrder = 'oldest';
            offset = 0;

            saveQueryToUrl(true);
            loadList(false);
        });
    });

    window.addEventListener('popstate', function() {
        const q = readQueryFromUrl();
        applyQueryToUI(q);
        offset = 0;
        loadList(false);
    });

    // 조회
    function loadList(append) {

        const params = {
            offset: offset,
            limit: limit,
            status: currentStatus,
            order: currentOrder,
            srchStrtDt: $('#srchStrtDt').val() || '',
            srchEndDt: $('#srchEndDt').val() || '',
            keyword: $('#keyword').val() || '',
            receiptTypeCd: $('#receiptTypeCd').val() || '',

        };

        $.ajax({
            url: '/pothole/list-data',
            type: 'get',
            dataType: 'json',
            data: params,
            success: function(res) {

                const list = res && res.list ? res.list : [];
                const hasMore = res && res.hasMore === true;
                const totalCount = res && res.totalCount ? res.totalCount : 0;

                renderList(list, append, totalCount);

                offset += list.length;

                if (hasMore) $('#btn-more').show();
                else $('#btn-more').hide();

                applyView(currentView);
            },
            error: function() {
                if (!append) {
                    $('#list-container').html("<p class='text-danger p-3 text-center'>조회 중 오류가 발생했습니다.</p>");
                }
                $('#btn-more').hide();
            }
        });
    }

    function renderList(list, append, totalCount) {

        const $box = $('#list-container');

        if (!append) {
            $box.empty();
        }

        if (!append && (!list || list.length === 0)) {
            $box.html("<p class='text-muted p-3 text-center'>조회 결과가 없습니다.</p>");
            return;
        }

        if (append && (!list || list.length === 0)) {
            return;
        }

        // wrapper(1번만 생성)
        if ($box.find('.ims-list').length === 0) {
            $box.append(
                "<div class='ims-list mt-2'>"
                + "  <div class='total' id='totalCountText'></div>"
                + "</div>"
            );
        }

        // 총 건수 업데이트
        $('#totalCountText').text("총 " + formatNumber(totalCount) + "건");

        let html = "";

        list.forEach(function(item) {

            const reportNo   = item.reportNo;
            const statusCd   = item.statusCd;
            const addr       = item.addr || '';
            const direction  = item.directionCd;
            const workStartAt = item.workStartAt || '';
            const workEndAt = item.workEndAt || '';
            const reportDate = item.reportDate || '';
            const applicant  = item.userName || '';
            const staText    = item.staText || '';
            const receiptGbNm    = item.receiptGbNm || '';

            // 상태 매핑
            let cardId = '';
            let stateText = '';
            let datePrefix = '';
            let dateValue = ''; // ✅ 상태별로 출력할 날짜값

            if (statusCd === 'RECEIVED') {
                cardId='received'; stateText='접수'; datePrefix='접수일시: ';
                dateValue = reportDate;
            } else if (statusCd === 'WORKING') {
                cardId='working'; stateText='작업중'; datePrefix='작업일시: ';
                dateValue = workStartAt;
            } else if (statusCd === 'DONE' || statusCd === 'COMPLETE') {
                cardId='completed'; stateText='완료'; datePrefix='완료일시: ';
                dateValue = workEndAt;
            } else if (statusCd === 'HOLD') {
                cardId='hold'; stateText='보류'; datePrefix='보류일시: ';
                dateValue = reportDate; // ✅ 보류일시 필드 없으면 접수일시로 대체(원하면 다른걸로)
            } else {
                cardId=''; stateText=statusCd; datePrefix='';
                dateValue = '';
            }
            // 방향 매핑
            let dirClass = '';
            let dirText  = '';

            if (direction) {
                dirText = '(' + (roadDirMap[direction] || direction) + ')';

                const seq = direction.split('_')[1] || '';
                if (seq === '1') dirClass = 'upward';
                if (seq === '2') dirClass = 'downward';
            }
            const detailUrl = "/pothole/detail/" + encodeURIComponent(reportNo);

            // 썸네일
            const hasThumb = !!item.thumbUrl;
            const thumbUrl = item.thumbUrl || '/img/ex-pothole.jpg';

            html += ""
                + "<div class='list-type card mb-3' id='" + cardId + "' onclick=\"location.href='" + detailUrl + "'\">"
                + "  <div class='detail-photo'>";

            html += "    <img src='" + thumbUrl + "' class='img-fluid w-100'"
                + " onerror=\"this.style.display='none'; this.nextElementSibling.classList.remove('d-none');\">"
                + "    <div class='no-img-msg d-none'><p class='mb-5'>접수된 사진이 없습니다.</p></div>";

            html += ""
                + "  </div>"
                + "  <div class='detail'>"
                + "    <div>"
                + "      <span class='state'>" + stateText + "</span>"
                + "      <span class='applicant-date'>" + escapeHtml(datePrefix + (dateValue || '')) + "</span>"
                + "      <span class='applicant-date photo-type-block ms-2'></span>"
                + "    </div>"
                + "    <p class='mb-0'>"
                + "      <span class='badge type'>" + receiptGbNm + "</span>"
                + "      <span><b class='" + dirClass + "'>" + dirText + "</b></span>"
                + "    </p>"
                + "    <p class='mb-0'>" + escapeHtml(addr) + "</p>"
                + "    <div>"
                + "      <span class='applicant fw-bold'> STA " + escapeHtml(staText) + "</span>"
                + "      <span class='applicant fw-bold'>" + escapeHtml(applicant) + "</span>"
                // + "      <span class='applicant-date'>" + escapeHtml(datePrefix + reportDate) + "</span>"
                + "    </div>"
                + "  </div>"
                + "</div>";

        });

        $box.find('.ims-list').append(html);
    }

    // 뷰 토글 적용
    function applyView(view) {

        currentView = view;

        if (view === 'list') {
            $('.ims-list .card').removeClass('photo-type').addClass('list-type');
        } else {
            $('.ims-list .card').removeClass('list-type').addClass('photo-type');
        }
    }


    // =========================
    // URL <-> 검색조건 동기화
    // =========================
    function buildQueryFromUI() {
        return {
            status: currentStatus || 'all',
            view: currentView || 'list',
            order: currentOrder || 'newest',
            srchStrtDt: $('#srchStrtDt').val() || '',
            srchEndDt: $('#srchEndDt').val() || '',
            keyword: $('#keyword').val() || ''
            // offset/limit까지 유지하고 싶으면 여기에 포함 가능
            // offset: String(offset || 0),
            // limit: String(limit || 5)
        };
    }

    function applyQueryToUI(q) {
        // status
        const status = q.status || 'all';
        const targetRadio = document.getElementById('status-' + status);
        if (targetRadio) {
            targetRadio.checked = true;
            currentStatus = status;
        } else {
            document.getElementById('status-all').checked = true;
            currentStatus = 'all';
        }

        // view
        const view = q.view || 'list';
        $('.filter-type a').removeClass('active');
        if (view === 'photo') {
            $('#view-photo').addClass('active');
            applyView('photo');
        } else {
            $('#view-list').addClass('active');
            applyView('list');
        }

        // dates / keyword
        if (q.srchStrtDt) $('#srchStrtDt').val(q.srchStrtDt);
        if (q.srchEndDt)  $('#srchEndDt').val(q.srchEndDt);
        if (typeof q.keyword === 'string') $('#keyword').val(q.keyword);

        const order = q.order || 'newest';
        $('.view-type a').removeClass('active');

        if (order === 'oldest') {
            $('#view-oldest').addClass('active');
            currentOrder = 'oldest';
        } else {
            $('#view-newest').addClass('active');
            currentOrder = 'newest';
        }
    }

    function readQueryFromUrl() {
        const sp = new URLSearchParams(window.location.search);
        return {
            status: sp.get('status') || '',
            view: sp.get('view') || '',
            order: sp.get('order') || '',
            srchStrtDt: sp.get('srchStrtDt') || '',
            srchEndDt: sp.get('srchEndDt') || '',
            keyword: sp.get('keyword') || ''
            // offset: sp.get('offset') || '',
            // limit: sp.get('limit') || ''
        };
    }

    function saveQueryToUrl(replace) {
        const q = buildQueryFromUI();
        const sp = new URLSearchParams();

        Object.keys(q).forEach(function(k) {
            if (q[k] !== '') sp.set(k, q[k]);
        });

        const newUrl = window.location.pathname + "?" + sp.toString();
        if (replace) history.replaceState(null, '', newUrl);
        else history.pushState(null, '', newUrl);
    }
    function handleNoImage(img) {
        img.style.display = 'none';
        const noImg = img.parentNode.querySelector('.no-img-msg');
        if (noImg) {
            noImg.classList.remove('d-none');
        }
    }
</script>
</html>
