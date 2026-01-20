using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

class GreenView extends WatchUi.WatchFace {
    private var _w, _h;
    private var _ps = 4; // Pixel size for 8-bit look

    // 8-bit Color Palette (limited colors like NES/SNES)
    private const C_SKY = 0x5C94FC;
    private const C_SKY_LIGHT = 0x88D8FF;

    private const C_CLOUD_WHITE = 0xFCFCFC;
    private const C_CLOUD_SHADOW = 0xBCBCBC;
    private const C_CLOUD_OUTLINE = 0x000000;

    private const C_SUN_YELLOW = 0xF8D830;
    private const C_SUN_ORANGE = 0xE45C10;
    private const C_SUN_RAY = 0xF8D830;

    private const C_MTN_BLUE = 0x6888FC;
    private const C_MTN_DARK = 0x3C5AFC;
    private const C_MTN_SNOW = 0xFCFCFC;
    private const C_MTN_OUTLINE = 0x000000;

    private const C_HILL_GREEN = 0x00A800;
    private const C_HILL_LIGHT = 0x00E800;
    private const C_HILL_DARK = 0x005800;
    private const C_HILL_OUTLINE = 0x000000;

    private const C_GRASS = 0x80D010;
    private const C_GRASS_DARK = 0x58A800;

    private const C_PATH = 0xC89868;
    private const C_PATH_DARK = 0x885838;

    private const C_TREE_TRUNK = 0x885818;
    private const C_TREE_GREEN = 0x00A800;
    private const C_TREE_LIGHT = 0x00E800;

