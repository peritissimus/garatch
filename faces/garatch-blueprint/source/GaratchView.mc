using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;
using Toybox.Activity;

class GaratchView extends WatchUi.WatchFace {
    private var _w; // Width
    private var _h; // Height

    // Fonts
    private var _fTime;
    private var _fData;

    // Pre-calculated heights
    private var _hLabel = 8;  // Height of your pixel char (approx 8px)
    private var _hData;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _w = dc.getWidth();  // 320
        _h = dc.getHeight(); // 360

        // Load Fonts
        _fTime = Graphics.FONT_SYSTEM_NUMBER_HOT;
        // XTINY fits best under your custom pixel labels
        _fData = Graphics.FONT_SYSTEM_XTINY;

        // Get actual font height for data values to center them later
        _hData = dc.getFontHeight(_fData);
    }

    function onUpdate(dc) {
        // 1. CLEAR BACKGROUND
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // 2. DRAW THE BLUEPRINT GRID
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

        // 3. Outer Border with rounded corners (Matching Venu Sq 2 hardware)
        var r = 40; // Adjusted radius to match hardware curve better
        var x1 = 1; // 1px offset to ensure line is visible
        var y1 = 1;
        var x2 = _w - 2; 
        var y2 = _h - 2;

        // Top edge
        dc.drawLine(x1 + r, y1, x2 - r, y1);
        // Bottom edge
        dc.drawLine(x1 + r, y2, x2 - r, y2);
        // Left edge
        dc.drawLine(x1, y1 + r, x1, y2 - r);
        // Right edge
        dc.drawLine(x2, y1 + r, x2, y2 - r);

        // Corner arcs
        dc.drawArc(x1 + r, y1 + r, r, Graphics.ARC_COUNTER_CLOCKWISE, 90, 180);  // Top-left
        dc.drawArc(x2 - r, y1 + r, r, Graphics.ARC_COUNTER_CLOCKWISE, 0, 90);    // Top-right
        dc.drawArc(x2 - r, y2 - r, r, Graphics.ARC_COUNTER_CLOCKWISE, 270, 0);   // Bottom-right
        dc.drawArc(x1 + r, y2 - r, r, Graphics.ARC_COUNTER_CLOCKWISE, 180, 270); // Bottom-left

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
        var topY = 70;
        var centerX = _w / 2;
        var spacing = 4; 

        // Vertical Centering Math
        var totalHeight = _hLabel + spacing + _hData;
        var startY = (topY - totalHeight) / 2;
        var labelY = startY;
        var valueY = labelY + _hLabel + spacing;

        var leftCenterX = centerX / 2;
        var rightCenterX = centerX + (centerX / 2);

        // --- LEFT HALF: BATTERY ---
        var stats = System.getSystemStats();
        var bat = stats.battery;

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        drawPixelLabel(dc, leftCenterX, labelY, "BATT");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(leftCenterX, valueY, _fData, bat.format("%d") + "%", Graphics.TEXT_JUSTIFY_CENTER);

        // --- RIGHT HALF: DATE ---
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var dateStr = Lang.format("$1$ $2$.$3$", [
            getDateName(info.day_of_week),
            info.month.format("%02d"),
            info.day.format("%02d")
        ]);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        drawPixelLabel(dc, rightCenterX, labelY, "DATE");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightCenterX, valueY, _fData, dateStr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawTime(dc) {
        var clockTime = System.getClockTime();
        var timeStr = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
        var centerX = _w / 2;
        var centerY = (_h / 2); 

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY, _fTime, timeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawStats(dc) {
        var topY = 270;
        var sectionHeight = _h - topY; 
        var centerX = _w / 2;
        var spacing = 4;

        // Vertical Centering Math
        var totalHeight = _hLabel + spacing + _hData;
        var startY = topY + (sectionHeight - totalHeight) / 2;
        var labelY = startY;
        var valueY = labelY + _hLabel + spacing;

        var leftCenterX = centerX / 2;
        var rightCenterX = centerX + (centerX / 2);

        var info = ActivityMonitor.getInfo();

        // --- LEFT HALF: STEPS ---
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        drawPixelLabel(dc, leftCenterX, labelY, "STEPS");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(leftCenterX, valueY, _fData, info.steps.format("%d"), Graphics.TEXT_JUSTIFY_CENTER);

        // --- RIGHT HALF: HR ---
        var hr = "--";
        var actInfo = Activity.getActivityInfo();
        if (actInfo != null && actInfo.currentHeartRate != null) {
            hr = actInfo.currentHeartRate.format("%d");
        } else if (info has :currentHeartRate && info.currentHeartRate != null) {
            hr = info.currentHeartRate.format("%d");
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        drawPixelLabel(dc, rightCenterX, labelY, "HR");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightCenterX, valueY, _fData, hr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // --- CUSTOM PIXEL FONT DRAWER ---
    function drawPixelLabel(dc, cx, y, label) {
        var charW = 6;
        var spacing = 2;
        // Calculate total width to center align the group
        var totalW = (label.length() * charW) + ((label.length() - 1) * spacing);
        var x = cx - (totalW / 2);

        var chars = label.toCharArray();

        for (var i = 0; i < chars.size(); i++) {
            drawPixelChar(dc, x, y, chars[i]);
            x += charW + spacing;
        }
    }

    function drawPixelChar(dc, x, y, ch) {
        dc.setPenWidth(1);
        
        // B
        if (ch == 'B') {
            dc.drawLine(x, y, x, y+7);
            dc.drawLine(x, y, x+4, y);
            dc.drawLine(x+4, y, x+5, y+1);
            dc.drawLine(x+5, y+1, x+5, y+2);
            dc.drawLine(x+5, y+2, x+4, y+3);
            dc.drawLine(x, y+3, x+4, y+3);
            dc.drawLine(x+4, y+3, x+5, y+4);
            dc.drawLine(x+5, y+4, x+5, y+6);
            dc.drawLine(x+5, y+6, x+4, y+7);
            dc.drawLine(x, y+7, x+4, y+7);
            return 6;
        } 
        // A
        else if (ch == 'A') {
            dc.drawLine(x+2, y, x, y+7);
            dc.drawLine(x+3, y, x+5, y+7);
            dc.drawLine(x+1, y+4, x+4, y+4);
            return 6;
        } 
        // T
        else if (ch == 'T') {
            dc.drawLine(x, y, x+5, y);
            dc.drawLine(x+2, y, x+2, y+7);
            return 6;
        } 
        // D
        else if (ch == 'D') {
            dc.drawLine(x, y, x, y+7);
            dc.drawLine(x, y, x+4, y);
            dc.drawLine(x+4, y, x+5, y+1);
            dc.drawLine(x+5, y+1, x+5, y+6);
            dc.drawLine(x+5, y+6, x+4, y+7);
            dc.drawLine(x, y+7, x+4, y+7);
            return 6;
        } 
        // E
        else if (ch == 'E') {
            dc.drawLine(x, y, x, y+7);
            dc.drawLine(x, y, x+5, y);
            dc.drawLine(x, y+3, x+4, y+3);
            dc.drawLine(x, y+7, x+5, y+7);
            return 6;
        } 
        // S
        else if (ch == 'S') {
            dc.drawLine(x+1, y, x+5, y);
            dc.drawLine(x, y+1, x, y+2);
            dc.drawLine(x+1, y+3, x+4, y+3);
            dc.drawLine(x+5, y+4, x+5, y+6);
            dc.drawLine(x, y+7, x+4, y+7);
            return 6;
        } 
        // P
        else if (ch == 'P') {
            dc.drawLine(x, y, x, y+7);
            dc.drawLine(x, y, x+4, y);
            dc.drawLine(x+4, y, x+5, y+1);
            dc.drawLine(x+5, y+1, x+5, y+2);
            dc.drawLine(x+5, y+2, x+4, y+3);
            dc.drawLine(x, y+3, x+4, y+3);
            return 6;
        } 
        // H
        else if (ch == 'H') {
            dc.drawLine(x, y, x, y+7);
            dc.drawLine(x+5, y, x+5, y+7);
            dc.drawLine(x, y+3, x+5, y+3);
            return 6;
        } 
        // R
        else if (ch == 'R') {
            dc.drawLine(x, y, x, y+7);
            dc.drawLine(x, y, x+4, y);
            dc.drawLine(x+4, y, x+5, y+1);
            dc.drawLine(x+5, y+1, x+5, y+2);
            dc.drawLine(x+5, y+2, x+4, y+3);
            dc.drawLine(x, y+3, x+4, y+3);
            dc.drawLine(x+2, y+3, x+5, y+7);
            return 6;
        }
        return 0;
    }

    function getDateName(dayVal) {
        var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        return days[dayVal - 1];
    }

    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}
}
