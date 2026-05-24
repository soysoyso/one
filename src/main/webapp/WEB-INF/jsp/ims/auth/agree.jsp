<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java"  pageEncoding="UTF-8"%>
<%@include file="../common/head.jsp" %>

<body>
<div class="container text-center pt-5">
    <img src="/img/icon/icon-modal.png" class="img-fluid mb-4">
    <h2>정확한 현장 정보 확인을 위해<br>위치 정보에 동의가 필요합니다!</h2>
    <p>다음단계로 이동하기 위해<br>위치 정보 동의에 <b class="fw-bold text-primary">‘허용’</b>해주세요.</p>

    <!-- 기존 버튼은 “권한 요청 트리거”로 바꾸는 걸 추천 -->
    <button type="button" class="btn btn-primary mt-3" id="btnAgreeGeo">위치 정보 동의하기</button>
</div>

<!-- ✅ 사전 안내 모달 (커스텀 팝업) -->
<div class="modal fade" id="geoAgreeModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-body text-center" style="padding: 30px 18px;">
                <h4 class="text-primary" style="margin-bottom: 10px;">위치 권한이 필요해요</h4>
                <p style="margin-bottom: 18px;">
                    포트홀 위치를 자동으로 가져와<br>
                    정확하고 빠르게 접수하기 위해 사용합니다.
                </p>

                <div class="d-grid gap-2">
                    <button type="button" class="btn btn-primary" id="btnRequestGeo">
                        허용하고 계속
                    </button>
                    <button type="button" class="btn bg-secondary-subtle" id="btnSkipGeo">
                        나중에 할게요
                    </button>
                </div>

                <p class="text-muted" style="margin-top: 12px; font-size: 12px;">
                    * 위치는 접수 목적 외로 사용하지 않습니다.
                </p>
            </div>
        </div>
    </div>
</div>

<%@include file="../common/modal.jsp" %>
<script src="/js/location-service.js"></script>

<script>
    function goNext() {
        location.href = '/manage';
    }

    function requestGeoThenGo() {
        if (!navigator.geolocation) {
            // 브라우저 미지원이면 안내 후 다음 단계(정책에 맞게)
            alert('이 브라우저는 위치 기능을 지원하지 않아요.');
            return;
        }

        navigator.geolocation.getCurrentPosition(
            function (pos) {
                // 성공 -> 다음으로
                goNext();
            },
            function (err) {
                // 권한 거부(1)면 기존 locModal 안내 사용
                if (err && err.code === 1) {
                    $('#geoAgreeModal').modal('hide');
                    $('#locModal').modal('show');
                } else {
                    alert('위치를 확인하지 못했어요. 실외로 이동 후 다시 시도해 주세요.');
                }
            },
            { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
        );
    }

    window.addEventListener('DOMContentLoaded', function () {
        // 페이지 진입 시 사전 안내 모달 먼저 띄우기
        $('#geoAgreeModal').modal('show');

        // 기존 버튼을 눌러도 동일하게 동작
        document.getElementById('btnAgreeGeo').addEventListener('click', function () {
            $('#geoAgreeModal').modal('show');
        });

        document.getElementById('btnRequestGeo').addEventListener('click', function () {
            requestGeoThenGo();
        });

        document.getElementById('btnSkipGeo').addEventListener('click', function () {
            // “나중에” 정책 선택:
            // 1) 그냥 머무르게(권장) / 2) 다음으로 보내되 main에서 다시 유도
            $('#geoAgreeModal').modal('hide');
        });
    });
</script>
</body>
</html>
