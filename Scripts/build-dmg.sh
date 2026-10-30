#!/usr/bin/env bash
# ==============================================================================
# build-dmg.sh — Universal Mac App DMG Build, Developer ID Sign, & Notarize
# Provided by GraceAppsLibraryMac
# ==============================================================================
# Prerequisites:
#   1. 'Developer ID Application' certificate installed in Keychain.
#   2. Notary credentials stored once in Keychain:
#      xcrun notarytool store-credentials "notarytool-profile" \
#        --apple-id "YOUR_APPLE_ID" --team-id "YOUR_TEAM_ID" --password "APP_SPECIFIC_PASSWORD"
#   3. 'create-dmg' installed (optional, falls back to hdiutil):
#      brew install create-dmg
# ==============================================================================

set -euo pipefail

NOTARIZE=0
NOTARY_PROFILE="${NOTARY_PROFILE:-notarytool-profile}"
PROJECT_PATH=""
SCHEME=""
CONFIGURATION=""
APP_NAME=""
OUTPUT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --notarize)
      NOTARIZE=1
      shift
      ;;
    --project)
      PROJECT_PATH="$2"
      shift 2
      ;;
    --scheme)
      SCHEME="$2"
      shift 2
      ;;
    --config|--configuration)
      CONFIGURATION="$2"
      shift 2
      ;;
    --app-name)
      APP_NAME="$2"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --keychain-profile)
      NOTARY_PROFILE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Auto-detect project if not specified
