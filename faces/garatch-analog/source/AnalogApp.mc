using Toybox.Application;
using Toybox.WatchUi;

class AnalogApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {}
    function onStop(state) {}

    function getInitialView() {
        return [new AnalogView()];
    }
}
