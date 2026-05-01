import Toybox.Lang;

// Diagnostic stub — no resource lookup, no Time/Gregorian imports,
// just literals. If the glance can render via this, the problem
// in the real LosungData/LosungIndex path is size, not annotations.
(:glance)
module StubData {
    function todayStub() as Array<String> {
        return ["Stub-Stelle", "Stub-Text"] as Array<String>;
    }
}
