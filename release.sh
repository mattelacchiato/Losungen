#!/usr/bin/env bash
# Build a release-mode .iq package for Connect IQ Store submission.
# Requires all device packs from manifest.xml to be installed locally
# via the Connect IQ SDK Manager.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
IQ_NAME="losungen.iq"
KEY_FILE="$PROJECT_DIR/developer_key.der"
MANIFEST="$PROJECT_DIR/garmin/manifest.xml"

# --- App version ------------------------------------------------------------
# Optional positional arg: bump manifest.xml version="..." in-place. Garmin
# Connect IQ Store rejects re-uploads with an unchanged version, so each
# release must bump this.

APP_VERSION="${1:-}"
if [[ -n "$APP_VERSION" ]]; then
    if [[ ! "$APP_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "ERROR: version must be MAJOR.MINOR.PATCH (got: $APP_VERSION)" >&2
        exit 1
    fi
    /usr/bin/sed -i '' -E "s/(version=\")[0-9]+\.[0-9]+\.[0-9]+(\")/\1${APP_VERSION}\2/" "$MANIFEST"
    echo "Updated manifest version to $APP_VERSION"
fi

# --- Locate Connect IQ SDK --------------------------------------------------

CIQ_SDK_DIR="$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks"
MONKEYC=$(find "$CIQ_SDK_DIR" -type f -name 'monkeyc' 2>/dev/null \
          | sort -V | tail -1)

if [[ -z "$MONKEYC" ]]; then
    echo "ERROR: monkeyc not found under $CIQ_SDK_DIR" >&2
    exit 1
fi
echo "Using SDK: $(dirname "$MONKEYC")"

# --- Check developer key ----------------------------------------------------

if [[ ! -f "$KEY_FILE" ]]; then
    echo "ERROR: Developer key not found at $KEY_FILE" >&2
    exit 1
fi

# --- Stamp build version -----------------------------------------------------

TIMESTAMP=$(TZ='Europe/Berlin' date '+%y-%m-%d_%H-%M')
COMMIT=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")
VERSION_TAG=$(git -C "$PROJECT_DIR" describe --tags --exact-match 2>/dev/null || true)
if [[ -n "$VERSION_TAG" ]]; then
    VERSION="${VERSION_TAG}"
else
    VERSION="release_${COMMIT}_${TIMESTAMP}"
fi

cat > "$PROJECT_DIR/garmin/source/BuildVersion.mc" <<EOF
import Toybox.Lang;

// Generated at build time by release.sh. Do not edit manually.
(:glance)
module BuildVersion {
    const VERSION = "${VERSION}";
}
EOF
echo "Build version: $VERSION"

# --- Export .iq for store ----------------------------------------------------

mkdir -p "$PROJECT_DIR/bin"
echo "Exporting .iq for all devices listed in manifest..."
"$MONKEYC" \
    -e \
    -r \
    -o "$PROJECT_DIR/bin/$IQ_NAME" \
    -f "$PROJECT_DIR/garmin/monkey.jungle" \
    -y "$KEY_FILE" \
    -w

echo ""
echo "Built: bin/$IQ_NAME ($(du -h "$PROJECT_DIR/bin/$IQ_NAME" | cut -f1 | xargs))"
echo ""
echo "Upload bin/$IQ_NAME at:"
echo "  https://apps.garmin.com/developer/"
