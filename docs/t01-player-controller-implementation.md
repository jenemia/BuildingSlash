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
- 좌이동 시 `AnimatedSprite2D`의 `"left"` 애니메이션 재생 훅
- `BodyVisual` 의존 제거
- 플레이어 콜라이더를 실제 스프라이트 프레임 크기(`255x248`) 기준으로 정렬
- 플레이어 이미지를 원본의 `1/4` 크기로 축소
- 축소 비율에 맞춰 플레이어 콜라이더 크기/배치를 재보정

### Out of Scope
- 공격/방어/필살(각각 T02~T07)
- 전체 애니메이션 상태머신/점프/피격 연출 완성도
- 사운드/이펙트

## 3) User scenarios
1. 플레이어가 좌우 키를 누르면 즉시 캐릭터가 이동한다.
2. 플레이어가 점프 키를 누르면 지면에서 점프하고 공중에서는 재점프되지 않는다(초기 프로토타입 기준).
3. 낙하 후 지면에 닿으면 안정적으로 착지한다.
4. 플레이어가 왼쪽으로 이동 중일 때 `AnimatedSprite2D`가 `"left"` 애니메이션을 재생한다.
5. 플레이어 씬에 `BodyVisual` 노드가 없어도 컨트롤러가 직접 `AnimatedSprite2D`를 사용한다.
6. 플레이어 콜라이더가 스프라이트 크기에 맞고, 바닥 스폰 시 발이 땅에 맞게 유지된다.
7. 플레이어 스프라이트가 `1/4` 크기로 표시되고 콜라이더도 같은 기준으로 줄어든다.

## 4) Feature list with priorities
- P0: 좌/우 이동, 점프, 착지 안정화
- P0: 프레임 독립 이동(`delta` 반영)
- P1: 가감속(입력 손맛 개선)
- P1: 이동 입력과 `AnimatedSprite2D` 기본 애니메이션 연결
- P1: `AnimatedSprite2D` 직접 참조로 비주얼 의존 단순화
- P1: 스프라이트 크기 기준 플레이어 충돌체 정렬
- P1: 스프라이트 축소와 충돌체 재정렬의 일관성 유지
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
- Visual hook
  - `AnimatedSprite2D` node: `Player/AnimatedSprite2D`
  - Required animation for this ticket: `"left"`
- Collision target
  - Player frame size: `255x248`
  - Collision baseline should keep the player standing on ground after resize
  - Quarter-size display/collision target: `63.75x62.0`

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
  5. 이동 방향 기반 비주얼/애니메이션 상태 갱신
  6. `move_and_slide()`
  7. 착지/이륙 상태 업데이트

## 7) UI/UX
- 이번 티켓은 UI 없음.
- 디버그 확인용으로 콘솔 로그 또는 에디터 인스펙터 관찰 기준 사용.

## 8) Error and edge cases
- 입력 맵 미등록 시 이동 불가 → 시작 시 assert/경고 로그
- 높은 중력/낮은 점프로 점프 체감 저하 → 수치 튜닝 범위 명시
- 지형 경사/코너에서 떨림 → `floor_snap_length` 조정(필요 시)
- `AnimatedSprite2D` 노드가 없거나 `"left"` 애니메이션이 없으면 재생 호출 시 오류 가능 → null/존재 체크 필요
- 기존 `BodyVisual` 직접 참조와 실제 씬 구조가 다르면 `_ready` 단계에서 실패 가능 → 안전한 노드 조회로 정리 필요
- 콜라이더를 `255x248`로 확대하면 기존 스폰 오프셋(`16`)이 더 이상 맞지 않음 → 스폰 높이를 충돌체 높이 기준으로 계산해야 함
- 원본 이미지에 투명 여백이 많으면 체감 히트박스가 과대해질 수 있음 → 이번 요청은 이미지 전체 크기 기준으로 적용
- 스프라이트만 축소하고 콜라이더를 같이 줄이지 않으면 피격/지면 접지 체감이 어긋남
- 중심 기준 정렬을 유지하면 콜라이더 position은 `0,0`으로 두고 size만 줄이는 편이 안전함

## 9) Definition of Done (DoD)
- 로컬 실행에서 좌우 이동/점프/착지가 정상 동작
- 왼쪽 이동 입력 시 `"left"` 애니메이션이 재생됨
- `BodyVisual` 관련 참조가 제거됨
- 플레이어가 `255x248` 콜라이더 기준으로 지면에 정상 배치됨
- 플레이어 스프라이트가 `1/4` 배율로 렌더링됨
- 플레이어 콜라이더가 `63.75x62.0` 기준으로 보정됨
- 공중 재점프가 발생하지 않음
- `PROTOTYPE_TRACKER.md`의 T01 상태 업데이트
- 변경 파일/검증 결과를 티켓 리포트로 기록

## 10) Constraints
- Godot 4.x 기준 GDScript
- 기존 폴더 규칙 우선 (`scripts/player`, `scenes/player`)
- T01에서 공격/방어 로직 절대 섞지 않음
- 복잡한 최적화보다 명확한 로직 우선
- 애니메이션 훅은 최소 변경으로 추가하고, 전체 상태머신 도입은 보류

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

### T01-D. 좌이동 애니메이션 연결
- Purpose: 좌이동 입력과 플레이어 비주얼 반응을 최소 비용으로 연결한다.
- Changed files:
  - `scripts/player/player_controller.gd`
- Implementation details:
  - `AnimatedSprite2D`를 안전하게 조회한다.
  - 왼쪽 입력 시 `"left"` 애니메이션을 재생한다.
  - 노드/애니메이션 누락 시 오류 대신 조용한 fallback 또는 경고를 사용한다.
  - 기존 `BodyVisual` 직접 참조는 씬 구조와 맞게 안전 조회로 정리한다.
