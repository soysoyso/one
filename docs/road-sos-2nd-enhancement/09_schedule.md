# road-sos 2차 고도화 스케줄 관리

## 1. 현재 상태 요약

작성일: 2026-05-22

로컬 환경:

- Docker 기반 `road-sos` 로컬 실행 환경 구성 완료
- App: `http://localhost:8703`
- DB: local Docker MySQL
- 운영 서버/운영 DB 직접 연동 없음

현재까지 진행:

- 2차 고도화 요구사항 분석 문서화
- 보고서 양식 PDF 기준 템플릿 후보 6종 정리
- `PDF / DOCX / HWPX` 출력 확장 구조 초안 구현
- 포트홀 관리대장 `DOCX/HWPX` PoC 코드 추가
- Docker 컨테이너 빌드 성공 확인
- 2026-05-24 기준, 실제 문서 생성 완성 작업은 후순위로 조정

현재 중단 지점:

- `/admin/reports/export` 호출 시 `500 Internal Server Error` 발생
- 로그인 세션은 `loginType=admin` 포함 시 정상 생성됨
- 500 원인 로그 확인은 보류
- 문서 생성 기능은 후속 마지막 단계에서 DOCX와 HWPX를 함께 정리

다음 재개 키워드:

> 시작하자

재개 시 첫 작업:

> 문서 생성은 잠시 보류하고, 다음 기능 단계부터 진행

## 2. 일정 기준

첨부 요구사항 표 기준 일정:

| 일정 | 구분 | 기능 | 요구사항 |
|---|---|---|---|
| 2026-06-12 | admin / 접수 | 보고서 | Word 출력 가능 여부 검토 및 적용 |
| 2026-06-12 | admin / 접수 | 보고서 | 보고서 템플릿 6종 제작 및 적용 |
| 2026-06-17 | 공통 | 알림톡 | 알림톡 수신자 설정 |
| 2026-06-24 | 사용자 / 일상점검 | 일상점검 | 체크리스트 작성 |
| 2026-06-24 | admin / 일상점검 | 일상점검 | 체크리스트 항목 생성 |
| 2026-06-30 | admin / 상황일지 | 상황일지 | 작성 기능 및 보고서 출력 |
| 2026-07-06 | test / qa | QA | 부분 QA, 통합 QA, 테스트 요청 |

## 3. 작업 단계

### Phase 1. 보고서 출력 고도화

목표 일정: 2026-06-12

| 순서 | 작업 | 상태 |
|---|---|---|
| 1 | 기존 보고서/PDF 구조 분석 | 완료 |
| 2 | 보고서 템플릿 6종 후보 정리 | 완료 |
| 3 | `PDF/DOCX/HWPX` 출력 타입 구조 추가 | 완료 |
| 4 | 보고서 데이터 조회/API 계약 정리 | 진행 중 |
| 5 | 어드민 접수상세 보고서 추가정보 확장 | 완료 |
| 6 | 템플릿 선택 UI 초안 | 예정 |
| 7 | 실제 DOCX 생성 완성 | 후순위 |
| 8 | HWPX 생성 PoC 및 호환성 검증 | 마지막 단계 |
| 9 | 보고서 6종 문서 출력 확장 | 마지막 단계 |

### Phase 2. 알림톡 수신자 설정

목표 일정: 2026-06-17

| 순서 | 작업 | 상태 |
|---|---|---|
| 1 | 수신자 DB 설계 | 초안 완료 |
| 2 | 관리자 CRUD API | 예정 |
| 3 | 관리자 화면 | 예정 |
| 4 | 로컬 발송 스텁 | 예정 |
| 5 | 실제 발송 연동 검토 | 보류 |

### Phase 3. 일상점검

목표 일정: 2026-06-24

| 순서 | 작업 | 상태 |
|---|---|---|
| 1 | 체크리스트 DB 설계 | 초안 완료 |
| 2 | 관리자 체크리스트 항목 CRUD | 예정 |
| 3 | 사용자 일상점검 작성 화면 | 예정 |
| 4 | 작업 전/후 이미지 등록 | 예정 |
| 5 | 일상점검일지 출력 | 예정 |
| 6 | 일상점검 결과보고서 출력 | 예정 |

### Phase 4. 상황일지

목표 일정: 2026-06-30

| 순서 | 작업 | 상태 |
|---|---|---|
| 1 | 상황일지 DB 설계 | 초안 완료 |
| 2 | 상황일지 목록/등록/수정/삭제 API | 예정 |
| 3 | 관리자 화면 | 예정 |
| 4 | 주/야간 구분 처리 | 예정 |
| 5 | 상황일지 보고서 출력 | 예정 |

### Phase 5. QA

목표 일정: 2026-07-06

