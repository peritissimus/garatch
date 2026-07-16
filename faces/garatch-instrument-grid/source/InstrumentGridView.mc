using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.SensorHistory;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;
using Toybox.Weather;

class InstrumentGridView extends WatchUi.WatchFace {
    private const INK = 0xF3F0E6;
    private const MUTED = 0x8F8A80;
    private const AMBER = 0xE7A74E;
    private const MINT = 0x72D6B2;
    private const CYAN = 0x67B7C5;
    private const GRID = 0x34342F;
    private const TRACK = 0x20231F;
    private const AOD = 0x55534D;

    private var _w;
    private var _h;
    private var _cx;
    private var _fTime;
    private var _fValue;
    private var _fLabel;
    private var _fHeader;
    private var _fChart;
    private var _fRail;
    private var _lowPower = false;

    private var _iconSun;
    private var _iconBattery;
    private var _iconSteps;
    private var _iconHeart;
    private var _iconBody;
    private var _iconStress;
    private var _iconOxygen;
    private var _iconCalories;
    private var _iconDistance;
    private var _iconActive;
    private var _iconRespiration;
    private var _iconRecovery;

    private var _stress = null;
    private var _bodyBattery = null;
    private var _oxygen = null;
    private var _temperatureC = null;
    private var _hrSamples = [];
    private var _hrMin = null;
    private var _hrMax = null;
    private var _slowDataStamp = -1;

    function initialize() { WatchFace.initialize(); }

    function onLayout(dc) {
        _w = dc.getWidth();
        _h = dc.getHeight();
        _cx = _w / 2;

        _fTime = WatchUi.loadResource(Rez.Fonts.InstrumentTime);
        _fValue = WatchUi.loadResource(Rez.Fonts.InstrumentValue);
        _fLabel = WatchUi.loadResource(Rez.Fonts.InstrumentLabel);
        _fHeader = WatchUi.loadResource(Rez.Fonts.InstrumentHeader);
        _fChart = WatchUi.loadResource(Rez.Fonts.InstrumentChart);
        _fRail = WatchUi.loadResource(Rez.Fonts.InstrumentRail);

        _iconSun = WatchUi.loadResource(Rez.Drawables.IconSun);
        _iconBattery = WatchUi.loadResource(Rez.Drawables.IconBattery);
        _iconSteps = WatchUi.loadResource(Rez.Drawables.IconSteps);
        _iconHeart = WatchUi.loadResource(Rez.Drawables.IconHeart);
        _iconBody = WatchUi.loadResource(Rez.Drawables.IconBody);
        _iconStress = WatchUi.loadResource(Rez.Drawables.IconStress);
        _iconOxygen = WatchUi.loadResource(Rez.Drawables.IconOxygen);
        _iconCalories = WatchUi.loadResource(Rez.Drawables.IconCalories);
        _iconDistance = WatchUi.loadResource(Rez.Drawables.IconDistance);
        _iconActive = WatchUi.loadResource(Rez.Drawables.IconActive);
        _iconRespiration = WatchUi.loadResource(Rez.Drawables.IconRespiration);
        _iconRecovery = WatchUi.loadResource(Rez.Drawables.IconRecovery);
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (_lowPower) {
            drawAlwaysOn(dc);
            return;
        }

        refreshSlowData();

        var monitor = ActivityMonitor.getInfo();
        var steps = (monitor != null && monitor.steps != null) ? monitor.steps : 0;
        var goal = (monitor != null && monitor.stepGoal != null && monitor.stepGoal > 0) ? monitor.stepGoal : 10000;
        var calories = (monitor != null && monitor.calories != null) ? monitor.calories : null;
        var distance = (monitor != null && monitor.distance != null) ? monitor.distance : null;
        var stress = _stress;
        var activeMinutes = null;
        var respiration = null;
        var recovery = null;

        if (monitor != null) {
            if ((monitor has :stressScore) && monitor.stressScore != null) {
                stress = monitor.stressScore;
            }
            if ((monitor has :activeMinutesDay) && monitor.activeMinutesDay != null &&
                    (monitor.activeMinutesDay has :total) && monitor.activeMinutesDay.total != null) {
                activeMinutes = monitor.activeMinutesDay.total;
            }
            if ((monitor has :respirationRate) && monitor.respirationRate != null) {
                respiration = monitor.respirationRate;
            }
            if ((monitor has :timeToRecovery) && monitor.timeToRecovery != null) {
                recovery = monitor.timeToRecovery;
            }
        }

        var heart = null;
        var current = Activity.getActivityInfo();
        if (current != null && current.currentHeartRate != null) {
            heart = current.currentHeartRate;
        }
        if (current != null && (current has :currentOxygenSaturation) && current.currentOxygenSaturation != null) {
            _oxygen = current.currentOxygenSaturation;
        }

        var stats = System.getSystemStats();
        var battery = (stats != null && stats.battery != null) ? stats.battery : null;

        drawHeader(dc, battery);
        drawTime(dc);
        drawSteps(dc, steps, goal);
        drawMetricGrid(dc, heart, stress, calories, distance);
        drawHeartHistory(dc);
        drawBottomRail(dc, activeMinutes, respiration, recovery);
    }

