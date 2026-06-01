# 일상점검 사진 업로드 Step 기록

작성일: 2026-05-25

## 범위
- 현장 사용자가 일상점검 작성 시 점검 전/후 사진을 함께 업로드한다.
- 관리자가 일상점검 상세에서 등록된 사진을 확인한다.
- 사진은 로컬 테스트 환경 기준으로 `Globals.File.UploadPath` 하위에 저장한다.

## 구현
- DB:
  - `daily_check_photo`
- 사용자 API:
  - `POST /manage/daily-checks/save-with-photos`
  - `GET /manage/daily-checks/photos/{photoId}`
- 관리자 API:
  - `GET /admin/daily-checks/photos/{photoId}`
- 화면:
  - 사용자 일상점검 작성 화면에 점검 전/후 사진 입력 추가
  - 관리자 일상점검 상세에 사진 미리보기 추가

## 권한 이슈 및 조치
- 관리자 상세 화면에서 `/manage/...` 사진 URL을 사용하면 보안 설정상 `ATH300`만 접근 가능해 관리자 화면에서 이미지가 보이지 않을 수 있었다.
- 관리자 전용 사진 조회 URL `/admin/daily-checks/photos/{photoId}`를 추가하고 관리자 화면은 이 URL을 사용하도록 변경했다.

## 검증
- `docker compose build road-sos` 성공
- 로컬 MySQL 마이그레이션 적용 성공
- Docker 앱 재기동 완료
- 테스트 이미지 업로드 저장 성공
- `daily_check_photo` 저장 확인
- 관리자 사진 조회 URL HTTP 200 및 `image/jpeg` 응답 확인
- 테스트 DB 데이터 정리 완료

## 다음 Step
- 상황일지 기본 CRUD
- 또는 일상점검 사진/목록 QA 보강
