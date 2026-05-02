import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class LosungGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var line1 = "?";
        var line2 = "?";
        try {
            // Today is 2026-05-01 → key 501 → Rez.Strings.D_0501.
            var resId = LosungIndex.resForDay(5, 1);
            if (resId == null) {
                line1 = "no res";
            } else {
                var raw = WatchUi.loadResource(resId) as String;
                var sep = indexOfPipe(raw);
                if (sep < 0) {
                    line1 = raw;
                } else {
                    line1 = raw.substring(0, sep);
                    line2 = raw.substring(sep + 1, raw.length());
                }
            }
        } catch (ex) {
            line1 = "err";
            var msg = ex.getErrorMessage();
            line2 = (msg == null ? "?" : msg);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var font = Graphics.FONT_XTINY;
        var lineH = dc.getFontHeight(font);
        dc.drawText(8, 0, font, line1, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(8, lineH, font, line2, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(8, lineH * 2, font, "v " + BuildInfo.VERSION, Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function indexOfPipe(s as String) as Number {
        var len = s.length();
        for (var i = 0; i < len; i += 1) {
            if (s.substring(i, i + 1).equals("|")) {
                return i;
            }
        }
        return -1;
    }
}