| 순서 | 작업 | 상태 |
|---|---|---|
| 1 | 보고서 부분 QA | 예정 |
| 2 | 알림톡 설정 QA | 예정 |
| 3 | 일상점검 QA | 예정 |
| 4 | 상황일지 QA | 예정 |
| 5 | 통합 QA | 예정 |
| 6 | 테스트 요청 자료 정리 | 예정 |

## 4. 다음 시작 체크리스트

사용자가 “시작하자”라고 하면 아래 순서로 진행한다.

1. 문서 생성 오류 확인은 보류한다.
2. 보고서 데이터/API 계약을 먼저 정리한다.
3. 다음 기능 단계인 알림톡 수신자 설정 또는 일상점검 설계/구현으로 이동한다.
4. DOCX/HWPX 실제 생성은 마지막 문서 출력 단계에서 함께 처리한다.
5. `09_schedule.md` 진행 상태를 계속 업데이트한다.

## 5. 현재 변경 파일

문서:

- `docs/road-sos-2nd-enhancement/00_framework_progress.md`
- `docs/road-sos-2nd-enhancement/01_service_definition.md`
- `docs/road-sos-2nd-enhancement/02_report_template_analysis.md`
- `docs/road-sos-2nd-enhancement/03_user_flows.md`
- `docs/road-sos-2nd-enhancement/04_db_design.md`
- `docs/road-sos-2nd-enhancement/05_api_design.md`
- `docs/road-sos-2nd-enhancement/06_policy_rules.md`
- `docs/road-sos-2nd-enhancement/07_admin_ui_plan.md`
- `docs/road-sos-2nd-enhancement/08_work_breakdown.md`
- `docs/road-sos-2nd-enhancement/09_schedule.md`
- `docs/road-sos-2nd-enhancement/10_github_pr_workflow.md`
- `docs/road-sos-2nd-enhancement/11_report_field_matrix.md`
- `docs/road-sos-2nd-enhancement/12_design_system.md`

코드:

- `src/main/java/com/yido/road/sos/admin/AdminReportExportController.java`
- `src/main/java/com/yido/road/sos/enums/ReportExportFormat.java`
- `src/main/java/com/yido/road/sos/enums/ReportTemplateCode.java`
- `src/main/java/com/yido/road/sos/service/ReportDocumentService.java`
- `src/main/java/com/yido/road/sos/model/Pothole.java`
- `src/main/java/com/yido/road/sos/model/work/EquipmentRow.java`
- `src/main/java/com/yido/road/sos/model/work/PersonnelRow.java`
- `src/main/java/com/yido/road/sos/model/work/MaterialRow.java`
- `src/main/resources/mapper.main/AdminPotholeMapper.xml`
- `src/main/webapp/WEB-INF/jsp/admin/common/imsManageModal.jsp`
- `src/main/webapp/WEB-INF/jsp/admin/ims/dashboard.jsp`
- `docker/mysql/init/01_local_schema.sql`
- `docker/mysql/migrations/20260524_report_extra_fields.sql`

## 6. 주의사항

- 현재 DOCX/HWPX PoC는 빌드 성공 상태이나, 다운로드 API는 500 오류 상태다.
- 500 오류 원인 확인은 후순위로 이동했다.
- HWPX는 완전한 한글 문서 호환 보장 단계가 아니라 마지막 PoC/확장 단계다.
- 기존 PDF 다운로드 기능은 유지한다.

## 7. 변경된 우선순위

문서 생성은 리소스가 크므로 다음처럼 분리한다.

1. 보고서에 필요한 데이터 구조와 API 계약은 먼저 정리한다.
2. 기존 PDF 기능은 유지한다.
3. DOCX/HWPX 실제 파일 생성 완성도 작업은 마지막 단계로 이동한다.
4. 특히 HWPX는 일정 리스크가 크므로 전체 기능 안정화 이후 별도 PoC로 검증한다.

## 8. GitHub PR식 관리

대상 저장소:

- `https://github.com/soysoyso/one`

각 step 완료 시 GitHub PR처럼 관리하는 것을 목표로 한다.

현재 Codex PowerShell 환경에서는 `git` 명령이 PATH에 잡혀 있지 않아 실제 push/PR 생성은 아직 진행할 수 없다.

관리 절차는 `10_github_pr_workflow.md`를 기준으로 한다.

## 9. 디자인 기준

2차 고도화의 공통 UI 기준은 `12_design_system.md`를 기준으로 한다.

새 화면은 기존 관리자/IMS 화면의 다음 특성을 유지한다.

- NotoSansKR 폰트
- 네이비 헤더 `#00263e`
- Bootstrap 기반 폼/버튼/테이블
- 관리자 화면은 업무형 테이블/모달/아코디언 중심
- 현장 화면은 모바일 카드형 중심
