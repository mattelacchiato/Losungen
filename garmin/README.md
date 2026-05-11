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
