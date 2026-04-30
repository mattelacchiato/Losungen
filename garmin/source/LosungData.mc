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
            var sep = raw.find("|");
            if (sep == null) {
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
}
