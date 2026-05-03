import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class LosungGlanceView extends WatchUi.GlanceView {

    private const MAX_LINES = 4;
    private const MARGIN_X = 4;

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

        var font = Graphics.FONT_XTINY;
        var lineH = dc.getFontHeight(font);
        var width = dc.getWidth();
        var height = dc.getHeight();
        var bodyW = width - 2 * MARGIN_X;

        var maxLines = (height / lineH).toNumber();
        if (maxLines > MAX_LINES) { maxLines = MAX_LINES; }
        if (maxLines < 1) { maxLines = 1; }

        var lines = wrap(dc, bodyLine, font, bodyW, maxLines);

        // Reference placement: own line if a slot is free, otherwise
        // appended to the last verse line if it still fits.
        var refOwnLine = -1;
        var refSuffix = false;
        var hasRef = refLine != null && refLine.length() > 0;
        if (hasRef && lines.size() < maxLines) {
            refOwnLine = lines.size();
            lines.add(refLine);
        } else if (hasRef && lines.size() > 0) {
            var lastIdx = lines.size() - 1;
            var combined = lines[lastIdx] + "  " + refLine;
            if (dc.getTextWidthInPixels(combined, font) <= bodyW) {
                refSuffix = true;
            }
        }

        for (var i = 0; i < lines.size(); i += 1) {
            var y = i * lineH;
            if (i == refOwnLine) {
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.drawText(MARGIN_X, y, font, lines[i], Graphics.TEXT_JUSTIFY_LEFT);
            } else if (refSuffix && i == lines.size() - 1) {
                var verse = lines[i] + "  ";
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(MARGIN_X, y, font, verse, Graphics.TEXT_JUSTIFY_LEFT);
                var prefW = dc.getTextWidthInPixels(verse, font);
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.drawText(MARGIN_X + prefW, y, font, refLine, Graphics.TEXT_JUSTIFY_LEFT);
            } else {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(MARGIN_X, y, font, lines[i], Graphics.TEXT_JUSTIFY_LEFT);
            }
        }
    }

    private function wrap(
        dc as Dc, text as String, font as Graphics.FontType,
        maxWidth as Number, maxLines as Number
    ) as Array<String> {
        var lines = [] as Array<String>;
        if (text == null || text.length() == 0) {
            return lines;
        }
        var words = splitWords(text);
        var current = "";
        for (var i = 0; i < words.size(); i += 1) {
            var w = words[i];
            var candidate = current.length() == 0 ? w : current + " " + w;
            if (dc.getTextWidthInPixels(candidate, font) <= maxWidth) {
                current = candidate;
            } else {
                if (current.length() > 0) {
                    lines.add(current);
                    if (lines.size() >= maxLines) {
                        return lines;
                    }
                }
                current = w;
            }
        }
        if (current.length() > 0 && lines.size() < maxLines) {
            lines.add(current);
        }
        return lines;
    }

    private function splitWords(text as String) as Array<String> {
        var result = [] as Array<String>;
        var start = 0;
        var len = text.length();
        for (var i = 0; i < len; i += 1) {
            var ch = text.substring(i, i + 1);
            if (ch.equals(" ")) {
                if (i > start) {
                    result.add(text.substring(start, i));
                }
                start = i + 1;
            }
        }
        if (start < len) {
            result.add(text.substring(start, len));
        }
        return result;
    }
}
