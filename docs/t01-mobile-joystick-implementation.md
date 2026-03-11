# T01 Mobile Joystick Implementation

## 1) Goal and background
- Goal: 모바일 웹에서 좌/우/점프 입력이 가능하도록 **좌측 원형 가상 조이스틱**을 추가한다.
- Background: 현재 키보드 입력 중심이라 모바일 터치 플레이가 불가능하다.

## 2) Scope (In/Out)
### In
- 좌측 하단 원형 조이스틱 UI
- 조이스틱 입력으로 `move_left`, `move_right`, `jump` 대체 입력 제공
- 모바일/터치 환경에서 동작

### Out
- 공격/방어/필살 버튼 (별도 티켓)
- 고급 멀티터치 제스처

## 3) User scenarios
1. 사용자가 왼쪽으로 드래그하면 캐릭터가 왼쪽으로 이동한다.
2. 사용자가 오른쪽으로 드래그하면 캐릭터가 오른쪽으로 이동한다.
3. 사용자가 위 방향으로 밀면 점프가 1회 입력된다.

## 4) Feature list with priorities
- P0: 원형 베이스 + 스틱 노브 + 드래그 입력
- P0: 좌/우 이동 축값 전달
- P0: 위쪽 입력 임계치 도달 시 점프 트리거(쿨다운 포함)
- P1: 모바일에서만 UI 표시(데스크탑 숨김 옵션)

## 5) Data and model
- 새 씬: `scenes/ui/MobileJoystick.tscn`
- 새 스크립트: `scripts/ui/mobile_joystick.gd`
- 출력 신호:
  - `move_axis_changed(axis: float)` (`-1.0 ~ 1.0`)
  - `jump_triggered()`
- 플레이어 컨트롤러 연동:
  - 키보드 axis + 조이스틱 axis 병합

## 6) Flow
1. 터치 시작(조이스틱 영역)
2. 기준점 대비 드래그 벡터 계산
3. x 성분으로 좌우 axis 산출
4. y 성분이 위 임계치 넘으면 jump 신호 1회 발생
5. 터치 종료 시 axis 0으로 복귀

## 7) Error/edge cases
- 멀티터치 시 첫 번째 터치 id 고정 필요
- 위/좌우 동시 입력에서 점프 중복 트리거 방지
- 화면 비율 따라 UI 위치가 깨지지 않도록 anchor 사용

## 8) DoD
- 모바일 브라우저에서 좌/우/점프 입력 가능
- 키보드 입력과 충돌 없이 공존
- 터치 해제 시 이동이 즉시 멈춤

## 9) Ticket plan
### T01-M1
- Purpose: 조이스틱 UI/터치 입력 구현
- Files:
  - `scenes/ui/MobileJoystick.tscn`
  - `scripts/ui/mobile_joystick.gd`
- Acceptance:
  - 드래그 시 axis 출력 정상

### T01-M2
- Purpose: 플레이어 컨트롤러 입력 병합
- Files:
  - `scripts/player/player_controller.gd`
  - `node_2d.tscn`
- Acceptance:
  - 키보드 + 터치 둘 다 정상

### T01-M3
- Purpose: 모바일 웹 확인 + 문서 갱신
- Files:
  - `docs/resource-replacement-checklist.md`
  - `PROTOTYPE_TRACKER.md` (로그)
- Acceptance:
  - 실제 모바일 웹 플레이 확인

## 10) Design decisions / tradeoffs
- 점프 입력 방식:
  - 옵션 A: 위로 밀면 점프 (요청사항 일치)
  - 옵션 B: 별도 점프 버튼
- 추천: **옵션 A 우선 구현**, 추후 B 병행 가능
