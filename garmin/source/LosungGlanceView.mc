import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class LosungGlanceView extends WatchUi.GlanceView {

    private var _reference as String;
    private var _preview as String;

    function initialize() {
        GlanceView.initialize();
        _reference = "";
        _preview = "";
    }

    function onShow() as Void {
        var entry = LosungData.entryFor(LosungData.todayKey());
        if (entry == null) {
            _reference = WatchUi.loadResource(Rez.Strings.NoDataTitle) as String;
            _preview = WatchUi.loadResource(Rez.Strings.NoDataBody) as String;
        } else {
            _reference = entry.get("r") as String;
            _preview = entry.get("t") as String;
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var titleFont = Graphics.FONT_GLANCE;
        var bodyFont = Graphics.FONT_GLANCE;

        var title = (WatchUi.loadResource(Rez.Strings.GlanceTitle) as String) +
            ": " + _reference;
        dc.drawText(0, 0, titleFont, title, Graphics.TEXT_JUSTIFY_LEFT);

        var titleHeight = dc.getFontHeight(titleFont);
        var bodyY = titleHeight + 2;
        var bodyHeight = height - bodyY;
        if (bodyHeight < dc.getFontHeight(bodyFont)) {
            return;
        }

        dc.drawText(
            0,
            bodyY,
            bodyFont,
            _preview,
            Graphics.TEXT_JUSTIFY_LEFT
        );
        // Glance auto-truncates with ellipsis when text exceeds width.
    }
}
