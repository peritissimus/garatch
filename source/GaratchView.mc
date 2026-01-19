using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;

class GaratchView extends WatchUi.WatchFace {
    private var _w; // Width
    private var _h; // Height
    
    // Fonts
    private var _fTime;  
    private var _fData;  
    private var _fLabel; // Tiny font for "technical" labels

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _w = dc.getWidth();  // 320
        _h = dc.getHeight(); // 360

        // Load Fonts
        _fTime  = Graphics.FONT_SYSTEM_NUMBER_HOT; 
        _fData  = Graphics.FONT_SYSTEM_MEDIUM;
        _fLabel = Graphics.FONT_SYSTEM_XTINY; 
    }

    function onUpdate(dc) {
        // 1. CLEAR BACKGROUND
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // 2. DRAW THE BLUEPRINT GRID (The "Architecture")
        drawBlueprintLayout(dc);

        // 3. DRAW DATA
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // --- TOP SECTION (y: 0 - 70) ---
        drawTopBar(dc);

        // --- MIDDLE SECTION (y: 70 - 270) ---
        drawTime(dc);

        // --- BOTTOM SECTION (y: 270 - 360) ---
        drawStats(dc);
    }

    // --- ARCHITECTURE LAYOUT ---
    function drawBlueprintLayout(dc) {
        // Set Grid Color (Dark Gray for subtle lines)
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);

        var topY = 70;
        var bottomY = 270;
        var centerX = _w / 2;

        // 1. Main Horizontal Lines
        dc.drawLine(0, topY, _w, topY);       // Top Divider
        dc.drawLine(0, bottomY, _w, bottomY); // Bottom Divider

        // 2. Vertical Lines
        dc.drawLine(centerX, 0, centerX, topY);          // Top Split
        dc.drawLine(centerX, bottomY, centerX, _h);      // Bottom Split

        // 3. Outer Border (Optional, framing)
        dc.drawRectangle(1, 1, _w-2, _h-2);
        
        // 4. "Technical" ticks on the Time Box
        var gap = 15;
        // Top Left Corner of Time box
        dc.drawLine(10, topY + 10, 10 + gap, topY + 10);
        dc.drawLine(10, topY + 10, 10, topY + 10 + gap);
        // Bottom Right Corner of Time box
        dc.drawLine(_w - 10, bottomY - 10, _w - 10 - gap, bottomY - 10);
        dc.drawLine(_w - 10, bottomY - 10, _w - 10, bottomY - 10 - gap);
    }

    function drawTopBar(dc) {
        var centerX = _w / 2;
        var centerY = 35; // Middle of top section (0-70)

        // --- LEFT: BATTERY ---
        var stats = System.getSystemStats();
        var bat = stats.battery;

        // Small Label
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(10, 5, _fLabel, "BATT", Graphics.TEXT_JUSTIFY_LEFT);

        // Value - positioned tighter to left side
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(85, centerY, _fData, bat.format("%d") + "%", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);

        // --- RIGHT: DATE ---
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var dateStr = Lang.format("$1$ $2$.$3$", [
            getDateName(info.day_of_week),
            info.month.format("%02d"),
            info.day.format("%02d")
        ]);

        // Small Label
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_w - 10, 5, _fLabel, "DATE", Graphics.TEXT_JUSTIFY_RIGHT);

        // Value - positioned tighter to right side
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(235, centerY, _fData, dateStr, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawTime(dc) {
        var clockTime = System.getClockTime();
        var timeStr = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        var centerX = _w / 2;
        var centerY = (_h / 2); // 180

        // Main Time
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY, _fTime, timeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawStats(dc) {
        var topY = 270;
        var centerY = topY + ((_h - topY) / 2); // Approx 315
        var q1 = _w / 4;      // 80
        var q3 = _w * 0.75;   // 240

        var info = ActivityMonitor.getInfo();
        
        // --- STEPS (Left) ---
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(q1, topY + 5, _fLabel, "STEPS", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(q1, centerY + 5, _fData, info.steps.format("%d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // --- HR (Right) ---
        var hr = "--";
        if (info has :currentHeartRate && info.currentHeartRate != null) {
            hr = info.currentHeartRate.format("%d");
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(q3, topY + 5, _fLabel, "HR", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(q3, centerY + 5, _fData, hr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function getDateName(dayVal) {
        var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        return days[dayVal - 1];
    }

    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}
}
