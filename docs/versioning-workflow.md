# Versioning Workflow (push마다 버전 관리)

## 구성
- `VERSION.txt`: 게임 버전 소스(semver)
- 인게임 표기: `node_2d.tscn`의 우상단 `VersionLabel`이 `VERSION.txt`를 읽어 표시
- 자동화 스크립트:
  - `scripts/release/bump_version.sh [major|minor|patch]`
  - `scripts/release/release_web_push.sh [major|minor|patch] [optional message]`

## 권장 사용법
### 1) 일반 개발 푸시
- 필요 시 수동 커밋/푸시

### 2) 배포성 푸시(버전+웹빌드+푸시)
```bash
./scripts/release/release_web_push.sh patch "t06 spawn curve"
```

동작 순서:
1. `VERSION.txt` patch 증가
2. `./scripts/build_web.sh` 실행
3. 웹 산출물 + VERSION 스테이징
4. `chore(release): vX.Y.Z - <message>` 커밋
5. `origin/main` 푸시

## 참고
- major/minor 릴리즈는 첫 번째 인자만 바꾸면 됨.
  - `major`, `minor`, `patch`
- 인게임 우상단 버전은 실행 시점 `VERSION.txt` 값을 그대로 표시한다.
