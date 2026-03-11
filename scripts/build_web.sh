#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_PREFIX="${OUTPUT_PREFIX:-index}"
GODOT_BIN="${GODOT_BIN:-}"
GODOT_TAG="${GODOT_TAG:-}"
GODOT_TEMPLATE_VERSION="${GODOT_TEMPLATE_VERSION:-}"
CACHE_DIR=""
DOWNLOAD_DIR=""
TEMPLATE_DIR=""
STANDARD_APP_BIN=""

log() {
  printf '[build_web] %s\n' "$1"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

detect_platform() {
  case "$(uname -s)" in
    Darwin)
      STANDARD_APP_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
      ;;
    Linux)
      ;;
    *)
      printf 'Unsupported platform: %s\n' "$(uname -s)" >&2
      exit 1
      ;;
  esac
}

resolve_godot_bin() {
  if [ -n "${GODOT_BIN}" ] && [ -x "${GODOT_BIN}" ]; then
    return
  fi

  case "$(uname -s)" in
    Darwin)
      if [ -x "${STANDARD_APP_BIN}" ]; then
        GODOT_BIN="${STANDARD_APP_BIN}"
        return
      fi

      printf 'Missing standard Godot app: %s\n' "${STANDARD_APP_BIN}" >&2
      printf 'Install Godot in /Applications/Godot.app or set GODOT_BIN explicitly.\n' >&2
      exit 1
      ;;
    Linux)
      if command -v godot >/dev/null 2>&1; then
        GODOT_BIN="$(command -v godot)"
        return
      fi

      if command -v Godot >/dev/null 2>&1; then
        GODOT_BIN="$(command -v Godot)"
        return
      fi

      if command -v godot4 >/dev/null 2>&1; then
        GODOT_BIN="$(command -v godot4)"
        return
      fi

      printf 'Missing Godot CLI. Set GODOT_BIN or install a godot executable in PATH.\n' >&2
      exit 1
      ;;
    *)
      printf 'Unsupported platform for automatic Godot detection: %s\n' "$(uname -s)" >&2
      exit 1
      ;;
  esac
}

resolve_template_version() {
  local godot_version

  if [ -n "${GODOT_TEMPLATE_VERSION}" ] && [ -n "${GODOT_TAG}" ]; then
    return
  fi

  godot_version="$("${GODOT_BIN}" --version | awk '{print $1}')"

  if [ -z "${GODOT_TEMPLATE_VERSION}" ]; then
    GODOT_TEMPLATE_VERSION="$(printf '%s' "${godot_version}" | awk -F. '{print $1 "." $2 "." $3 "." $4}')"
  fi

  if [ -z "${GODOT_TAG}" ]; then
    GODOT_TAG="$(printf '%s' "${GODOT_TEMPLATE_VERSION}" | sed 's/\.stable$/-stable/')"
  fi

  CACHE_DIR="${ROOT_DIR}/.cache/godot/${GODOT_TAG}"
  DOWNLOAD_DIR="${CACHE_DIR}/downloads"

  case "$(uname -s)" in
    Darwin)
      TEMPLATE_DIR="${HOME}/Library/Application Support/Godot/export_templates/${GODOT_TEMPLATE_VERSION}"
      ;;
    Linux)
      TEMPLATE_DIR="${HOME}/.local/share/godot/export_templates/${GODOT_TEMPLATE_VERSION}"
      ;;
  esac
}

install_templates() {
  if [ -d "${TEMPLATE_DIR}" ] && [ -n "$(find "${TEMPLATE_DIR}" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]; then
    return
  fi

  mkdir -p "${DOWNLOAD_DIR}" "${TEMPLATE_DIR}"
  if [ ! -f "${DOWNLOAD_DIR}/Godot_v${GODOT_TAG}_export_templates.tpz" ]; then
    log "Downloading export templates"
    curl -fsSL -o "${DOWNLOAD_DIR}/Godot_v${GODOT_TAG}_export_templates.tpz" \
      "https://github.com/godotengine/godot/releases/download/${GODOT_TAG}/Godot_v${GODOT_TAG}_export_templates.tpz"
  fi

  rm -rf "${DOWNLOAD_DIR}/export_templates"
  mkdir -p "${DOWNLOAD_DIR}/export_templates"
  unzip -qo "${DOWNLOAD_DIR}/Godot_v${GODOT_TAG}_export_templates.tpz" -d "${DOWNLOAD_DIR}/export_templates"
  cp -R "${DOWNLOAD_DIR}/export_templates/templates/." "${TEMPLATE_DIR}/"
}

clean_previous_export() {
  rm -f \
    "${ROOT_DIR}/${OUTPUT_PREFIX}.html" \
    "${ROOT_DIR}/${OUTPUT_PREFIX}.js" \
    "${ROOT_DIR}/${OUTPUT_PREFIX}.pck" \
    "${ROOT_DIR}/${OUTPUT_PREFIX}.wasm" \
    "${ROOT_DIR}/${OUTPUT_PREFIX}.png" \
    "${ROOT_DIR}/${OUTPUT_PREFIX}.png.import" \
    "${ROOT_DIR}/${OUTPUT_PREFIX}.icon.png" \
    "${ROOT_DIR}/${OUTPUT_PREFIX}.apple-touch-icon.png" \
    "${ROOT_DIR}/${OUTPUT_PREFIX}.audio.worklet.js" \
    "${ROOT_DIR}/${OUTPUT_PREFIX}.audio.position.worklet.js" \
    "${ROOT_DIR}/${OUTPUT_PREFIX}.icon.png.import" \
    "${ROOT_DIR}/${OUTPUT_PREFIX}.apple-touch-icon.png.import" \
    "${ROOT_DIR}/.nojekyll"
}

run_export() {
  log "Running Godot web export"
  "${GODOT_BIN}" --headless --path "${ROOT_DIR}" --export-release "Web" "${ROOT_DIR}/${OUTPUT_PREFIX}.html"
}

finalize_export() {
  touch "${ROOT_DIR}/.nojekyll"
}

main() {
  require_command curl
  require_command unzip
  detect_platform
  resolve_godot_bin
  resolve_template_version
  install_templates
  clean_previous_export
  run_export
  finalize_export
  log "Export complete: ${ROOT_DIR}/${OUTPUT_PREFIX}.html"
}

main "$@"
