# T04 낙하 건물(블록) 구현 점검 및 진행 계획

## 현재 작업물 점검 결과

✅ 2026-03-12 반영: `BuildingEnemy` 계열을 `FallingBlock` 계열로 리네임 완료.

이미 T04 관련 선행 구현이 존재함:
- 씬
  - `scenes/world/BuildingEnemy.tscn` (건물형 낙하 오브젝트)
  - `scenes/world/FallingEnemy.tscn` (소형 낙하 오브젝트)
- 스크립트
  - `scripts/world/building_enemy.gd`
  - `scripts/world/falling_enemy.gd`
  - `scripts/world/falling_enemy_spawner.gd`
- 메인 연결
  - `node_2d.tscn`에 `EnemySpawner`가 `BuildingEnemy.tscn`을 생성 중

즉, 티켓명은 T04(낙하 블록)인데 실제 구현은 `BuildingEnemy` 명명으로 진행된 상태.

## Scope (이번 T04에서 마무리)

### In
1. 기존 구현을 T04 기준으로 정합성 확보
2. 낙하/충돌/정리(화면 밖 정리 포함) 동작 명확화
3. 스폰 안정화(동시 개체 제한/간격)
4. T05 내구도 계층 확장을 위한 훅 유지

### Out
- 내구도 3계층 밸런싱(T05)
- 난이도 곡선 상승(T06)

## 남은 작업 티켓 (T04 내부)

### T04-A. 네이밍/역할 정리
- 목적: T04 산출물과 실제 파일명 간 혼선 제거
- 변경안:
  - 옵션1) 현재 파일명 유지 + 트래커에 매핑 기록 (빠름)
  - 옵션2) `FallingBlock*`로 리네임 (정석)
- 권장: **옵션1 먼저**, T06 전 리네임 일괄 처리

### T04-B. 낙하 종료 정리 로직 추가
- 목적: 화면 아래로 벗어난 개체 자동 정리
- 대상 파일: `scripts/world/building_enemy.gd` (우선)
- 완료 기준: 바닥/화면 아래 누적 개체 없음

### T04-C. 충돌 상호작용 최소 훅 정리
- 목적: 플레이어 접촉 시 후속 시스템(T03/T07) 연결 가능한 이벤트 지점 확보
- 대상 파일: `scripts/world/building_enemy.gd`, 필요시 Player 쪽
- 완료 기준: 접촉 시 로그/시그널로 이벤트 추적 가능

### T04-D. 스폰 안정성 점검
- 목적: 과도 스폰/관통/떨림 방지
- 대상 파일: `scripts/world/falling_enemy_spawner.gd`, `node_2d.tscn`
- 완료 기준: max_alive, spawn_interval 기준으로 안정 동작

## Acceptance Criteria (T04 완료 조건)
1. 상단 스폰 후 하강이 지속적으로 동작
2. 지면 충돌 시 물리 이상(관통/폭주) 없음
3. 화면 아래 이탈 개체 정리됨
4. 스포너 파라미터로 밀도 제어 가능

## 검증 방법
- 2~3분 수동 플레이
- 씬 재시작 3회 반복
- 콘솔 에러 0건
