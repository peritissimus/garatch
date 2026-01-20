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
    private var _hLabel = 10;  // Pixel-drawn label height (6x8 grid)
    private var _hData;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _w = dc.getWidth();  // 320
        _h = dc.getHeight(); // 360

        // Load Fonts
        _fTime = Graphics.FONT_SYSTEM_NUMBER_HOT;
        _fData = Graphics.FONT_XTINY;

        // Get actual font height for data values
        _hData = dc.getFontHeight(_fData);
    }

    // Draw a tiny pixel letter (6x8 grid) at position x,y
    // Returns width of drawn character for spacing
    function drawPixelChar(dc, x, y, ch) {
        // Each char is 6w x 8h pixels, 1px pen
        dc.setPenWidth(1);

        if (ch == 'B') {
            dc.drawLine(x, y, x, y+7);           // Left vertical
            dc.drawLine(x, y, x+4, y);           // Top horizontal
            dc.drawLine(x+4, y, x+5, y+1);       // Top-right curve
            dc.drawLine(x+5, y+1, x+5, y+2);
            dc.drawLine(x+5, y+2, x+4, y+3);     // Middle curve
            dc.drawLine(x, y+3, x+4, y+3);       // Middle horizontal
            dc.drawLine(x+4, y+3, x+5, y+4);     // Bottom-right curve
            dc.drawLine(x+5, y+4, x+5, y+6);
            dc.drawLine(x+5, y+6, x+4, y+7);
            dc.drawLine(x, y+7, x+4, y+7);       // Bottom horizontal
            return 6;
        } else if (ch == 'A') {
            dc.drawLine(x+2, y, x, y+7);         // Left diagonal
            dc.drawLine(x+3, y, x+5, y+7);       // Right diagonal
            dc.drawLine(x+1, y+4, x+4, y+4);     // Middle bar
            return 6;
        } else if (ch == 'T') {
            dc.drawLine(x, y, x+5, y);           // Top horizontal
            dc.drawLine(x+2, y, x+2, y+7);       // Vertical
            return 6;
        } else if (ch == 'D') {
            dc.drawLine(x, y, x, y+7);           // Left vertical
            dc.drawLine(x, y, x+4, y);           // Top
            dc.drawLine(x+4, y, x+5, y+1);
            dc.drawLine(x+5, y+1, x+5, y+6);     // Right vertical
            dc.drawLine(x+5, y+6, x+4, y+7);
            dc.drawLine(x, y+7, x+4, y+7);       // Bottom
            return 6;
        } else if (ch == 'E') {
            dc.drawLine(x, y, x, y+7);           // Left vertical
            dc.drawLine(x, y, x+5, y);           // Top
            dc.drawLine(x, y+3, x+4, y+3);       // Middle
            dc.drawLine(x, y+7, x+5, y+7);       // Bottom
            return 6;
        } else if (ch == 'S') {
            dc.drawLine(x+1, y, x+5, y);         // Top
            dc.drawLine(x, y+1, x, y+2);         // Top-left
            dc.drawLine(x+1, y+3, x+4, y+3);     // Middle
            dc.drawLine(x+5, y+4, x+5, y+6);     // Bottom-right
            dc.drawLine(x, y+7, x+4, y+7);       // Bottom
            return 6;
        } else if (ch == 'P') {
            dc.drawLine(x, y, x, y+7);           // Left vertical
            dc.drawLine(x, y, x+4, y);           // Top
            dc.drawLine(x+4, y, x+5, y+1);
            dc.drawLine(x+5, y+1, x+5, y+2);
            dc.drawLine(x+5, y+2, x+4, y+3);
            dc.drawLine(x, y+3, x+4, y+3);       // Middle
            return 6;
        } else if (ch == 'H') {
            dc.drawLine(x, y, x, y+7);           // Left vertical
            dc.drawLine(x+5, y, x+5, y+7);       // Right vertical
            dc.drawLine(x, y+3, x+5, y+3);       // Middle
            return 6;
        } else if (ch == 'R') {
            dc.drawLine(x, y, x, y+7);           // Left vertical
            dc.drawLine(x, y, x+4, y);           // Top
            dc.drawLine(x+4, y, x+5, y+1);
            dc.drawLine(x+5, y+1, x+5, y+2);
            dc.drawLine(x+5, y+2, x+4, y+3);
            dc.drawLine(x, y+3, x+4, y+3);       // Middle
            dc.drawLine(x+2, y+3, x+5, y+7);     // Leg
            return 6;
        }
        return 0;
    }

    // Draw a label string centered at x,y using pixel characters
    function drawPixelLabel(dc, cx, y, label) {
        var charW = 6;
        var spacing = 2;
        var totalW = label.length() * charW + (label.length() - 1) * spacing;
        var x = cx - totalW / 2;

        for (var i = 0; i < label.length(); i++) {
            drawPixelChar(dc, x, y, label.substring(i, i+1).toCharArray()[0]);
            x += charW + spacing;
        }
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

        // 3. Outer Border with rounded corners
        var r = 20; // Corner radius
        var x1 = 0;
        var y1 = 0;
        var x2 = _w - 0;  // Right line +1px
        var y2 = _h - 0;  // Bottom line +1px

        // Top edge (between corners)
        dc.drawLine(x1 + r, y1, x2 - r, y1);
        // Bottom edge
        dc.drawLine(x1 + r, y2, x2 - r, y2);
        // Left edge
        dc.drawLine(x1, y1 + r, x1, y2 - r);
        // Right edge
        dc.drawLine(x2, y1 + r, x2, y2 - r);

        // Corner arcs (top-left, top-right, bottom-right, bottom-left)
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
        // Top section geometry: y = 0 to 70, split vertically at centerX
        var topY = 70;
        var centerX = _w / 2;
        var spacing = 4; // Gap between label and value

        // Calculate vertical positions
        var totalHeight = _hLabel + spacing + _hData;
        var startY = (topY - totalHeight) / 2;
        var labelY = startY;
        var valueY = labelY + _hLabel + spacing;

        // Center of left half (80) and right half (240)
        var leftCenterX = centerX / 2;
        var rightCenterX = centerX + (centerX / 2);

        // --- LEFT HALF: BATTERY ---
        var stats = System.getSystemStats();
        var bat = stats.battery;

        // Pixel-drawn label
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        drawPixelLabel(dc, leftCenterX, labelY, "BATT");

        // Value
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

        // Pixel-drawn label
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        drawPixelLabel(dc, rightCenterX, labelY, "DATE");

        // Value
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightCenterX, valueY, _fData, dateStr, Graphics.TEXT_JUSTIFY_CENTER);
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
        // Bottom section geometry: y = 270 to _h (360), split vertically at centerX
        var topY = 270;
        var sectionHeight = _h - topY; // 90px
        var centerX = _w / 2;
        var spacing = 4; // Gap between label and value

        // Calculate vertical positions
        var totalHeight = _hLabel + spacing + _hData;
        var startY = topY + (sectionHeight - totalHeight) / 2;
        var labelY = startY;
        var valueY = labelY + _hLabel + spacing;

        // Center of left half (80) and right half (240)
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
        // Try Activity.getActivityInfo() first (best for watch faces)
        var actInfo = Activity.getActivityInfo();
        if (actInfo != null && actInfo.currentHeartRate != null) {
            hr = actInfo.currentHeartRate.format("%d");
        } else if (info has :currentHeartRate && info.currentHeartRate != null) {
            // Fallback to ActivityMonitor
            hr = info.currentHeartRate.format("%d");
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        drawPixelLabel(dc, rightCenterX, labelY, "HR");

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(rightCenterX, valueY, _fData, hr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function getDateName(dayVal) {
        var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        return days[dayVal - 1];
    }

    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}
}
