import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class LosungView extends WatchUi.View {

    private var _reference as String;
    private var _text as String;
    private var _dateLabel as String;
    private var _scroll as Number;
    private var _wrappedLines as Array<String> or Null;
    private var _lastWidth as Number;

    function initialize() {
        View.initialize();
        _reference = "";
        _text = "";
        _dateLabel = "";
        _scroll = 0;
        _wrappedLines = null;
        _lastWidth = 0;
    }

    function onShow() as Void {
        var entry = LosungData.entryForToday();
        if (entry == null) {
            _reference = WatchUi.loadResource(Rez.Strings.NoDataTitle) as String;
            _text = WatchUi.loadResource(Rez.Strings.NoDataBody) as String;
        } else {
            _reference = entry[0];
            _text = entry[1];
        }
        _dateLabel = formatToday();
        _scroll = 0;
        _wrappedLines = null;
    }

    function scrollBy(delta as Number) as Void {
        _scroll += delta;
        if (_scroll < 0) {
            _scroll = 0;
        }
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var headerFont = Graphics.FONT_TINY;
        var refFont = Graphics.FONT_SMALL;
        var bodyFont = Graphics.FONT_XTINY;

        var headerH = dc.getFontHeight(headerFont);
        var refH = dc.getFontHeight(refFont);
        var bodyLineH = dc.getFontHeight(bodyFont);
        var footerFont = Graphics.FONT_XTINY;
        var footerH = dc.getFontHeight(footerFont);
        var footerY = height - footerH - 2;

        // Header (date)
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 4, headerFont, _dateLabel, Graphics.TEXT_JUSTIFY_CENTER);

        // Reference
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        var refY = headerH + 6;
        dc.drawText(width / 2, refY, refFont, _reference, Graphics.TEXT_JUSTIFY_CENTER);

        // Body
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var bodyTop = refY + refH + 6;
        var bodyAreaH = footerY - bodyTop - 2;
        var bodyMargin = 8;
        var bodyW = width - 2 * bodyMargin;

        if (_wrappedLines == null || _lastWidth != bodyW) {
            _wrappedLines = wrap(dc, _text, bodyFont, bodyW);
            _lastWidth = bodyW;
        }

        var lines = _wrappedLines as Array<String>;
        var maxVisible = (bodyAreaH / bodyLineH).toNumber();
        var maxScroll = lines.size() - maxVisible;
        if (maxScroll < 0) { maxScroll = 0; }
        if (_scroll > maxScroll) { _scroll = maxScroll; }

        for (var i = 0; i < maxVisible && (i + _scroll) < lines.size(); i += 1) {
            dc.drawText(
                width / 2,
                bodyTop + i * bodyLineH,
                bodyFont,
                lines[i + _scroll],
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

        // Scroll indicator
        if (lines.size() > maxVisible) {
            drawScrollIndicator(dc, width, bodyTop, bodyAreaH, _scroll, maxScroll);
        }

        // Footer with build version (always visible, doesn't scroll)
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2,
            footerY,
            footerFont,
            BuildInfo.VERSION,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    private function drawScrollIndicator(
        dc as Dc, width as Number, top as Number, areaH as Number,
        pos as Number, maxPos as Number
    ) as Void {
        var trackX = width - 4;
        var trackH = areaH;
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(trackX, top, 2, trackH);
        var thumbH = trackH / (maxPos + 2);
        if (thumbH < 6) { thumbH = 6; }
        var thumbY = top + ((trackH - thumbH) * pos) / (maxPos > 0 ? maxPos : 1);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(trackX, thumbY, 2, thumbH);
    }

    private function wrap(dc as Dc, text as String, font as Graphics.FontType, maxWidth as Number) as Array<String> {
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
                }
                if (dc.getTextWidthInPixels(w, font) <= maxWidth) {
                    current = w;
                } else {
                    var broken = breakWord(dc, w, font, maxWidth);
                    for (var j = 0; j < broken.size() - 1; j += 1) {
                        lines.add(broken[j]);
                    }
                    current = broken[broken.size() - 1];
                }
            }
        }
        if (current.length() > 0) {
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

    private function breakWord(dc as Dc, word as String, font as Graphics.FontType, maxWidth as Number) as Array<String> {
        var pieces = [] as Array<String>;
        var current = "";
        for (var i = 0; i < word.length(); i += 1) {
            var ch = word.substring(i, i + 1);
            var test = current + ch;
            if (dc.getTextWidthInPixels(test, font) <= maxWidth) {
                current = test;
            } else {
                if (current.length() > 0) { pieces.add(current); }
                current = ch;
            }
        }
        if (current.length() > 0) { pieces.add(current); }
        if (pieces.size() == 0) { pieces.add(word); }
        return pieces;
    }

    private function formatToday() as String {
        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var day = info.day < 10 ? "0" + info.day : "" + info.day;
        var month = info.month;
        return day + ". " + month + " " + info.year;
    }
}
