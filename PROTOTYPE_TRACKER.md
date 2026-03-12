# BuildingSlash 인게임 프로토타입 작업 티켓 & 진행 체크리스트

업데이트 규칙
- 티켓 상태: `TODO` / `IN_PROGRESS` / `BLOCKED` / `DONE`
- 작업 시작 시: 상태를 `IN_PROGRESS`로 변경
- 막히면: 상태 `BLOCKED` + Blocker 메모 작성
- 완료 시: 체크박스 + 상태 `DONE` + 완료일 기록

---

## A. 작업 티켓 (Backlog)

### T01. 플레이어 기본 조작 구현
- 상태: DONE (2026-03-12)
- 목표: 좌/우 이동, 점프, 중력/착지
- 산출물:
  - `scripts/player/player_controller.gd`
  - (필요 시) `scenes/player/Player.tscn`
- 완료 기준:
  - 키 입력에 따라 안정적으로 이동/점프
  - 바닥 착지 판정 정상

### T02. 공격 시스템(근접 1종) + 히트 판정
- 상태: IN_PROGRESS
- 목표: 공격 입력 시 히트박스 생성, 블록 타격
- 산출물:
  - `scripts/player/player_attack.gd`
- 완료 기준:
  - 공격 1회당 타격 1회 처리
  - 피격 시 블록 HP 감소

### T03. 방어 시스템 + 방어 게이지
- 상태: IN_PROGRESS
- 목표: 방어 입력 중 피해 감소/시간 벌기 + 게이지 소모
- 산출물:
  - `scripts/player/player_guard.gd`
- 완료 기준:
  - 방어 중 게이지 감소
  - 게이지 0이면 방어 비활성

### T04. 낙하 건물(블록) 기본 오브젝트
- 상태: DONE (2026-03-12)
- 목표: 상단 스폰 후 하강, 플레이어/지면 상호작용
- 산출물:
  - `scenes/world/FallingBlock.tscn`
  - `scripts/world/falling_block.gd`
- 완료 기준:
  - 정상 낙하 및 충돌 처리

### T05. 내구도 3계층(약/중/강) + 시각 구분
- 상태: DONE (2026-03-12)
- 목표: 블록 타입별 HP/색상/파괴 시간 차등
- 산출물:
  - `scripts/world/block_data.gd` 또는 리소스 파일
- 완료 기준:
  - 플레이어가 시각적으로 내구도 구분 가능

### T06. 스포너 + 난이도 상승 곡선
- 상태: DONE (2026-03-12)
- 목표: 시간 경과에 따라 낙하 속도/강한 블록 비율 상승
- 산출물:
  - `scripts/world/spawner.gd`
- 완료 기준:
  - 3~5분 플레이에서 난이도 상승 체감

### T07. 필살기 게이지 + 필살기 1종
- 상태: TODO
- 목표: 전투 중 게이지 충전, 발동 시 광역 파괴/역전
- 산출물:
  - `scripts/player/player_special.gd`
- 완료 기준:
  - 게이지가 찼을 때만 발동 가능
  - 위기 상황 역전 체감 가능

### T08. 전투 HUD 구성
- 상태: TODO
- 목표: HP, 방어게이지, 필살게이지, 생존시간/점수 표시
- 산출물:
  - `scenes/ui/CombatHUD.tscn`
  - `scripts/ui/combat_hud.gd`
- 완료 기준:
  - 전투 핵심 정보가 한눈에 보임

### T09. 전투 결과창 + 자원 지급
- 상태: TODO
- 목표: 생존시간/파괴량 기반 재화 지급
- 산출물:
  - `scenes/ui/ResultPanel.tscn`
  - `scripts/meta/reward_calculator.gd`
- 완료 기준:
  - 전투 종료 후 재화 획득 로직 동작

### T10. 영구 업그레이드 4종 + 저장/불러오기
- 상태: TODO
- 목표: 메타 성장(공격/점프/방어/필살 충전)
- 산출물:
  - `scenes/meta/MetaMenu.tscn`
  - `scripts/meta/meta_progression.gd`
  - `scripts/meta/save_data.gd`
- 완료 기준:
  - 업그레이드 구매 후 다음 판에 수치 반영
  - 재실행 후 데이터 유지

### T11. 게임 루프 연결 (전투↔메타↔재시작)
- 상태: TODO
- 목표: 한 판 진행 후 메타 투자, 즉시 재도전
- 산출물:
  - `scenes/Main.tscn`
  - `scripts/main/game_flow.gd`
- 완료 기준:
  - 루프가 끊김 없이 순환

### T12. 플레이테스트 패스 + 밸런스 1차
- 상태: TODO
- 목표: 세션 길이/압박감/성장 체감 조정
- 산출물:
  - `docs/playtest-notes.md`
