# Glance-Debugging — Stand der Erkenntnisse

Dieses Dokument hält den Stand des Glance-Problems fest, damit eine
neue Session nahtlos anschließen kann.

## Projekt-Kontext

- **Ziel**: Garmin Forerunner 955 Connect IQ Widget, das die
  neutestamentliche Bibelstelle (Lehrtext) der Herrnhuter Losung als
  "Übersicht" (Glance) anzeigt + bei Tap die Hauptansicht öffnet.
- **Repo**: `github.com/mattelacchiato/Losungen`, Default-Branch
  `main`.
- **Daten**: 365 Tage 2026 als String-Resources unter
  `garmin/resources/strings/days.xml` (id `D_<MMDD>`, Format
  `<NT-Stelle>|<Lehrtext>`).
- **Manifest**: `type="widget"`, `minApiLevel="4.0.0"`,
  `version="1.0.0"`. Mit `type="watch-app"` verschwand die App aus
  dem Glance-Carousel — also bei `widget` bleiben.
- **SDK**: 9.1.0 fest gepinnt im CI; fr955-Device-Pack vendoriert
  unter `garmin/vendor/devices/fr955/`.
- **CI**: `.github/workflows/build.yml` baut `.prg` mit Buildnummer,
  publiziert GitHub-Release. Developer-Key liegt als Secret
  `CIQ_DEVELOPER_KEY` (base64 DER).

## Aktuelle Symptome

- **Hauptansicht**: funktioniert. Datum, NT-Stelle, scrollbarer
  Text, am Ende `Build <version>` als grauer Eintrag im scrollbaren
  Bereich. Scrollen mit Up/Down/Select sowie Swipe.
- **Glance**: zeigt nichts (komplett schwarz / leer), sobald
  `LosungIndex` oder `LosungData` aus dem Glance referenziert wird —
  selbst mit allen `(:glance)`-Annotationen.

## Was gesichert funktioniert ✅

- `getGlanceView()` mit `(:glance)`-Annotation wird vom System
  aufgerufen und `onUpdate` läuft (Build 14: roter Hintergrund +
  "Hallo" rendert).
- Externes `(:glance)`-Modul mit `const` String wird im Glance
  aufgelöst (Build 16: `BuildInfo.VERSION`).
- Externes `(:glance)`-Modul mit Funktion, die `Array<String>`
  zurückgibt, ist OK (Build 17 / Commit `29e299d`: `StubData`
  funktioniert).
- Manifest mit `type="widget"` packt die App automatisch in den
  Glance-Carousel.

## Was nicht funktioniert ❌

| Schritt | Build | Kommentar |
|---------|-------|-----------|
| `LosungIndex` mit 365 Cases + Rez-Refs | b9ceb31 | leer |
| `LosungIndex` mit 1 Case → `Rez.Strings.D_0501` | b965447 | leer |
| `LosungIndex` mit 1 Case → `Number 99999` (kein Rez) | 6a216ec | Build kaputt (Type-Error in LosungData) |
| `LosungIndex` mit 1 Case → `Rez.Strings.NoDataTitle` | c5b90e3 | leer |
| Vorher + `LosungData` ohne `(:glance)` | 92be0f5 | leer |

Letzter Stand auf `main` ist `92be0f5`: Glance ruft
`LosungIndex.resForDay(5,1)` und zeigt das ResourceId-Ergebnis. Schwarz.

## Hypothesen-Tracker

- ❌ Größe des 365-Case-Switch alleine. Auch mit nur 1 Case leer.
- ❌ Externe `(:glance)`-Module sind das Problem. StubData ging.
- ❌ Funktionen / Arrays in `(:glance)`-Modulen brechen. StubData ging.
- ❌ `LosungData` als `(:glance)`-Modul (Time/Gregorian-Imports)
  zieht zu viel mit. Annotation runter genommen — bleibt leer.
- ⚠️ **Verbleibender Hauptverdacht**: *Jeder* `Rez.Strings.X`-Verweis
  aus einem `(:glance)`-Modul zieht den **Resource-Table mit allen
  365 D_-Strings** ins Glance-Binary, weil die Resource-Tabelle
  monolithisch geladen wird. Das alleine reicht, um die 64 KB
  Glance-Memory zu sprengen.
  - Verifikations-Test (noch nicht gemacht): `days.xml` temporär
    auf 5 Einträge eindampfen + Glance referenziert
    `Rez.Strings.D_0501`. Wenn das geht → bewiesen.

