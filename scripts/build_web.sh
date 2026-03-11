#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_TAG="${GODOT_TAG:-4.6.1-stable}"
GODOT_TEMPLATE_VERSION="${GODOT_TEMPLATE_VERSION:-4.6.1.stable}"
CACHE_DIR="${ROOT_DIR}/.cache/godot/${GODOT_TAG}"
DOWNLOAD_DIR="${CACHE_DIR}/downloads"
OUTPUT_PREFIX="${OUTPUT_PREFIX:-index}"
GODOT_BIN="${GODOT_BIN:-}"

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
      GODOT_ARCHIVE="Godot_v${GODOT_TAG}_macos.universal.zip"
      DOWNLOADED_GODOT_BIN="${CACHE_DIR}/Godot.app/Contents/MacOS/Godot"
      STANDARD_APP_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
      TEMPLATE_DIR="${HOME}/Library/Application Support/Godot/export_templates/${GODOT_TEMPLATE_VERSION}"
      ;;
    Linux)
      GODOT_ARCHIVE="Godot_v${GODOT_TAG}_linux.x86_64.zip"
      DOWNLOADED_GODOT_BIN="${CACHE_DIR}/Godot_v${GODOT_TAG}_linux.x86_64"
      TEMPLATE_DIR="${HOME}/.local/share/godot/export_templates/${GODOT_TEMPLATE_VERSION}"
      ;;
    *)
      printf 'Unsupported platform: %s\n' "$(uname -s)" >&2
      exit 1
      ;;
  esac
}

resolve_godot_bin() {
  if [ -n "${GODOT_BIN}" ]; then
    return
  fi

  if [ "$(uname -s)" = "Darwin" ] && [ -x "${STANDARD_APP_BIN}" ]; then
    GODOT_BIN="${STANDARD_APP_BIN}"
    return
  fi

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

  GODOT_BIN="${DOWNLOADED_GODOT_BIN}"
}

download_godot() {
  if [ -x "${GODOT_BIN}" ]; then
    return
  fi

  mkdir -p "${DOWNLOAD_DIR}"
  if [ ! -f "${DOWNLOAD_DIR}/${GODOT_ARCHIVE}" ]; then
    log "Downloading ${GODOT_ARCHIVE}"
    curl -fsSL -o "${DOWNLOAD_DIR}/${GODOT_ARCHIVE}" \
      "https://github.com/godotengine/godot/releases/download/${GODOT_TAG}/${GODOT_ARCHIVE}"
  fi

  log "Extracting editor"
  if [[ "${GODOT_ARCHIVE}" == *.zip ]]; then
    unzip -qo "${DOWNLOAD_DIR}/${GODOT_ARCHIVE}" -d "${CACHE_DIR}"
  else
    tar -xf "${DOWNLOAD_DIR}/${GODOT_ARCHIVE}" -C "${CACHE_DIR}"
  fi
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
  download_godot
  install_templates
  clean_previous_export
  run_export
  finalize_export
  log "Export complete: ${ROOT_DIR}/${OUTPUT_PREFIX}.html"
}

main "$@"
