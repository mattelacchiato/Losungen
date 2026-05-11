#!/usr/bin/env bash
# Build the Connect IQ widget and launch it in the SDK simulator.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEY_FILE="$PROJECT_DIR/developer_key.der"
# Device can be passed as the first positional arg, via DEVICE=..., or
# defaults to fr955.
DEVICE="${1:-${DEVICE:-fr955}}"
PRG_NAME="losung-nt-${DEVICE}.prg"

# --- Locate Connect IQ SDK --------------------------------------------------

CIQ_SDK_DIR="$HOME/Library/Application Support/Garmin/ConnectIQ/Sdks"
SDK_ROOT=$(find "$CIQ_SDK_DIR" -maxdepth 1 -mindepth 1 -type d \
           | sort -V | tail -1)

if [[ -z "$SDK_ROOT" || ! -x "$SDK_ROOT/bin/monkeyc" ]]; then
    echo "ERROR: Connect IQ SDK not found under $CIQ_SDK_DIR" >&2
    exit 1
fi
echo "Using SDK: $SDK_ROOT"

if [[ ! -f "$KEY_FILE" ]]; then
    echo "ERROR: Developer key not found at $KEY_FILE" >&2
    exit 1
fi

# --- Stamp build version ----------------------------------------------------

TIMESTAMP=$(TZ='Europe/Berlin' date '+%y-%m-%d_%H-%M')
COMMIT=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")
VERSION="local_${COMMIT}_${TIMESTAMP}"

cat > "$PROJECT_DIR/garmin/source/BuildVersion.mc" <<EOF
import Toybox.Lang;

// Generated at build time by run-sim.sh. Do not edit manually.
(:glance)
module BuildVersion {
    const VERSION = "${VERSION}";
}
EOF
echo "Build version: $VERSION"

# --- Build ------------------------------------------------------------------

mkdir -p "$PROJECT_DIR/bin"
echo "Compiling for $DEVICE..."
"$SDK_ROOT/bin/monkeyc" \
    -o "$PROJECT_DIR/bin/$PRG_NAME" \
    -f "$PROJECT_DIR/garmin/monkey.jungle" \
    -y "$KEY_FILE" \
    -d "$DEVICE" \
    -w

# --- Launch simulator -------------------------------------------------------
# monkeydo can only switch the simulator's device if it isn't already
# locked to a different one. To keep "switch device" a one-command flow,
# remember the last-loaded device and restart the simulator on a switch.

STATE_FILE="$PROJECT_DIR/bin/.last-sim-device"
LAST_DEVICE=""
[[ -f "$STATE_FILE" ]] && LAST_DEVICE=$(cat "$STATE_FILE")

start_simulator() {
    # -g: launch without bringing the simulator to the foreground, so
    # the editor / terminal doesn't lose focus on each rebuild.
    open -ga "$SDK_ROOT/bin/ConnectIQ.app"
    for _ in $(seq 1 20); do
        pgrep -f "ConnectIQ.app/Contents/MacOS/simulator" >/dev/null && break
        sleep 0.5
    done
    # The process is up before its IPC socket is ready to accept monkeydo.
    sleep 2
}

# Retry monkeydo a few times — the simulator can return "Unable to connect"
# briefly after start, or when switching devices.
load_into_sim() {
    for _ in $(seq 1 5); do
        if "$SDK_ROOT/bin/monkeydo" "$PROJECT_DIR/bin/$PRG_NAME" "$DEVICE"; then
            return 0
        fi
        sleep 1
    done
    return 1
}

if pgrep -f "ConnectIQ.app/Contents/MacOS/simulator" >/dev/null; then
    if [[ -n "$LAST_DEVICE" && "$LAST_DEVICE" != "$DEVICE" ]]; then
        echo "Switching simulator from $LAST_DEVICE to $DEVICE (restart)..."
        pkill -f "ConnectIQ.app/Contents/MacOS/simulator" || true
        sleep 1
        start_simulator
    fi
else
    echo "Starting simulator..."
    start_simulator
fi

echo "Loading $PRG_NAME into simulator ($DEVICE)..."
load_into_sim
echo "$DEVICE" > "$STATE_FILE"
