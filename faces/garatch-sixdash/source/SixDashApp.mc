using Toybox.Application;

class SixDashApp extends Application.AppBase {
    function initialize() { AppBase.initialize(); }
    function onStart(state) {}
    function onStop(state) {}
    function getInitialView() { return [ new SixDashView() ]; }
}

function getApp() { return Application.getApp(); }
