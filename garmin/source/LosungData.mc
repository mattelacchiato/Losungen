import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

(:glance)
module LosungData {

    // [losungvers, losungtext, lehrtextvers, lehrtext]; null if today is
    // outside the bundled year.
    function entryForToday() as Array<String> or Null {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        // Pass year too: keys are year*10000+month*100+day so a mismatched
        // year (user running last year's build) falls through to null →
        // "Keine Losung" instead of silently showing a stale entry.
        var resId = LosungIndex.resForDay(now.year, now.month, now.day);
        if (resId == null) {
            return null;
        }
        try {
            var raw = WatchUi.loadResource(resId) as String;
            var parts = splitPipes(raw, 4);
            if (parts == null) {
                return null;
            }
            return parts;
        } catch (ex) {
            System.println("Resource load failed: " + ex.getErrorMessage());
            return null;
        }
    }

    // Split on '|' into exactly `count` fields. Returns null if the input
    // does not contain count-1 separators. String.find isn't part of the
    // documented Lang.String API, so scan manually.
    function splitPipes(s as String, count as Number) as Array<String> or Null {
        var parts = new [count] as Array<String>;
        var start = 0;
        var found = 0;
        var len = s.length();
        for (var i = 0; i < len; i += 1) {
            if (s.substring(i, i + 1).equals("|")) {
                if (found >= count - 1) {
                    return null;
                }
                parts[found] = s.substring(start, i);
                found += 1;
                start = i + 1;
            }
        }
        if (found != count - 1) {
            return null;
        }
        parts[found] = s.substring(start, len);
        return parts;
    }
}
