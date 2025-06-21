using Toybox.Application;
using Toybox.WatchUi;

class GaratchApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [ new GaratchView() ];
    }
}

function getApp() {
    return Application.getApp();
}