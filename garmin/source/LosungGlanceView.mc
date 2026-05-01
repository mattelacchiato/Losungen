import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class LosungGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    private function makeArray() as Array<String> {
        var a = ["inline a", "inline b"] as Array<String>;
        return a;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_RED);
        dc.clear();

        var line1 = "?";
        var line2 = "?";
        try {
            var arr = makeArray();
            line1 = arr[0];
            line2 = arr[1];
        } catch (ex) {
            var msg = ex.getErrorMessage();
            line1 = "arr err";
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
