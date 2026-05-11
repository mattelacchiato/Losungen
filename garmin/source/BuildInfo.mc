import Toybox.Lang;

// The version string lives in BuildVersion.mc (gitignored, regenerated
// by run-sim.sh / CI on every build). This stable wrapper exists so the
// rest of the code never has to import the generated file directly.
(:glance)
module BuildInfo {
    function version() as String {
        return BuildVersion.VERSION;
    }
}