if [[ -z "$PROJECT_PATH" ]]; then
  if ls *.xcodeproj 1>/dev/null 2>&1; then
    PROJECT_PATH="$(ls -d *.xcodeproj | head -n 1)"
  elif ls ../*.xcodeproj 1>/dev/null 2>&1; then
    PROJECT_PATH="$(ls -d ../*.xcodeproj | head -n 1)"
  fi
fi

if [[ -z "$PROJECT_PATH" || ! -d "$PROJECT_PATH" ]]; then
  echo "Error: Xcode project (.xcodeproj) not found. Specify with --project <path>" >&2
  exit 1
fi

PROJECT_DIR="$(cd "$(dirname "$PROJECT_PATH")" && pwd)"
PROJECT_NAME="$(basename "$PROJECT_PATH" .xcodeproj)"

if [[ -z "$APP_NAME" ]]; then
  APP_NAME="$PROJECT_NAME"
fi

if [[ -z "$SCHEME" ]]; then
  # Prefer "Direct" scheme if it exists, otherwise project name
  if xcodebuild -list -project "$PROJECT_PATH" 2>/dev/null | grep -E "^\s*${APP_NAME} Direct$" >/dev/null; then
    SCHEME="${APP_NAME} Direct"
  else
    SCHEME="$APP_NAME"
  fi
fi

if [[ -z "$CONFIGURATION" ]]; then
  if xcodebuild -list -project "$PROJECT_PATH" 2>/dev/null | grep -E "^\s*Direct Release$" >/dev/null; then
    CONFIGURATION="Direct Release"
  else
    CONFIGURATION="Release"
  fi
fi

if [[ -z "$OUTPUT_DIR" ]]; then
  OUTPUT_DIR="$PROJECT_DIR/Distribution/app"
fi

BUILD_DIR="$PROJECT_DIR/Distribution/build"
STAGE_DIR="$BUILD_DIR/source_folder"
DMG_PATH="$OUTPUT_DIR/${APP_NAME}-Installer.dmg"

echo "======================================================================"
echo "==> Packaging DMG for $APP_NAME"
echo "    Project:       $PROJECT_PATH"
echo "    Scheme:        $SCHEME"
echo "    Configuration: $CONFIGURATION"
echo "    Output DMG:    $DMG_PATH"
echo "    Notarize:      $NOTARIZE"
echo "======================================================================"

rm -rf "$BUILD_DIR"
mkdir -p "$STAGE_DIR" "$OUTPUT_DIR"

# Auto-detect Developer ID Application certificate
DEV_ID_CERT=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/' || true)

if [[ -n "$DEV_ID_CERT" ]]; then
  echo "==> Using Developer ID: $DEV_ID_CERT"
  xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY="$DEV_ID_CERT" \
    CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
    OTHER_CODE_SIGN_FLAGS="--timestamp" \
    build
else
  if [[ "$NOTARIZE" == "1" ]]; then
    echo "Error: No 'Developer ID Application' certificate found in Keychain." >&2
    echo "Developer ID Application is required for Apple notarization." >&2
    exit 1
  fi
  echo "==> Note: No Developer ID found; building with local development signature."
  xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    build
fi

APP_BUNDLE="$BUILD_DIR/DerivedData/Build/Products/$CONFIGURATION/${APP_NAME}.app"
if [[ ! -d "$APP_BUNDLE" ]]; then
  # Try finding any .app in the build products directory
  APP_BUNDLE=$(find "$BUILD_DIR/DerivedData/Build/Products/$CONFIGURATION" -maxdepth 1 -name "*.app" | head -n 1 || true)
fi

if [[ -z "$APP_BUNDLE" || ! -d "$APP_BUNDLE" ]]; then
  echo "Error: Built app bundle not found in $BUILD_DIR/DerivedData/Build/Products/$CONFIGURATION" >&2
  exit 1
fi

APP_BASENAME="$(basename "$APP_BUNDLE")"
cp -R "$APP_BUNDLE" "$STAGE_DIR/$APP_BASENAME"

# Strip symbols to minimize DMG size (~90% reduction)
if [[ -f "$STAGE_DIR/$APP_BASENAME/Contents/MacOS/$APP_NAME" ]]; then
  echo "==> Stripping symbol tables for direct release..."
  strip -rSTx "$STAGE_DIR/$APP_BASENAME/Contents/MacOS/$APP_NAME" 2>/dev/null || true
fi

# Re-sign with Developer ID if present (ensures clean signature after strip)
ENTITLEMENTS_FILE=$(find "$PROJECT_DIR" -name "*.entitlements" | head -n 1 || true)
if [[ -n "$DEV_ID_CERT" ]]; then
  echo "==> Re-signing $APP_BASENAME with Developer ID..."
  if [[ -n "$ENTITLEMENTS_FILE" ]]; then
    codesign --force --deep --options runtime --timestamp \
      --entitlements "$ENTITLEMENTS_FILE" \
      --sign "$DEV_ID_CERT" \
      "$STAGE_DIR/$APP_BASENAME"
  else
    codesign --force --deep --options runtime --timestamp \
      --sign "$DEV_ID_CERT" \
      "$STAGE_DIR/$APP_BASENAME"
  fi
  codesign --verify --deep --strict --verbose=2 "$STAGE_DIR/$APP_BASENAME"
fi

# Make sure old volume is detached
hdiutil detach "/Volumes/${APP_NAME} Installer" -force -quiet 2>/dev/null || true
rm -f "$DMG_PATH"

echo "==> Creating disk image: $DMG_PATH..."
if command -v create-dmg >/dev/null 2>&1; then
  create-dmg \
    --volname "${APP_NAME} Installer" \
    --window-pos 200 120 \
    --window-size 800 400 \
    --icon-size 100 \
    --icon "$APP_BASENAME" 200 190 \
    --hide-extension "$APP_BASENAME" \
    --app-drop-link 600 185 \
    --no-internet-enable \
    "$DMG_PATH" \
    "$STAGE_DIR/" || {
      if [[ ! -f "$DMG_PATH" ]]; then
        ln -sf /Applications "$STAGE_DIR/Applications"
        hdiutil create -volname "${APP_NAME} Installer" -srcfolder "$STAGE_DIR" -ov -format UDZO "$DMG_PATH"
      fi
    }
else
  ln -sf /Applications "$STAGE_DIR/Applications"
  hdiutil create -volname "${APP_NAME} Installer" -srcfolder "$STAGE_DIR" -ov -format UDZO "$DMG_PATH"
fi

rm -rf "$BUILD_DIR"

if [[ -n "$DEV_ID_CERT" ]]; then
  echo "==> Signing DMG with $DEV_ID_CERT..."
  codesign --force --sign "$DEV_ID_CERT" --timestamp "$DMG_PATH"
fi

if [[ "$NOTARIZE" == "1" ]]; then
  echo "==> Submitting $DMG_PATH to Apple Notary Service (profile: $NOTARY_PROFILE)..."
  xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
  echo "==> Stapling notarization ticket..."
  xcrun stapler staple "$DMG_PATH"
  echo "==> Verifying Gatekeeper approval..."
  spctl -a -t open --context context:primary-signature -v "$DMG_PATH"
fi

echo "======================================================================"
echo "==> Successfully created DMG:"
echo "    $DMG_PATH"
ls -lh "$DMG_PATH"
echo "======================================================================"
