import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Lang;

class LosungApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new LosungView();
        var delegate = new LosungDelegate();
        delegate.bind(view);
        return [view, delegate];
    }

    (:glance)
    function getGlanceView() as [GlanceView] or [GlanceView, GlanceViewDelegate] or Null {
        return [new LosungGlanceView()];
    }
}
