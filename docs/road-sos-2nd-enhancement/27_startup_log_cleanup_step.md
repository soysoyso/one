# STEP 27. 로컬 시작 로그 오류 정리

## 목적

로컬 프로필 실행 시 앱 시작 로그에 표시되던 `FileNotFoundException`을 제거한다.

## 원인

`Utils.getPropertiesByType`가 `develop`, `production` 프로필만 처리하고 있었다.

로컬 Docker 환경은 `local` 프로필을 사용하므로 properties 파일 경로가 빈 문자열로 남았고, 앱 시작 시 빈 경로를 `FileInputStream`으로 열려고 하면서 예외 로그가 출력됐다.

## 변경 범위

- `Utils.getPropertiesByType`
  - `local` 프로필에서 `application-local.properties`를 읽도록 추가
  - classpath resource를 `FileInputStream` 경로 대신 `InputStream`으로 읽도록 변경
  - properties 조회 실패 시 전체 스택트레이스 대신 경고 로그만 남기도록 정리

## 검증

- `docker compose build road-sos` 성공
- `docker compose up -d road-sos` 성공
- `/admin/login` HTTP 200 확인
- `docker logs --tail 120 road-sos`에서 기존 `FileNotFoundException` 미표시 확인
- `node qa/road_sos_mid_qa.js` 통과
