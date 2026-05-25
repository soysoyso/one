# road-sos 2차 고도화 진행 현황

## 2026-05-24 진행 업데이트
- 기준 소스를 `soysoyso/one` 저장소 `main` 브랜치에 업로드했다.
- `feature/notification-recipient-settings` 브랜치에서 알림톡 수신자 설정 기능을 구현했다.
- 추가 범위: `notification_recipient` 로컬 DB 테이블, `NOTI_TYPE` 공통코드, 관리자 화면 `/admin/notification/recipients`, 목록/상세/저장/삭제 API.
- 검증: `docker compose build road-sos` 성공, 로컬 DB 마이그레이션 적용 성공, 관리자 화면 HTTP 200 확인, 수신자 저장/조회 API 동작 확인.

## 2026-05-24 추가 진행 업데이트
- `feature/daily-checklist-admin` 브랜치에서 일상점검 체크리스트 관리자 기능을 구현했다.
- 추가 범위: `daily_checklist`, `daily_checklist_item`, `CHECK_INPUT_TYPE`, 관리자 화면 `/admin/daily-checklists/setting`, 목록/상세/저장/삭제 API.
- 저장 API에서 잘못된 요청이 `500`으로 터지지 않도록 숫자 변환과 항목 누락 방어를 추가했다.
- 검증: 빌드 성공, 마이그레이션 적용 성공, 화면 HTTP 200 확인, 잘못된 저장 요청 `code=9999` 확인, 정상 저장/조회 확인.

## 2026-05-24 사용자 일상점검 작성 업데이트
- `feature/daily-check-user-form` 브랜치에서 현장 사용자 일상점검 작성 화면을 구현했다.
- 추가 범위: `daily_check_log`, `daily_check_log_item`, 로컬 테스트 계정 `field / field123`, 화면 `/manage/daily-checks/form`, 체크리스트 상세/저장 API.
- 검증: 사용자 화면 HTTP 200, 필수 항목 누락 방어, 정상 저장 및 DB 저장 확인, 테스트 데이터 정리 완료.

## 2026-05-25 관리자 일상점검 조회 업데이트
- `feature/daily-check-admin-list` 브랜치에서 관리자 일상점검 목록/상세 조회 기능을 구현했다.
- 추가 범위: 관리자 화면 `/admin/daily-checks`, 목록/상세 API, 관리자 상단 `일상점검` 메뉴.
- 검증: 빌드 성공, 앱 재기동, 테스트 작성 데이터 생성, 목록/상세 조회 확인, 테스트 데이터 정리 완료.

## 2026-05-25 일상점검 사진 업로드 업데이트
- `feature/daily-check-photo-upload` 브랜치에서 일상점검 점검 전/후 사진 업로드 기능을 구현했다.
- 추가 범위: `daily_check_photo`, 사용자 사진 포함 저장 API, 사용자/관리자 사진 조회 API, 관리자 상세 사진 미리보기.
- 검증: 빌드 성공, 마이그레이션 적용, 앱 재기동, 테스트 이미지 업로드 저장, 관리자 이미지 조회 HTTP 200 확인.

## 2026-05-25 보고서 출력 UI 업데이트
- `feature/report-template-export-ui` 브랜치에서 현장관리 보고서 다운로드 UI를 확장한다.
- 추가 범위: 접수 선택 기반 포트홀 관리대장 `PDF/DOCX/HWPX` 선택 다운로드, 통합 export API 연결, Playwright QA 보강.
- 검증: Docker 빌드 및 중간 QA에서 확인한다.

## 2026-05-25 알림톡 로컬 스텁 업데이트
- `feature/notification-local-send-stub` 브랜치에서 알림톡 수신자 설정과 로컬 발송 흐름을 연결한다.
- 추가 범위: 로컬 프로필 외부 SMS 호출 차단, 수신자 설정 기반 발송 후보 조회, 발송 예정 로그 출력.
- 검증: Docker 빌드 및 중간 QA에서 확인한다.

## 기준

- 기준 프레임워크: `C:\Users\YIDO\Desktop\YIDO250728\codex\ai-service-framework`
- 요구사항 원천:
  - `2차고도화.pdf`
  - `보고서양식\*.pdf`
  - 첨부 요구사항 표
- 로컬 실행 기준:
  - App: `http://localhost:8703`
  - DB: local Docker MySQL
  - 운영 DB/운영 서버 직접 연동 없음

## STEP 적용 계획

| STEP | 상태 | 산출물 | 비고 |
|---|---|---|---|
| STEP-01 환경 구축 | 완료 | Docker local app/db | 로컬 테스트 환경 구성 완료 |
| STEP-02 서비스 정의 | 초안 완료 | `01_service_definition.md` | 2차 고도화 범위 정의 |
| STEP-03 사용자 흐름 | 초안 완료 | `03_user_flows.md` | 사용자/관리자/보고서 흐름 |
| STEP-04 정책 설계 | 초안 완료 | `06_policy_rules.md` | 권한, 상태, 보고서 정책 |
| STEP-05 DB 설계 | 초안 완료 | `04_db_design.md` | 신규/확장 테이블 |
| STEP-06 API 설계 | 초안 완료 | `05_api_design.md` | 화면-백엔드 계약 |
| STEP-07 사용자 화면 | 초안 완료 | `07_admin_ui_plan.md` | 일상점검/상황일지 사용자 화면 |
| STEP-08 관리자 화면 | 초안 완료 | `07_admin_ui_plan.md` | 설정/보고서/관리 화면 |
| STEP-09 작업 분리 | 초안 완료 | `08_work_breakdown.md` | 기능별 구현 순서 |
| STEP-10 테스트 | 예정 | `09_test_plan.md` | 부분 QA/통합 QA |
| STEP-11 리뷰 | 예정 | 구현 후 | 변경 범위 리뷰 |
| STEP-12 배포 | 보류 | 로컬 기준 | 사용자가 로컬 테스트 중심 요청 |
| STEP-13 운영 | 보류 | 로컬 기준 | 운영 반영 전 별도 검토 |

## 현재 결정

- DB는 로컬 Docker MySQL을 기준으로 확장한다.
- 실제 운영 DB 덤프 없이도 고도화 가능하도록 최소 샘플 데이터와 신규 스키마를 병행 관리한다.
- 보고서 출력은 PDF 유지, DOCX 신규 추가, HWPX 확장 가능 구조로 설계한다.
- 보고서 양식은 `보고서양식` 폴더 PDF를 기준으로 필드 구조를 역정의한다.

## 현재 중단 지점

- 오늘 목표는 내일 출근 후 로컬에서 각 기능과 UIUX를 바로 확인할 수 있는 상태로 만드는 것이다.
- Docker 빌드와 Playwright 중간 QA는 통과했다.
- 현재 확인 기준 문서는 `24_tomorrow_function_uiux_checklist.md`로 관리한다.
- 세부 일정은 `09_schedule.md`, 공통 디자인 기준은 `12_design_system.md`를 기준으로 관리한다.
