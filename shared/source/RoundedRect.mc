using Toybox.Graphics;

// Shared rounded rectangle drawing module
module RoundedRect {
    // Draw a rounded rectangle border
    function draw(dc, x1, y1, x2, y2, r) {
        // Top edge (between corners)
        dc.drawLine(x1 + r, y1, x2 - r, y1);
        // Bottom edge
        dc.drawLine(x1 + r, y2, x2 - r, y2);
        // Left edge
        dc.drawLine(x1, y1 + r, x1, y2 - r);
        // Right edge
        dc.drawLine(x2, y1 + r, x2, y2 - r);

        // Corner arcs
        dc.drawArc(x1 + r, y1 + r, r, Graphics.ARC_COUNTER_CLOCKWISE, 90, 180);  // Top-left
        dc.drawArc(x2 - r, y1 + r, r, Graphics.ARC_COUNTER_CLOCKWISE, 0, 90);    // Top-right
        dc.drawArc(x2 - r, y2 - r, r, Graphics.ARC_COUNTER_CLOCKWISE, 270, 0);   // Bottom-right
        dc.drawArc(x1 + r, y2 - r, r, Graphics.ARC_COUNTER_CLOCKWISE, 180, 270); // Bottom-left
    }
}
