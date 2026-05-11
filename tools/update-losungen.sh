#!/usr/bin/env bash
# Fetch the Losungen XML for a given year from losungen.de, replace the
# old year's archive, and regenerate the Connect IQ resources.
#
# Usage:
#   tools/update-losungen.sh           # defaults to next calendar year
#   tools/update-losungen.sh 2027      # explicit year

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

YEAR="${1:-$(($(TZ='Europe/Berlin' date '+%Y') + 1))}"
if [[ ! "$YEAR" =~ ^[0-9]{4}$ ]]; then
    echo "ERROR: invalid year '$YEAR'" >&2
    exit 1
fi

URL="https://www.losungen.de/fileadmin/media-losungen/download/Losung_${YEAR}_XML.zip"
OUT="Losung_${YEAR}_XML.zip"

echo "Fetching $URL"
curl -fSL --retry 4 --retry-delay 10 -o "$OUT" "$URL"
ls -lh "$OUT"

for f in Losung_*_XML.zip; do
    if [[ "$f" != "$OUT" ]]; then
        echo "Removing previous archive: $f"
        rm -- "$f"
    fi
done

rm -rf xml_extracted
unzip -o "$OUT" -d xml_extracted >/dev/null
python3 tools/convert.py

echo
echo "Done. Updated resources:"
git status --short -- "$OUT" garmin/resources/strings/days.xml \
    garmin/source/LosungIndex.mc Losung_*_XML.zip 2>/dev/null || true
