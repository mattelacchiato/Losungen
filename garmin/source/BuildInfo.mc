import Toybox.Lang;

// Default value for local builds. CI overwrites this file with the
// actual run number + timestamp before invoking monkeyc — see the
// "Stamp build version" step in .github/workflows/build.yml.
(:glance)
module BuildInfo {
    const VERSION = "local";
}
