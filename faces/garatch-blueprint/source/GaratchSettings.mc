using Toybox.Application;
using Toybox.Graphics;

module GaratchSettings {
    // Color themes
    enum {
        THEME_DEFAULT,
        THEME_DARK,
        THEME_LIGHT,
        THEME_COLORFUL,
        THEME_NIGHT
    }
    
    // Theme definitions
    const THEMES = {
        THEME_DEFAULT => {
            :background => Graphics.COLOR_BLACK,
            :timeColor => 0xFFD700,    // Gold
            :dateColor => 0xAABBCC,     // Light blue-gray
            :labelColor => 0x666666,    // Dark gray
            :valueColor => Graphics.COLOR_WHITE,
            :dividerColor => 0x333333,
            :batteryGood => Graphics.COLOR_GREEN,
            :batteryMid => Graphics.COLOR_YELLOW,
            :batteryLow => Graphics.COLOR_RED,
            :progressGood => 0x00FF00,
            :progressWarn => 0xFF8800,
            :weatherColor => 0x88AACC
        },
        THEME_DARK => {
            :background => Graphics.COLOR_BLACK,
            :timeColor => 0x888888,     // Medium gray
            :dateColor => 0x555555,     // Dark gray
            :labelColor => 0x333333,    // Very dark gray
            :valueColor => 0xAAAAAA,    // Light gray
            :dividerColor => 0x222222,
            :batteryGood => 0x008800,
            :batteryMid => 0x888800,
            :batteryLow => 0x880000,
            :progressGood => 0x006600,
            :progressWarn => 0x884400,
            :weatherColor => 0x555555
        },
        THEME_LIGHT => {
            :background => Graphics.COLOR_WHITE,
            :timeColor => 0x0066CC,     // Blue
            :dateColor => 0x333333,     // Dark gray
            :labelColor => 0x666666,    // Medium gray
            :valueColor => Graphics.COLOR_BLACK,
            :dividerColor => 0xCCCCCC,
            :batteryGood => 0x00AA00,
            :batteryMid => 0xAAAA00,
            :batteryLow => Graphics.COLOR_RED,
            :progressGood => 0x00CC00,
            :progressWarn => 0xFF8800,
            :weatherColor => 0x0088CC
        },
        THEME_COLORFUL => {
            :background => Graphics.COLOR_BLACK,
            :timeColor => 0xFF00FF,     // Magenta
            :dateColor => 0x00FFFF,     // Cyan
            :labelColor => 0xFF8800,    // Orange
            :valueColor => 0x00FF00,    // Green
            :dividerColor => 0x8800FF,  // Purple
            :batteryGood => 0x00FF00,
            :batteryMid => 0xFFFF00,
            :batteryLow => 0xFF0000,
            :progressGood => 0x00FFFF,
            :progressWarn => 0xFF00FF,
            :weatherColor => 0xFFFF00
        },
        THEME_NIGHT => {
            :background => Graphics.COLOR_BLACK,
            :timeColor => 0x880000,     // Dark red
            :dateColor => 0x440000,     // Very dark red
            :labelColor => 0x330000,    // Almost black red
            :valueColor => 0xAA0000,    // Medium red
            :dividerColor => 0x220000,
            :batteryGood => 0x004400,
            :batteryMid => 0x444400,
            :batteryLow => 0x440000,
            :progressGood => 0x003300,
            :progressWarn => 0x442200,
            :weatherColor => 0x660000
        }
    };
    
    function getTheme() {
        var app = Application.getApp();
        var theme = app.getProperty("theme");
        if (theme == null || !THEMES.hasKey(theme)) {
            theme = THEME_DEFAULT;
        }
        return THEMES[theme];
    }
    
    function setTheme(theme) {
        var app = Application.getApp();
        app.setProperty("theme", theme);
    }
}
