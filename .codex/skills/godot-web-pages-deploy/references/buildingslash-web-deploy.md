# BuildingSlash Web Deploy Reference

## Scope

Use this reference only when deploying or verifying the web build for this repository.

## Build Entry Point

- Build script: `./scripts/build_web.sh`
- Export preset file: `./export_presets.cfg`
- Project config: `./project.godot`

## Deployment Model

- GitHub Pages serves the root of `main`.
- The web export artifacts are committed at the repository root.
- `.nojekyll` must remain present.

## Expected Root Artifacts

- `index.html`
- `index.js`
- `index.wasm`
- `index.pck`
- `index.png`
- `index.icon.png`
- `index.apple-touch-icon.png`
- `index.audio.worklet.js`
- `index.audio.position.worklet.js`

## Known Constraints

- Web export uses `renderer/rendering_method="compatibility"` in `project.godot`.
- Web export uses `threads=false` in `export_presets.cfg` to avoid GitHub Pages header limitations.
- On macOS, `scripts/build_web.sh` prefers `/Applications/Godot.app` for web export.
- If the standard Godot app is missing, the script fails and expects the user to install it or set `GODOT_BIN`.
- The script downloads export templates only when the matching version is not installed yet.

## Verification

1. Run `./scripts/build_web.sh`.
2. Check `git status --short` for the expected root export artifacts.
3. If publishing, commit and push `main`.
4. Verify the live site:
   - URL: `https://jenemia.github.io/BuildingSlash/`
   - HTML should contain `GODOT_CONFIG` or `index.js`.
5. If the live site is stale, check the GitHub Actions workflow named `pages build and deployment`.
