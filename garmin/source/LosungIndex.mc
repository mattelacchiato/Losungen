// DIAGNOSTIC: lookup matches the 5 days currently in days.xml. Combined
// with the reduced days.xml (5 entries) this tests whether the full
// 365-entry resource table — not the lookup module — is what blows the
// 64 KB glance budget. tools/convert.py regenerates the full version.
import Toybox.Lang;

(:glance)
module LosungIndex {
    function resForDay(month as Number, day as Number) as Lang.ResourceId or Null {
        var key = month * 100 + day;
        switch (key) {
            case 429: return Rez.Strings.D_0429;
            case 430: return Rez.Strings.D_0430;
            case 501: return Rez.Strings.D_0501;
            case 502: return Rez.Strings.D_0502;
            case 503: return Rez.Strings.D_0503;
        }
        return null;
    }
}