- Acceptance criteria:
  - 플레이어가 왼쪽으로 움직일 때 `"left"` 애니메이션이 재생된다.
  - 애니메이션 노드가 있어도 없어도 컨트롤러가 즉시 깨지지 않는다.
- Verification:
  - Godot 실행 후 좌이동 입력 수동 확인
  - headless 구동으로 파싱/로딩 오류 확인

### T01-E. 비주얼 의존 제거 + 콜라이더 리사이즈
- Purpose: `BodyVisual` 의존을 제거하고 플레이어 충돌체를 실제 프레임 크기에 맞춘다.
- Changed files:
  - `scripts/player/player_controller.gd`
  - `scenes/player/Player.tscn`
  - `scripts/main/game_root.gd`
- Implementation details:
  - `BodyVisual` 변수/조회 로직을 제거하고 `AnimatedSprite2D`를 직접 사용한다.
  - 플레이어 `CollisionShape2D`를 `255x248`로 조정한다.
  - 바닥 스폰 로직은 콜라이더 절반 높이 기준으로 계산해 발 위치를 유지한다.
- Acceptance criteria:
  - `player_controller.gd`에 `BodyVisual` 의존이 남지 않는다.
  - 플레이어 충돌체가 `255x248`로 반영된다.
  - 씬 시작 시 플레이어가 바닥에 박히지 않고 정상 배치된다.
- Verification:
  - headless 구동으로 파싱/로딩 오류 확인
  - 실제 실행에서 시작 위치와 지면 충돌 상태 수동 확인

### T01-F. 스프라이트 1/4 축소 + 충돌체 재보정
- Purpose: 플레이어 표시 크기를 줄이고 충돌체/접지 계산을 같은 비율로 맞춘다.
- Changed files:
  - `scenes/player/Player.tscn`
  - `scripts/main/game_root.gd`
- Implementation details:
  - `AnimatedSprite2D` 표시 스케일을 `0.25, 0.25`로 조정한다.
  - 플레이어 `CollisionShape2D` 크기를 `63.75x62.0`로 조정한다.
  - 콜라이더 중심 정렬을 유지하고, 지면 배치는 새 충돌체 높이 기준으로 계속 계산한다.
- Acceptance criteria:
  - 플레이어 스프라이트가 기존 대비 1/4 크기로 보인다.
  - 플레이어 콜라이더가 축소된 크기에 맞게 반영된다.
  - 씬 시작 시 플레이어가 지면에 정상 배치된다.
- Verification:
  - headless 구동으로 파싱/로딩 오류 확인
  - 실제 실행에서 시작 위치와 스프라이트/콜라이더 상대 크기 수동 확인

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

4. 방향 애니메이션 처리 범위
- 옵션 A: 이번 요청 범위대로 좌이동 시 `"left"`만 확실히 재생
- 옵션 B: 좌/우/정지까지 묶어서 간단 상태 전환 추가
- 추천: **옵션 A** (요청 범위에 맞고, 현재 씬에는 `"left"`만 정의돼 있음)

5. 콜라이더 크기 기준
- 옵션 A: 텍스처 전체 크기 `255x248`를 그대로 충돌체로 사용
- 옵션 B: 실제 보이는 실루엣에 맞춰 별도 수치로 축소
- 추천: **옵션 A** (이번 요청이 "이미지 크기만큼"이기 때문)

6. 1/4 축소 적용 방식
- 옵션 A: `AnimatedSprite2D.scale`을 `0.25`로 줄이고 콜라이더도 `1/4` 크기로 수동 조정
- 옵션 B: 텍스처 자체를 리샘플링한 새 리소스를 만들어 교체
- 추천: **옵션 A** (변경 범위가 작고 기존 애니메이션 리소스를 그대로 쓸 수 있음)

## Proposed execution order
1. T01-A
2. T01-B
3. T01-C
4. T01-D
5. T01-E
6. T01-F

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
- T01-D: DONE
  - `AnimatedSprite2D` 안전 조회 및 `"left"` 애니메이션 재생 훅 추가
  - 이후 T01-E에서 `BodyVisual` fallback 제거
- T01-E: DONE
  - `BodyVisual` 의존 제거, 가드 시각 처리도 `AnimatedSprite2D` 직접 사용으로 단순화
  - 플레이어 콜라이더를 `255x248`로 조정하고 스폰 높이 계산을 충돌체 기준으로 보정
- T01-F: DONE
  - 플레이어 스프라이트를 `0.25` 배율로 축소
  - 본체 콜라이더를 `63.75x62.0`로 재보정하고 접지 계산을 그대로 유지

## Verification note
- Godot headless 실행 확인:
  - `"/Applications/Godot.app/Contents/MacOS/Godot" --headless --path /Users/sean/Documents/BuildingSlash --quit`
  - 결과: 에러 없이 종료
- T01-D 추가 검증:
  - `scripts/player/player_controller.gd` 파싱 및 프로젝트 로딩 성공
  - 수동 플레이 기반 좌이동 애니메이션 확인은 아직 실행하지 않음
- T01-E 추가 검증:
  - `BodyVisual` 참조 제거 후에도 프로젝트 로딩이 깨지지 않아야 함
  - `Player.tscn` 충돌체 크기 `255x248` 반영 상태에서 시작 위치 수동 확인 필요
- T01-F 추가 검증:
  - `AnimatedSprite2D.scale = Vector2(0.25, 0.25)` 반영
  - 본체 콜라이더 `63.75x62.0` 반영 후 headless 로딩 성공
  - 실제 실행에서 스프라이트 대비 공격 히트박스 체감은 아직 수동 확인하지 않음
