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
        if (_view != null) { _view.scrollBy(1); }
        return true;
    }

    function onPreviousPage() as Boolean {
        if (_view != null) { _view.scrollBy(-1); }
        return true;
    }

    function onSelect() as Boolean {
        if (_view != null) { _view.scrollBy(1); }
        return true;
    }
}
