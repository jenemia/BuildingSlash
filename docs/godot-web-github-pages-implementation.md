# Godot Web GitHub Pages Implementation

## Goal and Background

`BuildingSlash` Godot 프로젝트를 HTML5/Web 타깃으로 export해서 GitHub Pages에서 바로 실행 가능하게 만든다.

현재 저장소는 이미 GitHub Pages가 활성화되어 있고 `main` 브랜치 콘텐츠를 정적 사이트로 서빙하고 있다. 따라서 이번 작업은 Pages 설정을 Actions 기반으로 바꾸는 대신, 웹 export 산출물을 저장소 루트에 배치해 즉시 서빙되도록 구성한다.

## Scope

### In

- Godot 웹 export 설정 추가
- 웹 export용 로컬 빌드 스크립트 추가
- GitHub Pages에서 바로 서빙되도록 루트 정적 파일 배치
- README 배포/재빌드 방법 문서화

### Out

- 게임 플레이 로직 추가
- 커스텀 도메인 설정
- GitHub Pages Settings를 API로 변경하는 작업
- 자동 release tagging

## User Scenarios

1. 저장소를 푸시하면 GitHub Pages에서 게임이 열린다.
2. 로컬에서 웹 빌드를 다시 생성할 수 있다.
3. 저장소 방문자가 README 대신 게임 첫 화면을 본다.

## Feature List with Priorities

- P0: Godot 웹 export preset 추가
- P0: GitHub Pages가 바로 읽을 수 있는 `index.html` 및 관련 산출물 생성
- P0: Jekyll 우회를 위한 `.nojekyll` 추가
- P1: 로컬 재빌드 스크립트 추가
- P1: 배포/재빌드 문서화

## Data and Model

- 입력: Godot 프로젝트 파일 (`project.godot`, `node_2d.tscn`, `art/`, `fonts/`)
- 출력: 웹 정적 산출물 (`index.html`, `index.js`, `index.wasm`, `index.pck`, 관련 리소스)

## API / Events / Flow

1. 빌드 스크립트가 공식 Godot 4.6.1 에디터와 export templates를 내려받는다.
2. 스크립트가 `export_presets.cfg`의 `Web` preset으로 웹 export를 실행한다.
3. 산출물을 저장소 루트에 쓴다.
4. GitHub Pages가 루트의 `index.html`을 정적 파일로 서빙한다.

## UI / UX

- 초기 배포는 Godot 기본 웹 shell을 사용한다.
- GitHub Pages 하위 경로(`/BuildingSlash/`)에서도 상대 경로로 정상 동작해야 한다.

## Error and Edge Cases

- Web export는 Compatibility renderer가 더 안전하므로 프로젝트 렌더러를 `compatibility`로 맞춘다.
- GitHub Pages는 사용자 정의 응답 헤더를 제공하지 않으므로 `threads=false`로 export한다.
- GitHub Pages가 Jekyll 처리로 웹 산출물을 변형하지 않도록 `.nojekyll`을 둔다.
- 로컬에 Godot가 설치되어 있지 않아도 스크립트가 자체 다운로드로 빌드 가능해야 한다.

## Definition of Done

- `export_presets.cfg`가 저장소에 존재한다.
- 로컬 스크립트로 웹 export가 생성된다.
- 저장소 루트에 Pages 서빙용 산출물이 존재한다.
- README에 재빌드 및 Pages URL이 문서화된다.
- 변경사항이 커밋/푸시된다.

## Constraints

- 기존 프로젝트 구조는 유지한다.
- 로컬 전용 파일은 커밋하지 않는다.
- 공개 Pages 환경에 맞춰 보수적으로 설정한다.
- 코드/스크립트 설명은 간결하게 유지한다.

## Concerns and Risks

- 현재 GitHub Pages는 branch publishing 상태다. 따라서 Actions 전환 대신 루트 정적 산출물 배치가 가장 확실하다.
- 웹 export 산출물이 저장소 루트에 함께 존재하므로 작업 트리가 소스와 배포 파일을 같이 가진다.
- 이후 게임이 커지면 `gh-pages` 브랜치나 Actions 기반 배포로 분리하는 것이 더 좋다.

## Design Decisions

- 권장안: `main` 루트 배포
  - 이유: 현재 Pages가 이미 루트 콘텐츠를 서빙하고 있고, 추가 권한 없이 즉시 적용 가능하다.
- 렌더러: `compatibility`
  - 이유: Web 타깃 호환성이 가장 높다.
- 스레드: `false`
  - 이유: GitHub Pages에서 필요한 COOP/COEP 헤더를 제어할 수 없기 때문이다.

## Ticket Execution Order

### T1

- Purpose: 웹 export 설정과 빌드 도구를 추가한다.
- Changed files: `project.godot`, `export_presets.cfg`, `scripts/build_web.sh`
- Implementation details: 렌더러 조정, 웹 preset 작성, 자체 다운로드형 빌드 스크립트 추가
- Acceptance criteria: 스크립트가 웹 export를 실행할 수 있다.
- Verification method: 스크립트 실행 로그 확인

### T2

- Purpose: 실제 Pages 서빙 산출물을 만든다.
- Changed files: `index.html`, `index.js`, `index.wasm`, `index.pck`, `.nojekyll`
- Implementation details: 웹 export를 저장소 루트에 생성
- Acceptance criteria: 루트에 Godot 웹 산출물이 존재한다.
- Verification method: 파일 존재 확인, Pages URL 응답 확인

### T3

- Purpose: 운영 문서를 갱신하고 배포를 마무리한다.
- Changed files: `README.md`, 본 문서
- Implementation details: 재빌드 방법, Pages URL, 남은 리스크 기록
- Acceptance criteria: 재현 가능한 사용법이 문서화된다.
- Verification method: README 내용 검토

## Status

- T1: Completed
- T2: Completed
- T3: Completed

## Verification Notes

- 2026-03-11: `./scripts/build_web.sh`로 웹 export를 생성했다.
- 2026-03-11: GitHub Pages 내부 `pages build and deployment` 런이 `5e8bb75` 기준 `completed:success` 상태가 됐다.
- 2026-03-11: `https://jenemia.github.io/BuildingSlash/` 응답 본문이 Jekyll README 페이지가 아니라 Godot Web shell(`GODOT_CONFIG`, `index.js`)로 바뀐 것을 확인했다.
