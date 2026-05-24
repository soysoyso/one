# 알림톡 수신자 설정 Step 기록

작성일: 2026-05-24

## 범위
- 관리자 설정 영역에 알림톡 수신자 설정 화면을 추가한다.
- 외부 알림톡 발송 API 연동은 이번 Step 범위에서 제외한다.
- 로컬 DB에서 알림 유형별 수신자 목록을 등록, 조회, 수정, 미사용 처리할 수 있게 한다.

## 구현
- DB: `notification_recipient`
- 공통코드: `NOTI_TYPE`
- 화면: `/admin/notification/recipients`
- API:
  - `GET /admin/notification/recipients/data`
  - `GET /admin/notification/recipients/{recipientId}`
  - `POST /admin/notification/recipients/save`
  - `POST /admin/notification/recipients/delete`

## 검증
- `docker compose build road-sos` 성공
- 로컬 MySQL 마이그레이션 적용 성공
- 관리자 화면 HTTP 200 확인
- 수신자 저장/조회 API 동작 확인

## 다음 Step
- 일상점검 체크리스트 관리자 기능