    private const C_BLACK = 0x000000;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _w = dc.getWidth();
        _h = dc.getHeight();
    }

    function onUpdate(dc) {
        drawSky(dc);
        drawSun(dc);
        drawClouds(dc);
        drawMountains(dc);
        drawHill(dc);
        drawGrass(dc);
        drawPath(dc);
        drawTrees(dc);
    }

    // Draw a single "pixel" (actually a square block)
    function px(dc, x, y, color) {
        dc.setColor(color, color);
        dc.fillRectangle(x * _ps, y * _ps, _ps, _ps);
    }

    // Draw a horizontal line of pixels
    function pxLine(dc, x, y, len, color) {
        dc.setColor(color, color);
        dc.fillRectangle(x * _ps, y * _ps, len * _ps, _ps);
    }

    // Draw a filled rectangle of pixels
    function pxRect(dc, x, y, w, h, color) {
        dc.setColor(color, color);
        dc.fillRectangle(x * _ps, y * _ps, w * _ps, h * _ps);
    }

    // ========== SKY ==========
    function drawSky(dc) {
        // Fill with main sky color
        dc.setColor(C_SKY_LIGHT, C_SKY_LIGHT);
        dc.clear();

        // Lighter band near horizon
        pxRect(dc, 0, 64, 80, 10, C_SKY);
    }

    // ========== SUN (8-bit style) ==========
    function drawSun(dc) {
        var sx = 62; // pixel coords
        var sy = 8;

        // Sun rays (pixels)
        //    |
        //  \ | /
        // ---O---
        //  / | \
        //    |

        // Vertical rays
        px(dc, sx, sy - 3, C_SUN_RAY);
        px(dc, sx, sy - 2, C_SUN_RAY);
        px(dc, sx, sy + 4, C_SUN_RAY);
        px(dc, sx, sy + 5, C_SUN_RAY);

        // Horizontal rays
        px(dc, sx - 3, sy + 1, C_SUN_RAY);
        px(dc, sx - 2, sy + 1, C_SUN_RAY);
        px(dc, sx + 3, sy + 1, C_SUN_RAY);
        px(dc, sx + 4, sy + 1, C_SUN_RAY);

        // Diagonal rays
        px(dc, sx - 2, sy - 1, C_SUN_RAY);
        px(dc, sx + 3, sy - 1, C_SUN_RAY);
        px(dc, sx - 2, sy + 3, C_SUN_RAY);
        px(dc, sx + 3, sy + 3, C_SUN_RAY);

        // Sun body (3x3 orange core)
        pxRect(dc, sx - 1, sy, 3, 3, C_SUN_ORANGE);

        // Sun highlight (yellow)
        pxRect(dc, sx, sy, 2, 2, C_SUN_YELLOW);
    }

    // ========== CLOUDS (8-bit blocky) ==========
    function drawClouds(dc) {
        // Cloud 1 (left side)
        drawCloud8bit(dc, 6, 8);

        // Cloud 2 (right side, larger)
        drawCloud8bit(dc, 48, 5);
    }

    function drawCloud8bit(dc, x, y) {
        // Classic 8-bit cloud shape
        //     ██
        //   ██████
        //  ████████
        //   ██████

        // Shadow/outline bottom
        pxLine(dc, x + 1, y + 3, 6, C_CLOUD_SHADOW);

        // Main cloud body (white)
        pxLine(dc, x + 2, y, 2, C_CLOUD_WHITE);      // Top bumps
        pxLine(dc, x + 1, y + 1, 6, C_CLOUD_WHITE);  // Upper middle
        pxLine(dc, x, y + 2, 8, C_CLOUD_WHITE);      // Widest part
        pxLine(dc, x + 1, y + 3, 6, C_CLOUD_WHITE);  // Bottom

        // Outline pixels (black)
        px(dc, x + 1, y - 1, C_BLACK);
        px(dc, x + 4, y - 1, C_BLACK);
        px(dc, x, y, C_BLACK);
        px(dc, x + 5, y, C_BLACK);
        px(dc, x - 1, y + 1, C_BLACK);
        px(dc, x + 7, y + 1, C_BLACK);
        px(dc, x - 1, y + 2, C_BLACK);
        px(dc, x + 8, y + 2, C_BLACK);
        px(dc, x, y + 4, C_BLACK);
        px(dc, x + 7, y + 4, C_BLACK);
    }

    // ========== MOUNTAINS (8-bit triangles) ==========
    function drawMountains(dc) {
        var baseY = 65;

        // Back mountain (lighter blue)
        draw8bitMountain(dc, 58, baseY, 18, C_MTN_BLUE, C_MTN_BLUE, true);

        // Front mountain (with shading)
        draw8bitMountain(dc, 48, baseY, 22, C_MTN_DARK, C_MTN_BLUE, true);
    }

    function draw8bitMountain(dc, x, baseY, height, darkColor, lightColor, hasSnow) {
        // Draw pixel-by-pixel triangle
        for (var row = 0; row < height; row++) {
            var y = baseY - height + row;
            var halfWidth = row;

            // Left side (dark)
            for (var col = 0; col < halfWidth; col++) {
                px(dc, x - halfWidth + col, y, darkColor);
            }

            // Right side (light)
            for (var col = 0; col <= halfWidth; col++) {
                px(dc, x + col, y, lightColor);
            }
        }

        // Snow cap
        if (hasSnow) {
            var snowH = height / 4;
            for (var row = 0; row < snowH; row++) {
                var y = baseY - height + row;
                var halfWidth = row;
                pxLine(dc, x - halfWidth, y, halfWidth * 2 + 1, C_MTN_SNOW);
            }
        }

        // Outline peak
        px(dc, x, baseY - height - 1, C_BLACK);
    }

    // ========== GREEN HILL ==========
    function drawHill(dc) {
        var baseY = 72;
        var peakX = 18;
        var height = 25;

        // Draw pixel triangle hill
        for (var row = 0; row < height; row++) {
            var y = baseY - height + row;
            var halfWidth = row + (row / 2); // Wider hill

            // Left side (dark)
            for (var col = 0; col < halfWidth; col++) {
                px(dc, peakX - halfWidth + col, y, C_HILL_DARK);
            }

            // Right side (light)
            for (var col = 0; col <= halfWidth; col++) {
                px(dc, peakX + col, y, C_HILL_GREEN);
            }
        }

        // Highlight spots on hill
        px(dc, peakX + 2, baseY - 15, C_HILL_LIGHT);
        px(dc, peakX + 5, baseY - 10, C_HILL_LIGHT);
        px(dc, peakX + 3, baseY - 8, C_HILL_LIGHT);

        // Detail pixels (grass texture)
        px(dc, peakX - 5, baseY - 8, C_HILL_DARK);
        px(dc, peakX - 3, baseY - 5, C_HILL_DARK);
    }

    // ========== GRASS GROUND ==========
    function drawGrass(dc) {
        var groundY = 72;

        // Main grass
        pxRect(dc, 0, groundY, 80, 18, C_GRASS);

        // Top edge darker stripe
        pxRect(dc, 0, groundY, 80, 2, C_GRASS_DARK);

        // Random grass texture
        for (var i = 0; i < 30; i++) {
            var gx = ((i * 17 + 3) % 78) + 1;
            var gy = groundY + 3 + (i % 5) * 2;
            px(dc, gx, gy, C_GRASS_DARK);
        }
    }

    // ========== PATH (curved to the right) ==========
    function drawPath(dc) {
        var groundY = 72;

        // Path with perspective + curve to right
        for (var row = 0; row < 18; row++) {
            var y = groundY + row;
            var halfW = 4 + (row / 2);

            // Center shifts right as we go down (curve effect)
            var curve = (row * row) / 25; // Quadratic curve
            var cx = 40 + curve;

            // Main path
            pxLine(dc, cx - halfW, y, halfW * 2, C_PATH);

            // Dark edges
            px(dc, cx - halfW, y, C_PATH_DARK);
            px(dc, cx + halfW - 1, y, C_PATH_DARK);
        }

        // Path texture dots (adjusted for curve)
        px(dc, 40, 75, C_PATH_DARK);
        px(dc, 43, 78, C_PATH_DARK);
        px(dc, 46, 81, C_PATH_DARK);
        px(dc, 50, 84, C_PATH_DARK);
        px(dc, 54, 87, C_PATH_DARK);
    }

    // ========== TREES (8-bit style) ==========
    function drawTrees(dc) {
        var groundY = 72;

        // Left trees
        draw8bitTree(dc, 5, groundY);
        draw8bitTree(dc, 12, groundY);

        // Right trees
        draw8bitTree(dc, 68, groundY);
        draw8bitTree(dc, 74, groundY);
    }

    function draw8bitTree(dc, x, groundY) {
        // Trunk (2 pixels wide, 5 tall)
        pxRect(dc, x, groundY - 5, 2, 6, C_TREE_TRUNK);

        // Crown (blocky 8-bit style)
        //    ██
        //   ████
        //  ██████
        //   ████

        var cy = groundY - 8;

        pxLine(dc, x, cy - 3, 2, C_TREE_GREEN);      // Top
        pxLine(dc, x - 1, cy - 2, 4, C_TREE_GREEN);  // Upper
        pxLine(dc, x - 2, cy - 1, 6, C_TREE_GREEN);  // Widest
        pxLine(dc, x - 1, cy, 4, C_TREE_GREEN);      // Lower

        // Highlight pixels
        px(dc, x, cy - 3, C_TREE_LIGHT);
        px(dc, x - 1, cy - 2, C_TREE_LIGHT);
    }

    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}
}
