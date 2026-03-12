#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
VERSION_FILE="${ROOT_DIR}/VERSION.txt"
PART="${1:-patch}"

if [[ ! -f "${VERSION_FILE}" ]]; then
  echo "0.0.0" > "${VERSION_FILE}"
fi

CURRENT="$(tr -d '[:space:]' < "${VERSION_FILE}")"
IFS='.' read -r MAJOR MINOR PATCH <<< "${CURRENT}"
MAJOR=${MAJOR:-0}
MINOR=${MINOR:-0}
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

PROJECT_FILE="${ROOT_DIR}/project.godot"
if grep -q '^config/version=' "${PROJECT_FILE}"; then
  sed -i.bak "s/^config\/version=.*/config\/version=\"${NEXT}\"/" "${PROJECT_FILE}"
else
  awk -v v="${NEXT}" '
    BEGIN { in_app=0; inserted=0 }
    /^\[application\]$/ { in_app=1; print; next }
    /^\[/ {
      if (in_app && !inserted) {
        print "config/version=\"" v "\""
        inserted=1
      }
      in_app=0
      print
      next
    }
    { print }
    END {
      if (in_app && !inserted) print "config/version=\"" v "\""
    }
  ' "${PROJECT_FILE}" > "${PROJECT_FILE}.tmp" && mv "${PROJECT_FILE}.tmp" "${PROJECT_FILE}"
fi
rm -f "${PROJECT_FILE}.bak"

echo "${NEXT}"
