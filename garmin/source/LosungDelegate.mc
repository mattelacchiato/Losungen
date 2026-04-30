import Toybox.Lang;
import Toybox.WatchUi;

class LosungDelegate extends WatchUi.BehaviorDelegate {

    private var _view as LosungView or Null;

    function initialize() {
        BehaviorDelegate.initialize();
        _view = null;
    }

    function bind(view as LosungView) as Void {
        _view = view;
    }

    function onNextPage() as Boolean {
        return scroll(1);
    }

    function onPreviousPage() as Boolean {
        return scroll(-1);
    }

    function onSelect() as Boolean {
        return scroll(1);
    }

    // Catch raw key events too, so scrolling works even on devices where
    // page-up/down behaviour events aren't dispatched for our view type.
    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        var key = evt.getKey();
        if (key == WatchUi.KEY_UP) { return scroll(-1); }
        if (key == WatchUi.KEY_DOWN) { return scroll(1); }
        if (key == WatchUi.KEY_ENTER) { return scroll(1); }
        return false;
    }

    function onSwipe(evt as WatchUi.SwipeEvent) as Boolean {
        var dir = evt.getDirection();
        if (dir == WatchUi.SWIPE_UP) { return scroll(1); }
        if (dir == WatchUi.SWIPE_DOWN) { return scroll(-1); }
        return false;
    }

    private function scroll(delta as Number) as Boolean {
        if (_view != null) {
            _view.scrollBy(delta);
        }
        return true;
    }
}
