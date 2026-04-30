#!/usr/bin/env python3
"""Convert Losungen XML to compact JSON for Connect IQ."""
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
XML_PATH = ROOT / "xml_extracted" / "Losungen Free 2026.xml"
OUT_PATH = ROOT / "garmin/resources/jsonData/losungen.json"


def main() -> None:
    tree = ET.parse(XML_PATH)
    root = tree.getroot()

    entries = {}
    for item in root.findall("Losungen"):
        datum = item.findtext("Datum") or ""
        m = re.match(r"(\d{4})-(\d{2})-(\d{2})", datum)
        if not m:
            continue
        key = f"{m.group(1)}{m.group(2)}{m.group(3)}"
        entries[key] = {
            "r": (item.findtext("Lehrtextvers") or "").strip(),
            "t": (item.findtext("Lehrtext") or "").strip(),
        }

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with OUT_PATH.open("w", encoding="utf-8") as fh:
        json.dump(entries, fh, ensure_ascii=False, separators=(",", ":"))

    print(f"Wrote {len(entries)} entries to {OUT_PATH}")


if __name__ == "__main__":
    main()
