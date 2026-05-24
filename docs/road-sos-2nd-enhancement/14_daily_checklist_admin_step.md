# 일상점검 체크리스트 관리자 Step 기록

작성일: 2026-05-24

## 범위
- 관리자 설정 영역에 일상점검 체크리스트 설정 화면을 추가한다.
- 체크리스트 묶음과 점검 항목을 함께 등록, 조회, 수정, 미사용 처리할 수 있게 한다.
- 현장 사용자 작성 화면과 보고서 출력은 다음 Step 이후로 분리한다.

## 구현
- DB:
  - `daily_checklist`
  - `daily_checklist_item`
- 공통코드:
  - `CHECK_INPUT_TYPE`
- 화면:
  - `/admin/daily-checklists/setting`
- API:
  - `GET /admin/daily-checklists/data`
  - `GET /admin/daily-checklists/{checklistId}`
  - `POST /admin/daily-checklists/save`
  - `POST /admin/daily-checklists/delete`

## 500 오류 방어
- 원인:
  - 테스트 요청에서 배열/반복 파라미터가 브라우저 폼 전송 방식과 다르게 들어왔다.
  - 서버가 숫자 필드 변환 실패나 항목 누락을 명시적으로 방어하지 못하면 예외가 발생해 `500 Internal Server Error`가 될 수 있었다.
- 조치:
  - 숫자 변환 실패 시 기본값 또는 null로 처리하도록 방어했다.
  - 점검 항목이 없는 저장 요청은 `500` 대신 `code=9999` JSON 메시지로 응답하도록 했다.

## 검증
- `docker compose build road-sos` 성공
- 로컬 MySQL 마이그레이션 적용 성공
- 관리자 화면 HTTP 200 확인
- 잘못된 저장 요청: `200 + code=9999` 확인
- 정상 저장/조회 API 동작 확인
- 테스트 데이터 삭제 후 DB 정리 완료

## 다음 Step
- 사용자 일상점검 작성 화면
