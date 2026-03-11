# Godot Web Pages Skill Implementation

## Goal and Background

현재 `BuildingSlash` 프로젝트에 맞는 로컬 skill을 추가해, 이후 세션에서 Codex가 이 저장소의 Godot 웹 export 및 GitHub Pages 반영 절차를 일관되게 수행하도록 만든다.

이미 프로젝트에는 웹 export 설정과 `scripts/build_web.sh`가 존재한다. 이번 작업의 목적은 이 배포 절차를 재사용 가능한 skill로 명문화하고, 프로젝트 내부에 보관해 다음 세션에서도 바로 불러 쓸 수 있게 하는 것이다.

## Scope

### In

- 프로젝트 로컬 skill 디렉터리 추가
- Godot 웹 export 및 Pages 검증 절차를 담은 `SKILL.md` 작성
- 필요 시 project-specific reference 문서 추가
- skill validation 실행
- 프로젝트에서 skill을 발견하기 쉬운 인덱스/안내 갱신

### Out

- 기존 웹 export 로직 자체 변경
- GitHub Pages 배포 방식 전환
- Codex 홈 전역 skill 수정

## User Scenarios

1. 다음 세션에서 “이 프로젝트 웹에 다시 배포해” 같은 요청을 받으면 해당 skill이 바로 트리거된다.
2. Codex가 이 저장소의 `build_web.sh`, Pages URL, 검증 포인트를 다시 탐색하지 않고 바로 절차를 따른다.
3. 프로젝트 외부 전역 skill을 건드리지 않고, 이 저장소 안에서만 재사용 규칙을 유지한다.

## Feature List with Priorities

- P0: 프로젝트 로컬 skill root 추가
- P0: Godot 웹 export + GitHub Pages 배포 절차를 담은 `SKILL.md` 작성
- P0: 기존 스크립트/문서를 참조하는 project-specific workflow 정리
- P1: `agents/openai.yaml` 생성
- P1: skill validation 및 발견성 보강

## Data and Model

- 입력:
  - `scripts/build_web.sh`
  - `export_presets.cfg`
  - `README.md`
  - `docs/godot-web-github-pages-implementation.md`
- 출력:
  - `.codex/skills/godot-web-pages-deploy/SKILL.md`
  - `.codex/skills/godot-web-pages-deploy/agents/openai.yaml`
  - 선택적 `references/` 파일

## API / Events / Flow

1. skill skeleton을 프로젝트 내부 `.codex/skills/`에 생성한다.
2. `SKILL.md`에 trigger 설명과 실행 절차를 기록한다.
3. 필요한 project-specific details는 `references/`에 분리한다.
4. validation script로 구조를 점검한다.
5. 프로젝트 인덱스 파일에 로컬 skill 존재를 기록한다.

## UI / UX

- 없음. 이 작업은 agent workflow 문서화가 목적이다.

## Error and Edge Cases

- 프로젝트 안에 기존 로컬 skill root가 없으므로 새로 만들어야 한다.
- skill 내용이 기존 문서와 중복되면 유지 비용만 늘어난다. 핵심 절차만 `SKILL.md`에 두고 상세 사실은 `references/`로 분리해야 한다.
- Codex가 프로젝트 로컬 skill을 확실히 발견하도록 인덱스 파일에도 한 줄 남기는 편이 안전하다.

## Definition of Done

- 프로젝트 내부에 유효한 skill 폴더가 생성된다.
- `SKILL.md`가 이 프로젝트의 웹 배포 절차를 설명한다.
- validation이 통과한다.
- 프로젝트 문서 또는 인덱스에서 skill 존재를 발견할 수 있다.

## Constraints

- skill은 프로젝트 내부에 둔다.
- 기존 `scripts/build_web.sh`를 재사용하고 중복 스크립트를 만들지 않는다.
- `SKILL.md`는 짧고 trigger 설명 중심으로 유지한다.
- 절차 세부사항은 필요할 때만 읽도록 분리한다.

## Concerns and Risks

- 로컬 skill 위치 선택:
  - 옵션 A: `.codex/skills/`
  - 옵션 B: `.agents/skills/`
  - 옵션 C: `.claude/skills/`
- 권장안은 `.codex/skills/`다.
  - 이유: 현재 Codex 환경과 naming이 가장 직접적이고, `manage-skills` 지침의 탐색 우선순위에도 포함된다.

- 발견성 보강:
  - 옵션 A: skill 폴더만 추가
  - 옵션 B: skill 폴더 + `AGENTS.md`에 로컬 skill 안내 추가
- 권장안은 옵션 B다.
  - 이유: 다음 세션에서 인간과 에이전트 모두 프로젝트 skill 존재를 쉽게 알아볼 수 있다.

## Ticket Execution Order

### T1

- Purpose: 로컬 skill skeleton을 생성한다.
- Changed files: `.codex/skills/godot-web-pages-deploy/**`
- Implementation details: `init_skill.py`로 디렉터리와 메타데이터 파일을 만든다.
- Acceptance criteria: skill 폴더와 기본 파일이 생성된다.
- Verification method: 파일 존재 확인

### T2

- Purpose: 실제 프로젝트용 workflow를 skill에 반영한다.
- Changed files: `SKILL.md`, 필요 시 `references/*`
- Implementation details: trigger 문구, 실행 절차, 검증 절차, 주의사항을 기록한다.
- Acceptance criteria: 이 프로젝트의 Godot 웹 배포 요청을 처리할 수 있는 수준의 지침이 있다.
- Verification method: 문서 리뷰

### T3

- Purpose: 발견성과 유효성을 마무리한다.
- Changed files: `AGENTS.md` 또는 동등 인덱스, 필요 시 docs
- Implementation details: 로컬 skill 안내를 추가하고 validation을 실행한다.
- Acceptance criteria: skill을 찾기 쉽고 validator가 통과한다.
- Verification method: validation script 실행

## Status

- T1: Completed
- T2: Completed
- T3: Completed

## Verification Notes

- 2026-03-12: `init_skill.py`로 `.codex/skills/godot-web-pages-deploy` skeleton을 생성했다.
- 2026-03-12: `SKILL.md`와 `references/buildingslash-web-deploy.md`에 프로젝트 전용 배포 절차를 기록했다.
- 2026-03-12: `AGENTS.md`에 project-local skill 안내를 추가했다.
- 2026-03-12: `quick_validate.py`는 시스템 Python에 `yaml` 모듈이 없어 직접 실행은 실패했다.
- 2026-03-12: `.cache/skill-validator-venv` 임시 venv에 `PyYAML`을 설치해 validator를 재실행했고 `Skill is valid!`를 확인했다.
- 2026-03-12: 이후 `scripts/build_web.sh`를 설치된 `Godot.app` 전용 흐름으로 단순화하고, Godot 본체 다운로드 단계는 제거했다.
