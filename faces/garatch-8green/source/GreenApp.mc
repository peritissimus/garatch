using Toybox.Application;
using Toybox.WatchUi;

class GreenApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {}
    function onStop(state) {}

    function getInitialView() {
        return [new GreenView()];
    }
}
