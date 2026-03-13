# 게임오버 정지 + 로비/전투 씬 전환 인프라 구현서

## 1) Goal and background
- 목표: 전투 종료(HP 0) 시 게임 월드를 완전 정지하고, 메타 업그레이드 UX를 전투 내부 패널에서 분리해 로비 씬 중심으로 구성한다.
- 배경: 현재는 전투 씬 내부에 메타 업그레이드 패널이 있어 게임 루프/종료 UX와 메타 루프가 뒤섞여 있다. 씬 경계를 분리해 구조를 단순화하고 반복 플레이 흐름(로비→전투→결과→로비)을 명확히 한다.

## 2) Scope (In / Out)
### In
- HP 0 게임오버 시 월드 정지(time scale 제어) 및 결과 UI 입력 가능 상태 보장
- 로비 씬 신규 도입 및 메타 업그레이드 UI 분리
- 로비↔전투 씬 전환 인프라(공통 로더/전환 API)
- 결과 패널에서 로비 복귀/재시작 동선 정리

### Out
- 메타 업그레이드 밸런싱 수치 조정
- 세이브 포맷 개편
- 로비 아트/연출 고도화
- 신규 게임모드 추가

## 3) User scenarios
1. 플레이어가 전투 중 사망(HP 0)하면 게임이 멈추고 결과 메뉴가 뜬다.
2. 플레이어가 결과 메뉴에서 로비로 복귀한다.
3. 로비에서 메타 업그레이드를 구매하고 전투 시작을 누른다.
4. 업그레이드 효과가 반영된 상태로 전투를 진행한다.
5. 위 흐름을 반복해도 씬 전환 오류/상태 누적 없이 동작한다.

## 4) Feature list with priorities
- P0: 게임오버 시 월드 정지 + 결과 UI 동작
- P0: 로비 씬 생성 및 메타 업그레이드 UI 이동
- P0: 로비↔전투 전환 API/오토로드
- P1: 기존 전투 내 메타 진입 버튼의 역할 재정의(로비 이동)
- P1: 진입 씬 로비 기본화

## 5) Data and model
- 전역 런타임 상태
  - `Engine.time_scale` (게임 정지/재개)
- 씬 라우팅 상태
  - 현재 씬 경로
  - 전환 요청 함수 (`go_to_lobby`, `go_to_battle`)
- 메타 업그레이드 데이터
  - 기존 저장소(싱글톤/리소스)를 그대로 사용하고, 접근 위치만 로비 UI로 이동

## 6) API / events / flow
- `SceneLoader` (Autoload) 제안 API
  - `go_to_lobby()`
  - `go_to_battle()`
  - (선택) 내부 공통 `change_scene(path)`
- 전투 종료 플로우
  1) HP 0 감지
  2) `Engine.time_scale = 0.0`
  3) ResultPanel 노출
- 결과 메뉴 버튼 플로우
  - 재시작: `Engine.time_scale = 1.0` 후 전투 씬 재로딩
  - 로비로: `Engine.time_scale = 1.0` 후 `SceneLoader.go_to_lobby()`
- 로비 시작 버튼 플로우
  - `SceneLoader.go_to_battle()`

## 7) UI / UX
- Lobby 씬
  - 메타 업그레이드 패널
  - 전투 시작 버튼
- ResultPanel
  - 재시작 버튼
  - 로비 이동 버튼
- 게임오버 시
  - 월드(물리/액션) 정지, UI 상호작용은 유지

## 8) Errors and edge cases
- time_scale이 0으로 남아 다음 씬에서도 멈춘 상태로 시작되는 문제
- 씬 전환 중 중복 입력으로 전환 함수 중복 호출
- pause/time_scale 상호작용으로 ResultPanel 버튼이 먹통이 되는 문제
- 로비/전투 왕복 시 참조 끊김(노드 경로 하드코딩)

## 9) Definition of Done (DoD)
- HP 0 시 게임 월드가 멈추고 ResultPanel 입력 가능
- 로비 씬에서 업그레이드 구매 및 전투 시작 가능
- 결과 메뉴에서 로비 이동 가능
- 로비↔전투 왕복 5회 이상 수행해도 치명 오류 없음
- 웹 빌드/기본 검증 통과

