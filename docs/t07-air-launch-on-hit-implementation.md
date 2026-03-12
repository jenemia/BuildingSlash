# T07 확장: 낙하 적 피격 시 공중 띄우기(Launch) 구현

## 1) Goal and background
- 목표: 플레이어가 떨어지는 적(`FallingBlock`, `FallingEnemy`)을 타격했을 때, 대상이 위로 튀었다가 기존 중력으로 다시 떨어지는 launch 반응을 부여한다.
- 배경: 타격 손맛 강화 + 판정 피드백 강화. T07 필살기/공중 전투 감각과도 잘 맞는다.

## 2) Scope (In/Out)
### In
- 일반 공격 피격 시 대상에 상향 초기 속도 적용
- launch 후에는 기존 gravity를 그대로 유지해 다시 자유낙하로 복귀
- `FallingBlock`, `FallingEnemy` 둘 다 동일한 launch 규약 적용
- 최소 시각 피드백(위로 튀는 움직임 자체)

### Out
- 복잡한 넉백 상태머신/스턴 시스템
- 중력 방향 반전, anti-gravity 상태
- 파티클/사운드 고도화
- 적 AI 행동 변화

## 3) User scenarios
1. 플레이어가 낙하 적을 때리면 적이 잠깐 위로 튄다.
2. `FallingBlock`과 `FallingEnemy`가 모두 같은 방식으로 위 반응을 보인다.
3. 반복 타격 시 비정상 무한 상승/폭주가 발생하지 않는다.
4. 치명타로 사망한 적은 launch 없이 즉시 기존 제거 흐름을 따른다.

## 4) Feature list with priorities
- P0: `take_hit` 경유 시 launch 적용
- P0: launch 힘 clamp(최소/최대) 적용
- P0: 치명타/사망 시 launch 생략
- P1: `FallingBlock` tier별 저항값 연동(soft/normal/hard)
- P1: `FallingEnemy` 기본 launch 튜닝 export
- P1: 디버그 로그 토글

## 5) Data and model
- `falling_block.gd`
  - `launch_up_force` (기본 상향 힘)
  - `launch_min_force`
  - `launch_max_force`
  - `launch_resistance` (0~1, 높을수록 덜 뜸)
  - `launch_cooldown` (연속히트 과도 반응 방지)
- `falling_enemy.gd`
  - `launch_up_force` (기본 상향 힘)
  - `launch_min_force`
  - `launch_max_force`
  - `launch_resistance` (0~1, 높을수록 덜 뜸)
  - `launch_cooldown` (연속히트 과도 반응 방지)
- 실제 적용식(확정):
  - `force = clamp(launch_up_force * (1.0 - launch_resistance), launch_min_force, launch_max_force)`
  - `velocity.y = minf(velocity.y, -force)`
  - 다음 프레임부터는 기존 gravity가 다시 하강 방향으로 누적된다.

## 6) API / events / flow
- 기존 공격 흐름 유지: `player_attack.gd -> target.take_hit(damage, source)`
- `falling_block.gd::take_hit()` 및 `falling_enemy.gd::take_hit()` 내부에서:
  1) 데미지 처리
  2) HP가 남아 있으면 launch 적용
  3) launch cooldown 갱신
  4) 이후 일반 중력 처리로 자연 하강 복귀

## 7) UI/UX
- 별도 UI 없음.
- 체감 검증: 피격 순간 적이 위로 반응하는지 관찰.

## 8) Error and edge cases
- 과도 launch로 화면 이탈 증가 가능 → max clamp + despawn 규칙 유지
- 연타 시 떨림/진동 → launch cooldown 적용
- 바닥 근접 충돌 프레임에서 반응 누락 → 데미지 직후 즉시 적용
- 치명타 프레임 launch 중복 → 사망 시 즉시 `queue_free()` 또는 기존 파괴 흐름 우선

## 9) Definition of Done
- `FallingBlock` 비치명타 적중 시 위로 튄 뒤 다시 하강
- `FallingEnemy` 비치명타 적중 시 동일한 launch 반응 확인
- 치명타 적중 시 launch 떨림 없이 기존 제거 흐름 유지
- headless 로드 성공, 공격/필살기 기존 계약 유지

## 10) Constraints
- Godot 4.x, 현재 `CharacterBody2D` 기반 유지
- 기존 T07 구조(attack/special) 깨지지 않게 최소 변경
- `player_controller.gd`의 contact bounce 로직은 이번 범위에서 수정하지 않음

---

## Ticketed execution plan

### T07-L1. 적 공통 launch 규약 정리
- Changed files: `scripts/world/falling_block.gd`, `scripts/world/falling_enemy.gd`
- 구현: `take_hit` 생존 시 상향 속도 적용, 치명타 시 launch 생략
- AC: `FallingBlock`, `FallingEnemy` 모두 타격 시 즉시 위로 반응

### T07-L2. launch 파라미터/중력 복귀 확정
- Changed files: `scripts/world/falling_enemy.gd`, `docs/t07-air-launch-on-hit-implementation.md`
- 구현: launch clamp/cooldown과 "상향 초기 속도 + 기존 gravity 유지" 정책 확정
- AC: 중복 launch 폭주 없이 자연 하강 복귀

### T07-L3. 안정화/검증
- Changed files: `docs/t07-air-launch-on-hit-implementation.md`, `PROTOTYPE_TRACKER.md`
- 구현: headless 검증 기록, 수동 테스트 체크리스트 정리
- AC: headless 로드 통과 + 수동 검증 항목 문서화

---

## Verification checklist
- Headless: `Godot --headless --path /Users/sean/Documents/BuildingSlash --quit` 성공
- Manual 1: `FallingBlock` 비치명타 적중 시 즉시 위로 튄 뒤 다시 하강
- Manual 2: `FallingEnemy` 비치명타 적중 시 동일한 launch 반응 확인
- Manual 3: 연속 공격 시 cooldown 동안 launch가 과도하게 중첩되지 않음
- Manual 4: 치명타 적중 시 launch 떨림 없이 기존 제거 흐름 유지
