using Toybox.Application;

class AtelierApp extends Application.AppBase {
    function initialize() { AppBase.initialize(); }
    function onStart(state) {}
    function onStop(state) {}
    function getInitialView() { return [ new AtelierView() ]; }
}

function getApp() { return Application.getApp(); }
