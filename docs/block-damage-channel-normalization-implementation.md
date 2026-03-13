# Block Damage Channel Normalization Implementation

## 1) Goal and background

현재 블록 관련 피해 처리가 일부 충돌 경로에만 연결되어 있어, 다음 문제가 발생한다.
- 블록이 플레이어를 접촉했는데 HP가 감소하지 않는 케이스 존재
- 블록이 바닥(실패 조건)에 도달했는데 HP가 감소하지 않는 케이스 존재

목표는 **피해 적용 창구를 단일화/정규화**하여, 충돌/착지/추후 신규 트리거(예: 폭발, 범위 데미지)가 추가되어도 GameFlow가 일관된 방식으로 처리하도록 만드는 것이다.

## 2) Scope (In/Out)

### In Scope
- 블록 이벤트를 "사실(Event)" 단위로 표준화
- GameFlow의 HP 감소 로직을 단일 데미지 API로 통합
- 블록 한 개당 중복 타격 방지
- 기존 접촉 감지 안정성 보강

### Out of Scope
- 밸런스 수치 대규모 조정
- UI/이펙트 전면 개편
- 완전한 전투 시스템 리아키텍처

## 3) User scenarios

1. 플레이어가 낙하 블록에 머리/몸이 닿으면 HP가 즉시 감소한다.
2. 블록이 플레이어를 맞추지 못해도 바닥에 닿으면 실패 페널티로 HP가 감소한다.
3. 동일 블록으로 인해 동일 원인의 피해가 여러 번 누적되지 않는다.
4. 향후 새로운 피해 원인이 추가되어도 `apply_damage(...)` 창구로 쉽게 연결된다.

## 4) Feature list with priorities

- P0: GameFlow 데미지 창구 단일화 (`apply_damage`)
- P0: FallingBlock 이벤트 표준화 (`hit_player`, `reached_ground`)
- P0: 블록 인스턴스 단위 중복 피해 방지
- P1: 접촉 감지 보강(기존 slide 충돌 감지 + 센서/검증 루트)
- P1: 디버그 로그 포인트(개발 중 토글 가능)

## 5) Data and model

### DamageEvent (경량 구조)
- source_type: `"falling_block"`
- source_id: 블록 instance id
- cause: `"hit_player" | "reached_ground" | <future>`
- amount: int/float
- metadata: Dictionary (옵션)

### Damage 처리 책임
- FallingBlock: 물리 사실을 이벤트로 emit
- GameFlow: 정책(얼마를 깎는지, 중복 허용 여부) 결정
- Player/Health: 실제 HP 반영

## 6) API/events/flow

### 표준 창구
- `GameFlow.apply_damage(event: Dictionary) -> void`

### FallingBlock signals
- `signal hit_player(block, player)`
- `signal reached_ground(block)`

### 흐름
1. FallingBlock이 물리 상황을 감지
2. 해당 signal emit
3. GameFlow가 signal 수신 후 DamageEvent 생성
4. `apply_damage(event)` 호출
5. dedupe 검사 통과 시 HP 감소

### Dedupe 키
- `dedupe_key = "{source_id}:{cause}"`
- 이미 처리된 key면 무시

## 7) UI/UX (if any)

- 사용자 가시 UI 변경 없음
- 필요 시 디버그 오버레이/로그로 이벤트 확인

## 8) Error and edge cases

- 매우 짧은 접촉 프레임에서 충돌 누락 가능성 → 감지 경로 보강
- 블록 제거 시점과 이벤트 순서 레이스 → emit 후 free 순서 보장
- ground & player 동시 접촉 프레임 → 우선순위 정책 명시 (기본: `hit_player` 우선, ground 중복 무효)

## 9) Definition of Done (DoD)

- [x] 플레이어 접촉 시 HP 감소 재현 가능
- [x] 바닥 도달 시 HP 감소 재현 가능
- [x] 동일 블록 동일 원인 중복 피해 없음
- [x] 기존 게임 루프에서 회귀 없음
- [x] 관련 테스트/수동 검증 통과

## 10) Constraints

- 기존 프로젝트 스타일/파일 구조 준수
- 최소 침습 변경 우선
- 새 이벤트 추가 시 GameFlow 변경량 최소화
- 임시 디버그 로그는 토글 가능하게 유지

---

## Ticket Plan

### T1. 데미지 창구 정규화 (GameFlow)

**Purpose**
- 피해 반영 경로를 `apply_damage` 단일 메서드로 통합한다.

**Changed files**
- `src/.../game_flow.gd` (정확 경로 확인 후 반영)

**Implementation details**
- 기존 직접 HP 감소 코드를 `apply_damage(event)` 호출로 대체
- dedupe set/dictionary 추가
- cause별 데미지 매핑(초기: `hit_player`, `reached_ground`)

**Acceptance criteria**
- 모든 블록 기원 데미지가 `apply_damage`를 통해서만 반영

**Verification**
- 로그/브레이크포인트로 apply_damage 단일 경유 확인

---

### T2. FallingBlock 이벤트 표준화

**Purpose**
- 충돌 사실을 표준 signal로 전달한다.

**Changed files**
- `src/.../falling_block.gd`
- (필요 시) block scene 파일

**Implementation details**
- `hit_player`, `reached_ground` signal 추가/교체
- 기존 충돌 감지 루틴에서 이벤트 emit
- 블록당 이벤트 중복 emit 방지 플래그

**Acceptance criteria**
- 플레이어 접촉/지면 도달 모두 신호가 안정적으로 발생

**Verification**
- 수동 재현 20회 이상에서 이벤트 누락 없음

---

### T3. 접촉 감지 보강 + 우선순위 정책

**Purpose**
- 머리 위 접촉 누락을 줄이고 동시 충돌 정책을 명시한다.

**Changed files**
- `src/.../falling_block.gd`
- (필요 시) 관련 collision layer 설정 파일

**Implementation details**
- slide collision 기반 감지를 유지하되 보강 루트 추가(센서 또는 쿼리)
- 동일 프레임에서 player/ground 동시 충돌 시 `hit_player` 우선

**Acceptance criteria**
- 기존 누락 케이스 재현 불가

**Verification**
- 재현 시나리오 A/B/C 통과

---

### T4. 검증 및 문서 마감

**Purpose**
- 최종 검증 후 결과를 문서에 반영한다.

**Changed files**
- 본 문서
- (필요 시) 테스트 관련 파일

**Implementation details**
- 수동/자동 검증 실행
- DoD 체크 완료 및 잔여 리스크 기록

**Acceptance criteria**
- DoD 전 항목 체크

**Verification**
- 실행 로그 + 결과 요약 공유

---

## Status
- [x] Spec drafted
- [x] T1
- [x] T2
- [x] T3
- [x] T4

## Implementation Notes (2026-03-13)
- `GameFlow.apply_damage(event)`를 추가해 블록 기원 데미지를 단일 창구로 통합.
- 데미지 수치 분리: `hit_player_damage`, `reached_ground_damage_default` export로 원인별 조정 가능.
- FallingBlock 신호를 `hit_player`, `reached_ground`로 표준화하고, 기존 `touched_player`, `hit_ground`는 하위 호환 유지.
- 블록당 이벤트 중복 방지를 위해:
  - FallingBlock 내부 `_player_hit_processed`, `_ground_hit_processed` 사용
  - GameFlow에서 `source_id:cause` dedupe 추가
- 접촉 누락 보강을 위해 FallingBlock 씬에 `TouchSensor(Area2D)` 추가.
