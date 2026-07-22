<script>
  import { onMount } from "svelte";
  import Icon from "./Icon.svelte";
  import { DYNAMIC_TYPES, TYPE_NAMES } from "../lib/catalog.js";
  import { drawBitmapText, fontForElement, loadWatchFonts } from "../lib/bmfont.js";
  import { WATCH_HEIGHT, WATCH_WIDTH, clampPosition, defaultProgressMax, isShapeElement } from "../lib/project.js";
  import { ensureProjectFonts, positionedWatchText } from "../lib/textLayout.js";
  import { tactile } from "../lib/motion.js";
  import { drawCanvasIcon } from "../lib/iconDrawing.js";
  import { smoothHistorySamples } from "../lib/history.js";

  let { project, selectedId, showGrid, aod, onselect, onposition, ongrid, onaod } = $props();
  let canvas;
  let context;
  let fonts = $state(null);
  let drag = $state(null);
  let now = $state(new Date());
  const metricIcons = { steps: "steps", "heart-rate": "heart", stress: "stress", battery: "battery", calories: "flame", distance: "pin" };
  const previewNumbers = { steps: 8421, "heart-rate": 72, stress: 38, battery: 83, calories: 356, distance: 4.2 };
  const previewHistory = {
    "heart-rate": [62, 65, 64, 68, 72, 69, 74, 78, 75, 81, 77, 83, 79, 76, 72, 74],
    stress: [18, 22, 20, 31, 28, 35, 44, 39, 52, 48, 43, 37, 41, 34, 38, 32],
  };

  function previewProgress(element) {
    const maximum = Math.max(1, Number(element.progressMax) || defaultProgressMax(element.type));
    return Math.max(0, Math.min(1, (previewNumbers[element.type] ?? 0) / maximum));
  }

  function previewText(element) {
    if (element.type === "label") return element.text;
    if (element.type === "date") {
      const day = String(now.getDate()).padStart(2, "0");
      const month = String(now.getMonth() + 1).padStart(2, "0");
      const weekday = now.toLocaleDateString("en", { weekday: "short" }).toUpperCase();
      const monthName = now.toLocaleDateString("en", { month: "short" }).toUpperCase();
      const representation = element.representation ?? "value";
      if (representation === "weekday") return weekday;
      if (representation === "month-day") return `${monthName} ${day}`;
      if (representation === "full-date") return `${weekday}, ${monthName} ${day}`;
      if (representation === "date-year") return `${day} ${monthName} ${now.getFullYear()}`;
      return `${day}/${month}`;
    }
    if (element.type === "steps") return "8421";
    if (element.type === "heart-rate") return "72";
    if (element.type === "stress") return "38";
    if (element.type === "battery") return "83%";
    if (element.type === "calories") return "356";
    if (element.type === "distance") return element.unit === "miles" ? "2.6" : "4.2";
    if (element.type === "time") {
      const hour24 = now.getHours();
      const hour = element.format === "hour12" ? hour24 % 12 || 12 : hour24;
      const seconds = element.showSeconds && !aod ? `:${String(now.getSeconds()).padStart(2, "0")}` : "";
      return `${String(hour).padStart(2, "0")}:${String(now.getMinutes()).padStart(2, "0")}${seconds}`;
    }
    return "";
  }

  function configureCanvas() {
    if (!canvas) return;
    if (canvas.width !== WATCH_WIDTH || canvas.height !== WATCH_HEIGHT) {
      canvas.width = WATCH_WIDTH;
      canvas.height = WATCH_HEIGHT;
    }
    context = canvas.getContext("2d");
    context.setTransform(1, 0, 0, 1, 0, 0);
  }

  function drawGrid() {
    context.save();
    context.strokeStyle = "rgba(255,255,255,.045)";
    context.lineWidth = 1;
    context.beginPath();
    for (let x = 20.5; x < WATCH_WIDTH; x += 20) { context.moveTo(x, 0); context.lineTo(x, WATCH_HEIGHT); }
    for (let y = 20.5; y < WATCH_HEIGHT; y += 20) { context.moveTo(0, y); context.lineTo(WATCH_WIDTH, y); }
    context.stroke();
    context.strokeStyle = "rgba(114,214,178,.15)";
    context.beginPath();
    context.moveTo(WATCH_WIDTH / 2 + 0.5, 0); context.lineTo(WATCH_WIDTH / 2 + 0.5, WATCH_HEIGHT);
    context.moveTo(0, WATCH_HEIGHT / 2 + 0.5); context.lineTo(WATCH_WIDTH, WATCH_HEIGHT / 2 + 0.5);
    context.stroke();
    context.restore();
  }

  function textLayout(element, text = previewText(element), x = element.x, y = element.y, align = element.align) {
    return positionedWatchText(project, { ...element, x, y, align }, text);
  }

  function drawText(element, colorOverride = null, text = previewText(element), x = element.x, y = element.y, align = element.align) {
    if (!fonts) return;
    const font = fontForElement(fonts, element);
    const layout = textLayout(element, text, x, y, align);
    layout.lines.forEach((line) => {
      drawBitmapText(
        context,
        font,
        line.text,
        x,
        line.centerY,
        align,
        colorOverride ?? element.color,
        layout.letterSpacing,
      );
    });
  }

  function alignedLeft(element, width) {
    if (element.align === "left") return element.x;
    if (element.align === "right") return element.x - width;
    return element.x - width / 2;
  }

  function drawAnalogClock(element, includeDigital = false) {
    const radius = 52;
    const hourAngle = (((now.getHours() % 12) * 60 + now.getMinutes()) * 0.5 - 90) * Math.PI / 180;
    const minuteAngle = (now.getMinutes() * 6 - 90) * Math.PI / 180;
    context.save();
    context.strokeStyle = element.color;
    context.fillStyle = element.color;
    context.lineCap = "round";
    context.lineWidth = 2;
    context.beginPath(); context.arc(element.x, element.y, radius, 0, Math.PI * 2); context.stroke();
    for (let marker = 0; marker < 12; marker += 1) {
      const angle = (marker * 30 - 90) * Math.PI / 180;
      const innerRadius = marker % 3 === 0 ? 39 : 43;
      context.lineWidth = marker % 3 === 0 ? 2 : 1;
      context.beginPath();
      context.moveTo(element.x + Math.cos(angle) * innerRadius, element.y + Math.sin(angle) * innerRadius);
      context.lineTo(element.x + Math.cos(angle) * 47, element.y + Math.sin(angle) * 47);
      context.stroke();
    }
    context.lineWidth = 4;
    context.beginPath(); context.moveTo(element.x, element.y); context.lineTo(element.x + Math.cos(hourAngle) * 27, element.y + Math.sin(hourAngle) * 27); context.stroke();
    context.lineWidth = 2;
    context.beginPath(); context.moveTo(element.x, element.y); context.lineTo(element.x + Math.cos(minuteAngle) * 40, element.y + Math.sin(minuteAngle) * 40); context.stroke();
    if (element.showSeconds && !aod) {
      const secondAngle = (now.getSeconds() * 6 - 90) * Math.PI / 180;
      context.lineWidth = 1;
      context.beginPath(); context.moveTo(element.x, element.y); context.lineTo(element.x + Math.cos(secondAngle) * 44, element.y + Math.sin(secondAngle) * 44); context.stroke();
    }
    context.beginPath(); context.arc(element.x, element.y, 3, 0, Math.PI * 2); context.fill();
    context.restore();
    if (includeDigital) drawText({ ...element, type: "date" }, null, previewText(element), element.x, element.y + 66, "center");
  }

  function drawCalendar(element) {
    const month = now.toLocaleDateString("en", { month: "short" }).toUpperCase();
    const day = String(now.getDate()).padStart(2, "0");
    context.save();
    context.strokeStyle = element.color;
    context.lineWidth = 1;
    context.beginPath(); context.roundRect(element.x - 31, element.y - 32, 62, 64, 8); context.stroke();
    context.beginPath(); context.moveTo(element.x - 31, element.y - 10); context.lineTo(element.x + 31, element.y - 10); context.stroke();
    context.restore();
    drawText(element, null, month, element.x, element.y - 21, "center");
    drawText(element, null, day, element.x, element.y + 11, "center");
  }

  function drawGoalRing(element) {
    const left = alignedLeft(element, 88);
    const centerX = left + 20;
    context.save();
    context.lineWidth = 4;
    context.lineCap = "round";
    context.strokeStyle = "#242725";
    context.beginPath(); context.arc(centerX, element.y, 18, 0, Math.PI * 2); context.stroke();
    context.strokeStyle = element.color;
    context.beginPath(); context.arc(centerX, element.y, 18, -Math.PI / 2, -Math.PI / 2 + previewProgress(element) * Math.PI * 2); context.stroke();
    context.restore();
    drawText(element, null, previewText(element), left + 44, element.y, "left");
  }

  function drawZoneGauge(element) {
    const left = alignedLeft(element, 104);
    const colors = ["#5AC8FA", "#72D6B2", "#E5AD59", "#EF7E74", "#B8566F"];
    context.save();
    colors.forEach((color, index) => {
      context.fillStyle = color;
      context.beginPath(); context.roundRect(left + index * 21, element.y - 3, 19, 6, 3); context.fill();
    });
    const maximum = element.type === "heart-rate" ? Math.max(1, Number(element.progressMax) || 200) : 100;
    const rawRatio = (previewNumbers[element.type] ?? 0) / maximum;
    const ratio = element.type === "heart-rate"
      ? Math.max(0, Math.min(1, (rawRatio - 0.5) / 0.5))
      : Math.max(0, Math.min(1, rawRatio));
    context.fillStyle = element.color;
    context.fillRect(left + ratio * 103 - 1, element.y - 6, 3, 12);
    context.restore();
  }

  function drawHistoryGraph(element) {
    const left = alignedLeft(element, 104);
    const top = element.y + 2;
    const height = 30;
    const samples = smoothHistorySamples(previewHistory[element.type] ?? []);
    drawText(element, null, previewText(element), element.x, element.y - 18);
    if (samples.length < 2) return;
    const minimum = Math.min(...samples);
    const maximum = Math.max(...samples);
    const range = Math.max(1, maximum - minimum);
    context.save();
    context.strokeStyle = "#242725";
    context.lineWidth = 1;
    context.beginPath(); context.moveTo(left, top + height); context.lineTo(left + 104, top + height); context.stroke();
    context.strokeStyle = element.color;
    context.lineWidth = 2;
    context.lineCap = "round";
    context.lineJoin = "round";
    context.beginPath();
    samples.forEach((sample, index) => {
      const x = left + index * 104 / (samples.length - 1);
      const y = top + height - (sample - minimum) * height / range;
      if (index === 0) context.moveTo(x, y); else context.lineTo(x, y);
    });
    context.stroke();
    context.restore();
  }

  function drawDynamicElement(element) {
    const representation = element.representation ?? "value";
    if (element.type === "time" && representation === "split") {
      const [hours, ...minutes] = previewText(element).split(":");
      drawText(element, null, hours, element.x - 48, element.y, "center");
      drawText(element, null, minutes.join(":"), element.x + 48, element.y, "center");
      context.save(); context.strokeStyle = element.color; context.lineWidth = 2;
      context.beginPath(); context.moveTo(element.x, element.y - 24); context.lineTo(element.x, element.y + 24); context.stroke(); context.restore();
      return;
    }
    if (element.type === "time" && (representation === "analog" || representation === "analog-digital")) {
      drawAnalogClock(element, representation === "analog-digital");
      return;
    }
    if (element.type === "time" && representation === "seconds-ring") {
      context.save(); context.strokeStyle = element.color; context.lineWidth = 3;
      context.beginPath(); context.arc(element.x, element.y, 68, 0, Math.PI * 2); context.stroke();
      context.beginPath(); context.arc(element.x, element.y, 68, -Math.PI / 2, -Math.PI / 2 + (now.getSeconds() / 60) * Math.PI * 2); context.stroke(); context.restore();
      drawText(element, null, previewText(element), element.x, element.y, "center");
      return;
    }
    if (element.type === "date" && representation === "calendar") {
      drawCalendar(element);
      return;
    }
    if (representation === "goal-ring") {
      drawGoalRing(element);
      return;
    }
    if (representation === "zone-gauge") {
      drawZoneGauge(element);
      return;
    }
    if (representation === "history-graph") {
      drawHistoryGraph(element);
      return;
    }
    if (representation === "stacked") {
      const parts = previewText(element).split(/[/:]/);
      const gap = element.type === "time" ? project.fontHeights.time / 2 : Math.max(10, project.fontHeights.label / 2);
      drawText(element, null, parts[0] ?? "--", element.x, element.y - gap);
      drawText(element, null, parts.slice(1).join(":") || "--", element.x, element.y + gap);
      return;
    }
    if (representation === "icon" && metricIcons[element.type]) {
      const iconSize = 18;
      const left = alignedLeft(element, iconSize);
      drawCanvasIcon(context, { x: left + iconSize / 2, y: element.y, size: iconSize, icon: metricIcons[element.type], style: "filled", color: element.color });
      return;
    }
    if (representation === "progress-bar") {
      const width = 88;
      const height = 6;
      const left = alignedLeft(element, width);
      drawText(element, null, previewText(element), element.x, element.y - 11);
      context.save();
      context.fillStyle = "#242725";
      context.beginPath();
      context.roundRect(left, element.y + 15, width, height, height / 2);
      context.fill();
      context.fillStyle = element.color;
      context.beginPath();
      context.roundRect(left, element.y + 15, Math.max(height, width * previewProgress(element)), height, height / 2);
      context.fill();
      context.restore();
      return;
    }
    drawText(element);
  }

  function drawElement(element) {
    if (DYNAMIC_TYPES.has(element.type)) return drawDynamicElement(element);
    if (!isShapeElement(element)) return drawText(element);
    context.save();
    if (element.type === "rectangle") {
      context.fillStyle = element.fillColor;
      context.beginPath();
      context.roundRect(element.x, element.y, element.width, element.height, Math.min(element.cornerRadius, element.width / 2, element.height / 2));
      context.fill();
    } else if (element.type === "ellipse") {
      context.fillStyle = element.fillColor;
      context.beginPath();
      context.ellipse(element.x, element.y, element.radiusX, element.radiusY, 0, 0, Math.PI * 2);
      context.fill();
    } else if (element.type === "line") {
      context.strokeStyle = element.color;
      context.lineWidth = element.thickness;
      context.lineCap = "butt";
      context.beginPath();
      context.moveTo(element.x, element.y);
      context.lineTo(element.endX, element.endY);
      context.stroke();
    } else {
      drawCanvasIcon(context, element);
    }
    context.restore();
  }

  function unionBounds(bounds) {
    const left = Math.min(...bounds.map((item) => item.x));
    const top = Math.min(...bounds.map((item) => item.y));
    const right = Math.max(...bounds.map((item) => item.x + item.width));
    const bottom = Math.max(...bounds.map((item) => item.y + item.height));
    return { x: left, y: top, width: right - left, height: bottom - top };
  }

  function dynamicBounds(element) {
    const representation = element.representation ?? "value";
    if (element.type === "time" && representation === "split") {
      const [hours, ...minutes] = previewText(element).split(":");
      return unionBounds([
        textLayout(element, hours, element.x - 48, element.y, "center"),
        textLayout(element, minutes.join(":"), element.x + 48, element.y, "center"),
        { x: element.x - 1, y: element.y - 24, width: 2, height: 48 },
      ]);
    }
    if (element.type === "time" && representation === "analog") return { x: element.x - 53, y: element.y - 53, width: 106, height: 106 };
    if (element.type === "time" && representation === "analog-digital") {
      return unionBounds([{ x: element.x - 53, y: element.y - 53, width: 106, height: 106 }, textLayout({ ...element, type: "date" }, previewText(element), element.x, element.y + 66, "center")]);
    }
    if (element.type === "time" && representation === "seconds-ring") return { x: element.x - 70, y: element.y - 70, width: 140, height: 140 };
    if (element.type === "date" && representation === "calendar") return { x: element.x - 32, y: element.y - 33, width: 64, height: 66 };
    if (representation === "goal-ring") {
      const left = alignedLeft(element, 88);
      return unionBounds([{ x: left, y: element.y - 20, width: 40, height: 40 }, textLayout(element, previewText(element), left + 44, element.y, "left")]);
    }
    if (representation === "zone-gauge") {
      const left = alignedLeft(element, 104);
      return { x: left, y: element.y - 6, width: 104, height: 12 };
    }
    if (representation === "history-graph") {
      const left = alignedLeft(element, 104);
      return unionBounds([textLayout(element, previewText(element), element.x, element.y - 18), { x: left, y: element.y + 2, width: 104, height: 31 }]);
    }
    if (representation === "stacked") {
      const parts = previewText(element).split(/[/:]/);
      const gap = element.type === "time" ? project.fontHeights.time / 2 : Math.max(10, project.fontHeights.label / 2);
      return unionBounds([
        textLayout(element, parts[0] ?? "--", element.x, element.y - gap),
        textLayout(element, parts.slice(1).join(":") || "--", element.x, element.y + gap),
      ]);
    }
    if (representation === "icon" && metricIcons[element.type]) {
      const left = alignedLeft(element, 18);
      return { x: left, y: element.y - 9, width: 18, height: 18 };
    }
    if (representation === "progress-bar") {
      const left = alignedLeft(element, 88);
      return unionBounds([
        textLayout(element, previewText(element), element.x, element.y - 11),
        { x: left, y: element.y + 15, width: 88, height: 6 },
      ]);
    }
    return textLayout(element);
  }

  function elementBounds(element) {
    if (DYNAMIC_TYPES.has(element.type) && fonts) return dynamicBounds(element);
    if (element.type === "rectangle") return { x: element.x, y: element.y, width: element.width, height: element.height };
    if (element.type === "ellipse") return { x: element.x - element.radiusX, y: element.y - element.radiusY, width: element.radiusX * 2, height: element.radiusY * 2 };
    if (element.type === "line") {
      const half = element.thickness / 2;
      const left = Math.min(element.x, element.endX) - half;
      const top = Math.min(element.y, element.endY) - half;
      return {
        x: left,
        y: top,
        width: Math.max(element.thickness, Math.abs(element.endX - element.x) + element.thickness),
        height: Math.max(element.thickness, Math.abs(element.endY - element.y) + element.thickness),
      };
    }
    if (element.type === "icon") return { x: element.x - element.size / 2, y: element.y - element.size / 2, width: element.size, height: element.size };
    if (!fonts) return { x: element.x - 8, y: element.y - 8, width: 16, height: 16 };
    const layout = textLayout(element);
    return { x: layout.x, y: layout.y, width: layout.width, height: layout.height };
  }

  function drawSelection(element) {
    const bounds = elementBounds(element);
    const left = Math.round(bounds.x) + 0.5;
    const top = Math.round(bounds.y) + 0.5;
    const right = Math.round(bounds.x + bounds.width) + 0.5;
    const bottom = Math.round(bounds.y + bounds.height) + 0.5;
    context.save();
    context.strokeStyle = "#72D6B2";
    context.lineWidth = 1;
    context.setLineDash([4, 3]);
    context.strokeRect(left, top, Math.max(1, right - left), Math.max(1, bottom - top));
    context.setLineDash([]);
    context.fillStyle = "#72D6B2";
    for (const [x, y] of [[left, top], [right, top], [left, bottom], [right, bottom]]) {
      context.fillRect(Math.round(x) - 2, Math.round(y) - 2, 5, 5);
    }
    context.restore();
  }

  function renderCanvas() {
    if (!canvas) return;
    configureCanvas();
    context.clearRect(0, 0, WATCH_WIDTH, WATCH_HEIGHT);
    context.fillStyle = project.backgroundColor;
    context.fillRect(0, 0, WATCH_WIDTH, WATCH_HEIGHT);
    if (showGrid && !aod) drawGrid();
    if (aod) {
      const time = project.elements.find((element) => element.type === "time");
      if (time) drawText(time, "#555555");
      return;
    }
    project.elements.forEach(drawElement);
    const selected = project.elements.find((element) => element.id === selectedId);
    if (selected) drawSelection(selected);
  }

  function hitTest(x, y) {
    for (let index = project.elements.length - 1; index >= 0; index -= 1) {
      const element = project.elements[index];
      const bounds = elementBounds(element);
      const padding = isShapeElement(element) ? 4 : 7;
      if (x >= bounds.x - padding && x <= bounds.x + bounds.width + padding && y >= bounds.y - padding && y <= bounds.y + bounds.height + padding) return element;
    }
    return null;
  }

  function canvasPoint(event) {
    const bounds = canvas.getBoundingClientRect();
    return { x: ((event.clientX - bounds.left) / bounds.width) * WATCH_WIDTH, y: ((event.clientY - bounds.top) / bounds.height) * WATCH_HEIGHT };
  }

  function pointerDown(event) {
    if (aod) return;
    canvas.focus();
    const point = canvasPoint(event);
    const hit = hitTest(point.x, point.y);
    onselect(hit?.id ?? null);
    if (!hit) return;
    drag = { id: hit.id, offsetX: point.x - hit.x, offsetY: point.y - hit.y };
    canvas.setPointerCapture(event.pointerId);
  }

  function pointerMove(event) {
    if (!drag) return;
    const element = project.elements.find((item) => item.id === drag.id);
    if (!element) return;
    const point = canvasPoint(event);
    const next = clampPosition(element, point.x - drag.offsetX, point.y - drag.offsetY);
    onposition(element.id, next.x, next.y, false);
  }

  function finishDrag() {
    if (!drag) return;
    const id = drag.id;
    drag = null;
    const element = project.elements.find((item) => item.id === id);
    if (element) onposition(id, element.x, element.y, true);
  }

  $effect(() => {
    JSON.stringify(project);
    selectedId;
    showGrid;
    aod;
    now;
    renderCanvas();
  });

  $effect(() => {
    const family = project.fontFamily;
    const familySecondary = project.fontFamilySecondary ?? project.fontFamily;
    const heights = { ...project.fontHeights };
    let cancelled = false;
    Promise.all([
      loadWatchFonts(family, familySecondary, heights),
      ensureProjectFonts({ fontFamily: family, fontFamilySecondary: familySecondary, fontHeights: heights }),
    ]).then(([loaded]) => {
      if (cancelled) return;
      fonts = loaded;
      renderCanvas();
    });
    return () => { cancelled = true; };
  });

  onMount(() => {
    configureCanvas();
    renderCanvas();
    const timer = window.setInterval(() => { now = new Date(); }, 1000);
    window.addEventListener("resize", renderCanvas);
    return () => { window.clearInterval(timer); window.removeEventListener("resize", renderCanvas); };
  });
