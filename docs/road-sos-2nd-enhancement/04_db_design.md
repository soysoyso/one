# DB 설계 초안

## 1. 설계 원칙

- 운영 DB 직접 변경 없이 로컬 MySQL 스키마에서 먼저 검증한다.
- 기존 `pothole` 계열 테이블은 최대한 유지하고, 신규 기능은 별도 테이블로 확장한다.
- 보고서 출력은 특정 화면/JSP에 종속되지 않도록 템플릿 코드와 출력 타입을 분리한다.
- HWPX는 즉시 구현하지 않더라도 출력 타입과 이력 구조에서 확장 가능하게 둔다.

## 2. 신규/확장 테이블 후보

| 테이블 | 목적 | 우선순위 |
|---|---|---|
| report_template | 보고서 템플릿 정의 | 높음 |
| report_export_history | 보고서 출력 이력 | 중간 |
| daily_checklist | 일상점검 체크리스트 묶음 | 높음 |
| daily_checklist_item | 일상점검 체크리스트 항목 | 높음 |
| daily_check_log | 사용자 일상점검 작성 마스터 | 높음 |
| daily_check_log_item | 사용자 일상점검 항목별 결과 | 높음 |
| daily_check_photo | 일상점검 작업 전/후 사진 | 높음 |
| situation_log | 상황일지 | 높음 |
| notification_recipient | 알림톡 수신자 설정 | 중간 |
| road_location_master | 도로별 발생장소 마스터 | 중간 |
| work_type_master | 공종/작업유형 마스터 | 중간 |

## 3. report_template

### 목적

보고서 템플릿 6종과 향후 상황일지/HWPX 출력을 관리한다.

### 컬럼 정의

| 컬럼명 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| template_id | BIGINT | Y | AUTO_INCREMENT | PK |
| template_code | VARCHAR(50) | Y |  | 템플릿 코드 |
| template_name | VARCHAR(100) | Y |  | 템플릿명 |
| report_domain | VARCHAR(30) | Y |  | POTHOLE, DAILY_CHECK, SITUATION 등 |
| supported_formats | VARCHAR(100) | Y | pdf,docx | 지원 형식 |
| use_yn | CHAR(1) | Y | Y | 사용 여부 |
| sort_ord | INT | N | 0 | 정렬 |
| reg_datetime | DATETIME | Y | NOW() | 등록일시 |
| update_datetime | DATETIME | N |  | 수정일시 |

### 상태값

- `POTHOLE_LEDGER`
- `POTHOLE_SUMMARY`
- `MAINT_WORK_DAILY`
- `DAILY_CHECK_LOG`
- `DAILY_CHECK_RESULT`
- `LANDSCAPE_DAILY`
- `SITUATION_LOG`

## 4. daily_checklist

### 목적

관리자가 만드는 일상점검 체크리스트 묶음.

| 컬럼명 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| checklist_id | BIGINT | Y | AUTO_INCREMENT | PK |
| checklist_name | VARCHAR(100) | Y |  | 체크리스트명 |
| site_cd | VARCHAR(20) | N |  | 특정 현장용이면 값 저장 |
| common_yn | CHAR(1) | Y | Y | 공통 여부 |
| use_yn | CHAR(1) | Y | Y | 사용 여부 |
| sort_ord | INT | N | 0 | 정렬 |
| reg_user_id | VARCHAR(50) | N |  | 등록자 |
| reg_datetime | DATETIME | Y | NOW() | 등록일시 |
| update_datetime | DATETIME | N |  | 수정일시 |

## 5. daily_checklist_item

### 목적

일상점검 항목 단위 관리.

| 컬럼명 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| item_id | BIGINT | Y | AUTO_INCREMENT | PK |
| checklist_id | BIGINT | Y |  | 체크리스트 FK |
| item_name | VARCHAR(200) | Y |  | 항목명 |
| input_type | VARCHAR(20) | Y | CHECK | CHECK, TEXT, SELECT 등 |
| required_yn | CHAR(1) | Y | N | 필수 여부 |
| use_yn | CHAR(1) | Y | Y | 사용 여부 |
| sort_ord | INT | N | 0 | 정렬 |

## 6. daily_check_log

### 목적

사용자가 작성한 일상점검 마스터 데이터.

| 컬럼명 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| check_id | BIGINT | Y | AUTO_INCREMENT | PK |
| check_no | VARCHAR(30) | Y |  | 점검번호 |
| check_date | DATE | Y |  | 점검일자 |
| site_cd | VARCHAR(20) | Y |  | 현장 |
| checklist_id | BIGINT | Y |  | 사용한 체크리스트 |
| status_cd | VARCHAR(20) | Y | DRAFT | DRAFT, DONE |
| before_note | TEXT | N |  | 점검내용 |
| after_note | TEXT | N |  | 조치내용 |
| reg_user_id | VARCHAR(50) | N |  | 작성자 |
| reg_datetime | DATETIME | Y | NOW() | 등록일시 |
| update_datetime | DATETIME | N |  | 수정일시 |

## 7. situation_log

### 목적

일자별, 주/야간별 상황 정보를 기록한다.

| 컬럼명 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| situation_id | BIGINT | Y | AUTO_INCREMENT | PK |
| log_date | DATE | Y |  | 일자 |
| shift_cd | VARCHAR(10) | Y | DAY | DAY, NIGHT |
| event_time | TIME | Y |  | 상황 시간 |
| title | VARCHAR(200) | N |  | 제목 |
| content | TEXT | Y |  | 내용 |
| site_cd | VARCHAR(20) | N |  | 현장 |
| use_yn | CHAR(1) | Y | Y | 사용 여부 |
| reg_user_id | VARCHAR(50) | N |  | 등록자 |
| reg_datetime | DATETIME | Y | NOW() | 등록일시 |
| update_datetime | DATETIME | N |  | 수정일시 |

## 8. notification_recipient

### 목적

알림톡 발송 대상 설정.

| 컬럼명 | 타입 | 필수 | 기본값 | 설명 |
|---|---|---|---|---|
| recipient_id | BIGINT | Y | AUTO_INCREMENT | PK |
| notify_type | VARCHAR(30) | Y |  | 알림 유형 |
| user_id | VARCHAR(50) | N |  | 관리자 사용자 ID |
| user_name | VARCHAR(100) | Y |  | 수신자명 |
| phone_no | VARCHAR(50) | Y |  | 전화번호 |
| site_cd | VARCHAR(20) | N |  | 현장 제한 |
| use_yn | CHAR(1) | Y | Y | 사용 여부 |
| sort_ord | INT | N | 0 | 정렬 |

