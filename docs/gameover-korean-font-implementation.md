# 게임오버/메타 메뉴 한글 폰트 깨짐 대응 구현서

## 1) Goal and background
- 목표: HP 0 이후 표시되는 결과/메타 UI에서 한글이 에디터/웹 모두 동일하게 정상 렌더링되도록 보장한다.
- 배경: 기존 리소스(`Xolonium-Regular.ttf`)는 한글 글리프가 없고, 프로젝트는 시스템 fallback에 의존하고 있어 웹에서 한글 깨짐이 발생했다.

## 2) Scope (In/Out)
- In
  - Noto Sans KR 폰트를 프로젝트에 포함
  - 프로젝트 공통 UI Theme를 추가하고 기본 폰트 지정
  - Project Settings에서 공통 Theme 적용
- Out
  - 텍스트 카피 변경
  - 개별 UI 레이아웃/크기 리디자인
  - 다국어(i18n) 시스템 도입

## 3) User scenarios
- 플레이어가 게임오버 화면에서 `전투 결과`, `다시 시작`, `메타 업그레이드`를 깨짐 없이 읽는다.
- 플레이어가 메타 메뉴에서 `공격/점프/방어/필살` 텍스트를 깨짐 없이 읽는다.
- 웹 배포본에서도 동일하게 표시된다.

## 4) Feature list with priorities
- P0: 한글 글리프 포함 폰트 번들링
- P0: 공통 Theme 기본 폰트 지정
- P1: 폰트 크기 기본값 통일(가독성)

## 5) Data and model
- 신규 폰트 파일: `fonts/NotoSansKR-Regular.otf`
- 신규 Theme: `themes/ui_theme.tres`
- 프로젝트 설정: `project.godot`의 `[gui] theme/custom`

## 6) API/events/flow
- 런타임 시작 시 Project Settings의 `theme/custom`이 모든 Control 기반 UI에 적용된다.

## 7) UI/UX
- 기본 UI 폰트를 Noto Sans KR로 통일하여 한글 가독성과 플랫폼 일관성을 확보한다.

## 8) Error and edge cases
- 폰트 파일 누락 시: 기본 폰트로 fallback되어 재발 가능
- 특정 씬에서 개별 폰트 override가 있을 경우: Theme 적용이 부분 무시될 수 있음(현재 확인상 없음)

## 9) Definition of Done (DoD)
- 게임오버/메타 메뉴 한글이 깨지지 않는다.
- 웹 빌드 산출물에서 동일하게 표시된다.
- 변경 파일/설정이 저장소에 반영된다.

## 10) Constraints
- 기존 UI 구조/스크립트 로직은 변경하지 않는다.
- 폰트 적용은 공통 Theme 중심으로 최소 변경한다.

---

## Ticket Plan

### T1. Noto Sans KR 폰트 추가
- Purpose: 한글 글리프를 프로젝트에 내장
- Changed files: `fonts/NotoSansKR-Regular.otf`
- Implementation details: OFL 라이선스 공개 폰트 파일을 리포지토리에 포함
- Acceptance criteria: 파일 존재 및 Godot가 FontFile로 로드 가능
- Verification: 파일 존재 확인
- Status: DONE

### T2. 공통 UI Theme 생성 및 기본 폰트 지정
- Purpose: 플랫폼 fallback 의존 제거
- Changed files: `themes/ui_theme.tres`
- Implementation details: Theme default_font를 Noto Sans KR로 지정
- Acceptance criteria: Theme 리소스가 유효하고 default_font 지정됨
- Verification: 파일 내용 검증
- Status: DONE

### T3. 프로젝트 전역 Theme 연결
- Purpose: 결과/메타 포함 전체 Control UI에 일괄 적용
- Changed files: `project.godot`
- Implementation details: `[gui] theme/custom="res://themes/ui_theme.tres"` 설정
- Acceptance criteria: 설정값 반영
- Verification: 설정 grep 확인
- Status: DONE

## Discussion notes (결정)
- 선택지
  - A) 기존 Xolonium 유지 + fallback KR 폰트 추가
  - B) Noto Sans KR을 기본 폰트로 전역 적용
- 결정: **B안 채택** (요청사항 반영: "noto sans KR을 기본으로")
- 리스크: 영문 분위기(타이포 톤) 일부 변화 가능
- 완화: 필요 시 타이틀 전용 폰트 override를 후속 티켓으로 분리