    function drawHeader(dc, battery) {
        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateText = getDayName(date.day_of_week) + " " + date.day.format("%02d") + " " + getMonthName(date.month);
        var tempText = (_temperatureC == null) ? "--" : displayTemperature(_temperatureC).format("%d");
        var batteryText = (battery == null) ? "--" : battery.format("%d") + "%";

        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(12, 16, _fHeader, dateText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(GRID, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(109, 7, 109, 27);
        dc.drawLine(206, 7, 206, 27);

        dc.drawBitmap(133, 7, _iconSun);
        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(157, 16, _fHeader, tempText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        var tempWidth = dc.getTextWidthInPixels(tempText, _fHeader);
        dc.setPenWidth(1);
        dc.drawCircle(160 + tempWidth, 10, 2);

        dc.drawBitmap(227, 8, _iconBattery);
        dc.drawText(252, 16, _fHeader, batteryText,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(10, 32, 310, 32);
        for (var x = 10; x <= 310; x += 14) {
            var tickHeight = (x == 10 || x == 150 || x == 304) ? 5 : 3;
            dc.drawLine(x, 32, x, 32 + tickHeight);
        }
    }

    function drawTime(dc) {
        var clock = System.getClockTime();
        var hour = displayHour(clock.hour);
        var timeText = Lang.format("$1$:$2$", [hour.format("%02d"), clock.min.format("%02d")]);

        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(126, 87, _fTime, timeText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawText(264, 55, _fValue, clock.sec.format("%02d"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(AMBER, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(250, 75, 29, 2);
    }

    function drawSteps(dc, steps, goal) {
        dc.setColor(AMBER, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(10, 137, 300, 2);

        dc.drawBitmap(11, 144, _iconSteps);
        dc.setColor(GRID, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(35, 142, 35, 165);
        dc.drawLine(164, 142, 164, 165);
        dc.drawLine(205, 142, 205, 165);
        dc.setColor(MINT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(44, 153, _fLabel, "STEPS",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(86, 153, _fValue, formatNumber(steps),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(178, 153, _fHeader, compactGoal(goal),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        drawSegments(dc, 214, 148, clamp01(steps.toFloat() / goal.toFloat()));
    }

    function drawMetricGrid(dc, heart, stress, calories, distance) {
        dc.setColor(GRID, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(10, 168, 310, 168);
        dc.drawLine(10, 210, 310, 210);
        dc.drawLine(10, 252, 310, 252);
        dc.drawLine(10, 168, 10, 252);
        dc.drawLine(110, 168, 110, 252);
        dc.drawLine(210, 168, 210, 252);
        dc.drawLine(310, 168, 310, 252);

        var heartText = (heart == null) ? "--" : heart.format("%d");
        var bodyText = (_bodyBattery == null) ? "--" : _bodyBattery.format("%d");
        var stressText = (stress == null) ? "--" : stress.format("%d");
        var oxygenText = (_oxygen == null) ? "--" : _oxygen.format("%d");
        var caloriesText = (calories == null) ? "--" : calories.format("%d");
        var distanceText = (distance == null) ? "--" : (distance.toFloat() / 100000.0).format("%.1f");

        drawMetricCell(dc, 10, 168, _iconHeart, heartText, "BPM");
        drawMetricCell(dc, 110, 168, _iconBody, bodyText, "BODY");
        drawMetricCell(dc, 210, 168, _iconStress, stressText, "STRESS");
        drawMetricCell(dc, 10, 210, _iconOxygen, oxygenText, "% SPO2");
        drawMetricCell(dc, 110, 210, _iconCalories, caloriesText, "KCAL");
        drawMetricCell(dc, 210, 210, _iconDistance, distanceText, "KM");
    }

    function drawMetricCell(dc, x, y, icon, value, label) {
        dc.drawBitmap(x + 8, y + 10, icon);
        dc.setColor(GRID, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x + 34, y + 7, x + 34, y + 35);
        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + 44, y + 18, _fValue, value,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + 45, y + 34, _fLabel, label,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawHeartHistory(dc) {
        dc.setColor(AMBER, Graphics.COLOR_TRANSPARENT);
        dc.drawText(14, 263, _fLabel, "HR 24H",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(GRID, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(238, 258, 238, 321);
        for (var x = 20; x < 227; x += 8) {
            dc.drawLine(x, 283, x + 4, 283);
            dc.drawLine(x, 311, x + 4, 311);
        }

        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(15, 281, _fLabel, (_hrMax == null) ? "--" : _hrMax.format("%d"),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(18, 310, _fLabel, (_hrMin == null) ? "--" : _hrMin.format("%d"),
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(250, 276, _fLabel, "MIN",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(250, 305, _fLabel, "MAX",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(303, 276, _fChart, (_hrMin == null) ? "--" : _hrMin.format("%d"),
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(303, 305, _fChart, (_hrMax == null) ? "--" : _hrMax.format("%d"),
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(GRID, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(248, 288, 304, 288);

        var count = _hrSamples.size();
        if (count < 2 || _hrMin == null || _hrMax == null) {
            dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(123, 297, _fLabel, "NO DATA",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        var range = _hrMax - _hrMin;
        if (range < 1) { range = 1; }
        var previousX = 20;
        var previousY = 314;
        dc.setColor(AMBER, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        for (var i = 0; i < count; i++) {
            var sample = _hrSamples[count - 1 - i];
            var px = 20 + ((207 * i) / (count - 1));
            var py = 314 - (((sample - _hrMin) * 35) / range);
            if (i > 0) { dc.drawLine(previousX, previousY, px, py); }
            previousX = px;
            previousY = py;
        }
        dc.setPenWidth(1);
        dc.fillCircle(previousX, previousY, 2);
    }

    function drawBottomRail(dc, activeMinutes, respiration, recovery) {
        dc.setColor(GRID, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(10, 323, 310, 323);
        dc.drawLine(10, 357, 310, 357);
        dc.drawLine(10, 323, 10, 357);
        dc.drawLine(110, 323, 110, 357);
        dc.drawLine(210, 323, 210, 357);
        dc.drawLine(310, 323, 310, 357);

        drawRailMetric(dc, 10, _iconActive,
            (activeMinutes == null) ? "--" : activeMinutes.format("%d"), "MIN");
        drawRailMetric(dc, 110, _iconRespiration,
            (respiration == null) ? "--" : respiration.format("%d"), "RPM");
        drawRailMetric(dc, 210, _iconRecovery,
            (recovery == null) ? "--" : recovery.format("%d"), "H");
    }

    function drawRailMetric(dc, x, icon, value, unit) {
        dc.drawBitmap(x + 10, 331, icon);
        var valueW = dc.getTextWidthInPixels(value, _fRail);
        var unitW = dc.getTextWidthInPixels(unit, _fLabel);
        var startX = x + 60 - ((valueW + 3 + unitW) / 2);
        dc.setColor(INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX, 341, _fRail, value,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX + valueW + 3, 343, _fLabel, unit,
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawSegments(dc, x, y, pct) {
        var active = (pct * 12).toNumber();
        for (var i = 0; i < 12; i++) {
            dc.setColor((i < active) ? MINT : TRACK, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x + (i * 8), y, 6, 10);
        }
        dc.setColor(MINT, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(x, y, 94, 10);
    }

    function refreshSlowData() {
        var clock = System.getClockTime();
        var stamp = (clock.hour * 60) + clock.min;
        if (stamp == _slowDataStamp) { return; }
        _slowDataStamp = stamp;
        _stress = readLatestStress();
        _bodyBattery = readLatestBodyBattery();
        _oxygen = readLatestOxygen();
        _temperatureC = readTemperature();
        readHeartHistory();
    }

    function readLatestStress() {
        try {
            if (!(Toybox has :SensorHistory) || !(SensorHistory has :getStressHistory)) { return null; }
            var iterator = SensorHistory.getStressHistory({
                :period => 1,
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            if (iterator != null) {
                var sample = iterator.next();
                if (sample != null && sample.data != null) { return sample.data; }
            }
        } catch (ex) {}
        return null;
    }

    function readLatestBodyBattery() {
        try {
            if (!(Toybox has :SensorHistory) || !(SensorHistory has :getBodyBatteryHistory)) { return null; }
            var iterator = SensorHistory.getBodyBatteryHistory({
                :period => 1,
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            if (iterator != null) {
                var sample = iterator.next();
                if (sample != null && sample.data != null) { return sample.data; }
            }
        } catch (ex) {}
        return null;
    }

    function readLatestOxygen() {
        try {
            if (!(Toybox has :SensorHistory) || !(SensorHistory has :getOxygenSaturationHistory)) { return null; }
            var iterator = SensorHistory.getOxygenSaturationHistory({
                :period => 1,
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            if (iterator != null) {
                var sample = iterator.next();
                if (sample != null && sample.data != null) { return sample.data; }
            }
        } catch (ex) {}
        return null;
    }

    function readHeartHistory() {
        _hrSamples = [];
        _hrMin = null;
        _hrMax = null;
        try {
            if (!(Toybox has :SensorHistory) || !(SensorHistory has :getHeartRateHistory)) { return; }
            var iterator = SensorHistory.getHeartRateHistory({
                :period => 24,
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            if (iterator == null) { return; }
            var sample = iterator.next();
            while (sample != null && _hrSamples.size() < 24) {
                if (sample.data != null) {
                    var value = sample.data;
                    _hrSamples.add(value);
                    if (_hrMin == null || value < _hrMin) { _hrMin = value; }
                    if (_hrMax == null || value > _hrMax) { _hrMax = value; }
                }
                sample = iterator.next();
            }
        } catch (ex) {
            _hrSamples = [];
            _hrMin = null;
            _hrMax = null;
        }
    }

    function readTemperature() {
        try {
            if ((Toybox has :Weather) && (Weather has :getCurrentConditions)) {
                var conditions = Weather.getCurrentConditions();
                if (conditions != null && conditions.temperature != null) { return conditions.temperature; }
            }
        } catch (ex) {}
        return null;
    }

    function displayTemperature(celsius) {
        var settings = System.getDeviceSettings();
        if (settings != null && settings.temperatureUnits == System.UNIT_STATUTE) {
            return ((celsius * 9.0 / 5.0) + 32.0).toNumber();
        }
        return celsius.toNumber();
    }

    function drawAlwaysOn(dc) {
        var clock = System.getClockTime();
        var hour = displayHour(clock.hour);
        var timeText = Lang.format("$1$:$2$", [hour.format("%02d"), clock.min.format("%02d")]);
        var dx = ((clock.min % 3) - 1) * 2;
        var dy = (((clock.min / 3).toNumber() % 3) - 1) * 2;
        dc.setColor(AOD, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_cx + dx, 175 + dy, Graphics.FONT_SYSTEM_NUMBER_MEDIUM, timeText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function displayHour(hour) {
        var settings = System.getDeviceSettings();
        if (settings != null && !settings.is24Hour) {
            if (hour == 0) { return 12; }
            if (hour > 12) { return hour - 12; }
        }
        return hour;
    }

    function compactGoal(goal) {
        if (goal >= 1000) { return (goal / 1000).format("%d") + "K"; }
        return goal.format("%d");
    }

    function formatNumber(value) {
        var raw = value.format("%d");
        var result = "";
        var count = 0;
        for (var i = raw.length() - 1; i >= 0; i--) {
            if (count > 0 && (count % 3) == 0) { result = "," + result; }
            result = raw.substring(i, i + 1) + result;
            count++;
        }
        return result;
    }

    function clamp01(value) {
        if (value < 0.0) { return 0.0; }
        if (value > 1.0) { return 1.0; }
        return value;
    }

    function getDayName(day) {
        return ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"][day - 1];
    }

    function getMonthName(month) {
        return ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"][month - 1];
    }

    function onEnterSleep() { _lowPower = true; WatchUi.requestUpdate(); }
    function onExitSleep() { _lowPower = false; WatchUi.requestUpdate(); }
    function onHide() {}
}
