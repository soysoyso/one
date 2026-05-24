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
                <div class="col-6"><input class="form-control" type="date" id="srchStrtDt"></div>
                <div class="col-6"><input class="form-control" type="date" id="srchEndDt"></div>
                <div class="col-9"><input type="text" class="form-control" id="userId" placeholder="담당자, 작업명" name="userId" required="" value=""></div>
                <div class="col-3"><button type="button" class="btn btn-primary">검색</button></div>
            </div>
        </div>
    </div>

    <div class="ims-list mt-2">
        <div class="total">총 1,357건</div>
        <div class="photo-type card mb-3" id="received" onclick="location.href='/ims/porthole/detail'">
            <div class="detail-photo"><img src="/img/ex-pothole.jpg" class="img-fluid w-100"></div>
            <div class="detail">
                <div><span class="state">접수</span><span class="applicant-date photo-type-block ms-2"></span></div>
                <p><b class="upward">(상행)</b>경기도 용인시 처인구 포곡읍 신원리 208-11</p>
                <div>
                    <span class="applicant fw-bold">홍길동</span>
                    <span class="applicant-date">2025-11-25 15:00</span>
                </div>
            </div>
        </div>
        <div class="list-type card mb-3" id="received" onclick="location.href='/ims/porthole/detail'">
            <div class="detail-photo"><img src="/img/ex-pothole.jpg" class="img-fluid w-100"></div>
            <div class="detail">
                <div><span class="state">접수</span><span class="applicant-date photo-type-block ms-2"></span></div>
                <p><b class="upward">(상행)</b>경기도 용인시 처인구 포곡읍 신원리 208-11</p>
                <div>
                    <span class="applicant fw-bold">홍길동</span>
                    <span class="applicant-date">2025-11-25 15:00</span>
                </div>
            </div>
        </div>
        <div class="list-type card mb-3" id="working" onclick="location.href='/ims/porthole/detail'">
            <div class="detail-photo"><img src="/img/ex-pothole.jpg" class="img-fluid w-100"></div>
            <div class="detail">
                <div><span class="state">작업중</span><span class="applicant-date photo-type-block ms-2"></span></div>
                <p><b class="downward">(하행)</b>경기도 용인시 처인구 11</p>
                <div>
                    <span class="applicant fw-bold">홍길동</span>
                    <span class="applicant-date">2025-11-25 15:00</span>
                </div>
            </div>
        </div>
        <div class="list-type card mb-3" id="completed" onclick="location.href='/ims/porthole/detail'">
            <div class="detail-photo"><img src="/img/ex-pothole.jpg" class="img-fluid w-100"></div>
            <div class="detail">
                <div><span class="state">완료</span><span class="applicant-date photo-type-block ms-2"></span></div>
                <p><b class="downward">(하행)</b>경기 용인시 처인구 모현읍 초부리 472</p>
                <div>
                    <span class="applicant fw-bold">홍길동</span>
                    <span class="applicant-date">2025-11-25 15:00</span>
                </div>
            </div>
        </div>
        <div class="list-type card mb-3" id="hold" onclick="location.href='/ims/porthole/detail'">
            <div class="detail-photo"><img src="/img/ex-pothole.jpg" class="img-fluid w-100"></div>
            <div class="detail">
                <div><span class="state">보류</span><span class="applicant-date photo-type-block ms-2"></span></div>
                <p><b class="downward">(하행)</b>경기도 용인시 처인구 11</p>
                <div>
                    <span class="applicant fw-bold">홍길동</span>
                    <span class="applicant-date">2025-11-25 15:00</span>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
<script>
    // 날짜 앞 문구 추가
    $(document).ready(function() {
        $('.ims-list .card').each(function() {
            const stateText = $(this).find('.state').text().trim();
            const $dateSpan = $(this).find('.applicant-date');
            const originalDate = $dateSpan.text();

            let prefix = "";
            if (stateText === "접수") prefix = "접수일시: ";
            else if (stateText === "작업중") prefix = "작업일시: ";
            else if (stateText === "완료") prefix = "완료일시: ";
            else if (stateText === "보류") prefix = "보류일시: ";

            if (prefix !== "" && !originalDate.includes("일시:")) {
                $dateSpan.text(prefix + originalDate);
            }
        });
    });

    // 필터
    document.querySelectorAll('input[name="status"]').forEach((radio) => {
        radio.addEventListener('change', (e) => {
            const selectedStatus = e.target.id.replace('status-', ''); // all, received 등
            const isPhotoView = $('#view-photo').hasClass('active'); // 현재 포토뷰인지 확인

            const cards = document.querySelectorAll('.ims-list .card');

            cards.forEach((card) => {
                const statusMatch = (selectedStatus === 'all' || card.id === selectedStatus);
                const viewMatch = isPhotoView ? card.classList.contains('photo-type') : card.classList.contains('list-type');

                // 상태와 뷰 타입이 모두 맞아야 노출
                if (statusMatch && viewMatch) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        });
    });

    $(document).ready(function() {
        // 1. 리스트형 클릭 시
        $('#view-list').click(function() {
            // 아이콘 활성화 상태 변경
            $('.filter-type a').removeClass('active');
            $(this).addClass('active');

            // 모든 카드에서 photo-type을 빼고 list-type을 추가
            $('.ims-list .card').removeClass('photo-type').addClass('list-type');
        });

        // 2. 포토형 클릭 시
        $('#view-photo').click(function() {
            // 아이콘 활성화 상태 변경
            $('.filter-type a').removeClass('active');
            $(this).addClass('active');

            // 모든 카드에서 list-type을 빼고 photo-type을 추가
            $('.ims-list .card').removeClass('list-type').addClass('photo-type');
        });

        // 초기 실행: 디폴트로 list-type 적용
        $('#view-list').trigger('click');
    });

    // 상태에 따른 파라미터
    $(document).ready(function() {
        const urlParams = new URLSearchParams(window.location.search);
        const statusParam = urlParams.get('status');

        if (statusParam) {
            const targetRadio = document.getElementById('status-' + statusParam);

            if (targetRadio) {
                targetRadio.checked = true;
                targetRadio.dispatchEvent(new Event('change'));
            }
        }
    });


</script>
</html>