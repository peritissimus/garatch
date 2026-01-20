using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;
using Toybox.Math;

class AnalogView extends WatchUi.WatchFace {
    private var _cx;
    private var _cy;
    private var _isSleeping = false;

    // Colors
    private var _cBlack = Graphics.COLOR_BLACK;
    private var _cWhite = Graphics.COLOR_WHITE;
    private var _cOrange = 0xFFAA00;
    private var _cGray = Graphics.COLOR_LT_GRAY;
    private var _cDkGray = Graphics.COLOR_DK_GRAY;

    // Fonts
    private var _fLarge;
    private var _fMedium;
    private var _fSmall;
    private var _fTiny;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _cx = dc.getWidth() / 2;
        _cy = dc.getHeight() / 2;

        _fLarge = Graphics.FONT_MEDIUM;
        _fMedium = Graphics.FONT_SMALL;
        _fSmall = Graphics.FONT_TINY;
        _fTiny = Graphics.FONT_XTINY;
    }

    function onUpdate(dc) {
        dc.setColor(_cBlack, _cBlack);
        dc.clear();

        drawDial(dc);
        drawDataFields(dc);
        drawHands(dc);
    }

    function drawDial(dc) {
        // Rounded rectangle parameters matching the watch bezel
        var margin = 4;
        var left = margin;
        var right = _cx * 2 - margin;
        var top = margin;
        var bottom = _cy * 2 - margin;
        var cornerR = 50.0;

        dc.setPenWidth(1);

        // === Dense ticks (120 ticks - every 3 degrees) - LONG ===
        for (var i = 0; i < 120; i++) {
            var angle = Math.toRadians(i * 3 - 90);
            var outerPt = getRoundedRectPoint(angle, left, top, right, bottom, cornerR);

            // Long ticks - 25px length
            var tickLen = 25;
            var innerPt = getRoundedRectPoint(angle, left + tickLen, top + tickLen, right - tickLen, bottom - tickLen, cornerR - tickLen);

            dc.setColor(_cDkGray, _cBlack);
            dc.drawLine(outerPt[0], outerPt[1], innerPt[0], innerPt[1]);
        }

        // === 5-minute ticks (extra long, brighter) ===
        for (var i = 0; i < 60; i += 5) {
            var angle = Math.toRadians(i * 6 - 90);
            var outerPt = getRoundedRectPoint(angle, left, top, right, bottom, cornerR);

            var tickLen = 35;
            var color = _cGray;

            if (i % 15 == 0) {
                // Major ticks at 12, 3, 6, 9
                tickLen = 45;
                color = _cWhite;
            }

            var innerPt = getRoundedRectPoint(angle, left + tickLen, top + tickLen, right - tickLen, bottom - tickLen, cornerR - tickLen);

            dc.setColor(color, _cBlack);
            dc.drawLine(outerPt[0], outerPt[1], innerPt[0], innerPt[1]);
        }

        // Hour numbers: 12, 3, 6, 9 - small and gray
        dc.setColor(_cDkGray, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx, 52, _fTiny, "12", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_cx, _cy * 2 - 66, _fTiny, "6", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(52, _cy - 8, _fTiny, "9", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(_cx * 2 - 52, _cy - 8, _fTiny, "3", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Returns [x, y] point on a rounded rectangle at given angle from center
    function getRoundedRectPoint(angle, left, top, right, bottom, r) {
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        var w = right - left;
        var h = bottom - top;
        var hw = w / 2.0;
        var hh = h / 2.0;

        // Clamp corner radius
        if (r > hw) { r = hw; }
        if (r > hh) { r = hh; }

        // Ray from center
        var dx = cos;
        var dy = sin;

        // Find intersection with rounded rect
        // Check each edge/corner region based on angle
        var x = 0.0;
        var y = 0.0;

        // Determine which quadrant/region
        var abscos = cos < 0 ? -cos : cos;
        var abssin = sin < 0 ? -sin : sin;

        // Straight edges (not in corner)
        var cornerAngle = Math.atan2(hh - r, hw - r);
        var testAngle = Math.atan2(abssin, abscos);

        if (testAngle < cornerAngle) {
            // Hits vertical edge (left or right)
            var edgeX = cos > 0 ? hw : -hw;
            var t = edgeX / cos;
            y = sin * t;
            x = edgeX;
        } else if (testAngle > (Math.PI / 2.0 - cornerAngle)) {
            // Hits horizontal edge (top or bottom)
            var edgeY = sin > 0 ? hh : -hh;
            var t = edgeY / sin;
            x = cos * t;
            y = edgeY;
        } else {
            // Hits corner arc
            // Corner center position
            var ccx = cos > 0 ? (hw - r) : -(hw - r);
            var ccy = sin > 0 ? (hh - r) : -(hh - r);

            // Intersect ray with circle at corner center
            // Parametric: P = t * (cos, sin)
            // Circle: (x - ccx)^2 + (y - ccy)^2 = r^2
            // Solve quadratic
            var a = 1.0; // cos^2 + sin^2
            var b = -2.0 * (cos * ccx + sin * ccy);
            var c = ccx * ccx + ccy * ccy - r * r;
            var disc = b * b - 4 * a * c;
            if (disc < 0) { disc = 0; }
            var t = (-b + Math.sqrt(disc)) / (2.0 * a);
            x = cos * t;
            y = sin * t;
        }

        return [_cx + x, _cy + y];
    }

    function drawDataFields(dc) {
        var info = ActivityMonitor.getInfo();
        var clockTime = System.getClockTime();
        var stats = System.getSystemStats();
        var now = Time.now();
        var date = Gregorian.info(now, Time.FORMAT_SHORT);

        // === TOP: STEPS ===
        var steps = (info has :steps && info.steps != null) ? info.steps : 0;
        var stepsStr = (steps >= 1000) ? (steps / 1000.0).format("%.1f") + "K" : steps.format("%d");

        dc.setColor(_cOrange, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx, _cy - 75, _fMedium, stepsStr, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(_cDkGray, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx, _cy - 55, _fTiny, "STP", Graphics.TEXT_JUSTIFY_CENTER);

        // === LEFT (9 o'clock): Day Name ===
        var dayName = getDayShort(date.day_of_week);
        dc.setColor(_cWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx - 70, _cy - 12, _fLarge, dayName, Graphics.TEXT_JUSTIFY_CENTER);
        // Bracket lines
        dc.setColor(_cDkGray, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(_cx - 90, _cy - 22, _cx - 50, _cy - 22);
        dc.drawLine(_cx - 90, _cy + 14, _cx - 50, _cy + 14);

        // === RIGHT (3 o'clock): Date Number ===
        var dayNum = date.day.format("%d");
        dc.setColor(_cWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx + 70, _cy - 12, _fLarge, dayNum, Graphics.TEXT_JUSTIFY_CENTER);
        // Bracket lines
        dc.setColor(_cDkGray, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(_cx + 50, _cy - 22, _cx + 90, _cy - 22);
        dc.drawLine(_cx + 50, _cy + 14, _cx + 90, _cy + 14);

        // === BOTTOM SECTION ===
        var bottomY = _cy + 50;

        // Far Left: CAL label + value
        var cal = (info has :calories && info.calories != null) ? info.calories : 0;
        var calStr = (cal >= 1000) ? (cal / 1000.0).format("%.1f") + "K" : cal.format("%d");
        dc.setColor(_cDkGray, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx - 70, bottomY, _fTiny, "CAL", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(_cOrange, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx - 70, bottomY + 14, _fMedium, calStr, Graphics.TEXT_JUSTIFY_CENTER);

        // Far Right: HR label + value
        var hr = "--";
        if (info has :currentHeartRate && info.currentHeartRate != null) {
            hr = info.currentHeartRate.format("%d");
        }
        dc.setColor(_cDkGray, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx + 70, bottomY, _fTiny, "HR", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(_cOrange, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx + 70, bottomY + 14, _fMedium, hr, Graphics.TEXT_JUSTIFY_CENTER);

        // === CENTER CLUSTER ===
        // Battery percentage at top
        var bat = stats.battery.format("%d");
        dc.setColor(_cWhite, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx, bottomY - 5, _fSmall, bat, Graphics.TEXT_JUSTIFY_CENTER);

        // Left icon: Stopwatch (circle with line) + active minutes
        dc.setColor(_cDkGray, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(_cx - 22, bottomY + 18, 6);
        dc.drawLine(_cx - 22, bottomY + 14, _cx - 22, bottomY + 18); // top stem
        dc.drawLine(_cx - 22, bottomY + 18, _cx - 19, bottomY + 15); // hand
        // Active minutes value below
        var activeMin = 0;
        if (info has :activeMinutesDay && info.activeMinutesDay != null) {
            if (info.activeMinutesDay has :total && info.activeMinutesDay.total != null) {
                activeMin = info.activeMinutesDay.total;
            }
        }
        dc.drawText(_cx - 22, bottomY + 28, _fTiny, activeMin.format("%d"), Graphics.TEXT_JUSTIFY_CENTER);

        // Center: Vertical divider line
        dc.setColor(_cDkGray, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(_cx, bottomY + 12, _cx, bottomY + 45);

        // Right icon: Moon (sleep/recovery) + value
        dc.setColor(_cDkGray, Graphics.COLOR_TRANSPARENT);
        // Simple moon crescent
        dc.drawArc(_cx + 22, bottomY + 18, 6, Graphics.ARC_CLOCKWISE, 45, 225);
        // Recovery time or body battery
        var recoveryVal = "--";
        if (info has :timeToRecovery && info.timeToRecovery != null) {
            recoveryVal = info.timeToRecovery.format("%d");
        }
        dc.drawText(_cx + 22, bottomY + 28, _fTiny, recoveryVal, Graphics.TEXT_JUSTIFY_CENTER);

        // AM/PM indicator below center
        var ampm = (clockTime.hour < 12) ? "AM" : "PM";
        dc.setColor(_cDkGray, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx, bottomY + 38, _fTiny, ampm, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawHands(dc) {
        var clockTime = System.getClockTime();
        var hour = clockTime.hour % 12;
        var minute = clockTime.min;
        var second = clockTime.sec;

        // Hour hand
        var hourAngle = Math.toRadians(((hour * 60) + minute) * 0.5 - 90);
        drawSkeletonHand(dc, hourAngle, 55, 7, _cWhite);

        // Minute hand
        var minAngle = Math.toRadians(minute * 6 - 90);
        drawSkeletonHand(dc, minAngle, 85, 5, _cWhite);

        // Second hand (hide when sleeping)
        if (!_isSleeping) {
            var secAngle = Math.toRadians(second * 6 - 90);
            dc.setColor(_cOrange, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            // Tail
            var xTail = _cx - 15 * Math.cos(secAngle);
            var yTail = _cy - 15 * Math.sin(secAngle);
            dc.drawLine(_cx, _cy, xTail, yTail);
            // Main
            var xEnd = _cx + 90 * Math.cos(secAngle);
            var yEnd = _cy + 90 * Math.sin(secAngle);
            dc.drawLine(_cx, _cy, xEnd, yEnd);
        }

        // Center circle
        dc.setColor(_cOrange, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_cx, _cy, 5);
        dc.setColor(_cBlack, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_cx, _cy, 2);
    }

    function drawSkeletonHand(dc, angle, length, width, color) {
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        var x1 = _cx + length * cos;
        var y1 = _cy + length * sin;

        var wx = width * Math.sin(angle);
        var wy = width * Math.cos(angle);

        // Outer shape
        var polyOuter = [
            [_cx + wx, _cy - wy],
            [x1 + wx/2, y1 - wy/2],
            [x1 - wx/2, y1 + wy/2],
            [_cx - wx, _cy + wy]
        ];

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(polyOuter);

        // Inner cutout
        var cutLen = length - 12;
        var cutW = width / 2.5;
        var cwx = cutW * Math.sin(angle);
        var cwy = cutW * Math.cos(angle);

        var cx1 = _cx + 12 * cos;
        var cy1 = _cy + 12 * sin;
        var cx2 = _cx + cutLen * cos;
        var cy2 = _cy + cutLen * sin;

        var polyInner = [
            [cx1 + cwx, cy1 - cwy],
            [cx2 + cwx, cy2 - cwy],
            [cx2 - cwx, cy2 + cwy],
            [cx1 - cwx, cy1 + cwy]
        ];

        dc.setColor(_cBlack, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(polyInner);
    }

    function getDayShort(dayVal) {
        // Short 2-letter day names like reference: Wd for Wednesday
        var days = ["Su", "Mo", "Tu", "Wd", "Th", "Fr", "Sa"];
        return days[dayVal - 1];
    }

    function onEnterSleep() {
        _isSleeping = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() {
        _isSleeping = false;
        WatchUi.requestUpdate();
    }
}
