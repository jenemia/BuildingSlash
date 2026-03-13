# Block Contact Rebound Loop Implementation

## 1) Goal and background

요청 사항: 플레이어 공격으로 블록이 위로 튕겨지는 것처럼, 블록이 플레이어에 닿았을 때도 블록이 위로 튕겨 올라갔다가 다시 내려오며 재타격 가능한 루프를 만든다.

현재는 블록이 플레이어 접촉 시 피해 처리 후 계속 낙하 흐름을 유지하거나 즉시 제거되는 경향이 있어, 체감 상호작용(리듬/재도전)이 약하다.

## 2) Scope (In/Out)

### In Scope
- 블록-플레이어 접촉 시 블록 상향 반발(launch) 적용
- 반발 후 재낙하 시 재타격 가능
- 무한 다단히트/프레임당 과다히트 방지 쿨다운 정책

### Out of Scope
- 전체 전투 밸런싱 리워크
- 신규 VFX/SFX 대규모 추가
- 플레이어 피격 애니메이션 시스템 개편

## 3) User scenarios

1. 블록이 플레이어에 닿으면 플레이어 HP가 감소하고 블록이 위로 튕긴다.
2. 튕긴 블록이 다시 내려와 플레이어에 닿으면 다시 HP가 감소한다.
3. 한 번의 접촉 프레임에서 HP가 여러 번 깎이지 않는다.
4. 너무 짧은 시간 내 연속 접촉은 쿨다운으로 제한된다.

## 4) Feature list with priorities

- P0: 접촉 시 block rebound 적용
- P0: 재타격 루프 허용(1회성 플래그 제거/정책 변경)
- P0: per-block 피해 쿨다운(예: 0.25~0.4초)
- P1: 디버그 로그(접촉, 반발, 피해)

## 5) Data and model

- per block:
  - `last_player_hit_time_sec`
  - `player_hit_cooldown_sec`
  - `contact_rebound_force`

## 6) API/events/flow

- FallingBlock
  - 플레이어 접촉 감지 시
    1) 쿨다운 확인
    2) `hit_player` emit
    3) `_apply_launch()` 호출 (상향 반발)
- GameFlow
  - `hit_player` 수신 시 `apply_damage(event)` 실행
  - dedupe는 "동일 원인 영구 차단"이 아니라 "프레임/짧은 시간 중복 차단"으로 제한

## 7) UI/UX

- UI 변경 없음
- 체감: 블록이 탁- 튕겨올랐다가 다시 압박

## 8) Error and edge cases

- 천장 근처 충돌로 반발이 약해 보일 수 있음
- 플레이어 위에 블록이 낀 상태에서 떨림 다단히트 위험
- `hit_player` dedupe가 영구 키라면 재타격이 막히는 치명 이슈 가능

## 9) Definition of Done (DoD)

- [x] 블록 접촉 시 HP 감소 + 블록 상향 반발
- [x] 같은 블록 재낙하 재접촉 시 HP 재감소
- [x] 과다 다단히트 없음(쿨다운 동작)
- [x] 웹빌드 정상

## 10) Constraints

- 기존 데미지 창구(`apply_damage`) 유지
- 과도한 구조 변경 금지(최소 침습)
- 향후 원인 추가 쉬운 구조 유지

---

## Ticket plan

### T1. 재타격 정책 정리(GameFlow dedupe 조정)
- Purpose: 동일 블록의 재접촉 피해가 가능하도록 dedupe를 영구 차단에서 시간 기반 차단으로 변경
- Files: `scripts/main/game_flow.gd`
- AC: 동일 블록 재접촉 시 피해 재발생, 단 단시간 중복은 차단

### T2. 접촉 반발 적용(FallingBlock)
- Purpose: 플레이어 접촉 시 `_apply_launch()`로 상향 반발
- Files: `scripts/world/falling_block.gd`
- AC: 접촉 즉시 블록이 위로 튕김

### T3. per-block 접촉 쿨다운
- Purpose: 다단히트 폭주 방지
- Files: `scripts/world/falling_block.gd`, `scripts/main/game_flow.gd`
- AC: 붙어있는 프레임 연타 방지, 재낙하 타이밍 히트 허용

### T4. 검증/웹빌드/정리
- Purpose: 시나리오 검증 후 배포 준비
- Files: 본 문서 + 웹 산출물
- AC: DoD 체크 완료

## Status
- [x] Spec drafted
- [x] T1
- [x] T2
- [x] T3
- [x] T4

## Implementation Notes (2026-03-13)
- `GameFlow.apply_damage()` dedupe를 영구 차단에서 시간 기반 차단으로 조정 (`dedupe_window_sec`).
- `hit_player` 이벤트는 `hit_player_dedupe_window_sec`(기본 0.30s) 적용.
- FallingBlock의 플레이어 접촉 처리에서 1회성 플래그를 제거하고 `player_contact_cooldown`(기본 0.30s) 기반 재타격 허용.
- 플레이어 접촉 시 블록 `_apply_launch()`를 호출해 상향 반발 후 재낙하 루프 형성.
