import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

(:glance)
class LosungGlanceView extends WatchUi.GlanceView {

    private var _loaded as Boolean;
    private var _line1 as String;
    private var _line2 as String;

    function initialize() {
        GlanceView.initialize();
        _loaded = false;
        _line1 = "Lade...";
        _line2 = "b" + BuildInfo.VERSION;
    }

    function onShow() as Void {
        ensureLoaded();
    }

    function onUpdate(dc as Dc) as Void {
        ensureLoaded();

        var width = dc.getWidth();
        var height = dc.getHeight();

        // Sentinel: a thin red border. If you can see this on the watch,
        // onUpdate is being invoked and the system is showing my custom
        // glance. If you can't, the system is ignoring my GlanceView.
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(0, 0, width, height);

        var x = 16;
        var font = Graphics.FONT_TINY;
        var lineH = dc.getFontHeight(font);

        var blockH = 2 * lineH;
        var topY = (height - blockH) / 2;
        if (topY < 0) { topY = 0; }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x, topY, font, _line1,
            Graphics.TEXT_JUSTIFY_LEFT
        );
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x, topY + lineH, font, _line2,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    private function ensureLoaded() as Void {
        if (_loaded) {
            return;
        }
        _loaded = true;
        try {
            var entry = LosungData.entryForToday();
            if (entry == null) {
                _line1 = "Losung";
                _line2 = "Keine Daten b" + BuildInfo.VERSION;
                return;
            }
            _line1 = entry[0];
            _line2 = entry[1];
        } catch (ex) {
            _line1 = "Glance-Fehler";
            var msg = ex.getErrorMessage();
            _line2 = (msg == null ? "?" : msg);
            System.println("Glance error: " + msg);
        }
    }
}
