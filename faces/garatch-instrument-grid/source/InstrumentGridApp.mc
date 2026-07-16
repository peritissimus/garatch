using Toybox.Application;

class InstrumentGridApp extends Application.AppBase {
    function initialize() { AppBase.initialize(); }
    function onStart(state) {}
    function onStop(state) {}
    function getInitialView() { return [ new InstrumentGridView() ]; }
}

function getApp() { return Application.getApp(); }
