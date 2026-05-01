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
            var entry = StubData.todayStub();
            if (entry != null) {
                line1 = entry[0];
                line2 = entry[1];
            } else {
                line1 = "stub null";
            }
        } catch (ex) {
            var msg = ex.getErrorMessage();
            line1 = "stub err";
            line2 = (msg == null ? "?" : msg);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var font = Graphics.FONT_XTINY;
        dc.drawText(16, 0, font, line1, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(16, dc.getFontHeight(font), font, line2, Graphics.TEXT_JUSTIFY_LEFT);
    }
}
