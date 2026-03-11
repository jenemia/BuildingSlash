---
name: feature-spec-discuss-ticket-flow
description: Enforce a feature-spec-first workflow for implementation requests. Use by default for feature, bug fix, refactor, optimization, and architecture-change requests. Always create or update a feature implementation markdown first, discuss concerns/choices/plan with the user, and only after explicit agreement execute tickets sequentially.
---

# Feature Spec Discuss Ticket Flow

<!-- KR: 이 스킬은 구현 요청을 바로 코딩하지 않고, '스펙 문서 -> 토론 -> 승인 -> 순차 구현' 흐름으로 고정한다. -->

## Goal

<!-- KR: 모든 구현 작업이 반드시 따를 기본 순서를 정의한다. -->
Make every implementation task follow this order:
1. Write a feature implementation markdown.
2. Discuss design quality before coding.
3. Implement tickets in order after user agreement.

## Workflow

### 1) Start with a feature implementation markdown

<!-- KR: 실제 코드 수정 전에 기능 구현 명세 문서를 먼저 작성/갱신한다. -->
Create or update one spec file before writing production code.

Recommended path pattern:
- `docs/<feature-slug>-implementation.md`

If a relevant spec already exists, update it instead of creating a duplicate.

### 2) Fill required sections

<!-- KR: 문서 품질을 일정하게 유지하기 위한 필수 섹션 체크리스트다. -->
Use these sections in the spec:
1. Goal and background
2. Scope (In/Out)
3. User scenarios
4. Feature list with priorities
5. Data and model
6. API/events/flow
7. UI/UX (if any)
8. Error and edge cases
9. Definition of Done (DoD)
10. Constraints (coding rules, comment language, folder layout, libraries, prohibitions)

### 3) Define ticketed execution plan

<!-- KR: 구현 단위를 T1, T2처럼 쪼개고 각 티켓의 완료 조건을 명시한다. -->
Add ordered tickets (`T1`, `T2`, `T3`...) in the spec.
For each ticket, define:
1. Purpose
2. Changed files
3. Implementation details
4. Acceptance criteria
5. Verification method

### 4) Run design discussion before coding

<!-- KR: 구현 전에 리스크/선택지/트레이드오프를 사용자와 합의해 재작업 비용을 줄인다. -->
Before implementation, explicitly discuss:
1. Concerns and risks
2. Design decisions that require user choice
3. Tradeoffs by option
4. Recommended option and rationale
5. Ticket execution order

Pause for user feedback and refine the plan.

### 5) Wait for explicit go-ahead

<!-- KR: 사용자의 명시적 승인 전에는 코딩을 시작하지 않는다. -->
Start coding only after explicit user confirmation (examples: `start`, `go`, `begin tickets`).

### 6) Execute tickets sequentially

<!-- KR: 티켓은 선언된 순서대로 하나씩 처리하고, 매 티켓마다 검증과 상태 업데이트를 수행한다. -->
Implement one ticket at a time in declared order.

After each ticket:
1. Run relevant checks/tests.
2. Update ticket status in the spec.
3. Report result and next ticket.

### 7) Close the loop

<!-- KR: 전체 구현 후 최종 검증을 실행하고 문서/보고를 마무리한다. -->
After all tickets:
1. Run final verification commands appropriate to the repository.
2. Update the spec with final status and residual risks.
3. Share concise completion report with changed files and verification outcome.

## Operating Rules

<!-- KR: 이 스킬의 운영 원칙. 사용자가 명시적으로 생략을 요청하지 않는 한 기본 규칙으로 적용한다. -->
1. Treat this as default behavior for implementation-related requests unless the user explicitly asks to skip the spec/discussion phase.
2. Prefer practical tradeoff discussion over long theory.
3. Keep the spec as the single source of truth for ticket order and progress.
4. Avoid parallel ticket implementation unless the user explicitly requests parallelization.

