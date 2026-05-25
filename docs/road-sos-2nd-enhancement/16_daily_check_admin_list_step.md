# 관리자 일상점검 목록/상세 Step 기록

작성일: 2026-05-25

## 범위
- 관리자가 현장 사용자가 작성한 일상점검 기록을 조회한다.
- 기간, 현장, 키워드 기준으로 목록을 검색한다.
- 상세 패널에서 기본정보와 항목별 입력값을 확인한다.
- 보고서 출력과 사진 관리는 후속 Step으로 분리한다.

## 구현
- 화면:
  - `/admin/daily-checks`
- API:
  - `GET /admin/daily-checks/data`
  - `GET /admin/daily-checks/{checkId}`
- 메뉴:
  - 관리자 상단 `일상점검` 메뉴 추가

## 검증
- `docker compose build road-sos` 성공
- Docker 앱 재기동 완료
- 테스트 체크리스트 생성 후 `field / field123` 사용자 작성 저장 성공
- 관리자 목록 화면 HTTP 200 확인
- 목록 API에서 작성 기록 조회 확인
- 상세 API에서 항목별 입력값 조회 확인
- 테스트 데이터 삭제 후 DB 정리 완료

## 다음 Step
- 일상점검 사진 업로드
- 또는 상황일지 기본 CRUD
