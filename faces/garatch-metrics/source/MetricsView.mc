using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;
using Toybox.UserProfile;

module Theme {
    const C_BLACK   = Graphics.COLOR_BLACK;
    const C_ORANGE  = 0xFF5500;
    const C_BEIGE   = 0xFFEBCD;
    const C_DK_GRAY = 0x444444;

    // CHANGED: Switched to NUMBER_MEDIUM to prevent overlap. 
    // NUMBER_HOT was too big (approx 150px tall) for this layout.
    function getFontTime() { return Graphics.FONT_SYSTEM_NUMBER_MEDIUM; }
    
    // Using XTINY for labels to save space
    function getFontLbl()  { return Graphics.FONT_SYSTEM_XTINY; }
    
    // Using SMALL or TINY for values in the side/footer to save space
    function getFontVal()  { return Graphics.FONT_SYSTEM_TINY; }
    
    // Header Font
    function getFontHead() { return Graphics.FONT_SYSTEM_SMALL; }
}

module Icons {
    function drawBolt(dc, x, y, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[x+2, y-6], [x+6, y-6], [x+2, y], [x+5, y], [x, y+8], [x+1, y]]);
    }
    function drawBluetooth(dc, x, y, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(x, y-6, x, y+6);
        dc.drawLine(x, y-6, x+4, y-2);
        dc.drawLine(x+4, y-2, x-2, y+1);
        dc.drawLine(x-2, y+1, x+4, y+4);
        dc.drawLine(x+4, y+4, x, y+6);
    }
    function drawMessage(dc, x, y, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x-7, y-5, 14, 10, 2);
        dc.fillPolygon([[x-3, y+4], [x+3, y+4], [x, y+8]]);
    }
    function drawClock(dc, x, y, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawCircle(x, y, 7);
        dc.drawLine(x, y, x, y-4); 
        dc.drawLine(x, y, x+3, y); 
    }
    function drawHeart(dc, x, y, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x-4, y-2, 4);
        dc.fillCircle(x+4, y-2, 4);
        dc.fillPolygon([[x-9, y], [x+9, y], [x, y+9]]);
    }
    function drawShoe(dc, x, y, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[x-6, y+3], [x+6, y+3], [x+6, y-2], [x+3, y-4], [x-4, y-2]]);
    }
}

class MetricsView extends WatchUi.WatchFace {

