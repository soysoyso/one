# road-sos 2차 고도화 진행 현황

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

- 2026-05-22 기준 `PDF/DOCX/HWPX` export 구조와 포트홀 관리대장 PoC 코드를 추가했다.
- Docker 빌드는 성공했다.
- `/admin/reports/export` 호출 시 500 오류가 발생한다.
- 다음 재개 시 첫 작업은 `docker logs --tail 160 road-sos`로 오류 원인을 확인하는 것이다.
- 세부 일정은 `09_schedule.md`를 기준으로 관리한다.
- road-sos 공통 디자인 기준은 `12_design_system.md`를 기준으로 관리한다.
