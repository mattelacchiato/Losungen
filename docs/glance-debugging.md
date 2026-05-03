# Glance: warum stundenlang nichts ging

Postmortem für ein Problem, das ich nicht nochmal lösen will müssen.

## Symptom

Glance des Widgets blieb komplett schwarz, sobald *irgendein*
`Rez.Strings.X`-Verweis aus dem Glance-Binary erreichbar war —
selbst bei einer auf 5 Einträge reduzierten `days.xml` und einem
Verweis auf einen 12-Zeichen-String. Hauptansicht funktionierte
parallel einwandfrei.

## Ursache

In CIQ ≥ 3.1 hat jede Resource ein **Scope** (`foreground`,
`background`, `glance`). Resourcen ohne `scope="glance"` werden
**nicht ins Glance-Binary gelinkt**. Wenn `(:glance)`-Code
trotzdem auf so ein Symbol verweist, scheitert das Rendering
**stumm** — kein Compile-Fehler, kein Laufzeit-Log, einfach
schwarzer Screen.

Memory-Limits, das `(:glance)`-Annotations-Geflecht, die Größe
der Resource-Tabelle, `LosungData`/`LosungIndex` als Module —
alles Ablenkungen. Allein das fehlende Attribut hat alle Tests
gekippt.

## Fix

`scope="glance"` auf alle Resourcen, die der Glance braucht:

- `garmin/resources/strings/days.xml` — alle 365 `D_*`-Einträge
  (`tools/convert.py` setzt das Attribut beim Generieren).
- `garmin/resources/strings/strings.xml` — `GlanceTitle`,
  `NoDataTitle`, `NoDataBody`. `AppName` bleibt foreground.

`(:glance)` auf alle Module/Klassen, die der Glance referenziert:
`LosungApp.getGlanceView`, `LosungGlanceView`, `LosungData`,
`LosungIndex`, `BuildInfo` (sofern referenziert).

Verifikations-Commit: `ea60f18` (Test mit 5 Einträgen) +
folgender Cleanup-Commit (Scope an, alle 365 Tage zurück).

## Quellen

- Programmer's Guide → Resource Compiler →
  https://developer.garmin.com/connect-iq/programmers-guide/resource-compiler/
- Forum-Threads zum gleichen Symptom (leerer Glance bei
  Resource-Zugriff): siehe forums.garmin.com Suche nach
  "glance" + "scope".

## Was wir nicht gebraucht haben

Plan B (Storage-basierter Glance) war als Fallback vorgesehen,
aber überflüssig. Falls dieses Setup je doch wieder kippt:
`Application.Storage` ist aus dem Glance erreichbar und umgeht
das Resource-Scoping vollständig.
