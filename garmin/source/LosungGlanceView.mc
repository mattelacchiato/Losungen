import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class LosungGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        // Red background proves onUpdate runs.
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_RED);
        dc.clear();

        var line1 = "1:?";
        var line2 = "2:?";
        var line3 = "3:?";

        // Step 1: BuildInfo reachable from glance binary?
        try {
            line1 = "v " + BuildInfo.VERSION;
        } catch (ex) {
            line1 = "no BuildInfo";
        }

        // Step 2: LosungData reachable + entryForToday returns?
        try {
            var entry = LosungData.entryForToday();
            if (entry == null) {
                line2 = "data: null";
            } else {
                line2 = entry[0];
                line3 = entry[1];
            }
        } catch (ex) {
            var msg = ex.getErrorMessage();
            line2 = "data err: " + (msg == null ? "?" : msg);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var font = Graphics.FONT_XTINY;
        var lineH = dc.getFontHeight(font);
        dc.drawText(16, 0, font, line1, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(16, lineH, font, line2, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(16, lineH * 2, font, line3, Graphics.TEXT_JUSTIFY_LEFT);
    }
}
