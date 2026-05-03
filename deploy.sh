#!/usr/bin/env bash
# Build the Connect IQ widget and deploy it to a Garmin watch via MTP.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PRG_NAME="losung-nt.prg"
KEY_FILE="$PROJECT_DIR/developer_key.der"

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
VERSION="local_${COMMIT}_${TIMESTAMP}"

cat > "$PROJECT_DIR/garmin/source/BuildInfo.mc" <<EOF
import Toybox.Lang;

// Generated at build time. Do not edit manually.
(:glance)
module BuildInfo {
    const VERSION = "${VERSION}";
}
EOF
echo "Build version: $VERSION"

# --- Build -------------------------------------------------------------------

mkdir -p "$PROJECT_DIR/bin"
echo "Compiling..."
"$MONKEYC" \
    -o "$PROJECT_DIR/bin/$PRG_NAME" \
    -f "$PROJECT_DIR/garmin/monkey.jungle" \
    -y "$KEY_FILE" \
    -d fr955 \
    -w

echo "Built: bin/$PRG_NAME ($(du -h "$PROJECT_DIR/bin/$PRG_NAME" | cut -f1 | xargs))"

# --- Build mtp-upload helper (cached) ---------------------------------------
# Uses go-mtpx (the same Go MTP stack as OpenMTP) — libmtp's CLI tools cannot
# write to Garmin storage because the device rejects unknown MTP file types.

MTP_UPLOAD_BIN="$PROJECT_DIR/bin/mtp-upload"
MTP_UPLOAD_SRC="$PROJECT_DIR/tools/mtp-upload"

if [[ ! -x "$MTP_UPLOAD_BIN" \
      || "$MTP_UPLOAD_SRC/main.go" -nt "$MTP_UPLOAD_BIN" \
      || "$MTP_UPLOAD_SRC/go.mod" -nt "$MTP_UPLOAD_BIN" ]]; then
    echo ""
    echo "Building MTP uploader..."
    if ! command -v go >/dev/null 2>&1; then
        echo "ERROR: 'go' not found. Install Go to build the MTP uploader." >&2
        exit 1
    fi
    (cd "$MTP_UPLOAD_SRC" && go build -o "$MTP_UPLOAD_BIN" .)
fi

# --- Deploy via MTP ----------------------------------------------------------

echo ""
echo "Sending to watch via MTP (retrying until connected)..."
attempt=0
until "$MTP_UPLOAD_BIN" "$PROJECT_DIR/bin/$PRG_NAME" "/GARMIN/Apps" 2>/dev/null; do
    attempt=$((attempt + 1))
    if [[ $attempt -eq 1 ]]; then
        echo "  watch not ready – connect via USB and enable MTP..."
    fi
    sleep 2
done

echo ""
echo "Done! Disconnect the watch to start the app."
