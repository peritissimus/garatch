using Toybox.Application;

class TelemetryApp extends Application.AppBase {
    function initialize() { AppBase.initialize(); }
    function onStart(state) {}
    function onStop(state) {}
    function getInitialView() { return [ new TelemetryView() ]; }
}

function getApp() { return Application.getApp(); }
