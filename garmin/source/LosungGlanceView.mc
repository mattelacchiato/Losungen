import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class LosungGlanceView extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var refLine;
        var bodyLine;
        var entry = LosungData.entryForToday();
        if (entry == null) {
            refLine = WatchUi.loadResource(Rez.Strings.GlanceTitle) as String;
            bodyLine = WatchUi.loadResource(Rez.Strings.NoDataBody) as String;
        } else {
            refLine = entry[0];
            bodyLine = entry[1];
        }

        var refFont = Graphics.FONT_TINY;
        var bodyFont = Graphics.FONT_XTINY;
        var refH = dc.getFontHeight(refFont);

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(8, 0, refFont, refLine, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(8, refH, bodyFont, bodyLine, Graphics.TEXT_JUSTIFY_LEFT);
    }
}
