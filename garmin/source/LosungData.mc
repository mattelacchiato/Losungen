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
        // Each month is its own JSON resource. CIQ 3.x devices cap a module
        // at 254 members, so per-day string resources don't fit a full year;
        // 12 monthly chunks stay well under the limit and only one chunk
        // (~7 KB) is loaded per access.
        var resId = LosungIndex.jsonResForMonth(now.year, now.month);
        if (resId == null) {
            return null;
        }
        try {
            var chunk = WatchUi.loadResource(resId) as Dictionary;
            var entry = chunk[now.day.toString()];
            if (entry == null) {
                return null;
            }
            return entry as Array<String>;
        } catch (ex) {
            System.println("Resource load failed: " + ex.getErrorMessage());
            return null;
        }
    }
}
