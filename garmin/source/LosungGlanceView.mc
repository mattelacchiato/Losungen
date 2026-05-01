import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class LosungGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        // Solid red fill — if you see red, onUpdate runs.
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_RED);
        dc.clear();

        // White text on top.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            16,
            dc.getHeight() / 2,
            Graphics.FONT_TINY,
            "Hallo",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
