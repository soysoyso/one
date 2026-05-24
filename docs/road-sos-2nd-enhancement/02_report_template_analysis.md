# 보고서 양식 분석 및 출력 전략

## 1. 참고 양식

| 파일 | 해석한 양식 유형 |
|---|---|
| `도로파손(포트홀) 관리대장_2025년_작성중 - 최신.pdf` | 포트홀/도로파손 관리대장 |
| `3-2. 각 사업소별 보고서 자동생성에 필요하신 유형별 보고서 양식.pdf` | 포트홀 집계표, 포트홀 관리대장 |
| `2025년 1월 유지보수 일지.pdf` | 보수작업일지/유지보수 일지 |
| `2025년 일상점검일지(1월).pdf` | 일상점검일지, 일상점검 결과보고서 |
| `2025년 10월 01일 조경 작업일보.pdf` | 조경 작업일보, 사진대지 |
| `3-1. 각 사업소별 보고서 자동생성에 필요하신 유형별 보고서 양식.pdf` | 유지관리 결과보고서, 사진대지 |
| `2차고도화.pdf` | 2차 고도화 요구 흐름 및 신규 메뉴 |

## 2. 템플릿 6종 후보

요구사항 표에는 "보고서 템플릿 6종 제작 및 적용"으로 표현되어 있으나, 양식 PDF 기준으로는 다음 6종이 우선 후보이다.

| 코드 후보 | 템플릿명 | 용도 |
|---|---|---|
| POTHOLE_LEDGER | 도로파손/포트홀 관리대장 | 접수별 상세 보고 |
| POTHOLE_SUMMARY | 포트홀 집계표 | 기간별 집계 보고 |
| MAINT_WORK_DAILY | 보수작업일지 | 유지보수 작업 기록 |
| DAILY_CHECK_LOG | 일상점검일지 | 점검 기록 |
| DAILY_CHECK_RESULT | 일상점검 결과보고서 | 조치 결과 보고 |
| LANDSCAPE_DAILY | 조경 작업일보 | 조경 작업 및 사진대지 |

추가로 상황일지는 2차 고도화에서 신규 요구이므로 별도 템플릿으로 확장한다.

| 코드 후보 | 템플릿명 | 처리 |
|---|---|---|
| SITUATION_LOG | 상황일지 | 신규 메뉴 개발 시 7번째 템플릿 후보 |

## 3. 공통 필드

| 필드 그룹 | 주요 필드 |
|---|---|
| 문서 정보 | 문서번호, 접수번호, 접수년도, 보고월, 작성일자 |
| 위치 정보 | 현장, 행정구역, 도로이정, 방향, STA, 상세 위치 |
| 발생 정보 | 발생일자, 발생시간, 기상, 발생수량, 포장형식, 발생장소 |
| 작업 정보 | 조치일자, 조치시간, 작업내용, 작업량, 공종 |
| 자원 정보 | 투입인원, 투입장비, 투입자재, 사용량, 단위, 잔량, 금액 |
| 사진 정보 | 작업 전 대표사진, 작업 후 대표사진, 사진대지 |
| 결재 정보 | 담당, 반장, 팀장, 공구장, 소장 |

## 4. 현재 소스와의 매핑

현재 소스에는 보고서 생성 기반이 이미 일부 있다.

- PDF 출력: `PdfService`, `ImsReportPdfService`
- PDF 다운로드 엔드포인트: `/pdf/report/download`
- IMS 보고서 JSP: `/WEB-INF/jsp/admin/ims/report-pdf.jsp`, `/WEB-INF/jsp/admin/ims/report-ledger-pdf.jsp`
- 포트홀 데이터: `pothole`, `pothole_photo`, `pothole_work_scope`, `pothole_work_material`, `pothole_work_personnel`, `pothole_work_equipment`
- 관리대장용 조회: `AdminPotholeMapper.selectLedgerRows`

## 5. DOCX 출력 전략

현재 `build.gradle`에 Apache POI 의존성이 이미 있다.

- `org.apache.poi:poi-ooxml:4.0.0`
- `org.apache.poi:poi:4.0.0`

따라서 DOCX는 다음 방식이 현실적이다.

1. 보고서 데이터를 공통 DTO/Map으로 구성한다.
2. `ReportTemplateCode`로 템플릿을 선택한다.
3. `ReportExportService`가 출력 타입을 분기한다.
4. PDF는 기존 JSP/HTML 기반을 유지한다.
5. DOCX는 Apache POI `XWPFDocument` 기반으로 우선 구현한다.

초기에는 완벽한 원본 양식 복제보다, 업무에 필요한 표/사진/결재란이 유지되는 "실사용 가능한 Word 보고서"를 우선 목표로 한다.

## 6. HWPX 확장 전략

HWPX는 한글 문서의 XML/ZIP 기반 포맷이므로 DOCX보다 구현 리스크가 높다. 이번 단계에서는 완전 구현보다 다음 구조를 먼저 확보한다.

- 출력 타입에 `HWPX` enum을 미리 포함한다.
- 컨트롤러 URL은 `format=pdf|docx|hwpx` 구조로 설계한다.
- `HwpxReportGenerator` 인터페이스/스텁을 둘 수 있다.
- 실제 HWPX 생성은 별도 라이브러리 검토 또는 문서 변환 서버 검토 후 진행한다.

권장 순서는 `PDF 유지 -> DOCX 적용 -> HWPX PoC -> HWPX 정식 적용`이다.

## 7. 보고서 API 설계 방향

예상 URL 구조:

- 단건 출력: `/admin/reports/{reportNo}/export?template=POTHOLE_LEDGER&format=docx`
- 단건 미리보기: `/admin/reports/{reportNo}/preview?template=POTHOLE_LEDGER`
- 복합 출력: `/admin/reports/export?reportNos=...&template=POTHOLE_SUMMARY&format=pdf`
- 템플릿 목록: `/admin/report-templates`

기존 `/pdf/report/download`는 호환성을 위해 유지하고, 신규 구조를 병행 추가하는 방식이 안전하다.

