import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class LosungGlanceView extends WatchUi.GlanceView {

    // Layout values come from string resources (per-device overrides via
    // resources-fenix7/). Parse once at construction; they never change.
    private var _titleFont as Graphics.FontType;
    private var _marginX as Number;
    private var _titleGap as Number;

    function initialize() {
        GlanceView.initialize();
        _titleFont = resolveFont((WatchUi.loadResource(Rez.Strings.GlanceTitleFont) as String).toNumber());
        _marginX = (WatchUi.loadResource(Rez.Strings.GlanceMarginX) as String).toNumber();
        _titleGap = (WatchUi.loadResource(Rez.Strings.GlanceTitleGap) as String).toNumber();
    }

    function onUpdate(dc as Dc) as Void {
        // Do NOT clear: GlanceView gets a DC that the system has already
        // painted (icon, card background). Clearing would erase that.

        var title = WatchUi.loadResource(Rez.Strings.GlanceTitle) as String;
        var otRef;
        var ntRef;
        var entry = LosungData.entryForToday();
        if (entry == null) {
            otRef = WatchUi.loadResource(Rez.Strings.NoDataBody) as String;
            ntRef = WatchUi.loadResource(Rez.Strings.UpdateHintGlance) as String;
        } else {
            otRef = entry[0];
            ntRef = entry[2];
        }

        var refFont = Graphics.FONT_XTINY;
        var maxW = dc.getWidth() - _marginX;

        var titleH = dc.getFontHeight(_titleFont);
        var refH = dc.getFontHeight(refFont);
        var totalH = titleH + _titleGap + 2 * refH;
        var y = (dc.getHeight() - totalH) / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_marginX, y, _titleFont, fitWidth(dc, _titleFont, title, maxW), Graphics.TEXT_JUSTIFY_LEFT);
        y += titleH + _titleGap;
        dc.drawText(_marginX, y, refFont, fitWidth(dc, refFont, otRef, maxW), Graphics.TEXT_JUSTIFY_LEFT);
        y += refH;
        dc.drawText(_marginX, y, refFont, fitWidth(dc, refFont, ntRef, maxW), Graphics.TEXT_JUSTIFY_LEFT);
    }

    function resolveFont(idx as Number or Null) as Graphics.FontType {
        switch (idx) {
            case 0: return Graphics.FONT_XTINY;
            case 1: return Graphics.FONT_TINY;
            case 2: return Graphics.FONT_SMALL;
            case 3: return Graphics.FONT_MEDIUM;
            case 4: return Graphics.FONT_LARGE;
        }
        return Graphics.FONT_SMALL;
    }

    // Truncate text so it fits within maxW pixels. Adds an ellipsis if cut.
    function fitWidth(dc as Dc, font as Graphics.FontType, text as String, maxW as Number) as String {
        if (dc.getTextWidthInPixels(text, font) <= maxW) {
            return text;
        }
        var ell = "...";
        var ellW = dc.getTextWidthInPixels(ell, font);
        var lo = 0;
        var hi = text.length();
        while (lo < hi) {
            var mid = (lo + hi + 1) / 2;
            var w = dc.getTextWidthInPixels(text.substring(0, mid), font) + ellW;
            if (w <= maxW) {
                lo = mid;
            } else {
                hi = mid - 1;
            }
        }
        return text.substring(0, lo) + ell;
    }
}
