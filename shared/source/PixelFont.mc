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
}
