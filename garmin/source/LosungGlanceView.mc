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
        _line2 = "build " + BuildInfo.VERSION;
    }

    function onShow() as Void {
        ensureLoaded();
    }

    function onUpdate(dc as Dc) as Void {
        ensureLoaded();

        dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();

        var titleFont = Graphics.FONT_GLANCE;
        var bodyFont = Graphics.FONT_GLANCE;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, 0, titleFont, _line1, Graphics.TEXT_JUSTIFY_LEFT);

        var titleHeight = dc.getFontHeight(titleFont);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            0,
            titleHeight + 2,
            bodyFont,
            _line2,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    // Idempotent — runs once, leaves diagnostic strings on any failure
    // so the glance never goes silently blank.
    private function ensureLoaded() as Void {
        if (_loaded) {
            return;
        }
        _loaded = true;
        try {
            var entry = LosungData.entryForToday();
            if (entry == null) {
                _line1 = "Losung";
                _line2 = "Keine Daten (b" + BuildInfo.VERSION + ")";
                return;
            }
            _line1 = entry[0];
            _line2 = entry[1];
        } catch (ex) {
            _line1 = "Glance-Fehler";
            var msg = ex.getErrorMessage();
            _line2 = (msg == null ? "?" : msg) + " | b" + BuildInfo.VERSION;
            System.println("Glance error: " + msg);
        }
    }
}
