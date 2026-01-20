using Toybox.Application;
using Toybox.WatchUi;

class Ghibli2App extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {}
    function onStop(state) {}

    function getInitialView() {
        return [new Ghibli2View()];
    }
}
