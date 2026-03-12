# T11 확장: 블록 바닥 충돌 시 플레이어 HP 감소

## 1) Goal and background
- Goal: 낙하 블록이 바닥에 닿아 사라질 때도 플레이어가 피해를 받도록 한다.
- Background: 현재는 블록-플레이어 직접 접촉 시에만 HP가 감소한다. 압박감을 강화하려면 블록 처리 실패(바닥 도달)도 페널티로 연결해야 한다.

## 2) Scope (In/Out)
### In Scope
- 블록이 바닥에 닿았음을 감지
- 블록 타입별 바닥 충돌 피해값 정의
- `GameFlow`에서 HP 감소 처리

### Out of Scope
- 연출 강화(카메라 쉐이크/사운드)
- 바닥 내구도 시스템
- 연쇄/콤보 페널티

## 3) User scenario
1. 블록이 바닥에 닿는다.
2. 해당 블록은 즉시 제거된다.
3. 플레이어 HP가 정해진 수치만큼 감소한다.

## 4) Feature list with priority
- P0: 바닥 충돌 이벤트 시그널 추가
- P0: 타입별 바닥 피해(soft/normal/hard) 적용
- P1: 디버그 로그(어떤 타입이 몇 데미지)

## 5) Data/model
- 위치: `scripts/world/block_data.gd`
- 추가 필드: `ground_hit_damage`
  - SOFT: 4
  - NORMAL: 8
  - HARD: 12

## 6) API/events/flow
- `falling_block.gd`
  - 신규 시그널: `hit_ground(block, tier_name, ground_damage)`
  - 바닥 충돌 감지 시 emit 후 queue_free
- `game_flow.gd`
  - `hit_ground` 시그널 구독
  - HP 감소 처리 + 0 이하면 결과창

## 7) Error/edge cases
- 같은 블록이 중복 피해를 주지 않도록 1회 처리 플래그 필요
- 플레이어 사망 후 이벤트 무시

## 8) DoD
- 블록이 바닥에 닿을 때마다 HP 감소 확인
- 타입별 피해 차등 확인
- 웹 빌드 통과

## 9) Ticket plan
### T11-G1. 바닥 충돌 이벤트 추가
- files: `scripts/world/falling_block.gd`
- AC: 바닥 충돌 시 `hit_ground` 1회 emit

### T11-G2. 타입별 바닥 피해값 연결
- files: `scripts/world/block_data.gd`
- AC: tier별 `ground_hit_damage` 조회 가능

### T11-G3. 게임플로우 HP 반영
- files: `scripts/main/game_flow.gd`
- AC: `hit_ground` 수신 시 HP 감소/사망 처리 정상

### T11-G4. 검증
- command: `./scripts/build_web.sh`
- AC: 빌드 성공 + 플레이 중 바닥 충돌 데미지 확인