    var _w, _h;
    var _sidebarW = 50; 

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _w = dc.getWidth();
        _h = dc.getHeight();
    }

    function onUpdate(dc) {
        dc.setColor(Theme.C_BLACK, Theme.C_BLACK);
        dc.clear();

        drawLayoutLines(dc);
        drawSidebar(dc);
        drawMainColumn(dc);
        drawRightStats(dc);
        drawGraphs(dc);
    }

    function drawLayoutLines(dc) {
        dc.setColor(Theme.C_DK_GRAY, Theme.C_BLACK);
        dc.setPenWidth(1);
        // Vertical Divider
        dc.drawLine(_sidebarW, 0, _sidebarW, _h);
        // Horizontal Divider (Footer) - Moved down to make room for Time
        dc.drawLine(_sidebarW, _h - 85, _w, _h - 85);
    }

    function drawSidebar(dc) {
        var cx = _sidebarW / 2;
        var startY = 30; // Moved up slightly
        var spacing = 65; // Reduced spacing slightly

        var stats = System.getSystemStats();
        var settings = System.getDeviceSettings();
        
        // 1. Battery
        Icons.drawBolt(dc, cx, startY, Theme.C_BEIGE);
        dc.setColor(Theme.C_BEIGE, Theme.C_BLACK);
        dc.drawText(cx, startY + 12, Theme.getFontLbl(), stats.battery.format("%d"), Graphics.TEXT_JUSTIFY_CENTER);

        // 2. Bluetooth
        var btColor = settings.phoneConnected ? Theme.C_ORANGE : Theme.C_DK_GRAY;
        Icons.drawBluetooth(dc, cx, startY + spacing, btColor);
        dc.setColor(btColor, Theme.C_BLACK);
        dc.drawText(cx, startY + spacing + 12, Theme.getFontLbl(), settings.phoneConnected ? "ON" : "--", Graphics.TEXT_JUSTIFY_CENTER);

        // 3. Notifications
        var notifCount = settings.notificationCount;
        var notifColor = (notifCount > 0) ? Theme.C_BEIGE : Theme.C_DK_GRAY;
        Icons.drawMessage(dc, cx, startY + (spacing*2), notifColor);
        dc.setColor(notifColor, Theme.C_BLACK);
        dc.drawText(cx, startY + (spacing*2) + 12, Theme.getFontLbl(), notifCount.format("%d"), Graphics.TEXT_JUSTIFY_CENTER);

        // 4. Alarms
        var alarmCount = settings.alarmCount;
        var alarmColor = (alarmCount > 0) ? Theme.C_BEIGE : Theme.C_DK_GRAY;
        Icons.drawClock(dc, cx, startY + (spacing*3), alarmColor);
        dc.setColor(alarmColor, Theme.C_BLACK);
        dc.drawText(cx, startY + (spacing*3) + 12, Theme.getFontLbl(), alarmCount.format("%d"), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawMainColumn(dc) {
        var xStart = _sidebarW + 8;
        
        // FIXED HEADER POSITIONS
        var yDate = 5;  // Moved up to top edge
        var yBar  = 40; // Moved down to clear the text

        // 1. Header: Date
        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var dateStr = Lang.format("$1$ $2$.$3$", [getDateName(info.day_of_week), info.month.format("%02d"), info.day.format("%02d")]);
        
        dc.setColor(Theme.C_BEIGE, Theme.C_BLACK);
        dc.drawText(xStart, yDate, Theme.getFontHead(), dateStr, Graphics.TEXT_JUSTIFY_LEFT);

        // 2. Progress Bar
        var actInfo = ActivityMonitor.getInfo();
        var stepGoal = actInfo.stepGoal;
        if (stepGoal == null || stepGoal == 0) { stepGoal = 10000; }
        var pct = actInfo.steps.toFloat() / stepGoal;
        if (pct > 1.0) { pct = 1.0; }

        var barW = 100; // Reduced width slightly to avoid Right Stats
        var barH = 5;
        
        dc.setColor(Theme.C_DK_GRAY, Theme.C_BLACK);
        dc.fillRectangle(xStart, yBar, barW, barH);
        dc.setColor(Theme.C_ORANGE, Theme.C_BLACK);
        dc.fillRectangle(xStart, yBar, barW * pct, barH);
        
        // 3. Time Stack
        var fontTime = Theme.getFontTime();
        var fontH = dc.getFontHeight(fontTime);
        var overlap = fontH * 0.2; // Overlap amount

        var timeY = yBar + 15; // Start hours below bar
        var minY = timeY + fontH - overlap; // Start minutes

        var clockTime = System.getClockTime();
        var hStr = clockTime.hour.format("%02d");
        var mStr = clockTime.min.format("%02d");
        var sStr = clockTime.sec.format("%02d");

        dc.setColor(Theme.C_BEIGE, Theme.C_BLACK);
        dc.drawText(xStart, timeY, fontTime, hStr, Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(xStart, minY, fontTime, mStr, Graphics.TEXT_JUSTIFY_LEFT);

        // Seconds - Adjusted position for NUMBER_MEDIUM
        var secX = xStart + 85; 
        var secY = timeY + 10; 
        
        dc.setColor(Theme.C_ORANGE, Theme.C_BLACK);
        dc.drawText(secX, secY, Theme.getFontVal(), sStr.substring(0,1), Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(secX, secY + 20, Theme.getFontVal(), sStr.substring(1,2), Graphics.TEXT_JUSTIFY_LEFT);

        // 4. Footer (Below Divider)
        var footerY = _h - 70; // Adjusted for line at -85
        
        // HR
        Icons.drawHeart(dc, xStart + 10, footerY, Theme.C_ORANGE);
        var hr = "--";
        if (actInfo has :currentHeartRate && actInfo.currentHeartRate != null) {
            hr = actInfo.currentHeartRate.format("%d");
        }
        dc.setColor(Theme.C_BEIGE, Theme.C_BLACK);
        dc.drawText(xStart + 30, footerY - 12, Theme.getFontVal(), hr, Graphics.TEXT_JUSTIFY_LEFT);

        // Steps
        var stepY = footerY + 35;
        Icons.drawShoe(dc, xStart + 10, stepY, Theme.C_ORANGE);
        dc.setColor(Theme.C_BEIGE, Theme.C_BLACK);
        dc.drawText(xStart + 30, stepY - 12, Theme.getFontVal(), actInfo.steps.format("%d"), Graphics.TEXT_JUSTIFY_LEFT);
    }

function drawRightStats(dc) {
        var colX = _w - 2; 
        var startY = 10; 
        var rowH = 42;   

        var info = ActivityMonitor.getInfo();

        // 1. Calories (Safe integer check)
        var cal = info.calories;
        if (cal == null) { cal = 0; }
        drawStatRow(dc, colX, startY, "CAL", cal.format("%d"));

        // 2. Distance (Safe float conversion)
        var dist = info.distance; 
        if (dist == null) { dist = 0; }
        var distVal = (dist / 100000.0).format("%.1f");
        drawStatRow(dc, colX, startY + rowH, "KM", distVal);

        // 3. Active Min (THE FIX: Handle Object vs Number)
        var amVal = 0;
        var amData = info.activeMinutesWeek;
        
        if (amData != null) {
            // On Venu Sq 2, this is an Object with a 'total' property
            if (amData has :total) {
                amVal = amData.total; 
            } else if (amData instanceof Toybox.Lang.Number) {
                // On older devices, it's just a Number
                amVal = amData;
            }
        }
        drawStatRow(dc, colX, startY + (rowH*2), "AM", amVal.format("%d"));

        // 4. Resting HR (Safe check)
        var rhr = "--";
        var profile = UserProfile.getProfile();
        if (profile != null && profile has :restingHeartRate && profile.restingHeartRate != null) {
            rhr = profile.restingHeartRate.format("%d");
        }
        drawStatRow(dc, colX, startY + (rowH*3), "RHR", rhr);
    }

    function drawStatRow(dc, xAnchor, y, label, value) {
        // Label (Orange) - Moved label further left to avoid overlaps (offset 45 instead of 60)
        dc.setColor(Theme.C_ORANGE, Theme.C_BLACK);
        // Using smaller font for labels
        dc.drawText(xAnchor - 45, y + 2, Theme.getFontLbl(), label, Graphics.TEXT_JUSTIFY_RIGHT);
        
        // Value (Beige)
        dc.setColor(Theme.C_BEIGE, Theme.C_BLACK);
        dc.drawText(xAnchor, y, Theme.getFontVal(), value, Graphics.TEXT_JUSTIFY_RIGHT);

        // Divider
        dc.setColor(Theme.C_DK_GRAY, Theme.C_BLACK);
        dc.drawLine(xAnchor - 45, y + 25, xAnchor, y + 25);
    }

    function drawGraphs(dc) {
        var startX = _w - 85; // Moved right
        var startY = _h - 70; 
        
        var dummyData1 = [2,4,6,8,5,3,4];
        var dummyData2 = [3,5,7,4,6,9,5];

        drawBarGraph(dc, startX, startY, dummyData1, Theme.C_ORANGE);
        drawBarGraph(dc, startX, startY + 35, dummyData2, Theme.C_ORANGE);
    }

    function drawBarGraph(dc, x, y, data, color) {
        var barW = 6;
        var gap = 3;
        var maxH = 15;

        dc.setColor(color, Theme.C_BLACK);
        for (var i = 0; i < data.size(); i++) {
            var val = data[i];
            var h = (val / 10.0) * maxH;
            var bx = x + (i * (barW + gap));
            var by = y + (maxH - h); 
            
            dc.fillRectangle(bx, by, barW, h);
        }
    }

    function getDateName(dayVal) {
        var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        return days[dayVal - 1];
    }
}