## Nicht ausgeschlossen

- Build hat einen subtilen Cache-/Linker-Bug.
- `(:glance)` muss auch auf `LosungApp.getGlanceView()` *und* auf der
  Klasse `LosungGlanceView` *und* allen referenzierten Symbolen
  rekursiv sitzen — vielleicht doch ein Detail, das ich übersehen
  habe.
- Manifest fehlt vielleicht ein `<iq:application>`-Attribut, das in
  CIQ 9.x für Glances erforderlich ist (z. B. expliziter
  glance-Attribute-Hinweis).

## Memory-Limits FR955

Aus `garmin/vendor/devices/fr955/compiler.json`:

| App-Typ | Limit |
|---------|-------|
| watchApp | 786 432 B |
| datafield | 262 144 B |
| watchFace | 131 072 B |
| **glance** | **65 536 B** |
| background | 65 536 B |
| audioContentProvider | 524 288 B |

Glance ist mit Abstand am engsten.

## Plan B (wenn Hypothese sich bestätigt): Storage-basierter Glance

1. Main-View schreibt bei jedem `onShow` heutiges Datum + Ref + Text
   nach `Application.Storage`:
   ```
   today_date  → "2026-05-01"
   today_ref   → "1. Johannes 4,9"
   today_text  → "Darin ist erschienen..."
   ```
2. Glance liest *nur* aus Storage. Keine Resource-Lookups.
   `Application.Storage` ist von Glance aus erreichbar.
3. Wenn `today_date` ≠ heute (oder leer), Glance zeigt
   "App öffnen für heutige Losung".
4. Nutzer muss die App einmal pro Tag öffnen, damit der Glance
   aktuell bleibt — Trade-off, aber praktikabel.

Vermutlich der pragmatischste Weg.

## Plan C: AppGlance-API

`Toybox.Application.AppGlance` mit Templates statt
`WatchUi.GlanceView`. System cacht das Template, App aktualisiert
es periodisch. Komplexer, aber kein Memory-Problem im Glance, weil
das System das Rendern übernimmt. Erfordert Background-Trigger
oder Aktualisierung beim App-Start.

## Nächste Schritte (für die Folge-Session)

1. Verifikations-Test: `days.xml` auf 5 Einträge reduzieren, Glance
   referenziert `Rez.Strings.D_0501`. Bestätigt oder widerlegt die
   Resource-Table-Theorie endgültig.
2. Wenn bestätigt → Plan B umsetzen: `LosungData` und `LosungIndex`
   raus aus dem Glance-Binary (keine `(:glance)`-Annotation mehr),
   Storage-Schreibung in Main-View, Storage-Lesung im Glance.
3. Aufräumen:
   - `BuildInfo.mc` Annotation behalten.
   - Sync-Check in CI wieder aktivieren (`tools/convert.py` läuft).
   - Glance-Layout (`FONT_TINY`, kein roter Hintergrund mehr).
   - `LosungIndex.mc` aus `convert.py` regenerieren (volle 365 Cases,
     ohne `(:glance)`).
4. Wenn die Storage-Lösung fließt: README aktualisieren, dass Nutzer
   die App einmal pro Tag öffnen muss.

## Wichtige Dateien

- `garmin/manifest.xml` — App-Manifest, `type="widget"`
- `garmin/source/LosungApp.mc` — AppBase, `getGlanceView()` mit `(:glance)`
- `garmin/source/LosungGlanceView.mc` — aktuell Diagnose-Code
- `garmin/source/LosungView.mc` — Hauptansicht, scrollbarer Text
- `garmin/source/LosungData.mc` — Resource-Lookup-Helfer
- `garmin/source/LosungIndex.mc` — derzeit auf 1 Case eingedampft;
  normal von `tools/convert.py` mit 365 Cases generiert
- `garmin/source/BuildInfo.mc` — Default `local`; CI stempelt Version
- `garmin/source/LosungDelegate.mc` — Scroll-Handling
- `tools/convert.py` — XML → days.xml + LosungIndex.mc Generator
- `.github/workflows/build.yml` — CI, Sync-Check derzeit deaktiviert
