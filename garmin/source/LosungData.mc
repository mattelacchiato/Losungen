import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;

module LosungData {

    function todayKey() as String {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return formatKey(now.year, now.month, now.day);
    }

    function formatKey(year as Number, month as Number, day as Number) as String {
        var m = month < 10 ? "0" + month : "" + month;
        var d = day < 10 ? "0" + day : "" + day;
        return year + m + d;
    }

    function load() as Dictionary or Null {
        try {
            var raw = Application.loadResource(Rez.JsonData.LosungenData);
            if (raw instanceof Lang.Dictionary) {
                return raw;
            }
        } catch (ex) {
            System.println("Resource load failed: " + ex.getErrorMessage());
        }
        return null;
    }

    function entryFor(key as String) as Dictionary or Null {
        var data = load();
        if (data == null) {
            return null;
        }
        var entry = data.get(key);
        if (entry instanceof Lang.Dictionary) {
            return entry;
        }
        return null;
    }
}
