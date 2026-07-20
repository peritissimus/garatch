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

class SixDashView extends WatchUi.WatchFace {
    private const INK = 0xF1F3E8;
    private const WARM = 0xC9CBAE;
    private const CYAN = 0x49BBC2;
    private const MINT = 0x56D39B;
    private const DIM = 0x36383A;
    private const TRACK = 0x202425;

    private var _w;
    private var _h;
    private var _cx;
    private var _warmDigits;
    private var _dimDigits;
    private var _smallWarmDigits;
    private var _smallInkDigits;
    private var _smallWarmDot;
    private var _smallWarmPercent;
    private var _smallWarmDash;
    private var _smallWarmF;
    private var _smallWarmC;
    private var _smallInkDot;
    private var _smallInkPercent;
    private var _smallInkDash;
    private var _smallInkF;
    private var _smallInkC;
    private var _mediumInkDigits;
    private var _mediumInkDot;
    private var _mediumInkDash;
    private var _iconBolt;
    private var _iconBluetooth;
    private var _iconBluetoothDim;
    private var _iconShoe;
    private var _iconStopwatch;
    private var _iconPin;
    private var _iconStress;
    private var _iconBodyBattery;
    private var _iconHeart;
    private var _segmentTrack;
    private var _segmentWarm;
    private var _segmentCyan;
    private var _segmentMint;
    private var _lowPower = false;
    private var _stress = null;
    private var _bodyBattery = null;
    private var _temperatureC = null;
    private var _slowDataStamp = -1;

    function initialize() { WatchFace.initialize(); }

