using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Time.Gregorian;

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

        // Draw time
        drawTime(dc, _cx , _h - 100 );

        // Draw battery
        drawBattery(dc, 10, 10);
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

    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}
}
