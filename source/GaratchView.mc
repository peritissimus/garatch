using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;
using Toybox.UserProfile;
using Toybox.Math;
using Toybox.Weather;
using Toybox.Application;
import GaratchSettings;

class GaratchView extends WatchUi.WatchFace {
    private var _isLowPower = false;
    private var _screenShape;
    private var _centerX;
    private var _centerY;
    private var _screenRadius;
    private var _theme;
    private var _lastMinute = -1;
    private var _weatherCache = null;
    private var _weatherCacheTime = 0;

    function initialize() {
        WatchFace.initialize();
        _screenShape = System.getDeviceSettings().screenShape;
        _theme = GaratchSettings.getTheme();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() {
    }

    function onUpdate(dc) {
        // Get the current time
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        var seconds = clockTime.sec;
        
        // Skip full update if minute hasn't changed (except for seconds animation)
        var needsFullUpdate = (_lastMinute != minutes) || (_lastMinute == -1);
        _lastMinute = minutes;
        
        // Format hours for 12/24 hour display
        var is24Hour = System.getDeviceSettings().is24Hour;
        var displayHours = hours;
        if (!is24Hour) {
            if (hours > 12) {
                displayHours = hours - 12;
            } else if (hours == 0) {
                displayHours = 12;
            }
        }
        
        // Get date info
        var now = Time.now();
        var date = Gregorian.info(now, Time.FORMAT_MEDIUM);
        var dayString = date.day_of_week.toUpper().substring(0, 3);
        var dateString = Lang.format("$1$ $2$", [dayString, date.day.format("%02d")]);
        
        // Update theme only if needed
        if (needsFullUpdate) {
            _theme = GaratchSettings.getTheme();
        }
        
        // Clear the screen with theme background
        dc.setColor(_theme["background"], _theme["background"]);
        dc.clear();
        
        // Get screen dimensions and calculate center
        var width = dc.getWidth();
        var height = dc.getHeight();
        _centerX = width / 2;
        _centerY = height / 2;
        _screenRadius = (_centerX < _centerY) ? _centerX : _centerY;
        
        // Draw in low power mode
        if (_isLowPower) {
            drawLowPowerMode(dc, displayHours, minutes);
            return;
        }
        
        // Draw date at top
        dc.setColor(_theme["dateColor"], Graphics.COLOR_TRANSPARENT);
        dc.drawText(15, 15, Graphics.FONT_TINY, dateString, Graphics.TEXT_JUSTIFY_LEFT);
        
        // Draw battery with icon
        drawBatteryIndicator(dc, width - 60, 15);
        
        // Draw time with gradient effect
        var timeX = width / 4;
        var timeY = height / 2 - 60;
        
        // Hours
        dc.setColor(_theme["timeColor"], Graphics.COLOR_TRANSPARENT);
        dc.drawText(timeX, timeY, Graphics.FONT_NUMBER_MEDIUM, displayHours.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);
        
        // Divider dots with pulsing effect
        var dotRadius = 2;
        var dotY = timeY + 35;
        var pulseSize = (Math.sin(seconds * Math.PI / 30) + 1) * 0.3;
        dc.setColor(_theme["timeColor"], Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(timeX - 8, dotY, dotRadius + pulseSize);
        dc.fillCircle(timeX + 8, dotY, dotRadius + pulseSize);
        
        // Minutes
        dc.setColor(_theme["timeColor"], Graphics.COLOR_TRANSPARENT);
        dc.drawText(timeX, timeY + 55, Graphics.FONT_NUMBER_MEDIUM, minutes.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);
        
        // AM/PM indicator for 12-hour mode
        if (!is24Hour) {
            var amPm = hours < 12 ? "AM" : "PM";
            dc.setColor(_theme["labelColor"], Graphics.COLOR_TRANSPARENT);
            dc.drawText(timeX + 35, timeY + 25, Graphics.FONT_XTINY, amPm, Graphics.TEXT_JUSTIFY_LEFT);
        }
        
        // Get activity data
        var activityInfo = ActivityMonitor.getInfo();
        var profile = UserProfile.getProfile();
        
        // Draw activity stats with progress rings
        var startY = 90;
        var spacing = 50;
        var rightX = width - 60;
        
        // Steps with progress ring
        var stepGoal = activityInfo.stepGoal;
        var steps = activityInfo.steps;
        var stepProgress = stepGoal > 0 ? steps.toFloat() / stepGoal : 0;
        drawProgressRing(dc, rightX, startY + 15, 18, stepProgress, _theme["progressGood"]);
        drawIconAndValue(dc, rightX, startY, "STEP", steps.toString(), null);
        
        // Heart rate with zone indicator
        var hr = "--";
        var hrColor = 0xFFFFFF;
        if (ActivityMonitor has :getHeartRateHistory) {
            var hrHistory = ActivityMonitor.getHeartRateHistory(1, true);
            var hrSample = hrHistory.next();
            if (hrSample != null && hrSample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                hr = hrSample.heartRate.toString();
                hrColor = getHeartRateColor(hrSample.heartRate, profile);
            }
        }
        drawIconAndValue(dc, rightX, startY + spacing, "HR", hr, hrColor);
        
        // Calories with progress
        var calories = activityInfo.calories;
        var calGoal = 500; // Default calorie goal
        var calProgress = calories.toFloat() / calGoal;
        drawProgressRing(dc, rightX, startY + spacing + 15, 18, calProgress, _theme["progressWarn"]);
        drawIconAndValue(dc, rightX, startY + spacing * 2, "CAL", calories.toString(), null);
        
        // Distance
        var distance = activityInfo.distance / 100000.0;
        var distanceStr = distance.format("%.2f");
        drawIconAndValue(dc, rightX, startY + spacing * 3, "DIST", distanceStr + "km", null);
        
        // Add move bar indicator if needed
        var moveBarLevel = activityInfo.moveBarLevel;
        if (moveBarLevel > 0) {
            drawMoveBar(dc, width/2, height - 60, moveBarLevel);
        }
        
        // Draw stylized vertical divider
        dc.setColor(_theme["dividerColor"], Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        for (var y = 70; y < height - 70; y += 10) {
            dc.drawPoint(width / 2, y);
        }
        
        // Add weather info at bottom
        drawWeatherInfo(dc, width / 2, height - 40);
    }
    
    function drawBatteryIndicator(dc, x, y) {
        var battery = System.getSystemStats().battery;
        var batteryWidth = 40;
        var batteryHeight = 20;
        
        // Battery color based on level
        var batteryColor = _theme["batteryGood"];
        if (battery < 20) {
            batteryColor = _theme["batteryLow"];
        } else if (battery < 40) {
            batteryColor = _theme["batteryMid"];
        }
        
        // Draw battery outline
        dc.setColor(_theme["labelColor"], Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRectangle(x, y, batteryWidth, batteryHeight);
        dc.drawRectangle(x + batteryWidth, y + 5, 3, 10);
        
        // Draw battery fill
        var fillWidth = (batteryWidth - 4) * battery / 100;
        dc.setColor(batteryColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x + 2, y + 2, fillWidth, batteryHeight - 4);
        
        // Draw percentage
        dc.setColor(_theme["valueColor"], Graphics.COLOR_TRANSPARENT);
        dc.drawText(x - 5, y, Graphics.FONT_TINY, battery.format("%d") + "%", Graphics.TEXT_JUSTIFY_RIGHT);
    }
    
    function drawProgressRing(dc, centerX, centerY, radius, progress, color) {
        var startAngle = 90;
        var endAngle = startAngle - (360 * progress);
        
        // Draw background ring
        dc.setColor(_theme["dividerColor"], Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawCircle(centerX, centerY, radius);
        
        // Draw progress arc
        if (progress > 0) {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(4);
            dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE, startAngle, endAngle);
        }
    }
    
    function drawIconAndValue(dc, x, y, icon, value, color) {
        if (color == null) { color = _theme["valueColor"]; }
        
        // Use icon parameter directly as label
        dc.setColor(_theme["labelColor"], Graphics.COLOR_TRANSPARENT);
        dc.drawText(x - 45, y, Graphics.FONT_XTINY, icon, Graphics.TEXT_JUSTIFY_RIGHT);
        
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x + 15, y, Graphics.FONT_SMALL, value, Graphics.TEXT_JUSTIFY_RIGHT);
    }
    
    function getHeartRateColor(hr, profile) {
        if (profile == null || profile.restingHeartRate == null) {
            return Graphics.COLOR_WHITE;
        }
        
        // Simplified age calculation
        var age = 30; // Default age
        if (profile.birthYear != null) {
            var currentYear = Gregorian.info(Time.now(), Time.FORMAT_SHORT).year;
            age = currentYear - profile.birthYear;
        }
        var maxHr = 220 - age;
        var zone = hr.toFloat() / maxHr;
        
        if (zone < 0.5) {
            return 0x00AAFF; // Blue - rest
        } else if (zone < 0.6) {
            return 0x00FF00; // Green - light
        } else if (zone < 0.7) {
            return 0xFFFF00; // Yellow - moderate
        } else if (zone < 0.8) {
            return 0xFF8800; // Orange - hard
        } else {
            return 0xFF0000; // Red - maximum
        }
    }
    
    function drawMoveBar(dc, x, y, level) {
        var barWidth = 100;
        var barHeight = 6;
        var segmentWidth = barWidth / 5;
        
        dc.setColor(_theme["dividerColor"], Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - barWidth/2, y, barWidth, barHeight);
        
        // Fill move bar segments
        dc.setColor(0xFF0000, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < level && i < 5; i++) {
            dc.fillRectangle(x - barWidth/2 + (i * segmentWidth) + 1, y + 1, segmentWidth - 2, barHeight - 2);
        }
        
        dc.setColor(_theme["labelColor"], Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y - 15, Graphics.FONT_XTINY, "MOVE!", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function drawWeatherInfo(dc, x, y) {
        if (Weather has :getCurrentConditions) {
            var currentTime = System.getTimer();
            
            // Cache weather data for 5 minutes
            if (_weatherCache == null || (currentTime - _weatherCacheTime) > 300000) {
                var conditions = Weather.getCurrentConditions();
                if (conditions != null && conditions.temperature != null) {
                    var temp = conditions.temperature;
                    var tempStr = "--";
                    
                    // Convert from Celsius to user preference
                    var settings = System.getDeviceSettings();
                    if (settings has :temperatureUnits && settings.temperatureUnits == System.UNIT_STATUTE) {
                        temp = (temp * 9/5) + 32;
                        tempStr = temp.format("%d") + "°F";
                    } else {
                        tempStr = temp.format("%d") + "°C";
                    }
                    
                    _weatherCache = tempStr;
                    _weatherCacheTime = currentTime;
                }
            }
            
            if (_weatherCache != null) {
                dc.setColor(_theme["weatherColor"], Graphics.COLOR_TRANSPARENT);
                dc.drawText(x, y, Graphics.FONT_TINY, _weatherCache, Graphics.TEXT_JUSTIFY_CENTER);
            }
        }
    }
    
    function drawLowPowerMode(dc, hours, minutes) {
        // Simple time display for always-on mode
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var timeStr = Lang.format("$1$:$2$", [hours.format("%02d"), minutes.format("%02d")]);
        dc.drawText(_centerX, _centerY - 30, Graphics.FONT_SYSTEM_NUMBER_MEDIUM, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Basic date
        var now = Time.now();
        var date = Gregorian.info(now, Time.FORMAT_SHORT);
        dc.drawText(_centerX, _centerY + 20, Graphics.FONT_TINY, 
            Lang.format("$1$ $2$", [date.month, date.day]), 
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onHide() {
    }

    function onExitSleep() {
        _isLowPower = false;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() {
        _isLowPower = true;
        WatchUi.requestUpdate();
    }
}
