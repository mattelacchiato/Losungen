import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class LosungView extends WatchUi.View {

    private var _reference as String;
    private var _text as String;
    private var _scrollPx as Number;
    private var _maxScrollPx as Number;
    private var _viewportH as Number;
    private var _wrappedLines as Array<String> or Null;
    private var _lastWidth as Number;

    function initialize() {
        View.initialize();
        _reference = "";
        _text = "";
        _scrollPx = 0;
        _maxScrollPx = 0;
        _viewportH = 0;
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
        _scrollPx = 0;
        _wrappedLines = null;
    }

    function scrollByPx(deltaPx as Number) as Void {
        _scrollPx += deltaPx;
        if (_scrollPx < 0) { _scrollPx = 0; }
        if (_scrollPx > _maxScrollPx) { _scrollPx = _maxScrollPx; }
        WatchUi.requestUpdate();
    }

    function pageScroll(direction as Number) as Void {
        var step = _viewportH > 0 ? _viewportH / 2 : 60;
        scrollByPx(direction * step);
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var refFont = Graphics.FONT_SMALL;
        var bodyFont = Graphics.FONT_XTINY;
        var refH = dc.getFontHeight(refFont);
        var bodyLineH = dc.getFontHeight(bodyFont);

        // Round-screen viewport: stay clear of the curved top/bottom edges.
        var topInset = height / 8;
        var bottomInset = height / 8;
        var viewportH = height - topInset - bottomInset;

        var bodyMargin = 8;
        var bodyW = width - 2 * bodyMargin;

        if (_wrappedLines == null || _lastWidth != bodyW) {
            _wrappedLines = wrap(dc, _text, bodyFont, bodyW);
            _lastWidth = bodyW;
        }
        var verseLines = _wrappedLines as Array<String>;

        var refGap = 6;
        var spacerH = bodyLineH;
        var totalH = refH + refGap
                   + verseLines.size() * bodyLineH
                   + spacerH
                   + bodyLineH;

        // Overscroll past the natural end so the last line can travel up to
        // ~1/3 from the top of the screen (i.e. last-line top at 2/3 height).
        var maxScrollPx;
        if (totalH <= viewportH) {
            maxScrollPx = 0;
        } else {
            maxScrollPx = topInset + totalH - bodyLineH - (height * 2 / 3);
            if (maxScrollPx < 0) { maxScrollPx = 0; }
        }

        _maxScrollPx = maxScrollPx;
        _viewportH = viewportH;
        if (_scrollPx > maxScrollPx) { _scrollPx = maxScrollPx; }
        if (_scrollPx < 0) { _scrollPx = 0; }
        var scrollPx = _scrollPx;

        dc.setClip(0, topInset, width, viewportH);

        var y = topInset - scrollPx;

        // Reference
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, y, refFont, _reference, Graphics.TEXT_JUSTIFY_CENTER);
        y += refH + refGap;

        // Verse
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < verseLines.size(); i += 1) {
            dc.drawText(width / 2, y, bodyFont, verseLines[i], Graphics.TEXT_JUSTIFY_CENTER);
            y += bodyLineH;
        }

        y += spacerH;

        // Build footer
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, y, bodyFont, "Build " + BuildInfo.VERSION, Graphics.TEXT_JUSTIFY_CENTER);

        dc.clearClip();

        if (totalH > viewportH) {
            drawScrollIndicator(dc, width, topInset, viewportH, scrollPx, maxScrollPx);
        }
    }

    private function drawScrollIndicator(
        dc as Dc, width as Number, top as Number, areaH as Number,
        pos as Number, maxPos as Number
    ) as Void {
        var trackX = width - 4;
        var trackH = areaH;
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(trackX, top, 2, trackH);
        var thumbH = (trackH * areaH) / (areaH + maxPos);
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
}
