import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class LosungGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_RED);
        dc.clear();

        var line1 = "?";
        var line2 = "?";
        try {
            // Today is 2026-05-01 → key 501 → Rez.Strings.D_0501
            var resId = LosungIndex.resForDay(5, 1);
            line1 = "idx ok";
            line2 = "id=" + resId;
        } catch (ex) {
            line1 = "idx err";
            var msg = ex.getErrorMessage();
            line2 = (msg == null ? "?" : msg);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var font = Graphics.FONT_XTINY;
        var lineH = dc.getFontHeight(font);
        dc.drawText(16, 0, font, line1, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(16, lineH, font, line2, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(16, lineH * 2, font, "v " + BuildInfo.VERSION, Graphics.TEXT_JUSTIFY_LEFT);
    }
}
