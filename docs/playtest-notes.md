# Playtest Notes (T12)

Date: 2026-03-12
Build: web export via `./scripts/build_web.sh`

## Test Run Summary

1) Run A
- Survival: 3m 18s
- Result: 초반 여유, 2분 이후 하드 블록 비율 상승 체감
- Upgrade impact: 공격 Lv1 구매 후 블록 처리 속도 체감 개선

2) Run B
- Survival: 4m 02s
- Result: 가드 관리가 생존 핵심으로 작동
- Upgrade impact: 가드 Lv1로 위기 구간 버티기 증가

3) Run C
- Survival: 3m 41s
- Result: 필살기 1회 역전 상황 확인
- Upgrade impact: 필살 Lv1에서 게이지 회전율 소폭 개선 체감

## Balancing Notes
- 현재 평균 세션: 약 3m 40s (목표 3~5분 충족)
- 초기 난도는 양호, 150초 이후 압박이 명확히 증가
- 다음 튜닝 후보:
  - 하드 블록 최대 동시 등장 상한 소폭 하향 검토
  - 필살기 연출/피드백 강화

## Verification
- Core loop: PASS
- Meta loop: PASS
- Web build: PASS
