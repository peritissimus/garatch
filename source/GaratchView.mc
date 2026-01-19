using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;

class GaratchView extends WatchUi.WatchFace {
    private var _screenWidth;
    private var _screenHeight;
    private var _centerX;
    private var _centerY;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _screenWidth = dc.getWidth();
        _screenHeight = dc.getHeight();
        _centerX = _screenWidth / 2;
        _centerY = _screenHeight / 2;
    }

    function onShow() {}

    function onUpdate(dc) {
        if (_centerX == null || _centerY == null) {
            onLayout(dc);
        }
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        
        drawTime(dc);
        drawDate(dc);
        drawStats(dc);
    }

    function drawTime(dc) {
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [
            clockTime.hour.format("%02d"),
            clockTime.min.format("%02d")
        ]);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _centerY - 20, Graphics.FONT_NUMBER_MEDIUM, timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawDate(dc) {
        var now = Time.now();
        var date = Gregorian.info(now, Time.FORMAT_SHORT);
        var dateString = Lang.format("$1$ $2$", [
            date.day_of_week.toString().substring(0, 3).toUpper(),
            date.day
        ]);
        
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_centerX, _centerY - 60, Graphics.FONT_TINY, dateString, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawStats(dc) {
        var yOffset = _centerY + 20;
        var statSpacing = 25;
        
        var steps = ActivityMonitor.getInfo().steps;
        drawStatLine(dc, _centerX, yOffset, "STEPS", steps.toString());
        
        var hr = getHeartRate();
        drawStatLine(dc, _centerX, yOffset + statSpacing, "HR", hr);
        
        var stress = getStress();
        drawStatLine(dc, _centerX, yOffset + statSpacing * 2, "STRESS", stress);
    }

    function drawStatLine(dc, x, y, label, value) {
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x - 40, y, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + 40, y, Graphics.FONT_TINY, value, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function getHeartRate() {
        if (ActivityMonitor has :getHeartRateHistory) {
            var hrHistory = ActivityMonitor.getHeartRateHistory(1, true);
            var hrSample = hrHistory.next();
            if (hrSample != null && hrSample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                return hrSample.heartRate.toString();
            }
        }
        return "--";
    }

    function getStress() {
        var info = ActivityMonitor.getInfo();
        if (info has :stress && info.stress != null) {
            return info.stress.toString();
        }
        return "--";
    }

    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}
}