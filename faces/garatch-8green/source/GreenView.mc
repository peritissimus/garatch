using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Lang;

class GreenView extends WatchUi.WatchFace {
    private var _w, _h;

    // 8-bit Pixel Art Colors
    private const C_SKY = 0x87CEEB;          // Light blue sky
    private const C_CLOUD_WHITE = 0xFFFFFF;
    private const C_CLOUD_SHADOW = 0xDDDDDD;
    private const C_SUN_YELLOW = 0xFFCC00;
    private const C_SUN_ORANGE = 0xFF9900;
    private const C_SUN_RAY = 0xFFDD44;

    private const C_MOUNTAIN_BLUE = 0x5588BB;
    private const C_MOUNTAIN_DARK = 0x446699;
    private const C_SNOW = 0xFFFFFF;

    private const C_HILL_GREEN = 0x44AA44;
    private const C_HILL_DARK = 0x338833;
    private const C_HILL_LIGHT = 0x55BB55;

    private const C_GRASS = 0x7EC850;
    private const C_GRASS_DARK = 0x5DA040;

    private const C_PATH_LIGHT = 0xC4A060;
    private const C_PATH_DARK = 0x9A7848;

    private const C_TREE_TRUNK = 0x8B5A2B;
    private const C_TREE_GREEN = 0x228B22;
    private const C_TREE_LIGHT = 0x32CD32;

