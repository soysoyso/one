# 보고서 필드 매트릭스 및 어드민 접수상세 확장 기준

## 1. 목적

보고서 DOCX/HWPX/PDF 생성을 마지막 단계로 미루더라도, 보고서에 들어갈 원천 데이터는 먼저 입력/수정 가능해야 한다. 이 문서는 보고서 양식 6종에 필요한 데이터와 현재 road-sos 소스의 기존 데이터 구조를 매핑한다.

## 2. 현재 소스 기준 이미 존재하는 데이터

| 데이터 | 현재 위치 | 비고 |
|---|---|---|
| 접수번호 | `pothole.report_no` | 어드민 상세 `insReportNo` |
| 문서번호 | `pothole.doc_no` | 어드민 상세 `insDocNo` |
| 현장 | `pothole.site_cd`, `site_info.site_name` | 어드민 상세 `insSiteCd` |
| 작업유형/접수유형 | `pothole.receipt_gb_cd` | 공통코드 `006` |
| 작업상태 | `pothole.status_cd` | 공통코드 `005` |
| 접수자/작업자 | `receiver_id`, `manager_id` | 관리자 사용자 |
| 접수일시 | `pothole.report_date` | 보고서 접수일/작업일 기준 |
| 작업시작/종료 | `work_start_at`, `work_end_at` | 결과/조치일 기준 |
| 날씨/기온 | `weather_cd`, `temp`, `work_weather_cd`, `work_temp` | 발생/조치 시점 |
| GPS/주소 | `lat`, `lng`, `addr` | 위치정보 |
| 방향/STA | `direction_cd`, `sta_text`, `sta_meters`, `sta_km_decimal` | 도로이정 |
| 상세위치 | `detail_info`, `sta_ref_name` | 수기 위치정보 |
| 포장형식 | `pavement_type_cds` | 공통코드 `008` |
| 발생장소 | `occur_place_cds` | 공통코드 `009` |
| 접수내용 | `delivery_note` | 현장/접수 내용 |
| 작업내용 | `process_note` | 조치/작업 내용 |
| 작업 범위 | `pothole_work_scope` | 가로, 세로, 면적, 깊이, 폭 |
| 투입 장비 | `pothole_work_equipment` | 장비명, 보유량, 사용량 |
| 투입 인력 | `pothole_work_personnel` | 성명, 부서 |
| 투입 자재 | `pothole_work_material` | 자재명, 규격, 단위, 사용량 |
| 작업 전/후 사진 | `pothole_photo` | BEFORE/AFTER, 대표사진 |

## 3. 보고서 6종별 필드 매핑

| 템플릿 | 필요한 주요 필드 | 현재 충족 | 부족/확장 필요 |
|---|---|---|---|
| 도로파손/포트홀 관리대장 | 접수번호, 행정구역, 도로이정, 포장형식, 발생장소, 발생일시, 기상, 발생수량, 면적, 깊이, 조치일시, 투입인원, 투입장비, 투입자재, 전/후 사진 | 대부분 충족 | 행정구역 정제, 차선, 결재자, 사진 설명 |
| 포트홀 집계표 | 기간, 방향, 위치, 작업면적, 복구일자, 개소 수, 비고 | 일부 충족 | 개소 수, 비고, 집계 기준 |
| 보수작업일지 | 작업일자, 작업감독, 작업반, 작업공종, 위치, 작업내용, 실작업량, 환산작업량계, 자재 사용량, 잔량, 금액, 현장동원, 인건비, 사용장비, 비고 | 일부 충족 | 작업감독, 작업반, 실작업량/환산량, 잔량, 금액, 인건비, 비고 |
| 일상점검일지 | 점검일자, 점검부서, NO, 위치, 점검내용, 작업 전 사진 | 신규 필요 | 일상점검 테이블 필요 |
| 일상점검 결과보고서 | 점검일자, 조치부서, NO, 위치, 점검내용/조치내용, 작업 후 사진 | 신규 필요 | 일상점검 결과/조치 테이블 필요 |
| 조경 작업일보 | 작업일자, 작업감독, 작업반, 금일 작업, 명일 계획, 인원 출력 현황, 자재 사용 현황, 사진대지 | 일부 가능 | 조경 전용 공종/계획/누계/사진 설명 |

## 4. 어드민 접수상세 확장 우선순위

### 1차: 기존 포트홀/유지보수 보고서 대응

기존 `imsManageModal.jsp`와 `/admin/ims/save`를 확장한다.

| 영역 | 필드 | 처리 |
|---|---|---|
| 위치 상세 | 차선, 상세 위치 유형, 위치 보조명 | 신규 컬럼 또는 JSON 검토 |
| 보고서 비고 | 보고서 비고 | 신규 컬럼 권장 |
| 작업량 | 실작업량, 환산작업량계, 작업량계상 | `pothole_work_scope` 확장 또는 별도 테이블 |
| 자재 | 잔량, 금액 | `pothole_work_material` 확장 |
| 인력 | 인건비 | `pothole_work_personnel` 확장 |
| 장비 | 비고 | `pothole_work_equipment` 확장 |
| 사진대지 | 사진별 위치/내용 설명 | `pothole_photo` 확장 |
| 결재 | 담당/반장/팀장/공구장/소장 | 템플릿별 기본값 또는 설정 테이블 |

## 6. 2026-05-24 1차 반영

어드민 접수상세 모달에 `보고서 추가정보` 아코디언을 추가했다.

추가 입력:

- 차선/위치 보조정보: `laneInfo`
- 보고서 비고: `reportRemark`
- 실작업량: `workQty`
- 환산작업량계: `convertWorkQty`
- 작업량계상: `accountWorkQty`

작업정보 확장:

- 투입 장비 비고: `EquipmentRow.remark`
- 투입 인력 인건비: `PersonnelRow.laborCost`
- 투입 자재 잔량/금액: `MaterialRow.remainQty`, `MaterialRow.amount`

검증:

- Docker build 성공
- 로컬 DB 마이그레이션 적용
- `/admin/ims/dashboard` HTML에서 신규 입력 영역 렌더링 확인

### 2차: 일상점검 대응

일상점검은 기존 `pothole`에 억지로 넣지 않고 별도 테이블을 둔다.

- `daily_checklist`
- `daily_checklist_item`
- `daily_check_log`
- `daily_check_log_item`
- `daily_check_photo`

### 3차: 상황일지 대응

상황일지는 별도 메뉴/테이블로 둔다.

- `situation_log`
- 상황일지 보고서 출력용 조회 API

## 5. 어드민 접수상세 화면 반영 방식

현재 상세 모달은 아코디언 구조다.

기존:

- 기본정보
- 위치정보
- 작업정보
- 사진

권장 추가:

- 보고서 추가정보
- 작업량/비용
- 사진대지 설명
- 결재/출력 설정

화면 원칙:

- 기존 필수 접수 저장 흐름은 유지한다.
- 보고서 필드는 선택 입력으로 시작한다.
- 보고서 출력 시 누락 필드를 알려준다.
- 동일 데이터를 두 번 입력하지 않도록 기존 필드를 최대한 재사용한다.
