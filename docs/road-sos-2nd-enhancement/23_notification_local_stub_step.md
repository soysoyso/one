# STEP 23. 알림톡 로컬 발송 스텁 연동

## 목적

로컬 테스트 환경에서 외부 SMS/알림톡 발송 프로시저를 호출하지 않고, 관리자 수신자 설정에 등록된 대상자를 기준으로 발송 예정 로그를 확인할 수 있게 한다.

## 변경 범위

- `application-local.properties`
  - `notification.send.local-stub=true` 추가
- `CommonService`
  - 로컬 스텁 모드일 때 외부 `SmsSendMapper.sendSms` 호출 중단
  - 접수 상태별 알림 유형 매핑
    - 접수/시작/보류: `POTHOLE_RECEIPT`
    - 완료: `POTHOLE_COMPLETE`
  - 설정된 수신자별 발송 예정 로그 출력
- `NotificationRecipientMapper`
  - 발송용 활성 수신자 조회 추가

## 검증 기준

- 로컬 프로필에서는 외부 SMS 프로시저를 호출하지 않아야 한다.
- 수신자 설정에 등록된 `use_yn = Y` 대상만 발송 후보가 되어야 한다.
- 수신자 현장 코드가 비어 있거나 접수 현장 코드와 일치할 때 발송 후보로 잡혀야 한다.

## 비고

- 실제 알림톡 발송 연동은 운영 환경 API/프로시저 기준이 필요하므로 보류한다.
- 로컬에서는 기능 고도화와 QA가 막히지 않도록 스텁 로그 방식으로 검증한다.
