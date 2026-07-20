using Toybox.Application;

class OrbitApp extends Application.AppBase {
    function initialize() { AppBase.initialize(); }
    function onStart(state) {}
    function onStop(state) {}
    function getInitialView() { return [ new OrbitView() ]; }
}

function getApp() { return Application.getApp(); }
