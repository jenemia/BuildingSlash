# T07 확장: 낙하 적 피격 시 공중 띄우기(Launch) 구현

## 1) Goal and background
- 목표: 플레이어가 떨어지는 적(블록/적)을 타격했을 때, 대상이 위로 튀는 물리 반응(launch)을 부여한다.
- 배경: 타격 손맛 강화 + 판정 피드백 강화. T07 필살기/공중 전투 감각과도 잘 맞는다.

## 2) Scope (In/Out)
### In
- 일반 공격 피격 시 대상에 상향 임펄스 적용
- 적 타입별 launch 저항(간단 스칼라) 지원
- 최소 시각 피드백(위로 튀는 움직임 자체)

### Out
- 복잡한 넉백 상태머신/스턴 시스템
- 파티클/사운드 고도화
- 적 AI 행동 변화

## 3) User scenarios
1. 플레이어가 낙하 적을 때리면 적이 잠깐 위로 튄다.
2. 약한 적은 크게 튀고, 단단한 적은 적게 튄다.
3. 반복 타격 시 비정상 무한 상승/폭주가 발생하지 않는다.

## 4) Feature list with priorities
- P0: `take_hit` 경유 시 launch 적용
- P0: launch 힘 clamp(최소/최대) 적용
- P1: 티어별 저항값 연동(soft/normal/hard)
- P1: 디버그 로그 토글

## 5) Data and model
- `falling_block.gd`에 파라미터 추가:
  - `launch_up_force` (기본 상향 힘)
  - `launch_resistance` (0~1, 높을수록 덜 뜸)
  - `launch_cooldown` (연속히트 과도 반응 방지)
- 실제 적용식(초안):
  - `applied = clamp(launch_up_force * (1.0 - launch_resistance), min_launch, max_launch)`
  - `velocity.y = min(velocity.y, -applied)`

## 6) API / events / flow
- 기존 공격 흐름 유지: `player_attack.gd -> target.take_hit(damage, source)`
- `falling_block.gd::take_hit()` 내부에서:
  1) 데미지 처리
  2) 아직 생존이면 launch 적용
  3) 쿨다운 갱신

## 7) UI/UX
- 별도 UI 없음.
- 체감 검증: 피격 순간 적이 위로 반응하는지 관찰.

## 8) Error and edge cases
- 과도 launch로 화면 이탈 증가 가능 → max clamp + despawn 규칙 유지
- 연타 시 떨림/진동 → launch cooldown 적용
- 바닥 근접 충돌 프레임에서 반응 누락 → 데미지 직후 즉시 적용

## 9) Definition of Done
- 피격 시 적이 위로 튀는 반응 확인
- 티어별로 뜨는 높이 차이 확인
- 2분 플레이 중 물리 폭주/떨림/관통 이슈 없음
- 웹 빌드 성공 및 main 푸시

## 10) Constraints
- Godot 4.x, 현재 `CharacterBody2D` 기반 유지
- 기존 T07 구조(attack/special) 깨지지 않게 최소 변경

---

## Ticketed execution plan

### T07-L1. 기본 launch 물리 적용
- Changed files: `scripts/world/falling_block.gd`
- 구현: `take_hit` 생존 시 상향 속도 적용
- AC: 타격 시 즉시 위로 반응

### T07-L2. 티어별 저항/클램프 적용
- Changed files: `scripts/world/block_data.gd`, `scripts/world/falling_block.gd`
- 구현: soft/normal/hard launch 차등
- AC: 체감 가능한 높이 차이

### T07-L3. 안정화/검증
- Changed files: (필요 시) `docs/resource-replacement-checklist.md`
- 구현: cooldown/로그/수치 조정
- AC: 2분 플레이 안정성 + 웹 빌드 통과
