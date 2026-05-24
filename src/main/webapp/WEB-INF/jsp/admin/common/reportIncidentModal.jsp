<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!-- html2pdf (jsPDF+html2canvas 포함 배포본) -->
<script src="https://cdn.jsdelivr.net/npm/html2pdf.js@0.10.1/dist/html2pdf.bundle.min.js"></script>

<!-- 사고 접수 상세 (보고서용) 모달 -->
<div class="modal fade" id="incident-report-modal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
<div class="modal-dialog">
<div class="modal-content">
    <div class="modal-header">
        <div>
            <h3 class="modal-title" id="incident-title"><b>고속도로 사고 접수 처리 결과 보고서</b></h3>
            <label class="form-label">담당자</label>: <span id="rptManager"></span>
        </div>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
    </div>
    <div class="modal-body">
        <form id="fileForm3" action="fileUpload" method="post" enctype="multipart/form-data">
            <div class="mb-3">
                <h5><b>접수 내용</b></h5>
                <div class="">
                    <table class="table">
                        <colgroup>
                            <col width="20%">
                            <col width="*">
                        </colgroup>
                        <tr>
                            <th><label class="form-label">접수번호</label></th>
                            <td><span id="rptReportNo"></span></td>
                        </tr>
                        <tr>
                            <th><label class="form-label">접수방법</label></th>
                            <td><span id="rptIntakeMethodNm"></span></td>
                        </tr>
                        <tr>
                            <th><label class="form-label">전화번호</label></th>
                            <td><span id="rptTel"></span></td>
                        </tr>
                        <tr>
                            <th><label class="form-label">접수일시</label></th>
                            <td><span id="rptReportDt"></span></td>
                        </tr>
                        <tr>
                            <th><label class="form-label">처리완료일시</label></th>
                            <td><span id="rptUpdDt"></span></td>
                        </tr>
                    </table>
                </div>
                <div class="mb-3">
                    <h5><b>사고 내용</b></h5>
                    <div class="">
                        <table class="table">
                            <colgroup>
                                <col width="20%">
                                <col width="*">
                            </colgroup>
                            <tr>
                                <th><label class="form-label">고속도로</label></th>
                                <td><span id="rptSiteName"></span></td>
                            </tr>
                            <tr>
                                <th><label class="form-label">사고 위치(주소)</label></th>
                                <td><span id="rptAddr"></span></td>
                            </tr>
                            <tr>
                                <th><label class="form-label">GPS 좌표</label></th>
                                <td><span id="rptGps"></span></td>
                            </tr>
                            <tr>
                                <th><label class="form-label">현장사진</label></th>
                                <td>
                                    <div class="rptImgUrl row">
                                    <img id="rptImgUrl" src="" class="rpt-img img-fluid col-6 mb-3"
                                      crossorigin="anonymous" referrerpolicy="no-referrer">
                                    </div>
                                </td>
                            </tr>

                            <tr>
                                <th><label class="form-label">접수내용</label></th>
                                <td><span id="rptContent"></span></td>
                            </tr>
                        </table>
                    </div>
                    <button type="button" class="btn btn-primary" id="btnPdf">PDF로 저장</button>
                </div>
            </div>
        </form>
    </div>

</div>
</div>
</div>

<script>

html2pdf().set({
  html2canvas: { scale: 2, useCORS: true, imageTimeout: 0 }
});

document.getElementById('btnPdf').addEventListener('click', async function () {
  const $content = $('#rptContent');
  const originalText = $content.text();

  // 줄바꿈 보존용: 안전 이스케이프 + \n → <br>
  const safeHtml = $('<div>').text(originalText).html()
                   .replace(/(?:\r\n|\r|\n)/g, '<br>');
  $content.html(safeHtml);

  const modal = document.getElementById('incident-report-modal');
  const target = modal.querySelector('.modal-content');

  // 1) 모달 내부 모든 이미지 로드 대기
  const imgs = target.querySelectorAll('img');
  try {
    await Promise.all([...imgs].map(img => {
      // CORS 속성 보강(동적으로 만들어질 수도 있으니)
      img.setAttribute('crossorigin', 'anonymous');
      img.setAttribute('referrerpolicy', 'no-referrer');

      if (img.complete && img.naturalWidth > 0) return Promise.resolve();
      return new Promise((res, rej) => {
        img.onload = () => res();
        img.onerror = (e) => rej(e);
      });
    }));
  } catch(e) {
    console.warn('이미지 로드 실패:', e); // CORS 문제일 확률↑
  }

  // 2) PDF 옵션
  const opt = {
    margin: [10,10,10,10],
    filename: 'incident-report_' + ($('#rptReportNo').text() || 'report') + '.pdf',
    image: { type: 'jpeg', quality: 0.95 },
    html2canvas: { scale: 2, useCORS: true, imageTimeout: 0 },
    jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
  };

  // 3) 생성
  html2pdf().set(opt).from(target).save()
    .then(() => $content.text(originalText))
    .catch(() => $content.text(originalText));
});

</script>
<style>
/* 모달 안에서만 인쇄 시 숨김 */
@media print {
  #incident-report-modal .btn-close,
  #incident-report-modal #btnPdf { display: none !important; }

  #incident-report-modal.modal { position: static !important; }
}

/* 표 가독성: 모달 내부 테이블에만 적용 */
#incident-report-modal .table th { white-space: nowrap; width: 20%; }
#incident-report-modal .table td { word-break: break-word; }

/* 페이지 나눔: 모달 내부에서만 */
#incident-report-modal .html2pdf__page-break { page-break-before: always; }

#incident-report-modal #rptContent {
  white-space: pre-line;   /* \n을 줄바꿈으로 렌더링, 연속 공백은 1칸으로 */
  word-break: break-word;  /* 긴 단어 줄바꿈 */
}
</style>