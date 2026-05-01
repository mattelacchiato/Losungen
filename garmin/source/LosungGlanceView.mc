import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

(:glance)
class LosungGlanceView extends WatchUi.GlanceView {

    private var _reference as String;
    private var _preview as String;

    function initialize() {
        GlanceView.initialize();
        _reference = "Losung";
        _preview = "b" + BuildInfo.VERSION;
    }

    function onShow() as Void {
        try {
            var entry = LosungData.entryForToday();
            if (entry != null) {
                _reference = entry[0];
                _preview = entry[1];
            }
        } catch (ex) {
            _reference = "Glance-Fehler";
            var msg = ex.getErrorMessage();
            _preview = (msg == null ? "?" : msg);
            System.println("Glance error: " + msg);
        }
    }

    function onUpdate(dc as Dc) as Void {
        var x = 16;
        var width = dc.getWidth();
        var height = dc.getHeight();
        var titleFont = Graphics.FONT_TINY;
        var bodyFont = Graphics.FONT_XTINY;
        var titleH = dc.getFontHeight(titleFont);
        var bodyH = dc.getFontHeight(bodyFont);

        var blockH = titleH + bodyH;
        var topY = (height - blockH) / 2;
        if (topY < 0) { topY = 0; }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x, topY, titleFont, _reference,
            Graphics.TEXT_JUSTIFY_LEFT
        );
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x, topY + titleH, bodyFont, _preview,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }
}
