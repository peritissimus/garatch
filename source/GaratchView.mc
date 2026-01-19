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

        drawBorder(dc);
        drawGrid(dc);  // GRID HELPER - shows layout lines
        drawTime(dc);
        drawDate(dc);
        drawStats(dc);
    }

    function drawBorder(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRectangle(0, 0, _screenWidth, _screenHeight);
    }

    // Helper function to draw grid lines for layout testing
    function drawGrid(dc) {
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);

        // Vertical center line
        dc.drawLine(_centerX, 0, _centerX, _screenHeight);

        // Horizontal center lines
        dc.drawLine(0, _centerY, _screenWidth, _centerY);
    }

    function drawTime(dc) {
        var clockTime = System.getClockTime();
        var hourString = _screenHeight.format("%02d");
        var minString = _screenWidth.format("%02d");

        var leftX = 15;
        var timeY = _centerY - 30;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(leftX, timeY, Graphics.FONT_NUMBER_HOT, hourString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(leftX, timeY + 50, Graphics.FONT_NUMBER_HOT, minString, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawDate(dc) {
        var now = Time.now();
        var date = Gregorian.info(now, Time.FORMAT_SHORT);
        var dateString = Lang.format("$1$ $2$.$3$", [
            date.day_of_week.toString().substring(0, 3).toUpper(),
            date.day,
            date.month
        ]);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(10, 10, Graphics.FONT_XTINY, dateString, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawStats(dc) {
        var rightX = _screenWidth - 10;
        var startY = _centerY - 30;
        var spacing = 35;

        var info = ActivityMonitor.getInfo();
        var steps = info.steps;
        var hr = getHeartRate();
        var stress = getStress();

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightX, startY, Graphics.FONT_XTINY, "STEPS", Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightX, startY + 15, Graphics.FONT_SMALL, steps.toString(), Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightX, startY + spacing, Graphics.FONT_XTINY, "HR", Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightX, startY + spacing + 15, Graphics.FONT_SMALL, hr, Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightX, startY + spacing * 2, Graphics.FONT_XTINY, "STRESS", Graphics.TEXT_JUSTIFY_RIGHT);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightX, startY + spacing * 2 + 15, Graphics.FONT_SMALL, stress, Graphics.TEXT_JUSTIFY_RIGHT);
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
