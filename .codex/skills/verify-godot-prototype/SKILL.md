---
name: verify-godot-prototype
description: Verify this repository's Godot prototype changes end-to-end. Use after gameplay/meta changes, before commit, or when asked to run a prototype quality check for movement/combat/spawn loop, save/meta loop, and web export readiness.
---

# Verify Godot Prototype

Run this checklist in order and report pass/fail with concrete evidence.

## 1) Workspace + change scope
- Run `git status --short --branch`.
- List changed gameplay/meta files (`scripts/`, `scenes/`, `project.godot`, `export_presets.cfg`).
- If no relevant changes exist, state that and stop.

## 2) Static sanity checks
- Confirm no obvious parse issues in changed `.gd` files:
  - Missing `extends`
  - Duplicate function names in same file
  - Broken signal method names referenced in scenes
- Confirm new scene/script paths are consistent (no stale moved paths).

## 3) Gameplay loop verification (prototype-focused)
Check whether core loop still exists and is wired:
- Player can move/jump/attack/guard.
- Falling-object spawn loop runs and difficulty can escalate.
- Combat feedback path exists (damage/parry/guard/special resource updates).
- HUD fields are bound to live values (hp/gauge/timer/score or equivalents).

Use file-level evidence (function names, signal hookups, node paths).

## 4) Meta loop verification
- Verify result/reward flow exists from run end to meta screen.
- Verify permanent-upgrade data read/write path exists.
- Verify defaults + migration-safe handling for missing save keys.

## 5) Build/export readiness
- Run `./scripts/build_web.sh`.
- If build fails, capture first actionable error and exact failing step.
- If build succeeds, verify root artifacts are refreshed:
  - `index.html`, `index.js`, `index.wasm`, `index.pck`, `.nojekyll`

## 6) Final report format
Return a compact report:
- Verdict: `PASS` / `PASS WITH WARNINGS` / `FAIL`
- Sections:
  - Scope checked
  - Gameplay loop
  - Meta loop
  - Web export
  - Risks / follow-ups
- For each failure/warning, include:
  - file path
  - why it matters in gameplay
  - minimal fix direction
