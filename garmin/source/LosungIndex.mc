// DIAGNOSTIC: no Rez.Strings reference at all. If the glance now
// renders, the issue is referencing Rez.Strings entries (which seem
// to drag the full 365-entry resource table into the glance binary).
import Toybox.Lang;

(:glance)
module LosungIndex {
    function resForDay(month as Number, day as Number) as Number or Null {
        if (month == 5 && day == 1) {
            return 99999;
        }
        return null;
    }
}
