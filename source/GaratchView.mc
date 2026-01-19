using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;

class GaratchView extends WatchUi.WatchFace {
    private var _screenWidth = 320;
    private var _screenHeight = 360;
    private var _centerX = 160;
    private var _centerY = 180;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _screenWidth = dc.getWidth();
        _screenHeight = dc.getHeight();
        _centerX = _screenWidth / 2;
    }

    function onShow() {}

    function onUpdate(dc) {
        // Clear screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw border (2px white)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        // dc.drawRectangle(0, 0, _screenWidth, _screenHeight);

        // Top bar: Battery (left) and Date (right)
        drawBattery(dc, 4, 4);
        drawDate(dc, _screenWidth - 4 , 0);

        // Center: Time display (HH:MM)
        drawTime(dc, _centerX, _centerY);

        // Bottom: Steps (left) and Heart Rate (right)
        drawSteps(dc, 80, 290);
        drawHeartRate(dc, 240, 290);
    }

    function drawBattery(dc, x, y) {
        var stats = System.getSystemStats();
        var battery = stats.battery;
        var batStr = battery.format("%d") + "%";

        // Battery icon (simple rectangle with fill)
        var iconW = 60;
        var iconH = 26;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRectangle(x , y , iconW, iconH);

        // Battery terminal
        dc.fillRectangle(x + 60, y + 8, 3, 10);

        // Fill level
        var fillW = (iconW - 4) * (battery / 100.0);
        if (battery <= 20) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        }
        if (fillW > 0) {
            dc.fillRectangle(x + 1 , y + 1, fillW, iconH - 2);
        }
    }

    function drawDate(dc, x, y) {
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var dayOfWeek = getDayName(info.day_of_week);
        var dateStr = Lang.format("$1$ $2$.$3$", [
            dayOfWeek,
            info.month.format("%02d"),
            info.day.format("%02d")
        ]);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, Graphics.FONT_XTINY, dateStr, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function drawTime(dc, x, y) {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour.format("%02d");
        var min = clockTime.min.format("%02d");

        // Using FONT_NUMBER_MILD (82px) to fit better
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Draw hour
        dc.drawText(x - 60, y, Graphics.FONT_NUMBER_MILD, hour, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw colon
        dc.drawText(x, y, Graphics.FONT_NUMBER_MILD, ":", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw minutes
        dc.drawText(x + 60, y, Graphics.FONT_NUMBER_MILD, min, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawSteps(dc, x, y) {
        var info = ActivityMonitor.getInfo();
        var steps = info.steps;
        var stepsStr = steps.format("%d");

        // Draw shoe icon (simple)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawEllipse(x, y - 15, 12, 6);
        dc.drawArc(x - 3, y - 18, 8, Graphics.ARC_CLOCKWISE, 0, 150);

        // Label
        dc.drawText(x, y + 10, Graphics.FONT_XTINY, "STEPS", Graphics.TEXT_JUSTIFY_CENTER);

        // Value
        dc.drawText(x, y + 30, Graphics.FONT_MEDIUM, stepsStr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawHeartRate(dc, x, y) {
        var hr = getHeartRate();

        // Draw heart icon
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        var hrY = y - 15;
        dc.fillCircle(x - 6, hrY, 6);
        dc.fillCircle(x + 6, hrY, 6);
        dc.fillPolygon([
            [x - 12, hrY + 1],
            [x + 12, hrY + 1],
            [x, hrY + 14]
        ]);

        // Label
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + 10, Graphics.FONT_XTINY, "HR", Graphics.TEXT_JUSTIFY_CENTER);

        // Value
        dc.drawText(x, y + 30, Graphics.FONT_MEDIUM, hr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function getHeartRate() {
        var info = ActivityMonitor.getInfo();
        if (info has :currentHeartRate && info.currentHeartRate != null) {
            return info.currentHeartRate.format("%d");
        }
        return "--";
    }

    function getDayName(dayVal) {
        var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        return days[dayVal - 1];
    }

    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}
}
