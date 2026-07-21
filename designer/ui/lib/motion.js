import { animate } from "motion";

const reduceMotion = () => window.matchMedia("(prefers-reduced-motion: reduce)").matches;

export function tactile(node, options = {}) {
  const value = (option, variable, fallback) => {
    if (options[option] !== undefined) return options[option];
    const parsed = Number.parseFloat(getComputedStyle(node).getPropertyValue(variable));
    return Number.isFinite(parsed) ? parsed : fallback;
  };

  const move = (keyframes) => {
    if (reduceMotion()) return;
    animate(node, keyframes, {
      type: "spring",
      stiffness: value("stiffness", "--spring-stiffness", 520),
      damping: value("damping", "--spring-damping", 36),
      mass: 0.7,
    });
  };
  const enter = () => move({ y: value("hoverY", "--hover-lift", -1) });
  const leave = () => move({ y: 0, scale: 1 });
  const down = () => move({ scale: value("pressScale", "--press-scale", 0.96) });
  const up = () => move({ scale: 1 });

  node.addEventListener("pointerenter", enter);
  node.addEventListener("pointerleave", leave);
  node.addEventListener("pointerdown", down);
  node.addEventListener("pointerup", up);
  node.addEventListener("pointercancel", up);

  return {
    destroy() {
      node.removeEventListener("pointerenter", enter);
      node.removeEventListener("pointerleave", leave);
      node.removeEventListener("pointerdown", down);
      node.removeEventListener("pointerup", up);
      node.removeEventListener("pointercancel", up);
    },
  };
}
