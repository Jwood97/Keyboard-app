#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

require() {
  local cmd="$1"
  local pkg="${2:-$1}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
      echo "info: installing $pkg via Homebrew"
      brew install "$pkg"
    else
      echo "error: '$cmd' not found and Homebrew is not installed."
      echo "       Install Homebrew (https://brew.sh) or install $pkg manually, then re-run."
      exit 1
    fi
  fi
}

require xcodegen
require swiftlint
require swift swift

echo "info: regenerating icon assets"
swift Scripts/generate-icons.swift

echo "info: generating xcodeproj via XcodeGen"
xcodegen generate

echo ""
echo "Done. Open Keyboard.xcodeproj and run the 'Keyboard' scheme on iOS 17+."
