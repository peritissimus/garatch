export const ICON_OPTIONS = [
  ["heart", "Heart"],
  ["steps", "Steps"],
  ["battery", "Battery"],
  ["flame", "Flame"],
  ["pin", "Location"],
  ["sun", "Sun"],
  ["bolt", "Bolt"],
];

export const ICON_STYLE_OPTIONS = [
  ["filled", "Filled"],
  ["outline", "Outline"],
];

export function drawCanvasIcon(context, element) {
  const { x, y, size, icon, color } = element;
  const half = size / 2;
  const quarter = size / 4;
  const fifth = size / 5;
  const eighth = size / 8;
  const filled = element.style !== "outline";
  context.save();
  context.fillStyle = color;
  context.strokeStyle = color;
  context.lineWidth = 2;
  context.lineJoin = "round";
  context.lineCap = "round";
  const paint = () => filled ? context.fill() : context.stroke();
  context.beginPath();
  if (icon === "heart") {
    context.arc(x - fifth, y - eighth, quarter, 0, Math.PI * 2);
    context.arc(x + fifth, y - eighth, quarter, 0, Math.PI * 2);
    paint();
    context.beginPath(); context.moveTo(x - half, y - eighth); context.lineTo(x + half, y - eighth); context.lineTo(x, y + half); context.closePath(); paint();
  } else if (icon === "steps") {
    context.ellipse(x - quarter, y - quarter, quarter / 2, half / 2, -0.25, 0, Math.PI * 2);
    context.ellipse(x + quarter, y + eighth, quarter / 2, half / 2, -0.25, 0, Math.PI * 2); paint();
  } else if (icon === "battery") {
    if (filled) context.fillRect(x - half, y - quarter, size - 3, size / 2);
    else context.strokeRect(x - half, y - quarter, size - 3, size / 2);
    context.fillRect(x + half - 2, y - eighth, 3, size / 4);
  } else if (icon === "flame") {
    context.moveTo(x, y - half); context.lineTo(x + half, y + eighth); context.lineTo(x + quarter, y + half); context.lineTo(x - quarter, y + half); context.lineTo(x - half, y); context.closePath(); paint();
  } else if (icon === "pin") {
    context.arc(x, y - quarter, quarter, 0, Math.PI * 2); paint();
    context.beginPath(); context.moveTo(x - quarter, y - eighth); context.lineTo(x + quarter, y - eighth); context.lineTo(x, y + half); context.closePath(); paint();
  } else if (icon === "sun") {
    context.arc(x, y, quarter, 0, Math.PI * 2); paint();
    context.beginPath();
    [[x, y-half, x, y-quarter-2], [x, y+quarter+2, x, y+half], [x-half, y, x-quarter-2, y], [x+quarter+2, y, x+half, y]].forEach(([x1,y1,x2,y2]) => { context.moveTo(x1,y1); context.lineTo(x2,y2); });
    context.stroke();
  } else {
    context.moveTo(x + eighth, y - half); context.lineTo(x - half, y + eighth); context.lineTo(x - eighth, y); context.lineTo(x - quarter, y); context.lineTo(x - eighth, y + half); context.lineTo(x + half, y - eighth); context.closePath(); paint();
  }
  context.restore();
}
