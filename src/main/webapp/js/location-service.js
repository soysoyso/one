/**
 * ============================================================
 * location-service.js
 * ------------------------------------------------------------
 * 위치 기반 통합 서비스
 *
 * ▶ 1. 위치 수집 / 캐시
 * ▶ 2. 주소 변환 (Reverse Geocode)
 * ▶ 3. 고속도로 자동 매칭
 * ▶ 4. STA 계산
 * ▶ 5. 날씨 정보 조회
 * ▶ 6. 위치 신뢰도 / 안내 UI
 * ============================================================
 */

// 신뢰도 기준
const ACC_OK        = 100;      // 100m 이내면 좋음
const ACC_WARN      = 300;      // 300m 초과면 경고
const FRESH_OK      = 20_000;   // 20초 이내면 신선
const FRESH_WARN    = 60_000;   // 60초 초과면 경고
const FRESH_MS      = 20_000;   // 20초 이내면 신뢰

function fmtMs(ms){
    if (ms == null) return '?';
    const s = Math.round(ms/1000);
    return s < 60 ? `${s}s` : `${Math.floor(s/60)}m ${s%60}s`;
}


// 위치 캐시
var _posCache = null, _posCacheAt = 0;

function getCurrentPositionAsync(options) {
    return new Promise(function (resolve, reject) {
        navigator.geolocation.getCurrentPosition(resolve, reject, options);
    });
}

/**
 * 캐시된 위치가 충분히 "신선하고(fresh)" "정확하면(good)" 그 값을 반환하고,
 * 아니면 고정밀 위치를 새로 측정하여 반환한다. 실패/권한 거부/타임아웃 시 null.
 *
 * 동작:
 * 1) 내부 캐시(_posCache/_posCacheAt)가 maxAgeMs 이내이고 accuracy ≤ targetAcc 이면 캐시 반환
 * 2) 권한 상태를 사전 조회(가능한 경우). 'denied'면 이후 측정 시 실패 → null
 * 3) getCurrentPositionAsync(enableHighAccuracy=true, timeout=timeoutMs, maximumAge=0) 호출
 *    성공 시 캐시 갱신 후 GeolocationPosition 반환, 실패 시 null
 *
 * 부작용: 성공 시 _posCache, _posCacheAt 업데이트
 *
 * @param {Object} [cfg]
 * @param {number} [cfg.maxAgeMs=120000]   캐시 허용 최대 경과 시간(ms)
 * @param {number} [cfg.targetAcc=100]     허용 정확도 임계값(미터)
 * @param {number} [cfg.timeoutMs=20000]   새 측정 타임아웃(ms)
 * @returns {Promise<GeolocationPosition|null>} 최신/신뢰 가능한 위치 또는 null
 */
async function ensureLocation(cfg) {
    cfg = cfg || {};
    var maxAgeMs  = (cfg.maxAgeMs  != null ? cfg.maxAgeMs  : 120000);
    var targetAcc = (cfg.targetAcc != null ? cfg.targetAcc : 100);
    var timeoutMs = (cfg.timeoutMs != null ? cfg.timeoutMs : 20000);

    if (_posCache) {
        var fresh = (Date.now() - _posCacheAt) <= maxAgeMs;
        var good  = _posCache.coords && _posCache.coords.accuracy <= targetAcc;
        if (fresh && good) return _posCache;
    }

    try {
        if (navigator.permissions && navigator.permissions.query) {
            var s = await navigator.permissions.query({ name: 'geolocation' });
            if (s.state === 'denied') throw new Error('PERM_DENIED');
        }
    } catch (_) {}

    try {
        var pos = await getCurrentPositionAsync({ enableHighAccuracy: true, timeout: timeoutMs, maximumAge: 0 });
        _posCache = pos; _posCacheAt = Date.now();
        return pos;
    } catch (e) {
        return null;
    }
} // ensureLocation

/**
 * 페이지 로드 직후, Geolocation으로 현재 위치를 1회 측정해
 * 숨김 필드(lat/lng/acc, capturedAt/coordAgeMs)를 채우고
 * 위·경도로 주소를 비동기 조회한다.
 *
 * - 성공: #lat/#lng/#acc 설정 + ensureAddress() + fillCaptureTime(pos)
 * - 실패: 오류 코드별 로그만 남기고 종료(추후 모달에서 재시도)
 *
 * 옵션: {enableHighAccuracy:true, timeout:10000, maximumAge:0}
 */
