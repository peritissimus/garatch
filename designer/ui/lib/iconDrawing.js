export const ICON_OPTIONS = [
  ["heart", "Heart"],
  ["steps", "Steps"],
  ["battery", "Battery"],
  ["flame", "Flame"],
  ["pin", "Location"],
  ["sun", "Sun"],
  ["bolt", "Bolt"],
];

export function drawCanvasIcon(context, element) {
  const { x, y, size, icon, color } = element;
  const half = size / 2;
  const quarter = size / 4;
  const fifth = size / 5;
  const eighth = size / 8;
  context.save();
  context.fillStyle = color;
  context.strokeStyle = color;
  context.lineWidth = 2;
  context.beginPath();
  if (icon === "heart") {
    context.arc(x - fifth, y - eighth, quarter, 0, Math.PI * 2);
    context.arc(x + fifth, y - eighth, quarter, 0, Math.PI * 2);
    context.fill();
    context.beginPath(); context.moveTo(x - half, y - eighth); context.lineTo(x + half, y - eighth); context.lineTo(x, y + half); context.closePath(); context.fill();
  } else if (icon === "steps") {
    context.ellipse(x - quarter, y - quarter, quarter / 2, half / 2, -0.25, 0, Math.PI * 2);
    context.ellipse(x + quarter, y + eighth, quarter / 2, half / 2, -0.25, 0, Math.PI * 2); context.fill();
  } else if (icon === "battery") {
    context.strokeRect(x - half, y - quarter, size - 3, size / 2);
    context.fillRect(x + half - 2, y - eighth, 3, size / 4);
    context.fillRect(x - half + 4, y - quarter + 4, Math.max(1, size - 11), Math.max(1, (size - 8) / 2));
  } else if (icon === "flame") {
    context.moveTo(x, y - half); context.lineTo(x + half, y + eighth); context.lineTo(x + quarter, y + half); context.lineTo(x - quarter, y + half); context.lineTo(x - half, y); context.closePath(); context.fill();
  } else if (icon === "pin") {
    context.arc(x, y - quarter, quarter, 0, Math.PI * 2); context.fill();
    context.beginPath(); context.moveTo(x - quarter, y - eighth); context.lineTo(x + quarter, y - eighth); context.lineTo(x, y + half); context.closePath(); context.fill();
  } else if (icon === "sun") {
    context.arc(x, y, quarter, 0, Math.PI * 2); context.fill();
    context.beginPath();
    [[x, y-half, x, y-quarter-2], [x, y+quarter+2, x, y+half], [x-half, y, x-quarter-2, y], [x+quarter+2, y, x+half, y]].forEach(([x1,y1,x2,y2]) => { context.moveTo(x1,y1); context.lineTo(x2,y2); });
    context.stroke();
  } else {
    context.moveTo(x + eighth, y - half); context.lineTo(x - half, y + eighth); context.lineTo(x - eighth, y); context.lineTo(x - quarter, y); context.lineTo(x - eighth, y + half); context.lineTo(x + half, y - eighth); context.closePath(); context.fill();
  }
  context.restore();
}
