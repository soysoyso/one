# STEP-18 상황일지 CRUD

## 구현 범위

- 브랜치: `feature/situation-log-crud`
- DB: `situation_log`
- 공통코드: `SITUATION_SHIFT` (`DAY`, `NIGHT`)
- 관리자 화면: `/admin/situation-logs`
- API
  - `GET /admin/situation-logs/data`
  - `GET /admin/situation-logs/{situationId}`
  - `POST /admin/situation-logs/save`
  - `POST /admin/situation-logs/delete`

## 반영 내용

- 상황일지 일자, 주/야간, 시간, 현장, 제목, 내용을 등록/수정/삭제할 수 있게 구성했다.
- 목록은 일자, 주/야간, 현장, 키워드로 조회한다.
- 삭제는 실제 삭제가 아니라 `use_yn = 'N'` 처리로 이력을 보존한다.
- 필수값 누락 또는 형식 오류는 HTTP 500 대신 `code=9999` 응답으로 처리한다.

## 검증 항목

- 관리자 화면 HTTP 200
- 필수값 누락 저장 방어
- 정상 등록, 목록 조회, 상세 조회, 수정, 삭제
- 삭제 후 기본 목록에서 제외

## 다음 단계

- Playwright 중간 QA
- 보고서 DOCX/HWPX 출력 단계는 마지막으로 이동
