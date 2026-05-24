# API 설계 초안

## 1. 공통 응답

기존 프로젝트의 응답 구조와 JSP/Ajax 사용 방식을 우선 유지한다. 신규 API는 가능하면 JSON으로 통일한다.

```json
{
  "success": true,
  "data": {},
  "message": ""
}
```

## 2. 보고서 API

보고서 출력 API는 문서 파일을 생성하는 마지막 단계에서 완성한다. 단, 그 전에 어드민 접수상세에서 보고서에 필요한 원천 데이터를 입력/수정할 수 있어야 한다.

### 선행 조건: 어드민 접수상세 데이터 확장

보고서 양식 6종을 생성하려면 기존 접수상세 데이터만으로 부족한 필드가 있다. 따라서 `/admin/ims/detail`, `/admin/ims/save` 또는 기존 현장관리 저장 API에 다음 데이터 그룹을 반영해야 한다.

| 데이터 그룹 | 필요 필드 | 사용 보고서 |
|---|---|---|
| 문서 정보 | 문서번호, 접수번호, 접수년도, 작업일자, 보고월 | 전체 |
| 위치 정보 | 행정구역, 도로이정, 방향, STA, 상세위치, 차선 | 포트홀 관리대장, 유지보수 일지 |
| 분류 정보 | 접수유형, 공종, 작업유형, 발생장소, 포장형식 | 전체 |
| 발생 정보 | 발생일자, 발생시간, 기상, 발생수량, 면적, 깊이 | 포트홀 관리대장 |
| 조치 정보 | 조치일자, 조치시간, 조치내용, 작업상태 | 포트홀 관리대장, 결과보고서 |
| 투입 정보 | 투입인력, 투입장비, 투입자재, 사용량, 단위, 잔량, 금액 | 유지보수/보수작업일지 |
| 작업량 정보 | 실작업량, 환산작업량계, 작업량계상, 비고 | 보수작업일지 |
| 사진 정보 | 작업 전 대표사진, 작업 후 대표사진, 사진대지 설명 | 포트홀/일상점검/조경 |
| 결재 정보 | 담당, 반장, 팀장, 공구장, 소장 | 보고서 양식별 |

현재 `pothole`, `pothole_work_scope`, `pothole_work_material`, `pothole_work_personnel`, `pothole_work_equipment`, `pothole_photo`에 일부 데이터가 이미 있으므로, 신규 테이블을 만들기 전에 기존 필드와 부족 필드를 먼저 매핑한다.

권장 순서:

1. 보고서 6종별 필드 매트릭스 작성
2. 기존 DB 컬럼 매핑
3. 부족 필드 목록 도출
4. 어드민 접수상세 화면에 입력 영역 추가
5. 저장 API 확장
6. 보고서 데이터 조회 API 확정
7. 마지막 단계에서 DOCX/HWPX 생성 연결

### GET `/admin/report-templates`

보고서 템플릿 목록 조회.

#### Query

| 이름 | 설명 |
|---|---|
| domain | POTHOLE, DAILY_CHECK, SITUATION |
| format | pdf, docx, hwpx |

#### Response

```json
{
  "success": true,
  "data": [
    {
      "templateCode": "POTHOLE_LEDGER",
      "templateName": "도로파손 관리대장",
      "supportedFormats": ["pdf", "docx"]
    }
  ]
}
```

### GET `/admin/reports/{reportNo}/export`

단건 보고서 다운로드.

#### Query

| 이름 | 필수 | 설명 |
|---|---|---|
| template | Y | 템플릿 코드 |
| format | Y | pdf, docx, hwpx |
| inline | N | 브라우저 미리보기 여부 |

### POST `/admin/reports/export`

복합 보고서 다운로드.

#### Request

```json
{
  "reportNos": ["I2605220001", "I2605220002"],
  "template": "POTHOLE_SUMMARY",
  "format": "docx"
}
```

## 3. 일상점검 API

### GET `/admin/daily-checklists`

관리자 체크리스트 목록 조회.

### POST `/admin/daily-checklists`

체크리스트 생성.

```json
{
  "checklistName": "도로관리팀 일상점검",
  "siteCd": "LOCAL_SITE",
  "commonYn": "Y",
  "items": [
    {
      "itemName": "노면 상태 점검",
      "inputType": "CHECK",
      "requiredYn": "Y",
      "sortOrd": 1
    }
  ]
}
```

### PUT `/admin/daily-checklists/{checklistId}`

체크리스트 수정.

### DELETE `/admin/daily-checklists/{checklistId}`

체크리스트 미사용 처리.

### GET `/daily-checks/form`

사용자 일상점검 작성 화면용 체크리스트 조회.

### POST `/daily-checks`

사용자 일상점검 저장.

### PUT `/daily-checks/{checkId}`

사용자 일상점검 수정/완료 처리.

### GET `/daily-checks/{checkId}/export`

일상점검 보고서 출력.

## 4. 상황일지 API

### GET `/admin/situation-logs`

상황일지 목록 조회.

#### Query

| 이름 | 설명 |
|---|---|
| startDate | 조회 시작일 |
| endDate | 조회 종료일 |
| shiftCd | DAY, NIGHT |
| siteCd | 현장 |

### POST `/admin/situation-logs`

상황일지 등록.

```json
{
  "logDate": "2026-06-30",
  "shiftCd": "DAY",
  "eventTime": "09:30",
  "title": "강우 대응",
  "content": "현장 순찰 및 배수 상태 확인",
  "siteCd": "LOCAL_SITE"
}
```

### PUT `/admin/situation-logs/{situationId}`

상황일지 수정.

### DELETE `/admin/situation-logs/{situationId}`

상황일지 삭제 또는 미사용 처리.

### GET `/admin/situation-logs/export`

상황일지 보고서 출력.

## 5. 알림톡 수신자 API

### GET `/admin/notification-recipients`

수신자 목록 조회.

### POST `/admin/notification-recipients`

수신자 등록.

### PUT `/admin/notification-recipients/{recipientId}`

수신자 수정.

### DELETE `/admin/notification-recipients/{recipientId}`

수신자 미사용 처리.

## 6. 권한 원칙

| API 그룹 | 권한 |
|---|---|
| `/admin/report-templates` | 관리자 |
| `/admin/reports/**` | 관리자 |
| `/admin/daily-checklists/**` | 관리자 |
| `/daily-checks/**` | 현장 사용자 또는 관리자 |
| `/admin/situation-logs/**` | 관리자 또는 지정 권한 |
| `/admin/notification-recipients/**` | 관리자 |
