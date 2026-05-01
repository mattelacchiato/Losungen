// DIAGNOSTIC: returns a valid ResourceId (NoDataTitle) but never one
// of the 365 D_-entries. If the glance now renders, the issue is
// specifically referencing the day-resource entries, which seems to
// drag the full resource table into the glance binary.
import Toybox.Lang;

(:glance)
module LosungIndex {
    function resForDay(month as Number, day as Number) as Lang.ResourceId or Null {
        if (month == 5 && day == 1) {
            return Rez.Strings.NoDataTitle;
        }
        return null;
    }
}
