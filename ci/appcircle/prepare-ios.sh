#!/usr/bin/env bash
set -euo pipefail

ROOT="${AC_REPOSITORY_DIR:-$(pwd)}"
IOS_DIR="$ROOT/ios/WarifNative"
PROJECT_FILE="$IOS_DIR/WarifNative.xcodeproj"
WORKSPACE_FILE="$IOS_DIR/WarifNative.xcworkspace"
SECRETS_FILE="$IOS_DIR/Configuration/Secrets.xcconfig"

if [ ! -d "$IOS_DIR" ]; then
  echo "Warif iOS directory not found: $IOS_DIR" >&2
  exit 1
fi

cd "$IOS_DIR"

if [ ! -f "$SECRETS_FILE" ]; then
  cp Configuration/Secrets.example.xcconfig "$SECRETS_FILE"
fi

if ! command -v xcodegen >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install xcodegen
  else
    echo "xcodegen is required. Add an Appcircle step before this script to install XcodeGen." >&2
    exit 1
  fi
fi

xcodegen generate

if [ ! -d "$PROJECT_FILE" ]; then
  echo "XcodeGen did not create $PROJECT_FILE" >&2
  exit 1
fi

if [ -n "${AC_ENV_FILE_PATH:-}" ]; then
  {
    echo "AC_PROJECT_PATH=ios/WarifNative/WarifNative.xcworkspace"
    echo "AC_SCHEME=WarifNative"
    echo "AC_CONFIGURATION=Release"
  } >> "$AC_ENV_FILE_PATH"
fi

echo "Prepared Warif Native for Appcircle."
echo "Project: $PROJECT_FILE"
echo "Workspace after CocoaPods: $WORKSPACE_FILE"
