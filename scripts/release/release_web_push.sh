#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PART="${1:-patch}"
MESSAGE="${2:-}"

cd "${ROOT_DIR}"

NEXT_VERSION="$("${ROOT_DIR}/scripts/release/bump_version.sh" "${PART}")"
echo "[release] bumped version -> ${NEXT_VERSION}"

"${ROOT_DIR}/scripts/build_web.sh"

git add VERSION.txt index.html index.js index.wasm index.pck index.png index.icon.png index.apple-touch-icon.png index.audio.worklet.js index.audio.position.worklet.js .nojekyll

if [[ -n "${MESSAGE}" ]]; then
  git commit -m "chore(release): v${NEXT_VERSION} - ${MESSAGE}"
else
  git commit -m "chore(release): v${NEXT_VERSION}"
fi

git push origin main

echo "[release] done: v${NEXT_VERSION} pushed to origin/main"
