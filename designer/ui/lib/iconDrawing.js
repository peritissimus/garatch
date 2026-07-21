import { PHOSPHOR_ICON_PATHS } from "./phosphorIconPaths.generated.js";

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
  const style = element.style === "outline" ? "outline" : "filled";
  const pathData = PHOSPHOR_ICON_PATHS[icon]?.[style];
  if (!pathData) return;
  context.save();
  context.translate(x - size / 2, y - size / 2);
  context.scale(size / 256, size / 256);
  context.fillStyle = color;
  context.fill(new Path2D(pathData));
  context.restore();
}
