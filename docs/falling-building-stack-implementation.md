# Falling Building Stack + Upward Attack Implementation

## 1) Goal and background
- Goal: 화면을 크게 차지하는 단일 낙하 적(건물형)을 구현하고, 플레이어가 위 방향 공격으로 층을 하나씩 깎는 구조를 만든다.
- Reference intent: 예시 이미지처럼 거대한 적이 하늘에서 1개씩 떨어지고, 처치 과정에서 층 수가 줄어드는 시각 피드백 제공.

## 2) Scope
### In Scope
- 단일 대형 적 프리팹 1종 (건물)
- 층 수 기반 HP(예: 10층 = HP 10)
- 피격 시 1층 감소(시각 크기/층수 반영)
- 화면 상단에서 1개씩만 스폰
- 플레이어 공격 방향을 상향(위쪽)으로 전환

### Out of Scope
- 다양한 건물 타입/패턴
- 고급 파편 이펙트
- 보스 패턴 AI

## 3) Core design
- `BuildingEnemy`는 `max_floors`, `current_floors`를 가진다.
- `take_hit(1)` 호출마다 `current_floors -= 1`.
- 층 감소 시:
  - 충돌 영역 높이 감소
  - 시각 노드 높이 감소(임시 폴리곤/스프라이트 마스킹)
- `current_floors == 0`이면 제거.

## 4) Player attack direction change
- 기존: 좌/우 전방 근접 판정
- 변경: 플레이어 머리 위쪽에 고정된 상향 히트박스
- 모바일 공격 버튼은 그대로 사용 가능(방향만 상향 판정)

## 5) Spawn flow
- 스포너는 생존 중인 건물 적이 없을 때만 다음 건물 1개 생성
- 스폰 위치: 화면 상단 중앙 근처
- 낙하 속도: 초반 완만, 추후 티켓에서 난이도 곡선 추가

## 6) Ticket plan

### T2-R1. 상향 공격 판정으로 전환
- Files:
  - `scripts/player/player_attack.gd`
  - `scenes/player/Player.tscn`
- Acceptance:
  - Z/모바일 공격 시 머리 위 히트박스만 활성화

### T4-R1. 건물형 낙하 적 기본 구현
- Files:
  - `scenes/world/BuildingEnemy.tscn` (new)
  - `scripts/world/building_enemy.gd` (new)
- Acceptance:
  - 10층 기본값, 피격 시 층 1 감소

### T4-R2. 단일 개체 스폰 제어
- Files:
  - `scripts/world/falling_enemy_spawner.gd` (or rename to `building_spawner.gd`)
  - `node_2d.tscn`
- Acceptance:
  - 화면에 항상 건물 적 최대 1개

### T5-R1. 층 감소 시각 반영
- Files:
  - `scripts/world/building_enemy.gd`
  - `scenes/world/BuildingEnemy.tscn`
- Acceptance:
  - 맞을 때마다 외형이 한 층씩 줄어듦이 명확히 보임

## 7) Risks and choices
1. 시각 구현 방식
- A) 폴리곤/Rect로 임시 계단형 층 구현 (빠름)
- B) 실제 건물 스프라이트를 층별 프레임으로 분리 (퀄리티 높음)
- 추천: **A로 먼저 구현**, 이후 B로 교체

2. 충돌체 갱신 방식
- A) 층 감소마다 CollisionShape 높이 재계산
- B) 고정 충돌 + 내부 HP만 감소
- 추천: **A** (보이는 크기와 판정 일치)

## 8) Definition of done
- 건물 적이 상단에서 1개씩만 떨어짐
- 플레이어 상향 공격으로 층이 1개씩 감소
- 10회 타격 시 완전 파괴
- 시각/판정이 층 감소와 일치
