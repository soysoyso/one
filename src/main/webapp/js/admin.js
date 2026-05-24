// KST 기준이면 브라우저 시간대가 KST인지 전제. 서버 기준이 필요하면 API로 확인하세요.
function getYmd() {
  const d = new Date();
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  return `${d.getFullYear()}-${mm}-${dd}`;
}

function renderPagination(pageInfo) {
    if (!pageInfo) return '';

    const currentPage = pageInfo.currentPage;
    const totalPages = pageInfo.totalPages;
    const pageBlock = 5;  // 한 번에 보여줄 페이지 수
    let startPage = Math.floor((currentPage - 1) / pageBlock) * pageBlock + 1;
    let endPage = Math.min(startPage + pageBlock - 1, totalPages);

    let html = '<div class="d-flex justify-content-center flex-wrap gap-2 mt-3 mb-5 py-3">';

    // 이전 페이지 블록
    if (startPage > 1) {
        html += '<button onclick="doSearch(' + (startPage - 1) + ')">«</button>';
    }

    // 페이지 번호
    for (let p = startPage; p <= endPage; p++) {
        if (p === currentPage) {
            html += '<button style="font-weight:bold;" disabled>' + p + '</button>';
        } else {
            html += '<button onclick="doSearch(' + p + ')">' + p + '</button>';
        }
    }

    // 다음 페이지 블록
    if (endPage < totalPages) {
        html += '<button onclick="doSearch(' + (endPage + 1) + ')">»</button>';
    }

    html += '</div>';
    return html;
}

function enterkey() {
    if (window.event.keyCode === 13) { // Enter 키
        doSearch(1);
    }
}
function escapeHtml(str) {
    str = (str == null) ? '' : String(str);
    return str
        .replaceAll("&", "&amp;")
        .replaceAll("<", "&lt;")
        .replaceAll(">", "&gt;")
        .replaceAll('"', "&quot;")
        .replaceAll("'", "&#039;");
}


function clearNewBags(){
    // blob url 해제
    for (var i = 0; i < _newBefore.length; i++){
        if (_newBefore[i] && _newBefore[i].url) { try { URL.revokeObjectURL(_newBefore[i].url); } catch(e){} }
    }
    for (var j = 0; j < _newAfter.length; j++){
        if (_newAfter[j] && _newAfter[j].url) { try { URL.revokeObjectURL(_newAfter[j].url); } catch(e){} }
    }
    _newBefore = [];
    _newAfter  = [];
    _uidSeq    = 1;
}


function toNumOrNull(v) {
    v = (v == null ? '' : String(v)).trim();
    if (!v) return null;
    // 숫자 문자열만 허용(콤마 제거)
    v = v.replace(/,/g, '');
    return isFinite(Number(v)) ? Number(v) : null;
}

function toStr(v) {
    return (v == null ? '' : String(v)).trim();
}
function pad2(n) {
    n = String(n);
    return (n.length === 1) ? ('0' + n) : n;
}

function nowYmdHi() {
    var d = new Date();
    var y = String(d.getFullYear());
    var m = pad2(d.getMonth() + 1);
    var da = pad2(d.getDate());
    var hh = pad2(d.getHours());
    var mi = pad2(d.getMinutes());
    return y + '-' + m + '-' + da + ' ' + hh + ':' + mi;
}

function pad2(v){ return String(v).padStart(2, '0'); }

function nowHms(){
    var d = new Date();
    return pad2(d.getHours()) + ':' + pad2(d.getMinutes()) + ':' + pad2(d.getSeconds());
}

// ✅ yyyy-MM-dd / yyyy-MM-dd HH:mm / yyyy-MM-dd HH:mm:ss → yyyy-MM-dd HH:mm:ss
function normalizeYmdHms(v){
    v = (v || '').trim();
    if (!v) return '';

    if (v.length === 10) return v + ' ' + nowHms(); // date만 있으면 현재시간 붙임
    if (v.length === 16) return v + ':00';          // 초 없으면 :00
    if (v.length >= 19)  return v.substring(0, 19); // 초까지 자르기
    return v;
}
function _normalizeStaInput(raw, allowTrailingDot) {
    var s = String(raw || '').trim();
    if (!s) return '';

    s = s.replace(/^STA\s*/i, '');
    s = s.replace(/,/g, '.');
    s = s.replace(/[^0-9.]/g, '');

    var firstDot = s.indexOf('.');
    if (firstDot >= 0) {
        s = s.substring(0, firstDot + 1) + s.substring(firstDot + 1).replace(/\./g, '');
    }

    if (s.indexOf('.') >= 0) {
        var parts = s.split('.');
        var intPart = parts[0] || '';
        var decPart = parts[1] || '';

        // 입력 중이면 "9." 허용
        if (allowTrailingDot && raw && String(raw).trim().endsWith('.') && decPart === '') {
            return intPart + '.';
        }

        decPart = decPart.substring(0, 1);
        s = intPart + (decPart ? ('.' + decPart) : '');
    }

    return s;
}
function _roundTo1Decimal(n){
    return Math.round(n * 10) / 10;
}

function parseJsonSafe(str) {
    if (!str || str === '') return null;

    try {
        return JSON.parse(str);
    } catch (e) {
        return null;
    }
}


function nvl(v) {
    return (v === null || v === undefined) ? '' : String(v);
}