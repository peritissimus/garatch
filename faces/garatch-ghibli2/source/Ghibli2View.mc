using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;
using Toybox.Activity;

class Ghibli2View extends WatchUi.WatchFace {
    private var _bgImage;
    private var _w, _h, _cx, _cy;
    private var _offX = 0, _offY = 0;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _w = dc.getWidth();
        _h = dc.getHeight();
        _cx = _w / 2;
        _cy = _h / 2;
        _bgImage = WatchUi.loadResource(Rez.Drawables.GhibliBg);
    }

    function onUpdate(dc) {
        // Draw background image with offset
        dc.drawBitmap(_offX, _offY, _bgImage);

        // Draw battery (top left)
        drawBattery(dc, 10, 10);

        // Draw date/day (top right)
        drawDate(dc, _cx + 4, _h - 60);

        // Draw time (bottom center)
        drawTime(dc, _cx , _h - 100 );

        // Draw heart rate (bottom left)
        drawHeartRate(dc, 4, _h - 39);

        // Draw steps (bottom right)
        drawSteps(dc, _w - 4, _h - 39);
    }

    function drawTime(dc, xOff, yOff) {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var hour = now.hour;
        var min = now.min;

        // Format time string
        var timeStr = hour.format("%02d") + ":" + min.format("%02d");

        // Draw time with scaled pixel font (scale 4 = 4x4 pixel blocks)
        var scale = 4;
        var timeY =  yOff;
        var timeX =  xOff;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        PixelFont.drawLabelScaled(dc, timeX + 4, timeY + 4, timeStr, scale);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        PixelFont.drawLabelScaled(dc, timeX, timeY, timeStr, scale);
    }

    function drawBattery(dc, x, y) {
        var battery = System.getSystemStats().battery.toNumber();
        var w = 20;
        var h = 10;
        var fillW = (battery * (w - 2) / 100).toNumber();

        // Battery outline
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(x, y, w, h);
        dc.fillRectangle(x + w, y + 3, 2, 4); // battery tip

        // Battery fill
        if (battery <= 20) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        } else if (battery <= 50) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(x + 1, y + 1, fillW, h - 2);
    }

    function drawSteps(dc, x, y) {
        var steps = ActivityMonitor.getInfo().steps;
        if (steps == null) { steps = 1234; }
        var stepsStr = steps.toString();


        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + 4, y + 4, Graphics.FONT_XTINY, stepsStr, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, Graphics.FONT_XTINY, stepsStr, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function drawHeartRate(dc, x, y) {
        var hr = Activity.getActivityInfo().currentHeartRate;
        if (hr == null) { hr = 0; }
        var hrStr = hr.toString();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + 4, y + 4, Graphics.FONT_XTINY, hrStr, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, Graphics.FONT_XTINY, hrStr, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawDate(dc, x, y) {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var dayStr = days[now.day_of_week - 1];
        var dateStr = dayStr + " " + now.day.format("%02d") + "/" + now.month.format("%02d");

        var scale = 2;

        // Draw day (e.g., "MON")
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        PixelFont.drawLabelScaled(dc, x + 2, y + 2, dateStr, scale);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        PixelFont.drawLabelScaled(dc, x , y, dateStr, scale);

        // // Draw date (e.g., "21/01")
        // dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        // PixelFont.drawLabelScaled(dc, x - 30 + 1, y + 20 + 1, dateStr, scale);
        // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // PixelFont.drawLabelScaled(dc, x - 30, y + 20, dateStr, scale);
    }

    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}
}
