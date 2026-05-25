# 정책 추적성 테스트 매트릭스

이 문서는 `ai-service-framework`의 `qa.skill`, `reviewer.skill` 기준에 맞춰 정책 ID와 테스트 케이스, 구현 위치, 검증 상태를 연결한다.

## 1. 보고서 정책

| 정책_ID | 테스트 케이스 | 검증 내용 | 구현/검증 위치 | 상태 |
|---|---|---|---|---|
| REPORT-001 | TC-REPORT-001 | 기존 PDF 다운로드는 포트홀 관리대장에서 유지 | `AdminReportExportController`, `dashboard.jsp` | 통과 |
| REPORT-002 | TC-REPORT-002 | 보고서 출력 시 `template`, `format` 전달 | `dashboard.jsp`, `qa/road_sos_mid_qa.js` | 통과 |
| REPORT-003 | TC-REPORT-003 | 포트홀 관리대장 외 PDF 요청은 400 반환 | `AdminReportExportController`, QA `non ledger pdf rejected` | 통과 |
| REPORT-004 | TC-REPORT-004 | DOCX 응답이 정상 ZIP 패키지로 생성 | `ReportDocumentService`, QA `docx package` | 통과 |
| REPORT-005 | TC-REPORT-005 | HWPX 응답이 ZIP 패키지로 생성 | `ReportDocumentService`, QA `hwpx package` | 부분 통과 |
| REPORT-006 | TC-REPORT-006 | 선택 접수건 기반 복합 출력 | `getLedgerPdfData`, `/admin/reports/export` | 통과 |

## 2. 일상점검 정책

| 정책_ID | 테스트 케이스 | 검증 내용 | 구현/검증 위치 | 상태 |
|---|---|---|---|---|
| DAILY-001 | TC-DAILY-001 | 사용 중 체크리스트 노출 | `/manage/daily-checks/form` | 통과 |
| DAILY-002 | TC-DAILY-002 | 필수 항목 누락 방어 | `DailyCheckService`, 수동/부분 QA | 통과 |
| DAILY-003 | TC-DAILY-003 | 관리자 수정 이력 | 정책 후보, 미구현 | 후속 |
| DAILY-004 | TC-DAILY-004 | 점검 전/후 사진 저장 및 관리자 조회 | `daily_check_photo`, `/admin/daily-checks` | 통과 |

## 3. 상황일지 정책

| 정책_ID | 테스트 케이스 | 검증 내용 | 구현/검증 위치 | 상태 |
|---|---|---|---|---|
| SITUATION-001 | TC-SITUATION-001 | 일자/주야간/내용 필수값 검증 | QA `situation required validation` | 통과 |
| SITUATION-002 | TC-SITUATION-002 | 상황정보 목록 정렬 | `SituationLogMapper` | 통과 |
| SITUATION-003 | TC-SITUATION-003 | 삭제 시 `use_yn = 'N'` 처리 | QA `situation delete` | 통과 |

## 4. 알림톡 정책

| 정책_ID | 테스트 케이스 | 검증 내용 | 구현/검증 위치 | 상태 |
|---|---|---|---|---|
| NOTIFY-001 | TC-NOTIFY-001 | 로컬 환경 실제 발송 차단 | `notification.send.local-stub=true`, `CommonService` | 통과 |
| NOTIFY-002 | TC-NOTIFY-002 | 목록 전화번호 마스킹 표시 | `notificationRecipients.jsp`, QA `notification phone masked` | 통과 |
| NOTIFY-003 | TC-NOTIFY-003 | 알림 유형별 수신자 분리 | `notification_recipient.notification_type` | 통과 |

## 5. 권한 정책

| 정책_ID | 테스트 케이스 | 검증 내용 | 구현/검증 위치 | 상태 |
|---|---|---|---|---|
| AUTH-001 | TC-AUTH-001 | 관리자 설정 기능 관리자 접근 | Spring Security, 관리자 로그인 QA | 통과 |
| AUTH-002 | TC-AUTH-002 | 현장 사용자 일상점검 작성 | 현장 계정 `field / field123` QA | 통과 |
| AUTH-003 | TC-AUTH-003 | 보고서 출력 조회 권한 | 현재 관리자 세션 기준 | 부분 통과 |

## 6. 남은 QA 후보

- 관리자 외 계정으로 관리자 URL 접근 차단 확인
- 현장 사용자 타 현장 데이터 접근 차단 확인
- 알림톡 전화번호 마스킹/암호화 정책 결정
- HWPX 한컴 오피스 실호환성 수동 검증
- DOCX 원본 양식 레이아웃 수동 검증
