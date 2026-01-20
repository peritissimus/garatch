using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Math;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;

class CosmicView extends WatchUi.WatchFace {
    private var _w, _h, _cx, _cy;

    // Cosmic Colors
    private const C_DEEP_SPACE = 0x0A0A1A;
    private const C_NEBULA_PURPLE = 0x8B5CF6;
    private const C_NEBULA_PINK = 0xEC4899;
    private const C_NEBULA_BLUE = 0x3B82F6;
    private const C_CYAN_GLOW = 0x22D3EE;
    private const C_STAR_WHITE = 0xFFFFF0;
    private const C_STAR_YELLOW = 0xFDE047;
    private const C_AURORA_GREEN = 0x4ADE80;
    private const C_ORANGE_SUN = 0xFB923C;
    private const C_DIM = 0x334155;

    // Star field (pseudo-random fixed positions)
    private var _stars;

    function initialize() {
        WatchFace.initialize();
        _stars = generateStars(80);
    }

    function onLayout(dc) {
        _w = dc.getWidth();
        _h = dc.getHeight();
        _cx = _w / 2;
        _cy = _h / 2;
    }

    function onUpdate(dc) {
        // 1. Deep space background
        dc.setColor(C_DEEP_SPACE, C_DEEP_SPACE);
        dc.clear();

        // 2. Draw nebula clouds
        drawNebula(dc);

        // 3. Draw star field
        drawStars(dc);

        // 4. Draw orbital rings
        drawOrbitalRings(dc);

        // 5. Draw planet/sun in corner
        drawCelestialBody(dc);

        // 6. Draw time (holographic style)
        drawTime(dc);

        // 7. Draw date
        drawDate(dc);

        // 8. Draw stats with glow
        drawStats(dc);

        // 9. Draw scanning line effect
        drawScanLine(dc);
    }

    function generateStars(count) {
        var stars = new [count];
        // Fixed star positions for consistent display
        var seed = 42;
        for (var i = 0; i < count; i++) {
            seed = ((seed * 1103 + 12345) % 65536);
            var x = (seed % 320);
            seed = ((seed * 1103 + 12345) % 65536);
            var y = (seed % 360);
            seed = ((seed * 1103 + 12345) % 65536);
            var brightness = (seed % 3); // 0=dim, 1=medium, 2=bright
            stars[i] = [x, y, brightness];
        }
        return stars;
    }

    function drawStars(dc) {
        var sec = System.getClockTime().sec;

        for (var i = 0; i < _stars.size(); i++) {
            var star = _stars[i];
            var x = star[0];
            var y = star[1];
            var brightness = star[2];

            // Twinkle effect - some stars blink based on time
            var twinkle = ((i + sec) % 5 == 0);

            if (brightness == 2 || twinkle) {
                dc.setColor(C_STAR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, 2);
                // Glow
                dc.setColor(C_CYAN_GLOW, Graphics.COLOR_TRANSPARENT);
                dc.drawCircle(x, y, 3);
            } else if (brightness == 1) {
                dc.setColor(C_STAR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, 1);
            } else {
                dc.setColor(C_DIM, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x, y, 1);
            }
        }
    }

    function drawNebula(dc) {
        // Purple nebula cloud (top-left)
        dc.setColor(C_NEBULA_PURPLE, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 8; i++) {
            var x = 30 + (i * 12);
            var y = 40 + ((i % 3) * 15);
            var r = 25 - (i * 2);
            dc.fillCircle(x, y, r);
        }

        // Pink nebula (bottom-right)
        dc.setColor(C_NEBULA_PINK, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 6; i++) {
            var x = _w - 60 + (i * 10);
            var y = _h - 80 + ((i % 2) * 20);
            var r = 20 - (i * 2);
            dc.fillCircle(x, y, r);
        }

        // Blue nebula streak (middle)
        dc.setColor(C_NEBULA_BLUE, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 5; i++) {
            var x = _cx - 40 + (i * 25);
            var y = _cy + 60 + ((i % 2) * 10);
            dc.fillCircle(x, y, 15 - i * 2);
        }
    }

