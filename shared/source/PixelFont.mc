using Toybox.Graphics;

// Shared pixel font drawing module
// Can be used by any watch face
module PixelFont {
    // Draw a tiny pixel letter (6x8 grid) at position x,y
    // Returns width of drawn character for spacing
    function drawChar(dc, x, y, ch) {
        dc.setPenWidth(1);

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
        } else if (ch == 'A') {
            dc.drawLine(x+2, y, x, y+7);
            dc.drawLine(x+3, y, x+5, y+7);
            dc.drawLine(x+1, y+4, x+4, y+4);
            return 6;
        } else if (ch == 'T') {
            dc.drawLine(x, y, x+5, y);
            dc.drawLine(x+2, y, x+2, y+7);
            return 6;
        } else if (ch == 'D') {
            dc.drawLine(x, y, x, y+7);
            dc.drawLine(x, y, x+4, y);
            dc.drawLine(x+4, y, x+5, y+1);
            dc.drawLine(x+5, y+1, x+5, y+6);
            dc.drawLine(x+5, y+6, x+4, y+7);
            dc.drawLine(x, y+7, x+4, y+7);
            return 6;
        } else if (ch == 'E') {
            dc.drawLine(x, y, x, y+7);
            dc.drawLine(x, y, x+5, y);
            dc.drawLine(x, y+3, x+4, y+3);
            dc.drawLine(x, y+7, x+5, y+7);
            return 6;
        } else if (ch == 'S') {
            dc.drawLine(x+1, y, x+5, y);
            dc.drawLine(x, y+1, x, y+2);
            dc.drawLine(x+1, y+3, x+4, y+3);
            dc.drawLine(x+5, y+4, x+5, y+6);
            dc.drawLine(x, y+7, x+4, y+7);
            return 6;
        } else if (ch == 'P') {
            dc.drawLine(x, y, x, y+7);
            dc.drawLine(x, y, x+4, y);
            dc.drawLine(x+4, y, x+5, y+1);
            dc.drawLine(x+5, y+1, x+5, y+2);
            dc.drawLine(x+5, y+2, x+4, y+3);
            dc.drawLine(x, y+3, x+4, y+3);
            return 6;
        } else if (ch == 'H') {
            dc.drawLine(x, y, x, y+7);
            dc.drawLine(x+5, y, x+5, y+7);
            dc.drawLine(x, y+3, x+5, y+3);
            return 6;
        } else if (ch == 'R') {
            dc.drawLine(x, y, x, y+7);
            dc.drawLine(x, y, x+4, y);
            dc.drawLine(x+4, y, x+5, y+1);
            dc.drawLine(x+5, y+1, x+5, y+2);
            dc.drawLine(x+5, y+2, x+4, y+3);
            dc.drawLine(x, y+3, x+4, y+3);
            dc.drawLine(x+2, y+3, x+5, y+7);
            return 6;
        } else if (ch == '0') {
            dc.drawLine(x+1, y, x+4, y);
            dc.drawLine(x, y+1, x, y+6);
            dc.drawLine(x+5, y+1, x+5, y+6);
            dc.drawLine(x+1, y+7, x+4, y+7);
            return 6;
        } else if (ch == '1') {
            dc.drawLine(x+2, y, x+2, y+7);
            dc.drawLine(x+1, y+1, x+2, y);
            dc.drawLine(x, y+7, x+4, y+7);
            return 5;
        } else if (ch == '2') {
            dc.drawLine(x+1, y, x+4, y);
            dc.drawLine(x+5, y+1, x+5, y+2);
            dc.drawLine(x+4, y+3, x+1, y+3);
            dc.drawLine(x, y+4, x, y+6);
            dc.drawLine(x, y+7, x+5, y+7);
            return 6;
        } else if (ch == '3') {
            dc.drawLine(x, y, x+4, y);
            dc.drawLine(x+5, y+1, x+5, y+2);
            dc.drawLine(x+2, y+3, x+4, y+3);
            dc.drawLine(x+5, y+4, x+5, y+6);
            dc.drawLine(x, y+7, x+4, y+7);
            return 6;
        } else if (ch == '4') {
            dc.drawLine(x, y, x, y+3);
            dc.drawLine(x, y+3, x+5, y+3);
            dc.drawLine(x+4, y, x+4, y+7);
            return 6;
        } else if (ch == '5') {
            dc.drawLine(x, y, x+5, y);
            dc.drawLine(x, y, x, y+3);
            dc.drawLine(x, y+3, x+4, y+3);
            dc.drawLine(x+5, y+4, x+5, y+6);
            dc.drawLine(x, y+7, x+4, y+7);
            return 6;
        } else if (ch == '6') {
            dc.drawLine(x+1, y, x+5, y);
            dc.drawLine(x, y+1, x, y+6);
            dc.drawLine(x+1, y+3, x+4, y+3);
            dc.drawLine(x+5, y+4, x+5, y+6);
            dc.drawLine(x+1, y+7, x+4, y+7);
            return 6;
        } else if (ch == '7') {
            dc.drawLine(x, y, x+5, y);
            dc.drawLine(x+5, y, x+2, y+7);
            return 6;
        } else if (ch == '8') {
            dc.drawLine(x+1, y, x+4, y);
            dc.drawLine(x, y+1, x, y+2);
            dc.drawLine(x+5, y+1, x+5, y+2);
            dc.drawLine(x+1, y+3, x+4, y+3);
            dc.drawLine(x, y+4, x, y+6);
            dc.drawLine(x+5, y+4, x+5, y+6);
            dc.drawLine(x+1, y+7, x+4, y+7);
            return 6;
        } else if (ch == '9') {
            dc.drawLine(x+1, y, x+4, y);
            dc.drawLine(x, y+1, x, y+2);
            dc.drawLine(x+5, y+1, x+5, y+6);
            dc.drawLine(x+1, y+3, x+4, y+3);
            dc.drawLine(x, y+7, x+4, y+7);
            return 6;
        } else if (ch == ':') {
            dc.fillRectangle(x+1, y+2, 2, 2);
            dc.fillRectangle(x+1, y+5, 2, 2);
            return 4;
        }
        return 0;
    }

    // Draw a label string centered at x,y using pixel characters
    function drawLabel(dc, cx, y, label) {
        var charW = 6;
        var spacing = 2;
        var totalW = label.length() * charW + (label.length() - 1) * spacing;
        var x = cx - totalW / 2;

        for (var i = 0; i < label.length(); i++) {
            drawChar(dc, x, y, label.substring(i, i+1).toCharArray()[0]);
            x += charW + spacing;
        }
    }

    // Get the height of pixel-drawn labels
    function getLabelHeight() {
        return 10;
    }

    // Draw a scaled pixel at position using fillRectangle
    function px(dc, x, y, s) {
        dc.fillRectangle(x * s, y * s, s, s);
    }

    // Draw scaled character - s is pixel size (e.g., 3 = 3x3 pixels)
    function drawCharScaled(dc, x, y, ch, s) {
        if (ch == '0') {
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y, s); px(dc, x+i, y+7, s); }
            for (var i = 1; i <= 6; i++) { px(dc, x, y+i, s); px(dc, x+5, y+i, s); }
            return 6;
        } else if (ch == '1') {
            for (var i = 0; i <= 7; i++) { px(dc, x+2, y+i, s); }
            px(dc, x+1, y+1, s);
            for (var i = 0; i <= 4; i++) { px(dc, x+i, y+7, s); }
            return 5;
        } else if (ch == '2') {
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y, s); }
            px(dc, x+5, y+1, s); px(dc, x+5, y+2, s);
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y+3, s); }
            px(dc, x, y+4, s); px(dc, x, y+5, s); px(dc, x, y+6, s);
            for (var i = 0; i <= 5; i++) { px(dc, x+i, y+7, s); }
            return 6;
        } else if (ch == '3') {
            for (var i = 0; i <= 4; i++) { px(dc, x+i, y, s); }
            px(dc, x+5, y+1, s); px(dc, x+5, y+2, s);
            for (var i = 2; i <= 4; i++) { px(dc, x+i, y+3, s); }
            px(dc, x+5, y+4, s); px(dc, x+5, y+5, s); px(dc, x+5, y+6, s);
            for (var i = 0; i <= 4; i++) { px(dc, x+i, y+7, s); }
            return 6;
        } else if (ch == '4') {
            for (var i = 0; i <= 3; i++) { px(dc, x, y+i, s); }
            for (var i = 0; i <= 5; i++) { px(dc, x+i, y+3, s); }
            for (var i = 0; i <= 7; i++) { px(dc, x+4, y+i, s); }
            return 6;
        } else if (ch == '5') {
            for (var i = 0; i <= 5; i++) { px(dc, x+i, y, s); }
            px(dc, x, y+1, s); px(dc, x, y+2, s);
            for (var i = 0; i <= 4; i++) { px(dc, x+i, y+3, s); }
            px(dc, x+5, y+4, s); px(dc, x+5, y+5, s); px(dc, x+5, y+6, s);
            for (var i = 0; i <= 4; i++) { px(dc, x+i, y+7, s); }
            return 6;
        } else if (ch == '6') {
            for (var i = 1; i <= 5; i++) { px(dc, x+i, y, s); }
            for (var i = 1; i <= 6; i++) { px(dc, x, y+i, s); }
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y+3, s); }
            px(dc, x+5, y+4, s); px(dc, x+5, y+5, s); px(dc, x+5, y+6, s);
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y+7, s); }
            return 6;
        } else if (ch == '7') {
            for (var i = 0; i <= 5; i++) { px(dc, x+i, y, s); }
            px(dc, x+5, y+1, s); px(dc, x+4, y+2, s); px(dc, x+4, y+3, s);
            px(dc, x+3, y+4, s); px(dc, x+3, y+5, s); px(dc, x+2, y+6, s); px(dc, x+2, y+7, s);
            return 6;
        } else if (ch == '8') {
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y, s); px(dc, x+i, y+3, s); px(dc, x+i, y+7, s); }
            px(dc, x, y+1, s); px(dc, x, y+2, s); px(dc, x+5, y+1, s); px(dc, x+5, y+2, s);
            px(dc, x, y+4, s); px(dc, x, y+5, s); px(dc, x, y+6, s);
            px(dc, x+5, y+4, s); px(dc, x+5, y+5, s); px(dc, x+5, y+6, s);
            return 6;
        } else if (ch == '9') {
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y, s); px(dc, x+i, y+3, s); }
            px(dc, x, y+1, s); px(dc, x, y+2, s);
            for (var i = 1; i <= 6; i++) { px(dc, x+5, y+i, s); }
            for (var i = 0; i <= 4; i++) { px(dc, x+i, y+7, s); }
            return 6;
        } else if (ch == ':') {
            px(dc, x+1, y+2, s); px(dc, x+1, y+5, s);
            return 3;
        } else if (ch == '/') {
            px(dc, x+4, y, s); px(dc, x+4, y+1, s); px(dc, x+3, y+2, s); px(dc, x+3, y+3, s);
            px(dc, x+2, y+4, s); px(dc, x+2, y+5, s); px(dc, x+1, y+6, s); px(dc, x+1, y+7, s);
            return 5;
        } else if (ch == 'S') {
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y, s); }
            px(dc, x, y+1, s); px(dc, x, y+2, s);
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y+3, s); }
            px(dc, x+5, y+4, s); px(dc, x+5, y+5, s); px(dc, x+5, y+6, s);
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y+7, s); }
            return 6;
        } else if (ch == 'U') {
            for (var i = 0; i <= 6; i++) { px(dc, x, y+i, s); px(dc, x+5, y+i, s); }
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y+7, s); }
            return 6;
        } else if (ch == 'N') {
            for (var i = 0; i <= 7; i++) { px(dc, x, y+i, s); px(dc, x+5, y+i, s); }
            px(dc, x+1, y+1, s); px(dc, x+2, y+2, s); px(dc, x+3, y+3, s); px(dc, x+4, y+4, s);
            return 6;
        } else if (ch == 'M') {
            for (var i = 0; i <= 7; i++) { px(dc, x, y+i, s); px(dc, x+5, y+i, s); }
            px(dc, x+1, y+1, s); px(dc, x+2, y+2, s); px(dc, x+3, y+2, s); px(dc, x+4, y+1, s);
            return 6;
        } else if (ch == 'O') {
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y, s); px(dc, x+i, y+7, s); }
            for (var i = 1; i <= 6; i++) { px(dc, x, y+i, s); px(dc, x+5, y+i, s); }
            return 6;
        } else if (ch == 'T') {
            for (var i = 0; i <= 5; i++) { px(dc, x+i, y, s); }
            for (var i = 1; i <= 7; i++) { px(dc, x+2, y+i, s); }
            return 6;
        } else if (ch == 'E') {
            for (var i = 0; i <= 5; i++) { px(dc, x+i, y, s); px(dc, x+i, y+7, s); }
            for (var i = 0; i <= 7; i++) { px(dc, x, y+i, s); }
            for (var i = 1; i <= 3; i++) { px(dc, x+i, y+3, s); }
            return 6;
        } else if (ch == 'W') {
            for (var i = 0; i <= 7; i++) { px(dc, x, y+i, s); px(dc, x+5, y+i, s); }
            px(dc, x+1, y+6, s); px(dc, x+2, y+5, s); px(dc, x+3, y+5, s); px(dc, x+4, y+6, s);
            return 6;
        } else if (ch == 'D') {
            for (var i = 0; i <= 7; i++) { px(dc, x, y+i, s); }
            for (var i = 1; i <= 3; i++) { px(dc, x+i, y, s); px(dc, x+i, y+7, s); }
            px(dc, x+4, y+1, s); px(dc, x+4, y+6, s);
            for (var i = 2; i <= 5; i++) { px(dc, x+5, y+i, s); }
            return 6;
        } else if (ch == 'H') {
            for (var i = 0; i <= 7; i++) { px(dc, x, y+i, s); px(dc, x+5, y+i, s); }
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y+3, s); }
            return 6;
        } else if (ch == 'F') {
            for (var i = 0; i <= 5; i++) { px(dc, x+i, y, s); }
            for (var i = 0; i <= 7; i++) { px(dc, x, y+i, s); }
            for (var i = 1; i <= 3; i++) { px(dc, x+i, y+3, s); }
            return 6;
        } else if (ch == 'R') {
            for (var i = 0; i <= 7; i++) { px(dc, x, y+i, s); }
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y, s); }
            px(dc, x+5, y+1, s); px(dc, x+5, y+2, s);
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y+3, s); }
            px(dc, x+3, y+4, s); px(dc, x+4, y+5, s); px(dc, x+5, y+6, s); px(dc, x+5, y+7, s);
            return 6;
        } else if (ch == 'I') {
            for (var i = 0; i <= 4; i++) { px(dc, x+i, y, s); px(dc, x+i, y+7, s); }
            for (var i = 1; i <= 6; i++) { px(dc, x+2, y+i, s); }
            return 5;
        } else if (ch == 'A') {
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y, s); }
            for (var i = 1; i <= 7; i++) { px(dc, x, y+i, s); px(dc, x+5, y+i, s); }
            for (var i = 1; i <= 4; i++) { px(dc, x+i, y+3, s); }
            return 6;
        }
        return 0;
    }

    // Draw scaled label centered at cx, y (in actual pixels, not grid)
    function drawLabelScaled(dc, cx, y, label, s) {
        var charW = 6;
        var spacing = 2;
        var totalW = (label.length() * charW + (label.length() - 1) * spacing) * s;
        var startX = (cx - totalW / 2) / s;

        for (var i = 0; i < label.length(); i++) {
            drawCharScaled(dc, startX, y / s, label.substring(i, i+1).toCharArray()[0], s);
            startX += charW + spacing;
        }
    }
}
