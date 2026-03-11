---
name: verify-implementation
description: |
  Run all registered verify skills sequentially and produce an integrated verification report.
  Use after implementing features, before PR, or during review.
disable-model-invocation: true
argument-hint: "[optional: specific verify skill name]"
---

# Integrated Verification Runner

<!-- KR: 이 스킬은 '모든 verify-* 스킬'을 순차 실행해 통합 보고서를 만듭니다. Full Gate(lint/build/test)와는 별개로, 프로젝트 규칙(verify 스킬)을 종합 점검할 때 씁니다. -->

## Goal

Run all registered `verify-*` skills in sequence:

- Execute each skill’s Workflow checks
- Apply each skill’s Exceptions to avoid false positives
- Report issues with fix guidance
- Optionally apply fixes (with user approval) and re-verify impacted skills

<!-- KR: 목적은 "검증 스킬 체계"를 실제로 돌려서 규칙 준수 여부를 확인하는 것입니다. -->

## When to run

- After implementing a new feature
- Before PR/merge
- During code review
- Periodic audits for codebase invariants

---

## Workspace discovery (NO absolute paths)

This skill must work in:
- Windows + VS Code Codex
- WSL + OpenClaw

So **do not use absolute paths**. Always discover paths by walking up from the current working directory.

### Skills root discovery

Search upwards for one of these skill roots (priority order):

1) `.claude/skills`  
2) `.agents/skills`  
3) `.codex/skills`  

Stop at filesystem root.

<!-- KR: 레포/환경마다 스킬 위치가 다르므로, 상위 탐색으로 skills root를 찾습니다. -->

**Bash helper (conceptual):**
```bash
find_skills_root() {
  dir="."
  while [ "$dir" != "/" ]; do
    if [ -d "$dir/.claude/skills" ]; then echo "$dir/.claude/skills"; return 0; fi
    if [ -d "$dir/.agents/skills" ]; then echo "$dir/.agents/skills"; return 0; fi
    if [ -d "$dir/.codex/skills" ]; then echo "$dir/.codex/skills"; return 0; fi
    dir="$(cd "$dir/.." && pwd)"
  done
  return 1
}