    private const C_BLACK = 0x000000;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _w = dc.getWidth();
        _h = dc.getHeight();
    }

    function onUpdate(dc) {
        // LAYER 1: Sky background
        drawSky(dc);

        // LAYER 2: Sun with rays
        drawSun(dc);

        // LAYER 3: Clouds
        drawClouds(dc);

        // LAYER 4: Blue mountains (background)
        drawBlueMountains(dc);

        // LAYER 5: Green hills
        drawGreenHills(dc);

        // LAYER 6: Trees
        drawTrees(dc);

        // LAYER 7: Grass ground
        drawGrass(dc);

        // LAYER 8: Path
        drawPath(dc);
    }

    // ========== LAYER 1: SKY ==========
    function drawSky(dc) {
        dc.setColor(C_SKY, C_SKY);
        dc.clear();
    }

    // ========== LAYER 2: SUN ==========
    function drawSun(dc) {
        var sx = _w - 70;
        var sy = 45;

        // Sun rays (behind sun)
        dc.setColor(C_SUN_RAY, Graphics.COLOR_TRANSPARENT);
        // Draw pixel rays
        for (var i = 0; i < 8; i++) {
            var angle = i * 45;
            var rad = angle * 3.14159 / 180.0;
            var x1 = sx + 18 * Math.cos(rad);
            var y1 = sy + 18 * Math.sin(rad);
            var x2 = sx + 28 * Math.cos(rad);
            var y2 = sy + 28 * Math.sin(rad);
            dc.setPenWidth(3);
            dc.drawLine(x1, y1, x2, y2);
        }

        // Sun body (pixelated circle)
        dc.setColor(C_SUN_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(sx, sy, 15);
        dc.setColor(C_SUN_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(sx, sy, 12);

        // Pixel highlight
        dc.setColor(0xFFFF99, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(sx - 5, sy - 5, 4, 4);
    }

    // ========== LAYER 3: CLOUDS ==========
    function drawClouds(dc) {
        // Cloud 1 (left)
        drawPixelCloud(dc, 50, 50, 1.0);

        // Cloud 2 (right, behind sun)
        drawPixelCloud(dc, _w - 100, 35, 1.2);
    }

    function drawPixelCloud(dc, x, y, scale) {
        var s = scale.toNumber();
        if (s < 1) { s = 1; }
        var ps = 4 * s; // pixel size

        // Shadow layer
        dc.setColor(C_CLOUD_SHADOW, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x + ps, y + ps*2, ps*6, ps);

        // Main cloud body (white blobs)
        dc.setColor(C_CLOUD_WHITE, Graphics.COLOR_TRANSPARENT);

        // Bottom row
        dc.fillRectangle(x, y + ps, ps*6, ps);

        // Middle row
        dc.fillRectangle(x - ps, y, ps*2, ps);
        dc.fillRectangle(x + ps*2, y, ps*3, ps);

        // Top bumps
        dc.fillRectangle(x, y - ps, ps*2, ps);
        dc.fillRectangle(x + ps*3, y - ps, ps*2, ps);

        // Black outline (pixelated)
        dc.setColor(C_BLACK, Graphics.COLOR_TRANSPARENT);
        // Top outline
        dc.fillRectangle(x - ps, y - ps, ps, ps);
        dc.fillRectangle(x + ps*2, y - ps*2, ps, ps);
        dc.fillRectangle(x + ps*5, y - ps, ps, ps);
        // Side outlines
        dc.fillRectangle(x - ps*2, y, ps, ps*2);
        dc.fillRectangle(x + ps*6, y, ps, ps*2);
    }

    // ========== LAYER 4: BLUE MOUNTAINS ==========
    function drawBlueMountains(dc) {
        var groundY = _h - 90;

        // Mountain 1 (right side)
        var m1x = _w - 80;
        var m1w = 100;
        var m1h = 90;

        // Dark side
        dc.setColor(C_MOUNTAIN_DARK, Graphics.COLOR_TRANSPARENT);
        drawPixelTriangle(dc, m1x, groundY, m1x + m1w/2, groundY - m1h, m1x + m1w/2, groundY);

        // Light side
        dc.setColor(C_MOUNTAIN_BLUE, Graphics.COLOR_TRANSPARENT);
        drawPixelTriangle(dc, m1x + m1w/2, groundY - m1h, m1x + m1w, groundY, m1x + m1w/2, groundY);

        // Snow cap
        dc.setColor(C_SNOW, Graphics.COLOR_TRANSPARENT);
        drawPixelTriangle(dc, m1x + m1w/2, groundY - m1h, m1x + m1w/2 - 15, groundY - m1h + 25, m1x + m1w/2 + 15, groundY - m1h + 25);

        // Mountain 2 (smaller, behind)
        var m2x = _w - 50;
        var m2h = 70;

        dc.setColor(C_MOUNTAIN_DARK, Graphics.COLOR_TRANSPARENT);
        drawPixelTriangle(dc, m2x, groundY, m2x + 40, groundY - m2h, m2x + 80, groundY);

        dc.setColor(C_SNOW, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(m2x + 35, groundY - m2h, 10, 15);

        // Black outline on peaks
        dc.setColor(C_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(m1x + m1w/2 - 2, groundY - m1h - 2, 4, 4);
    }

    function drawPixelTriangle(dc, x1, y1, x2, y2, x3, y3) {
        dc.fillPolygon([[x1, y1], [x2, y2], [x3, y3]]);
    }

    // ========== LAYER 5: GREEN HILLS ==========
    function drawGreenHills(dc) {
        var groundY = _h - 70;

        // Left hill (large)
        dc.setColor(C_HILL_GREEN, Graphics.COLOR_TRANSPARENT);
        drawPixelTriangle(dc, -30, groundY + 20, 70, groundY - 80, 170, groundY + 20);

        // Hill shadow/detail
        dc.setColor(C_HILL_DARK, Graphics.COLOR_TRANSPARENT);
        drawPixelTriangle(dc, -30, groundY + 20, 70, groundY - 80, 70, groundY + 20);

        // Highlight
        dc.setColor(C_HILL_LIGHT, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(55, groundY - 50, 8, 8);
        dc.fillRectangle(65, groundY - 35, 6, 6);

        // Black outline dots on hill
        dc.setColor(C_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(50, groundY - 20, 3, 3);
        dc.fillRectangle(80, groundY - 10, 3, 3);
    }

    // ========== LAYER 6: TREES ==========
    function drawTrees(dc) {
        var groundY = _h - 70;

        // Left trees (near green hill)
        drawPixelTree(dc, 30, groundY, 0.8);
        drawPixelTree(dc, 55, groundY, 0.7);

        // Right trees (near mountains)
        drawPixelTree(dc, _w - 45, groundY, 0.9);
        drawPixelTree(dc, _w - 25, groundY, 0.75);
    }

    function drawPixelTree(dc, x, groundY, scale) {
        var trunkW = (8 * scale).toNumber();
        var trunkH = (20 * scale).toNumber();
        var crownR = (15 * scale).toNumber();

        // Trunk
        dc.setColor(C_TREE_TRUNK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - trunkW/2, groundY - trunkH, trunkW, trunkH);

        // Crown (layered circles for pixel look)
        dc.setColor(C_TREE_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x, groundY - trunkH - crownR, crownR);

        // Highlight on crown
        dc.setColor(C_TREE_LIGHT, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(x - 3, groundY - trunkH - crownR - 3, crownR / 2);

        // Black outline dots
        dc.setColor(C_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x - crownR, groundY - trunkH - crownR, 2, 2);
        dc.fillRectangle(x + crownR - 2, groundY - trunkH - crownR, 2, 2);
    }

    // ========== LAYER 7: GRASS GROUND ==========
    function drawGrass(dc) {
        var groundY = _h - 70;

        // Main grass area
        dc.setColor(C_GRASS, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, groundY, _w, _h - groundY);

        // Darker grass stripe
        dc.setColor(C_GRASS_DARK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, groundY, _w, 8);

        // Some grass detail pixels
        dc.setColor(C_GRASS_DARK, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 20; i++) {
            var gx = (i * 17 + 5) % _w;
            var gy = groundY + 15 + (i % 3) * 10;
            dc.fillRectangle(gx, gy, 3, 3);
        }
    }

    // ========== LAYER 8: PATH ==========
    function drawPath(dc) {
        var groundY = _h - 70;

        // Path - trapezoid shape (wider at bottom)
        var topW = 40;
        var botW = 80;
        var pathH = _h - groundY;

        // Main path
        dc.setColor(C_PATH_LIGHT, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [_w/2 - topW/2, groundY],
            [_w/2 + topW/2, groundY],
            [_w/2 + botW/2, _h],
            [_w/2 - botW/2, _h]
        ]);

        // Path dark edge (left)
        dc.setColor(C_PATH_DARK, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([
            [_w/2 - topW/2, groundY],
            [_w/2 - topW/2 + 5, groundY],
            [_w/2 - botW/2 + 8, _h],
            [_w/2 - botW/2, _h]
        ]);

        // Path dark edge (right)
        dc.fillPolygon([
            [_w/2 + topW/2 - 5, groundY],
            [_w/2 + topW/2, groundY],
            [_w/2 + botW/2, _h],
            [_w/2 + botW/2 - 8, _h]
        ]);

        // Path texture dots
        dc.setColor(C_PATH_DARK, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 8; i++) {
            var py = groundY + 10 + i * 12;
            var spread = 10 + i * 4;
            dc.fillRectangle(_w/2 - spread/2 + (i%2)*8, py, 4, 4);
            dc.fillRectangle(_w/2 + spread/2 - 8 - (i%2)*8, py, 4, 4);
        }
    }

    function onHide() {}
    function onExitSleep() {}
    function onEnterSleep() {}
}