</script>

<section class="stage" aria-label="Watch face preview">
  <header class="stage-toolbar">
    <div class="stage-title">
      <span class="live-indicator"></span>
      <strong>Live preview</strong>
      <span class="stage-meta">Venu SQ 2 · 320 × 360</span>
    </div>
    <div class="preview-controls" role="group" aria-label="Preview controls">
      <button class="icon-button" class:active={showGrid} type="button" aria-label="Toggle grid" aria-pressed={showGrid} onclick={ongrid} use:tactile>
        <Icon name="grid" size={17} />
      </button>
      <button class="toggle-button" class:active={aod} type="button" aria-pressed={aod} onclick={onaod} use:tactile>
        <Icon name="moon" size={16} /><span>Always-on</span>
      </button>
    </div>
  </header>

  <div class="canvas-area">
    <div class="ambient-orbit one"></div><div class="ambient-orbit two"></div>
    <div class="watch-shell">
      <span class="watch-crown"></span>
      <div class="watch-screen">
        <canvas
          bind:this={canvas}
          aria-label="Interactive 320 by 360 watch-face canvas"
          tabindex="0"
          onpointerdown={pointerDown}
          onpointermove={pointerMove}
          onpointerup={finishDrag}
          onpointercancel={finishDrag}
          class:dragging={drag}
        ></canvas>
      </div>
    </div>
  </div>

  <footer class="stage-footer">
    {#if selectedId}
      {@const selected = project.elements.find((element) => element.id === selectedId)}
      <span class="selection-readout">{selected ? `${TYPE_NAMES[selected.type]} · x ${selected.x} · y ${selected.y}` : "No selection"}</span>
    {:else}
      <span class="selection-readout muted">No selection</span>
    {/if}
    <span class="keyboard-hint"><kbd>↑</kbd><kbd>↓</kbd><kbd>←</kbd><kbd>→</kbd> nudge · <kbd>⇧</kbd> 10 px</span>
  </footer>
</section>
