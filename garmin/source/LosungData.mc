import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

module LosungData {

    // [reference, text]; null if today is outside the bundled year.
    function entryForToday() as Array<String> or Null {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var resId = LosungIndex.resForDay(now.month, now.day);
        if (resId == null) {
            return null;
        }
        try {
            var raw = WatchUi.loadResource(resId) as String;
            var sep = indexOfPipe(raw);
            if (sep < 0) {
                return null;
            }
            return [
                raw.substring(0, sep),
                raw.substring(sep + 1, raw.length())
            ] as Array<String>;
        } catch (ex) {
            System.println("Resource load failed: " + ex.getErrorMessage());
            return null;
        }
    }

    // String.find isn't part of the documented Lang.String API, so do the
    // scan manually to avoid depending on undocumented behaviour.
    function indexOfPipe(s as String) as Number {
        var len = s.length();
        for (var i = 0; i < len; i += 1) {
            if (s.substring(i, i + 1).equals("|")) {
                return i;
            }
        }
        return -1;
    }
}
