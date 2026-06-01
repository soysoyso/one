# STEP-20 보고서 문서 출력

## 구현 범위

- 포트홀 관리대장 DOCX/HWPX 출력
- 일상점검일지 DOCX/HWPX 출력
- 상황일지 DOCX/HWPX 출력
- 보고서 템플릿 목록 API 확장

## API

- `GET /admin/reports/templates`
- `POST /admin/reports/export`
  - `reportNos`
  - `template=POTHOLE_LEDGER`
  - `format=pdf|docx|hwpx`
- `GET /admin/daily-checks/export`
  - `checkIds`
  - `format=docx|hwpx`
- `GET /admin/situation-logs/export`
  - `startDate`
  - `endDate`
  - `shiftCd`
  - `siteCd`
  - `keyword`
  - `format=docx|hwpx`

## 반영 내용

- `ReportDocumentService`의 한글 깨짐 문자열을 정리하고 문서 생성 로직을 확장했다.
- 템플릿 코드를 2차 고도화 후보 양식 기준으로 확장했다.
- 포트홀 관리대장은 로컬 스키마 기준 조회 SQL을 별도로 추가해 문서 출력 API가 실제 동작하도록 했다.
- 일상점검과 상황일지는 기존 저장 데이터를 기반으로 문서를 생성한다.
- 상황일지 화면에는 DOCX/HWPX 출력 버튼을 추가했다.

## 검증 결과

| 항목 | 결과 |
|---|---|
| `docker compose build road-sos` | 성공 |
| `/admin/reports/templates` | 9종 조회 |
| 포트홀 관리대장 DOCX | 다운로드 성공 |
| 포트홀 관리대장 HWPX | 다운로드 성공 |
| 일상점검일지 DOCX | 다운로드 성공 |
| 일상점검일지 HWPX | 다운로드 성공 |
| 상황일지 DOCX | 다운로드 성공 |
| 상황일지 HWPX | 다운로드 성공 |

모든 문서 파일은 ZIP 기반 포맷 서명 `PK`로 생성되는 것을 확인했다.

## 제한 사항

- HWPX는 확장 가능성을 확인하기 위한 단순 패키지 구조다. 실제 한컴 서식의 정밀 렌더링은 후속 단계에서 템플릿 기반으로 보강하는 것이 안전하다.
- 현재 DOCX는 원본 PDF 양식을 완전 복제한 형태가 아니라, 업무 데이터가 들어가는 실사용 가능한 기본 문서 형태다.
- 사진대지의 이미지 삽입은 파일 저장소 연계 정리가 필요하므로 후속 고도화 대상으로 남긴다.