## 10) Constraints
- 커밋 메시지: 한글
- 배포/푸시 버전: patch +1 규칙 준수
- 기존 저장 데이터 호환 최대한 유지
- 불필요한 대규모 리팩터링 금지(이번 작업 범위 내 최소 변경)

---

## Ticket execution plan

### T13 - 게임오버 정지 처리
- 목적: HP 0 시 전투 월드 완전 정지 및 결과 UI 조작 보장
- 변경 파일(예정):
  - `scripts` 내 게임 흐름/결과 UI 관련 파일
- 구현 상세:
  - HP 0 분기에서 `Engine.time_scale = 0.0`
  - ResultPanel이 정지 상태에서도 입력 가능하도록 pause/time_scale 영향 점검
  - 재시작/로비 이동 시 `Engine.time_scale = 1.0` 복구
- Acceptance criteria:
  - 게임오버 직후 월드 정지
  - 결과 버튼 정상 동작
- Verification:
  - 수동 플레이로 사망 유도 후 입력 테스트

### T14 - 로비 씬 도입 + 메타 업그레이드 분리
- 목적: 메타 업그레이드 UX를 전투 씬에서 분리
- 변경 파일(예정):
  - `scenes/Lobby.tscn`
  - 메타 패널 관련 스크립트/씬
- 구현 상세:
  - 로비 씬 생성
  - 기존 메타 UI를 로비로 이동 또는 재사용 구성
  - 전투 시작 버튼 추가
- Acceptance criteria:
  - 로비 진입 시 업그레이드 UI 표시
  - 업그레이드 구매 가능
- Verification:
  - 로비 단독 실행 및 업그레이드 동작 확인

### T15 - 씬 전환 인프라 구축
- 목적: 로비↔전투 전환을 중앙화해 안정성 확보
- 변경 파일(예정):
  - `autoload/SceneLoader.gd` (또는 동등 위치)
  - `project.godot` (Autoload 등록)
- 구현 상세:
  - 공통 전환 함수 구현
  - 전환 시 time_scale/기본 상태 복구 공통 처리
- Acceptance criteria:
  - 로비→전투, 전투→로비 양방향 호출 가능
- Verification:
  - 왕복 전환 반복 테스트

### T16 - 진입/연결 정리 및 회귀 확인
- 목적: 실제 사용자 동선 완성
- 변경 파일(예정):
  - 메인 진입 씬 설정 파일
  - ResultPanel 버튼 연결
  - 전투 씬 내 기존 메타 진입 경로
- 구현 상세:
  - 기본 시작 씬을 로비로 설정
  - 결과 패널 로비 이동 연결
  - 전투 내 메타 버튼은 로비 이동으로 변경(필요 시)
- Acceptance criteria:
  - 신규 시작 동선: 로비→전투→결과→로비 완성
- Verification:
  - 전체 루프 수동 회귀 + 웹 빌드 검증

---

## Status
- [x] 스펙 문서 작성
- [x] 설계 합의
- [x] T13
- [x] T14
- [x] T15
- [x] T16
- [ ] 최종 검증/배포

## 구현 메모 (2026-03-13)
- T13: HP 0 시 `Engine.time_scale = 0.0` 적용, ResultPanel은 `PROCESS_MODE_WHEN_PAUSED`로 입력 가능 보장.
- T14: `scenes/Lobby.tscn` + `scripts/main/lobby.gd` 추가, 메타 업그레이드 UI를 로비 동선으로 분리.
- T15: `scripts/main/scene_loader.gd` 추가 및 Autoload 등록(`SceneLoader`), `go_to_lobby/go_to_battle/reload_current_scene` 제공.
- T16: 시작 씬을 로비로 변경(`project.godot`), 결과 패널 버튼을 `로비로` 동선으로 연결.
- 검증: `godot --headless --path . --quit` 실행 성공(파싱/부팅 오류 없음).
