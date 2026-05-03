import Toybox.Lang;
import Toybox.WatchUi;

class LosungDelegate extends WatchUi.BehaviorDelegate {

    private var _view as LosungView or Null;
    private var _lastDragY as Number;
    private var _dragging as Boolean;

    function initialize() {
        BehaviorDelegate.initialize();
        _view = null;
        _lastDragY = 0;
        _dragging = false;
    }

    function bind(view as LosungView) as Void {
        _view = view;
    }

    function onNextPage() as Boolean {
        return page(1);
    }

    function onPreviousPage() as Boolean {
        return page(-1);
    }

    function onSelect() as Boolean {
        return page(1);
    }

    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        var key = evt.getKey();
        if (key == WatchUi.KEY_UP) { return page(-1); }
        if (key == WatchUi.KEY_DOWN) { return page(1); }
        if (key == WatchUi.KEY_ENTER) { return page(1); }
        return false;
    }

    // Pixel-accurate touch scrolling: track finger Y between drag events
    // and shift the text by the same delta the finger moved.
    function onDrag(evt as WatchUi.DragEvent) as Boolean {
        var coords = evt.getCoordinates();
        var y = coords[1] as Number;
        var type = evt.getType();
        if (type == WatchUi.DRAG_TYPE_START) {
            _lastDragY = y;
            _dragging = true;
            return true;
        }
        if (type == WatchUi.DRAG_TYPE_CONTINUE && _dragging) {
            if (_view != null) {
                _view.scrollByPx(_lastDragY - y);
            }
            _lastDragY = y;
            return true;
        }
        if (type == WatchUi.DRAG_TYPE_STOP) {
            _dragging = false;
            return true;
        }
        return false;
    }

    // Consume swipes so they don't double-scroll on top of the drag stream.
    function onSwipe(evt as WatchUi.SwipeEvent) as Boolean {
        return true;
    }

    private function page(direction as Number) as Boolean {
        if (_view != null) {
            _view.pageScroll(direction);
        }
        return true;
    }
}
