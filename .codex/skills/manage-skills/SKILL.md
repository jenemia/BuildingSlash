---
name: manage-skills
description: |
  Analyze session changes to detect verification-skill drift: uncovered changed files, stale refs, missing checks, outdated patterns.
  Dynamically discover existing skills, create/update verify skills, and maintain the project skills index (CLAUDE.md or equivalent).
disable-model-invocation: true
argument-hint: "[optional: specific skill name or focus area]"
---

# Session-based Skills Maintenance (Verification Coverage)

<!-- KR: 이 스킬은 '코드 검증 실행'이 아니라 '검증 스킬(verify-*)의 커버리지/드리프트 관리'가 목적입니다. -->

## Goal

Detect and fix verification-skill drift based on current session changes:

1. **Coverage gaps** — changed files not referenced by any `verify-*` skill  
2. **Invalid references** — skills referencing deleted/moved files  
3. **Missing checks** — new patterns/rules introduced without matching checks  
4. **Outdated patterns/values** — grep/glob/keys no longer match current codebase

<!-- KR: 변경된 코드가 '어떤 verify 스킬로 검증되는지'가 끊기면(UNCOVERED) 스킬 체계가 무너집니다. -->

## When to run

- After implementing features that introduce new patterns/rules
- Before PR/merge to ensure verification coverage stays aligned
- When validation missed issues you expected to catch
- Periodically to keep skills aligned with refactors

<!-- KR: Full Gate(lint/build/test) 통과와 별개로, verify 스킬들이 변경 영역을 제대로 커버하는지 점검할 때 사용 -->

---

## Workspace discovery (NO absolute paths)

This skill must work in:
- Windows + VS Code Codex
- WSL + OpenClaw
So **do not use absolute paths**. Always discover skills by walking up from the current working directory.

### Skills root discovery

Search upwards for one of these skill roots (in priority order):

1) `.claude/skills`  
2) `.agents/skills`  
3) `.codex/skills`  

Stop at filesystem root.

<!-- KR: 레포마다 스킬 위치가 다를 수 있으니, 현재 디렉토리에서 상위로 올라가며 스킬 루트를 찾습니다. -->

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
