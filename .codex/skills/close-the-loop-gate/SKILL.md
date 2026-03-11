---
name: close-the-loop-gate
description: |
  Perform automated Full Gate validation: lint, build, and test. Use for "풀 게이트", "close the loop", "전체 검증", 
  "lint/build/test", "gate 통과" and similar phrases in user requests.
---

# Close the Loop Gate Skill

## Purpose
This skill defines how to **verify and validate code changes automatically** until the Full Gate passes.  
Agents SHOULD use this when the user asks to validate code by running linting, building and testing without bypassing checks.

## When to Use
- User requests **Full Gate 통과** or **전체 검증**
- Mentions of **lint/build/test**
- “검증해줘”, “배포 전 검증”, “Gate 실행”
- Similar phrases that imply running automated verification

## Requirements
- The skill MUST run commands in the order:
  1) Quick Gate: lint + build/type check
  2) Full Gate: Quick Gate + all tests
- Must collect evidence of each step’s success or failure
- Must **NOT skip lint**, disable tests, or lower thresholds

## Workflow
1. **Detect project scripts**
   - If project defines `gate:quick` and `gate:full` scripts in package.json or Makefile targets, use those.
   - Otherwise infer commands based on project language conventions (e.g., npm/pnpm/yarn, pytest, cargo, go test, etc.)
2. **Run Quick Gate**
   - Execute the Quick Gate commands
   - If failure:
     - Extract the first failing cause
     - Suggest localized fix
     - Rerun Quick Gate
3. **Run Full Gate**
   - Run Full Gate commands only after Quick Gate passes
   - If failure:
     - Isolate root cause (compile/test/test suite)
     - Propose minimal fix
     - Rerun Full Gate
4. **Evidence Collection**
   - Save key outputs for both gates
   - Summarize success/failure succinctly

## Expected Output Structure
The agent should produce an **artifact file** (e.g. `artifacts/gate-report.md`) or a structured summary with:

- Commands run
- Pass/Fail per gate
- Key errors (if any)
- Fix suggestions
- Final Gate proof

## Constraints
- No disabling of static analysis, tests, hooks
- No skipping of test suites
- Changes must be minimal and localized
- Provide clear rationale for every change or suggestion

## Examples of Trigger Phrases
- “풀 게이트 실행해”
- “close the loop”
- “전체 검증”
- “lint, build 그리고 test까지 검증”
