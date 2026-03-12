# 확인용 체크리스트 (임시 리소스 → 실제 리소스 교체)

현재 T01은 **플레이 감각 검증 우선**으로 임시 리소스를 사용했다.
아래를 나중에 실제 아트/연출로 교체하면 된다.

## 1) 플레이어 비주얼 교체
- [ ] 파일: `scenes/player/Player.tscn`
- [ ] 현재 임시: `BodyVisual(Polygon2D)`
- [ ] 교체 대상:
  - [ ] `AnimatedSprite2D` 또는 `Sprite2D`
  - [ ] 실제 스프라이트 시트(대기/이동/점프)
- [ ] 확인 포인트:
  - [ ] 콜라이더(`CollisionShape2D`) 크기와 스프라이트 체형이 맞는지
  - [ ] 원점(pivot) 때문에 착지 시 발이 땅에 박히지 않는지

## 2) 바닥(지형) 임시 도형 교체
- [ ] 파일: `node_2d.tscn`
- [ ] 현재 임시: `GroundVisual(Polygon2D)`
- [ ] 교체 대상:
  - [ ] 타일맵(`TileMap`) 또는 실제 지면 스프라이트
- [ ] 확인 포인트:
  - [ ] `Ground/CollisionShape2D`와 실제 보이는 지면 높이 일치

## 3) 카메라 튜닝
- [ ] 파일: `node_2d.tscn` (`Camera2D`)
- [ ] 현재 임시: 고정 오프셋
- [ ] 교체/튜닝 대상:
  - [ ] 드래그 마진
  - [ ] 경계 제한(limit)
  - [ ] 스무딩(smoothing)
- [ ] 확인 포인트:
  - [ ] 점프 시 화면 멀미 없는지
  - [ ] 낙하 블록이 들어올 상단 시야가 충분한지

## 4) 입력맵 확장
- [ ] 파일: `project.godot`
- [ ] 현재 등록: `move_left(A)`, `move_right(D)`, `jump(Space)`, `attack(J)`
- [ ] 추가 권장:
  - [ ] 방향키(←, →)
  - [ ] 게임패드 축/버튼
  - [ ] 추후 방어/필살 액션 (`guard`, `special`)

## 5) 물리 수치 밸런싱(임시값 정리)
- [ ] 파일: `scripts/player/player_controller.gd`
- [ ] 현재 임시값:
  - `move_speed=260`
  - `accel=1800`
  - `decel=2200`
  - `jump_velocity=-420`
  - `max_fall_speed=980`
- [ ] 튜닝 체크:
  - [ ] 방향 전환 시 미끄러짐 과다 여부
  - [ ] 점프 높이/체공 시간 적절성
  - [ ] 낙하속도 체감이 과도하지 않은지

## 6) 모바일 조이스틱/공격버튼(임시 도형) 교체/튜닝
- [ ] 파일: `scenes/ui/MobileJoystick.tscn`, `scripts/ui/mobile_joystick.gd`
- [ ] 현재 임시: 코드 드로잉 원형 조이스틱 + 우하단 공격버튼(`draw_circle`)
- [ ] 1차 프리셋(적용됨):
  - `base_radius=172`
  - `knob_radius=70`
  - `left_margin=188`
  - `bottom_margin=190`
  - `deadzone=0.18`
  - `jump_threshold=0.62`
  - `attack_button_radius=68`
  - `attack_right_margin=128`
  - `attack_bottom_margin=156`
- [ ] 교체 대상:
  - [ ] 실제 UI 스프라이트(베이스/노브/공격버튼)
  - [ ] 해상도별 스케일 프리셋
- [ ] 확인 포인트:
  - [ ] 좌/우 입력 민감도(deadzone) 적정
  - [ ] 위로 밀기 점프 임계치(jump_threshold) 적정
  - [ ] 공격버튼 위치/크기가 엄지 터치에 맞는지
  - [ ] 모바일 웹에서만 보이고 데스크톱에서는 숨김 유지
  - [ ] 멀티터치 시 오동작 없음

## 7) T02 공격 리소스 교체 포인트
- [ ] 파일: `scenes/player/Player.tscn`, `scripts/player/player_attack.gd`
- [ ] 현재 임시: `AttackDebugVisual(Polygon2D)` + 단일 사각 판정
- [ ] 교체 대상:
  - [ ] 공격 애니메이션(무기 스윙/타격 프레임)
  - [ ] 히트 이펙트(스파크/슬래시)
  - [ ] 공격 사운드 1종
- [ ] 확인 포인트:
  - [ ] 보이는 공격 타이밍과 실제 판정 타이밍 일치
  - [ ] 좌/우 전환 시 판정 위치 반전 정상
  - [ ] 연타 시 쿨다운 동작이 체감상 자연스러운지

## 8) 더미 적(임시 리소스) 교체
- [ ] 파일: `scenes/world/DummyTarget.tscn`, `scripts/world/dummy_target.gd`, `node_2d.tscn`
- [ ] 현재 임시: 단색 사각형 + 단순 HP 감소 후 제거
- [ ] 교체 대상:
  - [ ] 실제 적 프리팹(애니메이션/피격반응)
  - [ ] 적별 HP/피격/사망 연출
  - [ ] (필요 시) 허트박스/히트박스 분리
- [ ] 유지 권장 인터페이스:
  - [ ] `take_hit(damage, source)`
- [ ] 확인 포인트:
  - [ ] 한 번의 공격에서 대상 중복 타격 과다 발생 없음
  - [ ] 실제 적 콜라이더와 공격 판정의 체감 일치

## 9) T01+T02 완료 직전 최종 확인
- [ ] 2분 이상 플레이 시 입력 누락/오작동 없음
- [ ] 공중 재점프 없음
- [ ] 착지 안정적(경사/코너 떨림 최소)
- [ ] 모바일 웹에서 조이스틱으로 좌/우/점프 가능
- [ ] 공격 입력/판정/쿨다운 정상
- [ ] `PROTOTYPE_TRACKER.md`의 T01/T02 acceptance criteria 충족
