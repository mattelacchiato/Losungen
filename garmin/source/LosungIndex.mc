// DIAGNOSTIC: temporarily reduced to a single case to test whether
// the full 365-case generated index blows the glance binary budget.
// If this version makes the glance render, the size hypothesis is
// confirmed and we'll switch to a different lookup mechanism.
import Toybox.Lang;

(:glance)
module LosungIndex {
    function resForDay(month as Number, day as Number) as Lang.ResourceId or Null {
        if (month == 5 && day == 1) {
            return Rez.Strings.D_0501;
        }
        return null;
    }
}
