# T02 Attack System Implementation

## 1) Goal and background
- Goal: 근접 공격 1종과 히트 판정의 최소 프로토타입을 구현한다.
- Background: T01 이동/점프 기반 위에 즉각적 타격 반응(손맛)을 올려, 낙하 오브젝트 파괴 루프의 핵심 입력을 만든다.

## 2) Scope
### In Scope
- 입력 액션 `attack` 추가
- 플레이어 근접 공격 히트박스(짧은 지속시간)
- 공격 쿨다운/연타 제한(스팸 방지)
- 피격 가능한 대상 인터페이스(간단)
- 디버그용 피격 로그

### Out of Scope
- 콤보/차지/캔슬
- 복잡한 애니메이션 블렌딩
- 방어 관통/크리티컬 등 전투 확장

## 3) User scenarios
1. 플레이어가 공격 키를 누르면 전방으로 짧은 공격이 발동된다.
2. 공격 범위 안의 대상은 1회 피해를 받는다.
3. 공격 입력을 연타해도 쿨다운 규칙 내에서만 유효 타격이 발생한다.

## 4) Feature list with priorities
- P0: 단일 공격 + 단일 타격 판정
- P0: 방향 기반 전방 판정(좌/우)
- P1: 간단 쿨다운
- P1: 디버그 히트 확인 로그
- P2: 타격 시 간단 플래시/사운드 훅(placeholder)

## 5) Data and model
- Player 공격 변수
  - `attack_damage: int = 1`
  - `attack_cooldown: float = 0.25`
  - `attack_active_time: float = 0.08`
  - `attack_range: Vector2 = Vector2(28, 18)`
- 런타임 상태
  - `is_attacking: bool`
  - `attack_cooldown_left: float`

## 6) API / events / flow
- Input: `attack`
- Flow (`_physics_process` 일부)
  1. 쿨다운 감소
  2. `attack` 입력 시 발동 가능 여부 검사
  3. 히트박스 활성화 (`Area2D`)
  4. 중복 타격 방지 집합 처리
  5. `attack_active_time` 종료 시 비활성화

- Hit contract (간단 규약)
  - 대상 노드가 `take_hit(damage: int, source: Node)`를 구현하면 호출
  - 없으면 그룹 `hittable` 대상에 한해 경고 로그 출력

## 7) UI/UX
- T02 자체 UI 추가 없음
- 디버그 모드에서 공격 시작/히트 로그 출력

## 8) Error and edge cases
- 입력맵 누락(`attack`) 시 경고
- 한 번의 공격에서 다중 중복 판정 방지
- 공격 중 방향 전환 시 판정 튐 방지(발동 시 facing 스냅샷 사용)

## 9) Definition of Done (DoD)
- 공격 입력 시 전방 판정이 정상 동작
- 쿨다운 동안 중복 발동되지 않음
- 피격 함수가 있는 대상에 피해 전달 확인
- `PROTOTYPE_TRACKER.md`의 T02 상태 업데이트

## 10) Constraints
- T02는 **한 가지 공격만** 구현
- T03(방어), T07(필살) 로직과 혼합 금지
- 리소스는 placeholder 유지, 교체 포인트만 주석으로 명시

---

## Ticketed execution plan (T02 내부 분할)

### T02-A. 입력/공격 골격
- Purpose: 공격 액션과 상태 변수 연결
- Changed files:
  - `project.godot`
  - `scripts/player/player_controller.gd`
  - `scripts/player/player_attack.gd` (new)
- Acceptance:
  - attack 입력 시 공격 시작/종료 상태 변화 확인
- Verification:
  - 콘솔 로그로 attack state 전이 확인

### T02-B. 히트박스 + 타격 전달
- Purpose: 실제 피격 판정 구현
- Changed files:
  - `scenes/player/Player.tscn` (Area2D/CollisionShape2D 추가)
  - `scripts/player/player_attack.gd`
- Acceptance:
  - 범위 내 대상 1회 타격 적용
- Verification:
  - 더미 타겟 노드에 `take_hit()` 로그 확인

### T02-C. 쿨다운/중복타격 방지 + 디버그 정리
- Purpose: 반복 입력 안정화
- Changed files:
  - `scripts/player/player_attack.gd`
- Acceptance:
  - 연타 시 쿨다운 규칙 준수
  - 한 번의 공격에서 대상 중복 타격 없음
- Verification:
  - 연타 30초 테스트에서 이상 판정 없음

---

## Risks / decisions / tradeoffs

1. 판정 방식
- 옵션 A: `Area2D` 오버랩 기반
- 옵션 B: `RayCast2D` 단일선 기반
- 추천: **옵션 A** (근접 타격 범위 확장/튜닝이 쉬움)

2. 공격 스크립트 배치
- 옵션 A: `player_controller.gd` 내부 통합
- 옵션 B: `player_attack.gd` 분리
- 추천: **옵션 B** (T03/T07과 충돌 줄이고 유지보수 용이)

3. 피격 인터페이스
- 옵션 A: 그룹 기반 직접 HP 접근
- 옵션 B: `take_hit()` 메시지 계약
- 추천: **옵션 B** (결합도 낮음)

## Proposed execution order
1. T02-A
2. T02-B
3. T02-C
