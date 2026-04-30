# Losung NT — Forerunner 955

Connect IQ Widget mit Glance ("Übersicht"), das die neutestamentliche
Bibelstelle (Lehrtext) der Herrnhuter Losungen anzeigt. Daten 2026 sind
als JSON-Ressource eingebettet — keine Internetverbindung nötig.

## Verhalten

- **Glance**: Datum, NT-Stelle und Anfang des Textes in der Übersicht-Reihe.
- **App**: Volltext-Ansicht mit Scrollen via Hoch/Runter oder Touch.

## Lokal bauen

Voraussetzungen:
- [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) (>= 4.2.4)
- Java 17+
- Ein Developer-Key (`monkeybrains` → `Generate a Developer Key`)

Daten regenerieren (falls Quelle aktualisiert wird):
```sh
python3 tools/convert.py
```

Bauen:
```sh
cd garmin
monkeyc \
    -o losung-nt.prg \
    -f monkey.jungle \
    -y "$DEVELOPER_KEY_PATH" \
    -d fr955 \
    --warn
```

Im Simulator starten:
```sh
connectiq        # SDK-Simulator starten
monkeydo losung-nt.prg fr955
```

Auf der Uhr installieren: `losung-nt.prg` per USB nach
`GARMIN/APPS/` auf der Forerunner 955 kopieren.

## CI

GitHub Actions baut automatisch eine `.prg` mit Buildnummer im Namen
(`losung-nt-build-<run_number>.prg`) — siehe
`.github/workflows/build.yml`. Die SDK-Version (`9.1.0`) ist im
Workflow gepinnt; das fr955-Device-Pack liegt in
`garmin/vendor/devices/fr955/` mit drin und wird im CI nach
`~/.Garmin/ConnectIQ/Devices/fr955` installiert. Beim Aktualisieren
SDK und Device-Pack zusammen bumpen.

Optional: **Secret** `CIQ_DEVELOPER_KEY` setzen — Developer-Key
(DER-PKCS8) Base64-kodiert (`base64 -w0 developer_key.der`). Ohne
Secret baut der Workflow mit einem Wegwerf-Key und warnt.

Releases:

- Push auf den Default-Branch → "Latest"-Release
  (`<branch>-build-<n>`) mit der `.prg` als Asset
- Tag `vX.Y.Z` → reguläres Release
- Push auf andere Branches → Pre-Release

In allen Fällen liegt die `.prg` zusätzlich als Workflow-Artifact am
Run-Eintrag.