    function drawOrbitalRings(dc) {
        dc.setPenWidth(1);

        // Outer ring (cyan)
        dc.setColor(C_CYAN_GLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(_cx, _cy, 140, Graphics.ARC_CLOCKWISE, 30, 150);
        dc.drawArc(_cx, _cy, 140, Graphics.ARC_CLOCKWISE, 210, 330);

        // Middle ring (purple)
        dc.setColor(C_NEBULA_PURPLE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(_cx, _cy, 120, Graphics.ARC_CLOCKWISE, 0, 90);
        dc.drawArc(_cx, _cy, 120, Graphics.ARC_CLOCKWISE, 180, 270);

        // Inner ring (pink, dotted effect)
        dc.setColor(C_NEBULA_PINK, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 36; i++) {
            var angle = Math.toRadians(i * 10);
            var x = _cx + 100 * Math.cos(angle);
            var y = _cy + 100 * Math.sin(angle);
            if (i % 2 == 0) {
                dc.fillCircle(x, y, 2);
            }
        }
    }

    function drawCelestialBody(dc) {
        // Sun/planet in top-right corner
        var px = _w - 35;
        var py = 35;

        // Outer glow layers
        dc.setColor(C_ORANGE_SUN, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(px, py, 30);

        dc.setColor(C_STAR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(px, py, 22);

        dc.setColor(C_STAR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(px, py, 14);

        // Corona rays
        dc.setColor(C_ORANGE_SUN, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        for (var i = 0; i < 8; i++) {
            var angle = Math.toRadians(i * 45);
            var x1 = px + 32 * Math.cos(angle);
            var y1 = py + 32 * Math.sin(angle);
            var x2 = px + 45 * Math.cos(angle);
            var y2 = py + 45 * Math.sin(angle);
            dc.drawLine(x1, y1, x2, y2);
        }
    }

    function drawTime(dc) {
        var clockTime = System.getClockTime();
        var hStr = clockTime.hour.format("%02d");
        var mStr = clockTime.min.format("%02d");
        var sStr = clockTime.sec.format("%02d");

        var timeY = _cy - 30;
        var font = Graphics.FONT_NUMBER_HOT;

        // Glow effect - draw slightly offset in glow color first
        dc.setColor(C_CYAN_GLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx + 2, timeY + 2, font, hStr + ":" + mStr, Graphics.TEXT_JUSTIFY_CENTER);

        // Main time text
        dc.setColor(C_STAR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx, timeY, font, hStr + ":" + mStr, Graphics.TEXT_JUSTIFY_CENTER);

        // Seconds with aurora green glow
        dc.setColor(C_AURORA_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx + 85, timeY + 15, Graphics.FONT_MEDIUM, sStr, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawDate(dc) {
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var dayName = days[info.day_of_week - 1];
        var dateStr = dayName + " " + info.day.format("%d");

        var y = _cy + 45;

        // Holographic box
        dc.setColor(C_NEBULA_PURPLE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawRoundedRectangle(_cx - 55, y - 5, 110, 28, 5);

        // Date text
        dc.setColor(C_STAR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx, y, Graphics.FONT_SMALL, dateStr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawStats(dc) {
        var info = ActivityMonitor.getInfo();
        var stats = System.getSystemStats();

        // Bottom left - Steps with glow
        var stepsY = _h - 50;
        var steps = (info has :steps && info.steps != null) ? info.steps : 0;
        var stepsStr = (steps >= 1000) ? (steps / 1000.0).format("%.1f") + "K" : steps.format("%d");

        // Step icon (shoe/footprint)
        dc.setColor(C_AURORA_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(25, stepsY, 3);
        dc.fillCircle(32, stepsY - 3, 3);
        dc.fillCircle(39, stepsY, 3);

        dc.setColor(C_STAR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(50, stepsY - 12, Graphics.FONT_SMALL, stepsStr, Graphics.TEXT_JUSTIFY_LEFT);

        // Bottom right - Battery with color gradient
        var batY = _h - 50;
        var bat = stats.battery;

        // Battery color based on level
        var batColor = C_AURORA_GREEN;
        if (bat < 20) {
            batColor = C_NEBULA_PINK;
        } else if (bat < 50) {
            batColor = C_ORANGE_SUN;
        }

        // Battery icon
        dc.setColor(batColor, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(_w - 85, batY - 8, 20, 12);
        dc.fillRectangle(_w - 65, batY - 5, 3, 6);
        var fillW = (16 * bat / 100).toNumber();
        dc.fillRectangle(_w - 83, batY - 6, fillW, 8);

        dc.setColor(C_STAR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_w - 50, batY - 12, Graphics.FONT_SMALL, bat.format("%d") + "%", Graphics.TEXT_JUSTIFY_LEFT);

        // Heart rate (top-left area, below nebula)
        var hr = "--";
        if (info has :currentHeartRate && info.currentHeartRate != null) {
            hr = info.currentHeartRate.format("%d");
        }

        // Heart icon
        dc.setColor(C_NEBULA_PINK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(20, 95, 5);
        dc.fillCircle(30, 95, 5);
        dc.fillPolygon([[12, 98], [38, 98], [25, 112]]);

        dc.setColor(C_STAR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(45, 90, Graphics.FONT_SMALL, hr, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawScanLine(dc) {
        // Animated horizontal scan line effect
        var sec = System.getClockTime().sec;
        var lineY = (sec * 6) % _h; // Moves down screen each second

        dc.setColor(C_CYAN_GLOW, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(0, lineY, _w, lineY);

        // Faded trail
        dc.setColor(C_DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, lineY - 5, _w, lineY - 5);
    }

    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}
}
