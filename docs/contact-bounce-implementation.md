# Contact Bounce Implementation (Player ↔ Falling Object)

## 1) Goal and background
- Goal: 플레이어가 점프/공격 타이밍에 낙하 오브젝트와 맞닿았을 때, 충돌 방향의 반대(위쪽)로 튕겨 오르는 물리 반응을 만든다.
- Background: 액션 손맛 강화 + 타이밍 보상 + 공중 운영 재미를 강화한다.

## 2) Scope (In / Out)
### In
- 플레이어가 `jump` 중이거나 `attack` 중일 때 유효 충돌 판정
- 유효 충돌 시 플레이어 반발력(위 방향 impulse) 적용
- 동일 오브젝트 연속 트리거 쿨다운(중복 바운스 방지)

### Out
- 적 AI/상세 피해 계산 리워크
- 파티클/사운드 연출 고도화

## 3) User scenarios
1. 플레이어가 점프 타이밍에 블록 하단/측면과 접촉하면 위로 튕겨 오른다.
2. 플레이어가 공격 타이밍에 접촉하면 더 강한 바운스를 받는다.
3. 같은 프레임에서 다중 충돌이 나도 과도한 다중 바운스는 발생하지 않는다.

## 4) Feature list with priorities
- P0: 충돌 유효 조건 + 반발력 적용
- P0: 중복 발동 방지(짧은 쿨다운)
- P1: 공격 중 보너스 바운스 계수
- P1: 디버그 로그/토글

## 5) Data/model
- Player (`scripts/player/player_controller.gd`)
  - `bounce_velocity_base: float = 360.0`
  - `bounce_velocity_attack_bonus: float = 120.0`
  - `bounce_cooldown: float = 0.12`
  - `_bounce_cd_left: float`
- FallingBlock (`scripts/world/falling_block.gd`)
  - 충돌 시 플레이어에게 bounce 신호/콜백 전달

## 6) API / flow
- Player 쪽 API 추가
  - `request_contact_bounce(source: Node, normal: Vector2, is_attack_timing: bool) -> bool`
- Flow
  1. FallingBlock 충돌 감지
  2. 플레이어 상태 확인(점프중/공격중)
  3. 조건 만족 시 player에 bounce 요청
  4. player가 `velocity.y = -bounce_value` 적용 + 쿨다운 시작

## 7) Edge cases
- 지면에 붙은 상태에서 bounce 요청: 최소 조건 미충족이면 무시
- 블록 여러 개 중첩: 쿨다운 동안 추가 bounce 무시
- 하강 속도 매우 큰 블록: 바운스 후 즉시 재충돌 루프 방지

## 8) DoD
- 점프/공격 타이밍 접촉 시 체감 가능한 상향 바운스 발생
- 연속 프레임 과도한 중첩 바운스 없음
- T05/T06 루프와 충돌 없이 동작

## 9) Ticket plan
### CB-1. Player bounce API 추가
- Files: `scripts/player/player_controller.gd`
- AC: bounce 요청 시 위 반발력 적용 + 쿨다운 동작

### CB-2. FallingBlock 충돌 연동
- Files: `scripts/world/falling_block.gd`
- AC: 유효 타이밍에서만 bounce 요청

### CB-3. Attack 상태 연동
- Files: `scripts/player/player_attack.gd` (필요 시 getter), `player_controller.gd`
- AC: 공격 중 바운스가 일반 점프보다 강함

### CB-4. 검증/튜닝
- Manual test 3회 + 파라미터 범위 기록
