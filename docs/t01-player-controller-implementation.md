# T01 Player Controller Implementation

## 1) Goal and background
- Goal: T01(플레이어 기본 조작 구현)을 안정적으로 완료한다.
- Background: `게임컨셉.md`의 코어 감각(즉각 반응, 짧은 판단 연속)을 위해 입력 반응성과 이동 일관성이 최우선이다.

## 2) Scope
### In Scope
- 좌/우 이동
- 점프
- 중력/착지
- 기본 입력 맵(`move_left`, `move_right`, `jump`) 확인
- 최소 디버그 출력(속도/착지 상태)

### Out of Scope
- 공격/방어/필살(각각 T02~T07)
- 애니메이션 완성도
- 사운드/이펙트

## 3) User scenarios
1. 플레이어가 좌우 키를 누르면 즉시 캐릭터가 이동한다.
2. 플레이어가 점프 키를 누르면 지면에서 점프하고 공중에서는 재점프되지 않는다(초기 프로토타입 기준).
3. 낙하 후 지면에 닿으면 안정적으로 착지한다.

## 4) Feature list with priorities
- P0: 좌/우 이동, 점프, 착지 안정화
- P0: 프레임 독립 이동(`delta` 반영)
- P1: 가감속(입력 손맛 개선)
- P1: 점프 컷(키를 빨리 떼면 낮은 점프)
- P2: 코요테타임/점프버퍼(선택)

## 5) Data and model
- Node type: `CharacterBody2D`
- Core variables
  - `move_speed: float = 260.0`
  - `accel: float = 1800.0`
  - `decel: float = 2200.0`
  - `jump_velocity: float = -420.0`
  - `gravity_scale: float = 1.0`
  - `max_fall_speed: float = 980.0`
- Runtime state
  - `is_grounded: bool`
  - `facing: int` (`-1|1`)

## 6) API / events / flow
- Input actions required:
  - `move_left`
  - `move_right`
  - `jump`
- Main loop flow (`_physics_process`)
  1. 입력 축 계산 (`-1~1`)
  2. 수평 속도 갱신(가감속)
  3. 중력 적용
  4. 점프 입력 처리(지면일 때)
  5. `move_and_slide()`
  6. 착지/이륙 상태 업데이트

## 7) UI/UX
- 이번 티켓은 UI 없음.
- 디버그 확인용으로 콘솔 로그 또는 에디터 인스펙터 관찰 기준 사용.

## 8) Error and edge cases
- 입력 맵 미등록 시 이동 불가 → 시작 시 assert/경고 로그
- 높은 중력/낮은 점프로 점프 체감 저하 → 수치 튜닝 범위 명시
- 지형 경사/코너에서 떨림 → `floor_snap_length` 조정(필요 시)

## 9) Definition of Done (DoD)
- 로컬 실행에서 좌우 이동/점프/착지가 정상 동작
- 공중 재점프가 발생하지 않음
- `PROTOTYPE_TRACKER.md`의 T01 상태 업데이트
- 변경 파일/검증 결과를 티켓 리포트로 기록

## 10) Constraints
- Godot 4.x 기준 GDScript
- 기존 폴더 규칙 우선 (`scripts/player`, `scenes/player`)
- T01에서 공격/방어 로직 절대 섞지 않음
- 복잡한 최적화보다 명확한 로직 우선

---

## Ticketed execution plan (T01 내부 분할)

### T01-A. 입력/물리 골격 구성
- Purpose: 이동/점프 기본 루프 골격 확립
- Changed files:
  - `scripts/player/player_controller.gd` (new)
- Implementation details:
  - CharacterBody2D 기반 스크립트 생성
  - 입력축/중력/점프/이동 처리 기본 구현
- Acceptance criteria:
  - 좌우 이동/점프/착지 동작
- Verification:
  - 수동 플레이 2분, 재현 체크

### T01-B. 가감속 + 낙하 속도 캡
- Purpose: 조작 손맛 안정화
- Changed files:
  - `scripts/player/player_controller.gd`
- Implementation details:
  - accel/decel 분리
  - max fall speed 제한
- Acceptance criteria:
  - 미끄러짐 과다/급정지 과도 현상 없음
- Verification:
  - 방향 전환 반복 테스트

### T01-C. 입력 검증/디버그 보강
- Purpose: 초기 장애 빠른 탐지
- Changed files:
  - `scripts/player/player_controller.gd`
  - (필요 시) `project.godot` input map 확인
- Implementation details:
  - 필수 액션 누락 경고
  - 디버그 상태값 출력 함수 추가(토글형)
- Acceptance criteria:
  - 액션 누락 시 원인 식별 가능
- Verification:
  - 액션 명 오타 상황에서 경고 출력 확인

---

## Risks / Decisions / Tradeoffs

1. 이동 모델
- 옵션 A: 즉시 속도 변경(단순)
- 옵션 B: 가감속 적용(손맛)
- 추천: **옵션 B** (프로토타입이라도 체감 품질 차이가 큼)

2. 점프 확장 기능
- 옵션 A: 단일 점프만
- 옵션 B: 점프버퍼/코요테타임 포함
- 추천: **옵션 A로 시작**, T01 완료 후 필요 시 T01-EX로 추가

3. 상태머신 도입 시점
- 옵션 A: 지금 바로 도입
- 옵션 B: T02 이후(공격/방어 합류 시)
- 추천: **옵션 B** (지금은 과설계 방지)

## Proposed execution order
1. T01-A
2. T01-B
3. T01-C

---

## Execution status (2026-03-12)
- T01-A: DONE
  - `scripts/player/player_controller.gd` 생성, 기본 물리 루프 구성
  - `scenes/player/Player.tscn` 생성 및 연결
- T01-B: DONE
  - 가감속(`accel`/`decel`) 적용
  - `max_fall_speed` 적용
- T01-C: DONE
  - 입력 액션 누락 경고(`_validate_input_actions`) 추가
  - 디버그 출력 토글(`debug_print`) 추가

## Verification note
- Godot headless 실행 확인:
  - `"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path /Users/sean/Documents/BuildingSlash --quit`
  - 결과: 에러 없이 종료
