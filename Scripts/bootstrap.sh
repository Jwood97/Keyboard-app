#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

require_brew_tool() {
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

# Swift ships with Xcode — it cannot be installed via 'brew install swift'
# for iOS development. Verify Xcode Command Line Tools are present.
require_xcode() {
  if ! xcode-select -p &>/dev/null; then
    echo "error: Xcode Command Line Tools not found."
    echo "       Run:  xcode-select --install"
    echo "       Or install Xcode from the Mac App Store, then re-run."
    exit 1
  fi
  # Verify an iOS SDK is actually available (catches CLT-only installs)
  if ! xcrun --sdk iphoneos --show-sdk-path &>/dev/null; then
    echo "error: iOS SDK not found. Xcode (not just Command Line Tools) is required."
    echo "       Install Xcode from the Mac App Store, then re-run."
    exit 1
  fi
  echo "info: Xcode found at $(xcode-select -p)"
}

# ---------------------------------------------------------------------------
# Prerequisites
# ---------------------------------------------------------------------------

require_xcode
require_brew_tool xcodegen
require_brew_tool swiftlint

# ---------------------------------------------------------------------------
# Generate icons + xcodeproj
# ---------------------------------------------------------------------------

echo "info: regenerating icon assets"
swift Scripts/generate-icons.swift

echo "info: generating xcodeproj via XcodeGen"
xcodegen generate

echo ""
echo "Done. Open Keyboard.xcodeproj and run the 'Keyboard' scheme on iOS 17+."