    function onLayout(dc) {
        _w = dc.getWidth();
        _h = dc.getHeight();
        _cx = _w / 2;
        _warmDigits = [
            WatchUi.loadResource(Rez.Drawables.DigitWarm0),
            WatchUi.loadResource(Rez.Drawables.DigitWarm1),
            WatchUi.loadResource(Rez.Drawables.DigitWarm2),
            WatchUi.loadResource(Rez.Drawables.DigitWarm3),
            WatchUi.loadResource(Rez.Drawables.DigitWarm4),
            WatchUi.loadResource(Rez.Drawables.DigitWarm5),
            WatchUi.loadResource(Rez.Drawables.DigitWarm6),
            WatchUi.loadResource(Rez.Drawables.DigitWarm7),
            WatchUi.loadResource(Rez.Drawables.DigitWarm8),
            WatchUi.loadResource(Rez.Drawables.DigitWarm9)
        ];
        _dimDigits = [
            WatchUi.loadResource(Rez.Drawables.DigitDim0),
            WatchUi.loadResource(Rez.Drawables.DigitDim1),
            WatchUi.loadResource(Rez.Drawables.DigitDim2),
            WatchUi.loadResource(Rez.Drawables.DigitDim3),
            WatchUi.loadResource(Rez.Drawables.DigitDim4),
            WatchUi.loadResource(Rez.Drawables.DigitDim5),
            WatchUi.loadResource(Rez.Drawables.DigitDim6),
            WatchUi.loadResource(Rez.Drawables.DigitDim7),
            WatchUi.loadResource(Rez.Drawables.DigitDim8),
            WatchUi.loadResource(Rez.Drawables.DigitDim9)
        ];
        _smallWarmDigits = [
            WatchUi.loadResource(Rez.Drawables.SmallWarm0),
            WatchUi.loadResource(Rez.Drawables.SmallWarm1),
            WatchUi.loadResource(Rez.Drawables.SmallWarm2),
            WatchUi.loadResource(Rez.Drawables.SmallWarm3),
            WatchUi.loadResource(Rez.Drawables.SmallWarm4),
            WatchUi.loadResource(Rez.Drawables.SmallWarm5),
            WatchUi.loadResource(Rez.Drawables.SmallWarm6),
            WatchUi.loadResource(Rez.Drawables.SmallWarm7),
            WatchUi.loadResource(Rez.Drawables.SmallWarm8),
            WatchUi.loadResource(Rez.Drawables.SmallWarm9)
        ];
        _smallInkDigits = [
            WatchUi.loadResource(Rez.Drawables.SmallInk0),
            WatchUi.loadResource(Rez.Drawables.SmallInk1),
            WatchUi.loadResource(Rez.Drawables.SmallInk2),
            WatchUi.loadResource(Rez.Drawables.SmallInk3),
            WatchUi.loadResource(Rez.Drawables.SmallInk4),
            WatchUi.loadResource(Rez.Drawables.SmallInk5),
            WatchUi.loadResource(Rez.Drawables.SmallInk6),
            WatchUi.loadResource(Rez.Drawables.SmallInk7),
            WatchUi.loadResource(Rez.Drawables.SmallInk8),
            WatchUi.loadResource(Rez.Drawables.SmallInk9)
        ];
        _smallWarmDot = WatchUi.loadResource(Rez.Drawables.SmallWarmDot);
        _smallWarmPercent = WatchUi.loadResource(Rez.Drawables.SmallWarmPercent);
        _smallWarmDash = WatchUi.loadResource(Rez.Drawables.SmallWarmDash);
        _smallWarmF = WatchUi.loadResource(Rez.Drawables.SmallWarmF);
        _smallWarmC = WatchUi.loadResource(Rez.Drawables.SmallWarmC);
        _smallInkDot = WatchUi.loadResource(Rez.Drawables.SmallInkDot);
        _smallInkPercent = WatchUi.loadResource(Rez.Drawables.SmallInkPercent);
        _smallInkDash = WatchUi.loadResource(Rez.Drawables.SmallInkDash);
        _smallInkF = WatchUi.loadResource(Rez.Drawables.SmallInkF);
        _smallInkC = WatchUi.loadResource(Rez.Drawables.SmallInkC);
        _mediumInkDigits = [
            WatchUi.loadResource(Rez.Drawables.MediumInk0),
            WatchUi.loadResource(Rez.Drawables.MediumInk1),
            WatchUi.loadResource(Rez.Drawables.MediumInk2),
            WatchUi.loadResource(Rez.Drawables.MediumInk3),
            WatchUi.loadResource(Rez.Drawables.MediumInk4),
            WatchUi.loadResource(Rez.Drawables.MediumInk5),
            WatchUi.loadResource(Rez.Drawables.MediumInk6),
            WatchUi.loadResource(Rez.Drawables.MediumInk7),
            WatchUi.loadResource(Rez.Drawables.MediumInk8),
            WatchUi.loadResource(Rez.Drawables.MediumInk9)
        ];
        _mediumInkDot = WatchUi.loadResource(Rez.Drawables.MediumInkDot);
        _mediumInkDash = WatchUi.loadResource(Rez.Drawables.MediumInkDash);
        _iconBolt = WatchUi.loadResource(Rez.Drawables.IconBolt);
        _iconBluetooth = WatchUi.loadResource(Rez.Drawables.IconBluetooth);
        _iconBluetoothDim = WatchUi.loadResource(Rez.Drawables.IconBluetoothDim);
        _iconShoe = WatchUi.loadResource(Rez.Drawables.IconShoe);
        _iconStopwatch = WatchUi.loadResource(Rez.Drawables.IconStopwatch);
        _iconPin = WatchUi.loadResource(Rez.Drawables.IconPin);
        _iconStress = WatchUi.loadResource(Rez.Drawables.IconStress);
        _iconBodyBattery = WatchUi.loadResource(Rez.Drawables.IconBodyBattery);
        _iconHeart = WatchUi.loadResource(Rez.Drawables.IconHeart);
        _segmentTrack = WatchUi.loadResource(Rez.Drawables.SegmentTrack);
        _segmentWarm = WatchUi.loadResource(Rez.Drawables.SegmentWarm);
        _segmentCyan = WatchUi.loadResource(Rez.Drawables.SegmentCyan);
        _segmentMint = WatchUi.loadResource(Rez.Drawables.SegmentMint);
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (_lowPower) {
            drawAlwaysOn(dc);
            return;
        }

        var activity = ActivityMonitor.getInfo();
        var steps = (activity != null && activity.steps != null) ? activity.steps : 0;
        var stepGoal = (activity != null && activity.stepGoal != null && activity.stepGoal > 0) ? activity.stepGoal : 10000;
        var activeMinutes = 0;
        var activeGoal = 150;
        if (activity != null && (activity has :activeMinutesWeek) && activity.activeMinutesWeek != null) {
            activeMinutes = activity.activeMinutesWeek.total;
        }
        if (activity != null && (activity has :activeMinutesWeekGoal) && activity.activeMinutesWeekGoal != null && activity.activeMinutesWeekGoal > 0) {
            activeGoal = activity.activeMinutesWeekGoal;
        }
        var distance = (activity != null && activity.distance != null) ? activity.distance : 0;
        var stepPct = clamp01(steps.toFloat() / stepGoal.toFloat());
        var activePct = clamp01(activeMinutes.toFloat() / activeGoal.toFloat());

        var stats = System.getSystemStats();
        var battery = (stats != null && stats.battery != null) ? stats.battery : 0;

        var hr = null;
        var current = Activity.getActivityInfo();
        if (current != null && current.currentHeartRate != null) { hr = current.currentHeartRate; }

        refreshSlowData();
        var settings = System.getDeviceSettings();
        var phoneConnected = (settings != null && settings.phoneConnected);

        drawHeader(dc, battery, _temperatureC, phoneConnected);
        drawMetricRows(dc, steps, stepPct, activeMinutes, activePct, distance);
        drawRadials(dc, _stress, _bodyBattery, hr);
        drawClock(dc);
    }

