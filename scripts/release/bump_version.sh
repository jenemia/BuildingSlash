#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VERSION_FILE="${ROOT_DIR}/VERSION.txt"
PART="${1:-patch}"

if [[ ! -f "${VERSION_FILE}" ]]; then
  echo "0.1.0" > "${VERSION_FILE}"
fi

CURRENT="$(tr -d '[:space:]' < "${VERSION_FILE}")"
IFS='.' read -r MAJOR MINOR PATCH <<< "${CURRENT}"
MAJOR=${MAJOR:-0}
MINOR=${MINOR:-1}
PATCH=${PATCH:-0}

case "${PART}" in
  major)
    ((MAJOR+=1)); MINOR=0; PATCH=0 ;;
  minor)
    ((MINOR+=1)); PATCH=0 ;;
  patch)
    ((PATCH+=1)) ;;
  *)
    echo "Usage: $0 [major|minor|patch]" >&2
    exit 1 ;;
esac

NEXT="${MAJOR}.${MINOR}.${PATCH}"
echo "${NEXT}" > "${VERSION_FILE}"
echo "${NEXT}"
