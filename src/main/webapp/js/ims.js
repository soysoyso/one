function formatNumber(n) {
    n = (n == null) ? 0 : Number(n);
    return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function getToday() {
    const d = new Date();
    const yyyy = d.getFullYear();
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const dd = String(d.getDate()).padStart(2, '0');
    return yyyy + '-' + mm + '-' + dd;
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