- 완료 기준:
  - 평균 3~5분 세션
  - 업그레이드 1~2개만으로도 체감 개선

---

## B. 진행 체크리스트 (실시간 추적)

### 마일스톤 M1 - 전투 코어 (T01~T06)
- [x] T01 플레이어 기본 조작
- [ ] T02 공격 + 히트 판정
- [ ] T03 방어 + 방어 게이지
- [x] T04 낙하 블록
- [x] T05 내구도 3계층
- [x] T06 스포너/난이도 상승

### 마일스톤 M2 - 역전/가시화 (T07~T08)
- [ ] T07 필살기 게이지 + 필살기
- [ ] T08 전투 HUD

### 마일스톤 M3 - 메타 성장 루프 (T09~T11)
- [ ] T09 결과창 + 자원 지급
- [ ] T10 영구 업그레이드 + 저장
- [ ] T11 전투↔메타 루프 연결

### 마일스톤 M4 - 밸런스/검증 (T12)
- [ ] T12 플레이테스트 + 밸런스 1차

---

## C. Blocker / 이슈 로그

- (비어있음)

---

## D. 최신 상태 스냅샷

- 전체 티켓: 12
- 완료: 4
- 진행중: 2
- 막힘: 0
- 미착수: 6
- 마지막 업데이트: 2026-03-12

---

## E. 마일스톤별 DONE 검증 게이트

공통 규칙
- 마일스톤을 `DONE`으로 바꾸기 전에 `verify-godot-prototype` 체크를 실행한다.
- 최소 증거를 `docs/playtest-notes.md` 또는 본 파일 하단에 기록한다.
- 증거 없는 완료 처리 금지.

### M1 DONE 조건 (전투 코어)
- T01~T06 체크박스 모두 완료
- 플레이 루프 증거:
  - 이동/점프/공격/방어 입력 동작 확인
  - 낙하 블록 스폰 + 난이도 상승 확인
- `verify-godot-prototype` 결과:
  - Gameplay loop 섹션 `PASS` 또는 `PASS WITH WARNINGS`

### M2 DONE 조건 (역전/가시화)
- T07~T08 체크박스 모두 완료
- 플레이 루프 증거:
  - 필살기 게이지 충전/발동 확인
  - HUD 수치 실시간 반영 확인
- `verify-godot-prototype` 결과:
  - Gameplay loop + HUD 관련 경고만 허용(치명 실패 불가)

### M3 DONE 조건 (메타 성장 루프)
- T09~T11 체크박스 모두 완료
- 메타 루프 증거:
  - 전투 종료 → 보상 지급
  - 업그레이드 구매 후 다음 판 반영
  - 저장/재실행 후 데이터 유지
- `verify-godot-prototype` 결과:
  - Meta loop 섹션 `PASS` 필수

### M4 DONE 조건 (밸런스/최종 검증)
- T12 체크 완료
- 밸런스 증거:
  - 평균 세션 3~5분 (최소 3회 테스트 로그)
  - 업그레이드 1~2개에서 체감 개선 기록
- `verify-godot-prototype` 결과:
  - 최종 Verdict `PASS` 또는 `PASS WITH WARNINGS`
- 웹 빌드 증거:
  - `./scripts/build_web.sh` 성공
  - 주요 산출물 갱신 확인 (`index.html`, `index.js`, `index.wasm`, `index.pck`, `.nojekyll`)

---

## F. 검증 실행 로그 (간단 기록)

- 2026-03-12 08:05 | 대상: T01(로컬 사전검증) | 결과: PASS | Godot headless 실행(`--headless --path ... --quit`) 정상 종료, 입력/씬/스크립트 로드 에러 없음
- 2026-03-12 08:20 | 대상: T01-모바일조이스틱 확장 | 결과: PASS | 좌측 원형 조이스틱 추가(좌/우/위점프), Player 신호 연동 완료
- 2026-03-12 10:16 | 대상: T04(낙하 블록) | 결과: PASS | BuildingEnemy 계열을 FallingBlock으로 리네임, out-of-bounds 정리 + player 접촉 시그널 훅 + 스포너 그룹 기준 정리, 웹 빌드 성공
- 2026-03-12 10:45 | 대상: T05(내구도 3계층) | 결과: PASS | block_data 추가, SOFT/NORMAL/HARD HP·색상 분리, take_damage/break_block 도입, 스포너 tier 주입 준비, 웹 빌드 성공
- 2026-03-12 11:07 | 대상: T06(스포너 곡선) | 결과: PASS | 시간 경과 기반 스폰 간격 감소 + 동시 개체수 증가 + tier 가중치(soft→hard) 이동 적용
- YYYY-MM-DD HH:mm | 대상: Mx | 결과: PASS/PASS WITH WARNINGS/FAIL | 메모