    function drawHeader(dc, battery, temperatureC, phoneConnected) {
        drawBolt(dc, 37, 54, WARM);
        drawSmallText(dc, 48, 39, battery.format("%d") + "%", true, Graphics.TEXT_JUSTIFY_LEFT);

        drawTemperature(dc, temperatureC);
        drawBluetooth(dc, _w - 37, 55, phoneConnected);

        dc.setColor(TRACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(31, 69, _w - 62, 3);
    }

    function drawTemperature(dc, temperatureC) {
        var rightEdge = _w - 60;
        if (temperatureC == null) {
            drawSmallText(dc, rightEdge, 39, "--", true, Graphics.TEXT_JUSTIFY_RIGHT);
            return;
        }

        var temperature = temperatureC;
        var unit = "C";
        var settings = System.getDeviceSettings();
        if (settings != null && settings.temperatureUnits == System.UNIT_STATUTE) {
            temperature = (temperatureC * 9.0 / 5.0) + 32.0;
            unit = "F";
        }

        var value = temperature.format("%.1f");
        var valueW = smallTextWidth(value);
        var unitW = smallTextWidth(unit);
        var startX = rightEdge - valueW - unitW - 7;
        drawSmallText(dc, startX, 39, value, true, Graphics.TEXT_JUSTIFY_LEFT);
        var degreeX = startX + valueW + 2;
        dc.setColor(WARM, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(degreeX, 45, 2);
        dc.setPenWidth(1);
        drawSmallText(dc, degreeX + 5, 39, unit, true, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function refreshSlowData() {
        var clock = System.getClockTime();
        var stamp = (clock.hour * 60) + clock.min;
        if (stamp == _slowDataStamp) { return; }
        _slowDataStamp = stamp;
        _stress = readLatestStress();
        _bodyBattery = readLatestBodyBattery();
        _temperatureC = readTemperature();
    }

    function readLatestStress() {
        if ((Toybox has :SensorHistory) && (SensorHistory has :getStressHistory)) {
            var iterator = SensorHistory.getStressHistory({
                :period => 1,
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            if (iterator != null) {
                var sample = iterator.next();
                if (sample != null && sample.data != null) { return sample.data; }
            }
        }
        return null;
    }

    function readLatestBodyBattery() {
        if ((Toybox has :SensorHistory) && (SensorHistory has :getBodyBatteryHistory)) {
            var iterator = SensorHistory.getBodyBatteryHistory({
                :period => 1,
                :order => SensorHistory.ORDER_NEWEST_FIRST
            });
            if (iterator != null) {
                var sample = iterator.next();
                if (sample != null && sample.data != null) { return sample.data; }
            }
        }
        return null;
    }

    function readTemperature() {
        if ((Toybox has :Weather) && (Weather has :getCurrentConditions)) {
            var conditions = Weather.getCurrentConditions();
            if (conditions != null && conditions.temperature != null) {
                return conditions.temperature;
            }
        }
        return null;
    }

    function drawMetricRows(dc, steps, stepPct, activeMinutes, activePct, distance) {
        drawShoe(dc, 30, 91, MINT);
        drawMetricValue(dc, steps.format("%d"), 75);
        drawSegmentBar(dc, 75, 101, 210, 9, stepPct, WARM);

        drawStopwatch(dc, 42, 126, CYAN);
        drawMetricValue(dc, activeMinutes.format("%d"), 116);
        drawSegmentBar(dc, 75, 140, 210, 9, activePct, CYAN);

        drawPin(dc, 44, 163, MINT);
        var km = distance.toFloat() / 100000.0;
        drawMetricValue(dc, km.format("%.2f"), 153);
        drawSegmentBar(dc, 75, 179, 210, 9, clamp01(km / 10.0), MINT);
    }

    function drawMetricValue(dc, text, y) {
        drawSmallText(dc, 75, y, text, false, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawSegmentBar(dc, x, y, width, height, pct, color) {
        var gap = 4;
        var segmentW = (width - (gap * 4)) / 5;
        var filled = _segmentWarm;
        if (color == CYAN) { filled = _segmentCyan; }
        else if (color == MINT) { filled = _segmentMint; }
        for (var i = 0; i < 5; i++) {
            var sx = x + (i * (segmentW + gap));
            var threshold = i.toFloat() / 5.0;
            dc.drawBitmap(sx, y, (pct > threshold) ? filled : _segmentTrack);
        }
    }

    function drawRadials(dc, stress, bodyBattery, hr) {
        var stressText = (stress == null) ? "--" : stress.format("%d");
        var stressPct = (stress == null) ? 0.0 : clamp01(stress.toFloat() / 100.0);
        var bodyText = (bodyBattery == null) ? "--" : bodyBattery.format("%d");
        var bodyPct = (bodyBattery == null) ? 0.0 : clamp01(bodyBattery.toFloat() / 100.0);
        var hrText = (hr == null) ? "--" : hr.format("%d");
        var hrPct = (hr == null) ? 0.0 : clamp01(hr.toFloat() / 180.0);

        var ringOne = 48;
        var ringTwo = 138;
        var ringThree = 228;

        dc.setColor(DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(111, 204, 111, 244);
        dc.drawLine(201, 204, 201, 244);

        drawRing(dc, ringOne, 220, 15, stressPct, WARM);
        drawStress(dc, ringOne + 37, 210, WARM);
        drawRadialValue(dc, ringOne + 23, stressText);

        drawRing(dc, ringTwo, 220, 15, bodyPct, CYAN);
        drawBodyBattery(dc, ringTwo + 37, 211, CYAN);
        drawRadialValue(dc, ringTwo + 23, bodyText);

        drawRing(dc, ringThree, 220, 15, hrPct, MINT);
        drawHeart(dc, ringThree + 37, 210, MINT);
        drawRadialValue(dc, ringThree + 23, hrText);
    }

    function drawRing(dc, x, y, radius, pct, color) {
        dc.setPenWidth(6);
        dc.setColor(DIM, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(x, y, radius, Graphics.ARC_CLOCKWISE, 0, 360);
        var sweep = (360 * clamp01(pct)).toNumber();
        if (sweep > 0) {
            // Garmin angles increase counter-clockwise. For a clockwise gauge,
            // subtract the desired sweep from the 12 o'clock start angle.
            var endAngle = 90 - sweep;
            if (endAngle < 0) { endAngle += 360; }
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(x, y, radius, Graphics.ARC_CLOCKWISE, 90, endAngle);
        }
        dc.setPenWidth(1);
    }

    function drawRadialValue(dc, x, text) {
        drawSmallText(dc, x, 215, text, false, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function drawClock(dc) {
        var clock = System.getClockTime();
        var hour = displayHour(clock.hour);
        var hours = hour.format("%02d");
        var minutes = clock.min.format("%02d");
        var seconds = clock.sec.format("%02d");
        // Final-size Rajdhani cells preserve the intended squared forms and optical weight.
        var x = 24;
        var y = 237;

        drawClockNumber(dc, x, y, hours, _warmDigits);
        var hoursW = 74;
        var colonOneX = x + hoursW + 13;
        drawTimeColon(dc, colonOneX, y, WARM);
        var minuteX = colonOneX + 10;
        drawClockNumber(dc, minuteX, y, minutes, _warmDigits);

        var minuteW = 74;
        var colonTwoX = minuteX + minuteW + 13;
        drawTimeColon(dc, colonTwoX, y, DIM);
        drawClockNumber(dc, colonTwoX + 10, y, seconds, _dimDigits);

        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateText = date.day.format("%02d") + "." + date.month.format("%02d") + "." + (date.year % 100).format("%02d");
        drawMediumText(dc, 30, 296, dateText, 1);
    }

    function drawTimeColon(dc, x, y, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, y + 29, 3);
        dc.fillCircle(x, y + 47, 3);
    }

    function drawClockNumber(dc, x, y, text, digits) {
        var chars = text.toCharArray();
        for (var i = 0; i < chars.size(); i++) {
            var digit = chars[i].toNumber() - 48;
            dc.drawBitmap(x + (i * 37), y, digits[digit]);
        }
    }

    function drawAlwaysOn(dc) {
        var clock = System.getClockTime();
        var hour = displayHour(clock.hour);
        var hours = hour.format("%02d");
        var minutes = clock.min.format("%02d");
        var dx = ((clock.min % 3) - 1) * 2;
        var dy = (((clock.min / 3).toNumber() % 3) - 1) * 2;
        var hoursW = 74;
        var minutesW = 74;
        var startX = (_w - (hoursW + minutesW + 20)) / 2;
        var y = 145 + dy;
        drawClockNumber(dc, startX + dx, y, hours, _dimDigits);
        drawTimeColon(dc, startX + dx + hoursW + 10, y, DIM);
        drawClockNumber(dc, startX + dx + hoursW + 20, y, minutes, _dimDigits);
    }

    function drawSmallText(dc, x, y, text, warm, justify) {
        var cursor = x;
        var width = smallTextWidth(text);
        if (justify == Graphics.TEXT_JUSTIFY_RIGHT) { cursor -= width; }
        else if (justify == Graphics.TEXT_JUSTIFY_CENTER) { cursor -= width / 2; }

        var chars = text.toCharArray();
        for (var i = 0; i < chars.size(); i++) {
            var code = chars[i].toNumber();
            // Four transparent guard pixels prevent adjacent atlas glyphs from clipping.
            dc.drawBitmap(cursor - 4, y, smallGlyph(code, warm));
            cursor += smallGlyphAdvance(code);
        }
    }

    function drawMediumText(dc, x, y, text, tracking) {
        var cursor = x;
        var chars = text.toCharArray();
        for (var i = 0; i < chars.size(); i++) {
            var code = chars[i].toNumber();
            dc.drawBitmap(cursor - 4, y, mediumGlyph(code));
            cursor += mediumGlyphAdvance(code);
            if (i < chars.size() - 1) { cursor += tracking; }
        }
    }

    function mediumGlyphAdvance(code) {
        if (code >= 48 && code <= 57) { return 12; }
        if (code == 46) { return 6; }
        return 9;
    }

    function mediumGlyph(code) {
        if (code >= 48 && code <= 57) { return _mediumInkDigits[code - 48]; }
        if (code == 46) { return _mediumInkDot; }
        return _mediumInkDash;
    }

    function smallTextWidth(text) {
        var width = 0;
        var chars = text.toCharArray();
        for (var i = 0; i < chars.size(); i++) {
            width += smallGlyphAdvance(chars[i].toNumber());
        }
        return width;
    }

    function smallGlyphAdvance(code) {
        if (code >= 48 && code <= 57) { return 11; }
        if (code == 46) { return 5; }
        if (code == 37) { return 18; }
        if (code == 45) { return 8; }
        if (code == 70) { return 10; }
        if (code == 67) { return 11; }
        return 8;
    }

    function smallGlyph(code, warm) {
        if (code >= 48 && code <= 57) {
            return warm ? _smallWarmDigits[code - 48] : _smallInkDigits[code - 48];
        }
        if (code == 46) { return warm ? _smallWarmDot : _smallInkDot; }
        if (code == 37) { return warm ? _smallWarmPercent : _smallInkPercent; }
        if (code == 70) { return warm ? _smallWarmF : _smallInkF; }
        if (code == 67) { return warm ? _smallWarmC : _smallInkC; }
        return warm ? _smallWarmDash : _smallInkDash;
    }

    function drawBolt(dc, x, y, color) {
        dc.drawBitmap(x - 7, y - 10, _iconBolt);
    }

    function drawShoe(dc, x, y, color) {
        dc.drawBitmap(x, y - 4, _iconShoe);
    }

    function drawStopwatch(dc, x, y, color) {
        dc.drawBitmap(x - 12, y - 9, _iconStopwatch);
    }

    function drawPin(dc, x, y, color) {
        dc.drawBitmap(x - 12, y - 10, _iconPin);
    }

    function drawStress(dc, x, y, color) {
        dc.drawBitmap(x - 11, y - 13, _iconStress);
    }

    function drawBodyBattery(dc, x, y, color) {
        dc.drawBitmap(x - 9, y - 13, _iconBodyBattery);
    }

    function drawBluetooth(dc, x, y, connected) {
        dc.drawBitmap(x - 9, y - 12, connected ? _iconBluetooth : _iconBluetoothDim);
    }

    function drawHeart(dc, x, y, color) {
        dc.drawBitmap(x - 12, y - 13, _iconHeart);
    }

    function clamp01(value) {
        if (value < 0.0) { return 0.0; }
        if (value > 1.0) { return 1.0; }
        return value;
    }

    function displayHour(hour) {
        if (!System.getDeviceSettings().is24Hour) {
            if (hour == 0) { return 12; }
            if (hour > 12) { return hour - 12; }
        }
        return hour;
    }

    function getDayName(day) {
        return ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"][day - 1];
    }

    function onEnterSleep() { _lowPower = true; WatchUi.requestUpdate(); }
    function onExitSleep() { _lowPower = false; WatchUi.requestUpdate(); }
    function onHide() {}
}
