---
name: godot-web-pages-deploy
description: Export and publish this repository's Godot project to the web using the existing build script and root-level GitHub Pages artifacts. Use when working in this repository and the user asks to deploy, redeploy, publish, refresh, rebuild, or verify the Godot web build or GitHub Pages site.
---

# Godot Web Pages Deploy

## Overview

Use the repository's existing web export flow instead of inventing a new pipeline. Rebuild the root Pages artifacts, keep the deployment files committed on `main`, and verify the live site after pushing.

## Workflow

1. Check the repository state with `git status --short --branch`.
2. Reuse `scripts/build_web.sh` to generate the web export. Do not create a second deploy script unless the user explicitly asks for a new deployment architecture.
3. Review the generated root artifacts before committing:
   - `index.html`
   - `index.js`
   - `index.wasm`
   - `index.pck`
   - `index.png`
   - `index.icon.png`
   - `index.apple-touch-icon.png`
   - `index.audio.worklet.js`
   - `index.audio.position.worklet.js`
   - `.nojekyll`
4. If the user asked to publish, commit the generated artifacts together with any related config or doc changes and push `main`.
5. Verify the live site by requesting the published URL and checking for `GODOT_CONFIG` or `index.js` in the HTML response.

## Repository Rules

- Prefer the existing `scripts/build_web.sh` path.
- Keep GitHub Pages on the current root-of-`main` publishing model unless the user explicitly asks to change the deployment architecture.
- Keep `.nojekyll` in place so Pages serves the Godot artifacts as static files.
- Keep web export settings aligned with the repository defaults:
  - `renderer/rendering_method="compatibility"`
  - `threads=false`
- On macOS, prefer `/Applications/Godot.app` for web export.

## Verification

- Run `./scripts/build_web.sh` and confirm it completes without export errors.
- After pushing, request the live site and confirm it no longer serves the Jekyll README shell.
- If the site still serves stale content, inspect the repository's `pages build and deployment` workflow status and wait for completion before retrying the URL.

## References

Read `references/buildingslash-web-deploy.md` for repository-specific paths, the live Pages URL, known caveats, and verification commands.
