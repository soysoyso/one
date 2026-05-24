# GitHub PR식 관리 절차

## 1. 대상 저장소

- GitHub: `https://github.com/soysoyso/one`

## 2. 목표

각 step이 끝날 때마다 변경사항을 GitHub에 올리고, PR 단위로 최신화한다.

권장 방식:

- 기능 단위 브랜치 생성
- 로컬 검증
- 커밋
- GitHub push
- Pull Request 생성 또는 갱신

## 3. 현재 확인 사항

2026-05-24 현재 Codex PowerShell 환경에서는 `git` 명령이 PATH에 잡혀 있지 않다.

GitHub 플러그인으로 `soysoyso/one` 저장소 접근 권한은 확인했다.

- 권한: push/admin 가능
- 상태: 빈 저장소
- `initialized=false`

따라서 현재 상태에서는 바로 PR을 만들 수 없다. PR 방식으로 관리하려면 먼저 기준 소스가 `main` 브랜치에 올라가야 한다.

따라서 실제 업로드/PR 갱신을 자동으로 하려면 다음 중 하나가 필요하다.

1. 로컬 PC에 Git 설치 및 PATH 등록
2. GitHub CLI(`gh`) 설치 및 로그인
3. Codex GitHub 플러그인/커넥터 사용
4. 사용자가 직접 GitHub Desktop 또는 웹에서 업로드

## 3-1. 빈 저장소 초기화 선택지

### 선택지 A. 사용자가 기준 소스를 직접 업로드

가장 안전하다.

1. GitHub Desktop 또는 Git 설치
2. 현재 `road-sos-master` 폴더를 `soysoyso/one`에 최초 push
3. 이후 Codex가 기능 브랜치/PR 방식으로 관리

### 선택지 B. Codex가 변경 파일 중심으로 업로드

가능하지만 추천도는 낮다.

- 저장소에 전체 기준 소스가 없으므로 PR diff가 실제 프로젝트 기준과 맞지 않을 수 있다.
- 문서/변경 파일만 올라가므로 나중에 전체 소스와 병합하기 어렵다.

### 선택지 C. Codex가 전체 소스를 GitHub API로 초기 업로드

이론상 가능하지만 리소스가 크다.

- PDF, 폰트, 모델, 이미지, 빌드 산출물 제외 기준을 먼저 정해야 한다.
- `.gitignore`, `.dockerignore` 기준으로 업로드 범위를 정리해야 한다.
- 업로드 파일 수가 많아 실패/누락 가능성이 있다.

현재 추천은 선택지 A다.

## 4. PR식 운영 플로우

### Step 시작 전

1. 현재 변경사항 확인
2. 작업 브랜치 생성
3. 스케줄 문서에서 이번 step 범위 확인

브랜치명 예시:

- `feature/road-sos-report-data`
- `feature/road-sos-notification-recipient`
- `feature/road-sos-daily-check`
- `feature/road-sos-situation-log`

### Step 완료 시

1. 빌드 또는 로컬 검증
2. 변경 파일 목록 정리
3. 스케줄 문서 업데이트
4. 커밋 생성
5. GitHub push
6. PR 생성 또는 기존 PR 업데이트

### PR 제목 예시

```text
[road-sos] 2차 고도화 - 보고서 데이터/API 기반 정리
```

### PR 본문 예시

```markdown
## 작업 내용
- 보고서 6종 데이터 필드 정리
- 어드민 접수상세 데이터 확장 설계 반영
- 스케줄 문서 업데이트

## 검증
- Docker build 확인
- 로컬 화면/API 확인

## 다음 작업
- 알림톡 수신자 설정
```

## 5. 현재 추천

지금은 Git 명령이 없으므로, 우선 로컬에서 기능 개발과 문서화를 진행한다.

사용자가 Git을 설치하거나 GitHub CLI/플러그인 사용을 승인하면 다음부터 각 step 종료 시 PR처럼 관리한다.

## 6. 다음에 필요한 확인

- `git --version` 실행 가능 여부
- `gh --version` 실행 가능 여부
- `soysoyso/one` 저장소에 push 권한이 있는지
- 현재 `road-sos-master`가 Git 저장소인지 또는 새로 초기화해야 하는지