function requestPositionOnLoad() {

    if (!navigator.geolocation) {
        showLocationMessage('이 브라우저는 위치 기능을 지원하지 않아요 😢');
        return;
    }

    // ✅ 위치 수집 시작 안내
    showLocationMessage('📍 현재 위치를 수집 중입니다...');

    navigator.geolocation.getCurrentPosition(
        function (pos) {
            // ✅ 성공 → 안내 문구 숨김
            hideLocationMessage();

            var c = pos.coords;
            _posCache = pos;
            _posCacheAt = Date.now();

            var latEl = document.getElementById('lat');
            var lngEl = document.getElementById('lng');
            var accEl = document.getElementById('accuracyM');

            if (latEl) latEl.value = c.latitude;
            if (lngEl) lngEl.value = c.longitude;
            if (accEl) accEl.value = Math.round(c.accuracy);
            console.log('초기 위치:', c.latitude, c.longitude, '±', Math.round(c.accuracy), 'm');

            ensureAddress();        // 주소 획득
            fillCaptureTime(pos);   // 좌표 취득 시간
            loadNearbyHighways(c.latitude, c.longitude); // 근처 고속도로 추천

        },
        function (err) {

            // ❌ 실패 → 메시지 교체
            if (err.code === 1) {
                hideLocationMessage();
                $('#locModal').modal('show');
            } else if (err.code === 2) {
                showLocationMessage('위치를 바로 확인하지 못했어요. 창가나 실외로 이동 후, 새로고침 해주세요. Wi-Fi를 켜면 더 정확해집니다.');
            } else if (err.code === 3) {
                showLocationMessage('시간이 오래 걸려 실패했어요. 주변이 잘 터지는 곳으로 이동 후 다시 시도해 주세요.');
            } else {
                showLocationMessage('위치 확인 중 알 수 없는 오류가 발생했어요. 잠시 후 다시 시도해 주세요.');
                console.error('Geo error:', err);
            }
        },
        { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
    );
}

/**
 * 포트홀 접수용: 위치 1회 측정 → lat/lng/accuracyM 채우고 주소만 조회
 */
function requestPositionForPothole() {

    if (!navigator.geolocation) {
        showLocationMessage('이 브라우저는 위치 기능을 지원하지 않아요 😢');
        return;
    }

    showLocationMessage('📍 현재 위치를 수집 중입니다...');

    navigator.geolocation.getCurrentPosition(
        function (pos) {
            hideLocationMessage();

            var c = pos.coords;
            _posCache = pos;
            _posCacheAt = Date.now();

            var siteCd = $('#siteCd').val() || '';

            var latEl = document.getElementById('lat');
            var lngEl = document.getElementById('lng');
            var accEl = document.getElementById('accuracyM');

            if (latEl) latEl.value = c.latitude;
            if (lngEl) lngEl.value = c.longitude;
            if (accEl) accEl.value = Math.round(c.accuracy);

            console.log('포트홀 위치:', c.latitude, c.longitude, '±', Math.round(c.accuracy), 'm');

            $('#locationUpdated').val('Y');  // 수정화면에서 위치를 다시 조회한 경우에만 서버로 위치 정보 전송

            $('#btn-get-location').hide(); // 현재 위치 가져오기 버튼 숨기기
            $('#location-result').show(); // 주소 보여주기

            ensureAddress();      // ✅ 주소 획득
            fillCaptureTime(pos); // ✅ 좌표 취득 시간

            // 날씨 호출
            requestWeatherSummary(c.latitude, c.longitude);

            // STA 조회
            console.log('STA조회 > siteCd:', siteCd, '/ lat:', pos.coords.latitude, '/ lng: ', pos.coords.longitude );
           // fetchStaAndRender(siteCd, 'ALL', pos.coords.latitude, pos.coords.longitude);
            //fetchStaAndRenderWithMatch(siteCd, 'ALL', pos.coords.latitude, pos.coords.longitude);
            fetchStaSmart(siteCd, 'ALL', pos.coords.latitude, pos.coords.longitude);

        },
        function (err) {
            if (err.code === 1) {
                hideLocationMessage();
                $('#locModal').modal('show');
            } else if (err.code === 2) {
                showLocationMessage('위치를 바로 확인하지 못했어요. 창가나 실외로 이동 후, 새로고침 해주세요. Wi-Fi를 켜면 더 정확해집니다.');
            } else if (err.code === 3) {
                showLocationMessage('시간이 오래 걸려 실패했어요. 주변이 잘 터지는 곳으로 이동 후 다시 시도해 주세요.');
            } else {
                showLocationMessage('위치 확인 중 알 수 없는 오류가 발생했어요. 잠시 후 다시 시도해 주세요.');
                console.error('Geo error:', err);
            }
        },
        { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
    );
}

function showLocationMessage(msg) {
    $('#errorMessage')
        .html('<p style="margin:0;">' + msg + '</p>')
        .show();
}

function hideLocationMessage() {
    $('#errorMessage').hide().html('');
}

// 좌표 → 주소 (백엔드 API)
async function fetchAddress(lat, lng) {
    const url =
        '/api/geo/rev?lat=' + encodeURIComponent(lat) +
        '&lng=' + encodeURIComponent(lng) +
        '&lang=ko';

    const res = await fetch(url, {headers: {'Accept':'application/json'}});
    if (!res.ok) throw new Error('reverse geocode failed');
    const data = await res.json();
    return data.address || '';   // 백엔드에서 {address:"..."} 로 내려준다고 가정
} // fetchAddress

// 주소 비어있으면 lat/lng로 채우기(타임아웃 1.5초)
async function ensureAddress() {

    var addrEl = document.getElementById('addr');      // hidden input
    var viewEl = document.getElementById('locAddr');   // 주소 표시 <p>
    var boxEl  = document.getElementById('locAddress'); // 부모 div

    // 1) 이미 addr가 있으면 그대로 표시
    if (addrEl && addrEl.value) {
        if (viewEl) {
            viewEl.textContent = addrEl.value;
            viewEl.style.display = 'block';
        }
        if (boxEl) boxEl.style.display = 'block';
        return addrEl.value;
    }

    // 2) 위경도 확인
    var latEl = document.getElementById('lat');
    var lngEl = document.getElementById('lng');
    var lat = latEl ? latEl.value : '';
    var lng = lngEl ? lngEl.value : '';
    if (!lat || !lng) return '';

    // 3) 주소 확인 중 → 부모부터 보여주기
    if (boxEl) boxEl.style.display = 'block';
    if (viewEl) {
        viewEl.textContent = '주소 확인 중...';
        viewEl.style.display = 'block';
    }

    var p = fetchAddress(lat, lng).then(function (txt) {
        var s = txt || '';
        if (addrEl) addrEl.value = s;

        // 4) 주소 획득 성공 시
        if (s) {
            if (viewEl) viewEl.textContent = s;
            if (boxEl) boxEl.style.display = 'block';
        }
        return s;
    }).catch(function () {
        // 실패 시에도 영역은 유지
        if (viewEl) viewEl.textContent = '주소를 확인하지 못했어요.';
        if (boxEl) boxEl.style.display = 'block';
        return '';
    });

    return Promise.race([
        p,
        new Promise(function (r) {
            setTimeout(function () { r(''); }, 1500);
        })
    ]);
}



// 좌표취득시간: ISO 문자열(capturedAt) + epoch ms(capturedTs) + 신선도(ms, coordAgeMs)
function fillCaptureTime(pos) {
    const t = (pos && typeof pos.timestamp === 'number') ? pos.timestamp : Date.now(); // epoch ms
    const iso = new Date(t).toISOString();    // 예: 2025-09-12T04:15:23.123Z
    const age = Math.max(0, Date.now() - t);  // 신선도(ms)

    const at   = document.getElementById('capturedAt');
    const ts   = document.getElementById('capturedTs');   // ← 추가
    const ageEl= document.getElementById('coordAgeMs');

    if (at)   at.value   = iso;
    if (ts)   ts.value   = String(t);        // epoch ms 저장
    if (ageEl)ageEl.value= String(age);
}

// hidden 값 갱신 헬퍼
function fillHiddenFromPos(pos){
    if (!pos || !pos.coords) return;
    const c = pos.coords;

    const latEl = document.getElementById('lat');
    const lngEl = document.getElementById('lng');
    const accEl = document.getElementById('accuracyM');

    if (latEl) latEl.value = Number(c.latitude).toFixed(6);   // DECIMAL(9,6) 맞춤
    if (lngEl) lngEl.value = Number(c.longitude).toFixed(6);  // DECIMAL(9,6) 맞춤
    if (accEl) accEl.value = String(Math.round(c.accuracy));  // SMALLINT/Integer 맞춤

    fillCaptureTime(pos); // capturedAt/capturedTs/coordAgeMs 채움
}


function isReliable(accuracyM, coordAgeMs){
    return accuracyM <= ACC_OK && coordAgeMs <= FRESH_MS;
}

function renderLocReliability(level, accuracyM, coordAgeMs) {
    var $alert = $('#locAlert');
    var html;

    if (level === 'bad') {
        html = '※ 위치 신뢰 : 낮음 (오차 ±' + (accuracyM ?? '?') + 'm, 측정 경과 ' + fmtMs(coordAgeMs) + '.)<br>터널/실내 가능성이 높습니다.';
        $alert.removeClass('d-none alert-success alert-warning').addClass('alert-danger');
    } else if (level === 'warn') {
        html = '※ 위치 신뢰 : 보통 (오차 ±' + (accuracyM ?? '?') + 'm, 측정 경과 ' + fmtMs(coordAgeMs) + '.)<br>필요 시 현장 확인으로 보완하세요.';
        $alert.removeClass('d-none alert-danger alert-warning').addClass('alert-success');
    } else {
        $alert.addClass('d-none').removeClass('alert-danger alert-success alert-warning');
        $('#locMessage').empty();
        return;
    }
    $('#locMessage').html(html);
}

function buildNearbyText(row) {
    const siteNm = row.site_name || '';
    const sectionNm = row.section_name || '';
    const nearMNum = row.near_m != null ? Math.round(Number(row.near_m)) : null;
    const nearPoint = row.near_point || ''; // 'START' | 'END'

    const pointText = nearPoint === 'START' ? '시작지점'
        : (nearPoint === 'END' ? '종료지점' : '');

    // sectionNm이 이미 괄호를 포함하면 괄호 중복 방지
    const cleanSection =
        sectionNm !== '' && sectionNm.indexOf('(') === 0 && sectionNm.lastIndexOf(')') === sectionNm.length - 1
            ? sectionNm.substring(1, sectionNm.length - 1)
            : sectionNm;

    let text = '';
    text += siteNm;
/*
    if (nearMNum != null) {
        if (pointText !== '') {
            text += ' <br> (' + pointText + '으로부터 ' + nearMNum.toLocaleString() + 'm)';
        } else {
            text += ' (' + nearMNum.toLocaleString() + 'm)';
        }
    }*/

    return text;
}

function loadNearbyHighways(lat, lng) {

    $.ajax({
        url: "/sos/nearby-sections?lat=" + encodeURIComponent(lat) + "&lng=" + encodeURIComponent(lng),
        type: "get",
        dataType: "json",
        success: function (res) {
            if (!res || !res.result) return;

            const list = res.list || [];
            const fallback = res.fallback || 'NEARBY'; // 백엔드에서 ALL / NEARBY 내려준다고 가정

            // fallback=ALL (근처 못찾아서 전체목록) 안내
            if (fallback === 'ALL') {
                $('#nearbyMessage').html('현재 위치 근처 고속도로를 특정할 수 없어, <br>전체 고속도로 목록을 보여드립니다. <br>고속도로를 선택해 주세요.');
                $('#errorMessage').html('');

                // 전체목록이면 자동확정 하지 않고 수동선택 유도
                $('#matchType').val('MANUAL');
                $('#matchedSectionId').val('');
                $('#matchDistanceM').val('');
                $('#siteCd').val('');
                $('#siteName').hide();

                // 전화버튼은 선택 후 세팅되도록 일단 숨김
                setCallButton('');
            } else {
                $('#errorMessage').hide();
            }

            // 1) 근처 1개면 -> 자동 확정 + 전화번호 즉시 매핑 (fallback=ALL이면 자동확정 X)
            if (fallback !== 'ALL' && list.length === 1) {
                const row = list[0];

                const siteCd = row.site_cd || '';
                const sectionId = row.section_id || '';
                const nearM = row.near_m != null ? Math.round(Number(row.near_m)) : '';
                const callNo = row.call_center_no || row.callCenterNo || '';

                const displayText = buildNearbyText(row);

                $('#siteName').html('<i class="bi bi-geo-alt-fill"></i> ' + displayText);
                $('#siteName').show();

                // hidden 세팅 (AUTO)
                $('#siteCd').val(siteCd);
                $('#matchType').val('AUTO');
                $('#matchedSectionId').val(sectionId);
                $('#matchDistanceM').val(nearM);

                // ✅ 전화번호 매핑
                setCallButton(callNo);

                return;
            }

            // 2) 여러 개면 -> 모달 버튼 생성
            let html = '';
            let siteCdList = '';

            for (let i = 0; i < list.length; i++) {
                const row = list[i];

                const siteCd = row.site_cd || '';
                const sectionId = row.section_id || '';
                const nearM = row.near_m != null ? Math.round(Number(row.near_m)) : '';
                const callNo = row.call_center_no || row.callCenterNo || '';

                const displayText = buildNearbyText(row);

                html += ''
                    + '<button type="button" '
                    + 'class="btn bg-danger text-white w-100 mb-2 btnPickSection" '
                    + 'data-site-cd="' + siteCd + '" '
                    + 'data-section-id="' + sectionId + '" '
                    + 'data-distance-m="' + nearM + '" '
                    + 'data-site-name="' + (row.site_name || '') + '" '
                    + 'data-section-name="' + (row.section_name || '') + '" '
                    + 'data-near-point="' + (row.near_point || '') + '" '
                    + 'data-call-no="' + callNo + '">'
                    + displayText
                    + '</button>';

                if (i === 0) siteCdList = siteCd;
                else siteCdList += "," + siteCd;
            }

            $('#siteCdList').val(siteCdList);

            // "알수없음" 버튼
            html += ''
                + '<button type="button" '
                + 'class="btn bg-secondary-subtle w-100 btnPickUnknown">'
                + '알수없음'
                + '</button>';

            $('#nearbyHighways').html(html);
            $('#nearbyHighwaysModal').modal("show");
        }
    });
}

/**
 * 전화신고 버튼에 전화번호를 세팅/초기화
 * - callNo 없으면 버튼 숨김
 * - 있으면 data-tel + 텍스트 업데이트
 */
function setCallButton(callNo) {

    callCenterNo = callNo;

    if (!callNo) {
        $('#btnCall').attr('data-tel', '').hide();
        return;
    }

    $('#btnCall')
        .attr('data-tel', callNo)
        .show();

    $('#txtCallMsg').text('전화신고하기 ' + callNo);
}



// 고속도로 선택 시, 화면 표시/hidden 세팅
/*
$(document).on('click', '.btnPickSection', function () {
    const siteCd = $(this).data('site-cd') || '';
    const sectionId = $(this).data('section-id') || '';
    const distanceM = $(this).data('distance-m');

    const siteName = $(this).data('site-name') || '';
    const sectionName = $(this).data('section-name') || '';
    const nearPoint = $(this).data('near-point') || '';
    const callNo = $(this).data('call-no');

    // 표시 문구 재구성(위 buildNearbyText 동일 로직)
    const nearMNum = distanceM != null && distanceM !== '' ? Math.round(Number(distanceM)) : null;
    const pointText = nearPoint === 'START' ? '시작지점' : (nearPoint === 'END' ? '종료지점' : '');
    const cleanSection =
        sectionName !== '' && sectionName.indexOf('(') === 0 && sectionName.lastIndexOf(')') === sectionName.length - 1
            ? sectionName.substring(1, sectionName.length - 1)
            : sectionName;

    let displayText = '';
    displayText += siteName;
    if (cleanSection !== '') displayText += '(' + cleanSection + ')';
    if (nearMNum != null) {
        if (pointText !== '') displayText += ' (' + pointText + '으로부터 ' + nearMNum.toLocaleString() + 'm)';
        else displayText += ' (' + nearMNum.toLocaleString() + 'm)';
    }

    $('#siteName').html('<i class="bi bi-geo-alt-fill"></i> ' + displayText);
    $('#siteName').show();

    $('#siteCd').val(siteCd);
    $('#matchType').val('PICK');
    $('#matchedSectionId').val(sectionId);
    $('#matchDistanceM').val(nearMNum != null ? nearMNum : '');

    setCallButton(callNo);

    $('#nearbyHighwaysModal').modal("hide");
});*/

// 알수없음 선택
$(document).on('click', '.btnPickUnknown', function () {
    $('#errorMessage').html('현재 정확한 고속도로를 알 수 없어,<br>인근 고속도로에 모두 온라인 사고 접수를 합니다.');
    $('#errorMessage').css('display', '');

    $('#matchType').val('MANUAL');
    $('#matchedSectionId').val('');
    $('#matchDistanceM').val('');
    $('#siteCd').val('');
    $('#siteName').hide();
    $('#btnCall').hide(); // 전화접수 버튼 숨기기
    $('.is-basic').hide();  // 기본
    $('.is-unknown').show(); // 알수없음 선택했을시..
    
    $('#nearbyHighwaysModal').modal("hide");
});

// 후보 버튼 클릭 -> hidden 업데이트
$(document).on('click', '.btnPickSection', function () {
    const siteCd = $(this).data('site-cd') || '';
    const sectionId = $(this).data('section-id') || '';
    const distM = $(this).data('distance-m');

    $('#siteCd').val(siteCd);
    $('#matchType').val('USER_SELECT');
    $('#matchedSectionId').val(sectionId);
    $('#matchDistanceM').val(distM != null && distM !== '' ? String(distM) : '');

    // 상단 표시도 바꿔주면 UX 좋음
    $('#siteName').html('<i class="bi bi-geo-alt-fill"></i> ' + $(this).text());
    $('#siteName').show();

    $('#nearbyHighwaysModal').modal('hide');
});

// 알수없음 클릭 -> 미확정으로 세팅 (여기서 “모든 고속도로 접수” 로직은 서버 정책에 따라 처리)
$(document).on('click', '.btnPickUnknown', function () {
    $('#matchType').val('MANUAL');
    $('#matchedSectionId').val('');
    $('#matchDistanceM').val('');

    // siteCd를 바꿀지/유지할지 정책 필요:
    // - 유지: 현재 페이지 siteCd 그대로
    // - 바꿈: 대표 siteCd로 세팅
    // 일단 유지하는 게 안전함

    $('#nearbyHighwaysModal').modal('hide');
});

function requestWeatherSummary(lat, lng) {
    $.ajax({
        url: '/api/weather/summary',
        type: 'GET',
        data: {
            lat: lat,
            lng: lng
        },
        success: function (res) {
            console.log('[날씨 응답]', res);

            var icon = (res && res.weatherIcon) ? res.weatherIcon : '-';
            var text = (res && res.weatherText) ? res.weatherText : '확인불가';
            var cd   = (res && res.weatherCd)   ? res.weatherCd   : '999';
            var temp = (res && res.temp != null) ? res.temp + '°' : '--°';
            var tempVal = (res && res.temp != null) ? String(res.temp) : '';

            $('#weatherIcon').text(icon);
            $('#weatherText').text(text);
            $('#weatherTemp').text(temp);

            var cdEl = document.getElementById('weatherCd');
            if (cdEl) cdEl.value = cd;

            var tempEl = document.getElementById('temp');
            if (tempEl) tempEl.value = tempVal;
        },
        error: function (err) {
            console.error('[날씨 조회 실패]', err);

            $('#weatherIcon').text('-');
            $('#weatherText').text('확인불가');
            $('#weatherTemp').text('--°');

            var cdEl = document.getElementById('weatherCd');
            if (cdEl) cdEl.value = '999';

            var tempEl = document.getElementById('temp');
            if (tempEl) tempEl.value = '';
        }
    });
}

/** STA 로딩 상태 표시(있으면) */
function setStaLoading(isLoading) {
    // 예: 로딩 스피너/문구가 있다면 여기서 처리
    // #staText가 있으면 임시로 로딩 문구 표시
    if (isLoading) {
        setTextIfExists('#staText', 'STA 계산중...');
    }
}

/** STA 실패 시 화면 초기화/표시 */
function renderStaFallback(text) {
    if (!text) text = 'STA 확인불가';

    setTextIfExists('#staText', text);

// 숨기거나 비우고
}
/**
 * STA 표시용 <p>를 locAddr 아래에 만들고/업데이트
 * - 성공: "STA 7" 표시
 * - 실패: "STA 확인불가" 표시(원하면 숨김 처리로 바꿔도 됨)
 */
function renderStaUnderAddress(text) {

    var addrP = document.getElementById('locAddr');
    if (!addrP) return;

    // locAddr 다음에 들어갈 p (없으면 생성)
    var staP = document.getElementById('locSta');
    if (!staP) {
        staP = document.createElement('p');
        staP.id = 'locSta';
        staP.style.margin = '4px 0 0 0';
        staP.style.fontSize = '13px';
        // 필요하면 색/스타일 더 주기
        // staP.style.color = '#666';

        // locAddr 바로 아래에 추가
        addrP.insertAdjacentElement('afterend', staP);
    }

    staP.textContent = text || '';
}
/**
 * STA 계산 호출 후 locAddr 아래에 표시 + hidden 값 세팅
 * - POST /api/sta/calc
 * - hidden: #staMeters, #staKmDecimal, #staText
 */
function fetchStaAndRender(siteCd, directionCd, lat, lng) {

    if (!siteCd) {
        renderStaUnderAddress('STA 확인불가');
        setStaHidden('', '', '');
        return;
    }
    if (!directionCd) directionCd = 'ALL';

    if (lat === null || lat === undefined || lng === null || lng === undefined) {
        renderStaUnderAddress('STA 확인불가');
        setStaHidden('', '', '');
        return;
    }

    // 로딩 표시
    renderStaUnderAddress('STA 계산중...');
    setStaHidden('', '', 'STA 계산중...');

    $.ajax({
        url: '/api/sta/calc',
        type: 'POST',
        contentType: 'application/json; charset=UTF-8',
        dataType: 'json',
        data: JSON.stringify({
            siteCd: siteCd,
            directionCd: directionCd,
            lat: lat,
            lng: lng
        }),
        success: function (res) {

            if (!res || res.ok !== true || !res.data) {
                renderStaUnderAddress('STA 확인불가');
                setStaHidden('', '', '');
                console.log('STA calc fail:', res && res.msg ? res.msg : '');
                return;
            }

            var d = res.data;

            // ✅ TOO_FAR여도 staText는 표시하고, 안내만 붙이기
            if (d.staStatus && String(d.staStatus) === 'TOO_FAR') {

                // 서버가 준 staText 우선
                var staText = d.staText || '';

                // 없으면 만들어주기(방어)
                if (!staText) {
                    if (d.staKmDecimal !== null && d.staKmDecimal !== undefined && d.staKmDecimal !== '') {
                        staText = 'STA ' + d.staKmDecimal;
                    } else if (d.staKm !== null && d.staKm !== undefined && d.staKm !== '') {
                        staText = 'STA ' + d.staKm;
                    } else {
                        staText = 'STA 확인불가';
                    }
                }

                // 화면에는 staText + 경고 문구(원하면 문구는 조절)
                // 예: "STA 9.6 (도로에서 멀어 참고용)"
                if (staText !== 'STA 확인불가') {
                    staText = staText;
                }

                // hidden도 저장하고 싶으면 세팅 (추천: 저장)
                var staMeters = (d.staMeters !== null && d.staMeters !== undefined) ? d.staMeters : '';
                var staKmDecimal = '';

                if (staMeters !== null && staMeters !== undefined && staMeters !== '') {
                    staKmDecimal = (Number(staMeters) / 1000).toFixed(3);
                }
                var formattedStaText = formatStaText(staMeters);

                // 화면 표시
                renderStaUnderAddress('STA ' + formattedStaText);
                setStaHidden(staMeters, staKmDecimal, formattedStaText);

                // ✅ 관리자 입력칸에도 반영
                $('#insStaTextView').val(formattedStaText);
                applyStaFromAdminInput();

                return;

            }
            // 서버가 staText 주면 그걸 우선 사용
            var staText = d.staText || '';

            // 표시용 텍스트 없으면 생성
            if (!staText) {
                if (d.staKmDecimal !== null && d.staKmDecimal !== undefined && d.staKmDecimal !== '') {
                    staText = 'STA ' + d.staKmDecimal;
                } else if (d.staKm !== null && d.staKm !== undefined && d.staKm !== '') {
                    // 혹시 서버가 예전 필드(staKm)로 내려주는 경우 대비
                    staText = 'STA ' + d.staKm;
                } else {
                    staText = 'STA 확인불가';
                }
            }

            // ✅ hidden 세팅 (draft 저장에 같이 넘어가게)
            var staMeters = (d.staMeters !== null && d.staMeters !== undefined) ? d.staMeters : '';
            var staKmDecimal = '';

            if (staMeters !== null && staMeters !== undefined && staMeters !== '') {
                staKmDecimal = (Number(staMeters) / 1000).toFixed(3);
            }
            var formattedStaText = formatStaText(staMeters);

            // 화면 표시
            renderStaUnderAddress('STA ' + formattedStaText);
            setStaHidden(staMeters, staKmDecimal, formattedStaText);

            $('#siteCd').val(d.siteCd);

        },
        error: function (xhr, status, err) {
            renderStaUnderAddress('STA 확인불가');
            setStaHidden('', '', '');
            console.log('STA ajax error:', status, err);
        }
    });
}

// hidden 값 세팅 헬퍼
function setStaHidden(staMeters, staKmDecimal, staText) {
    var el1 = document.getElementById('staMeters');
    var el2 = document.getElementById('staKmDecimal');
    var el3 = document.getElementById('staText');

    if (el1) el1.value = (staMeters !== null && staMeters !== undefined) ? String(staMeters) : '';
    if (el2) el2.value = (staKmDecimal !== null && staKmDecimal !== undefined) ? String(staKmDecimal) : '';
    if (el3) el3.value = (staText !== null && staText !== undefined) ? String(staText) : '';
}

function extractStaNumberText(staText) {
    // "STA 274.5" / "sta274.5" / "STA: 274.5" / "STA 274" 등 대응
    if (!staText) return '';
    var s = String(staText).trim();

    // 1) "STA" 접두어 제거
    s = s.replace(/^\s*STA\s*[:\-]?\s*/i, '');

    // 2) 남은 값에서 숫자(정수/소수)만 추출
    var m = s.match(/-?\d+(?:\.\d+)?/);
    return m ? m[0] : '';
}

function fetchStaAndRenderWithMatch(parentSiteCd, directionCd, lat, lng) {

    if (!parentSiteCd) {
        renderStaUnderAddress('STA 확인불가');
        setStaHidden('', '', '');
        return;
    }
    if (!directionCd) directionCd = 'ALL';

    renderStaUnderAddress('STA 계산중...');
    setStaHidden('', '', 'STA 계산중...');

    $.ajax({
        url: '/api/sta/match',
        type: 'POST',
        contentType: 'application/json; charset=UTF-8',
        dataType: 'json',
        data: JSON.stringify({
            siteCd: parentSiteCd,
            directionCd: directionCd,
            lat: lat,
            lng: lng
        }),
        success: function(res){
            if (!res || res.ok !== true || !res.data) {
                renderStaUnderAddress('STA 확인불가');
                setStaHidden('', '', '');
                return;
            }

            var d = res.data;
            var bestSiteCd = d.bestSiteCd || '';
            var needChoice = (d.needChoice === true);
            var candidates = d.candidates || [];
console.log('candidates:', candidates);
            if (!bestSiteCd) {
                renderStaUnderAddress('STA 확인불가');
                setStaHidden('', '', '');
                return;
            }

            if (!needChoice) {
                // ✅ 자동 선택 → 기존 calc 그대로 재사용
                fetchStaAndRender(bestSiteCd, directionCd, lat, lng);
                return;
            }

            // ✅ 팝업(중복 후보만 표기)
            // 여기서 candidates를 화면에 뿌리고, 사용자가 선택하면:
            // fetchStaAndRender(chosenSiteCd, directionCd, lat, lng);
            openStaRoadChoicePopup(candidates, function(chosenSiteCd){
                // ✅ 선택한 실제 노선으로 siteCd 확정
                $('#siteCd').val(chosenSiteCd);
                console.log('----------------------');
                // ✅ STA 계산
                fetchStaAndRender(chosenSiteCd, directionCd, lat, lng);
            });
        },
        error: function(){
            renderStaUnderAddress('STA 확인불가');
            setStaHidden('', '', '');
        }
    });
}

var _staRoadChoiceCallback = null;

function openStaRoadChoicePopup(candidates, callback) {

    _staRoadChoiceCallback = (typeof callback === 'function') ? callback : null;

    candidates = candidates || [];
    if (!candidates.length) {
        if (_staRoadChoiceCallback) _staRoadChoiceCallback('');
        return;
    }

    // 안내 문구
    var msg = '';
    msg += '현재 위치 기준으로 도로가 여러 개 매칭됩니다.<br>';
    msg += '가장 정확한 도로를 선택해 주세요.';
    $('#staRoadChoiceMsg').html(msg);

    // 버튼 렌더링
    var html = '';

    for (var i = 0; i < candidates.length; i++) {
        var c = candidates[i] || {};
        var siteCd = c.siteCd || '';
        var directionCd = c.directionCd || 'ALL';

        var siteName = c.siteName || '';
        var routeName = c.routeName || ''; // 서버에서 내려주면 표시됨(없으면 공백)

        var distM = (c.distM !== null && c.distM !== undefined && c.distM !== '') ? Math.round(Number(c.distM)) : '';

        var label = '';
        if (siteName) label += siteName;
        else label += siteCd;

        if (routeName) label += ' (' + routeName + ')';

        var sub = '';
        if (distM !== '') sub = '약 ' + distM + 'm';

        html += ''
            + '<button type="button" class="btn btn-danger w-100 mb-2 btnStaPickRoad" '
            + 'data-site-cd="' + siteCd + '" '
            + 'data-direction-cd="' + directionCd + '">'
            + '<div style="display:flex; justify-content:space-between; align-items:center;">'
            +   '<div style="text-align:left;">' + label + '</div>'
            +   '<div style="font-size:12px; opacity:0.9;">' + sub + '</div>'
            + '</div>'
            + '</button>';
    }

    $('#staRoadChoiceList').html(html);

    // 모달 오픈
    $('#staRoadChoiceModal').modal('show');
}

$(document)
    .off('hidden.bs.modal', '#staRoadChoiceModal')
    .on('hidden.bs.modal', '#staRoadChoiceModal', function () {
        if (!_staRoadChoiceCallback) return;

        renderStaUnderAddress('STA 확인불가');
        setStaHidden('', '', '');
        _staRoadChoiceCallback = null;
    });

$(document).on('click', '.btnStaPickRoad', function () {
    var siteCd = $(this).data('site-cd') || '';
    var directionCd = $(this).data('direction-cd') || 'ALL';

    $('#staRoadChoiceModal').modal('hide');

    if (_staRoadChoiceCallback) {
        // 콜백은 siteCd만 받도록 했으니(너희 기존 코드), 필요하면 directionCd도 넘길 수 있음
        _staRoadChoiceCallback(siteCd, directionCd);
    }

    _staRoadChoiceCallback = null;
});

function fetchStaSmart(siteCd, directionCd, lat, lng) {
    if (!siteCd) {
        renderStaUnderAddress('STA 확인불가');
        setStaHidden('', '', '');
        return;
    }
    if (!directionCd) directionCd = 'ALL';

    renderStaUnderAddress('STA 계산중...');
    setStaHidden('', '', 'STA 계산중...');

    // 1) 하위노선 여부 먼저 확인
    $.ajax({
        url: '/api/sta/has-sub',
        type: 'POST',
        contentType: 'application/json; charset=UTF-8',
        dataType: 'json',
        data: JSON.stringify({ siteCd: siteCd }),
        success: function (res) {
            var hasSub = (res && res.ok === true) ? (res.data === true) : false;

            if (!hasSub) {
                $('#adminSiteCd').val('');   // ← 하위노선 없으면 제거
            } else {
                $('#adminSiteCd').val(siteCd); // ← 있으면 유지
            }

            // 하위노선 없음 → 팝업 없이 바로 calc
            if (!hasSub) {
                fetchStaAndRender(siteCd, directionCd, lat, lng);
                return;
            }

            // 하위노선 있음 → match → 필요시 팝업
            fetchStaAndRenderWithMatch(siteCd, directionCd, lat, lng);
        },
        error: function () {
            // 안전장치: 실패하면 그냥 calc(팝업 없이)
            fetchStaAndRender(siteCd, directionCd, lat, lng);
        }
    });
}

function formatStaText(staMeters) {

    if (staMeters === null || staMeters === undefined || staMeters === '') {
        return '';
    }

    var meters = parseInt(staMeters, 10);

    var km = Math.floor(meters / 1000);
    var m = meters % 1000;

    return km + '+' + String(m).padStart(3, '0') + 'k';
}