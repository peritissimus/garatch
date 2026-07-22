<script>
  import { PHOSPHOR_ICON_PATHS } from "../lib/phosphorIconPaths.generated.js";
  import { smoothHistorySamples } from "../lib/history.js";

  let { template } = $props();
  const samples = { time: "10:28", date: "22/07", steps: "8421", "heart-rate": "72", stress: "38", battery: "83%", calories: "356", distance: "4.2" };
  const metricIcons = { steps: "steps", "heart-rate": "heart", stress: "stress", battery: "battery", calories: "flame", distance: "pin" };
  const history = {
    "heart-rate": [62, 68, 65, 74, 70, 82, 77, 86, 72],
    stress: [18, 30, 24, 47, 38, 56, 42, 35, 38],
  };

  function textFor(element) {
    if (element.type === "label") return element.text;
    if (element.type === "date") {
      if (element.representation === "weekday") return "WED";
      if (element.representation === "month-day") return "JUL 22";
      if (element.representation === "full-date") return "WED, JUL 22";
      if (element.representation === "date-year") return "22 JUL 2026";
    }
    return samples[element.type] ?? "";
  }

  function anchorFor(element) {
    return element.align === "left" ? "start" : element.align === "right" ? "end" : "middle";
  }

  function fontSizeFor(element) {
    const heights = template.fontHeights ?? {};
    if (element.type === "time") return Math.round((heights.time ?? 88) * 0.72);
    if (element.type === "label") return Math.round((heights.label ?? 18) * 0.72);
    return Math.round((heights.value ?? 30) * 0.72);
  }

  function metricWidth(element, width) {
    if (element.align === "left") return element.x;
    if (element.align === "right") return element.x - width;
    return element.x - width / 2;
  }

  function progressFor(element) {
    const values = { steps: 8421, battery: 83, calories: 356, distance: 4.2 };
    const defaults = { steps: 10000, battery: 100, calories: 500, distance: 5 };
    return Math.min(1, (values[element.type] ?? 0) / (element.progressMax ?? defaults[element.type] ?? 100));
  }

  function pointsFor(element) {
    const values = smoothHistorySamples(history[element.type] ?? []);
    const minimum = Math.min(...values);
    const maximum = Math.max(...values);
    const range = Math.max(1, maximum - minimum);
    const left = metricWidth(element, 104);
    return values.map((value, index) => `${left + index * 104 / (values.length - 1)},${element.y + 31 - (value - minimum) * 30 / range}`).join(" ");
  }
</script>

<svg viewBox="0 0 320 360" role="img" aria-label={`${template.name} preview`}>
  <rect width="320" height="360" fill={template.backgroundColor ?? "#000000"} />
  {#each template.elements as element}
    {@const representation = element.representation ?? "value"}
    {#if element.type === "rectangle"}
      <rect x={element.x} y={element.y} width={element.width} height={element.height} rx={element.cornerRadius} fill={element.fillColor} />
    {:else if element.type === "ellipse"}
      <ellipse cx={element.x} cy={element.y} rx={element.radiusX} ry={element.radiusY} fill={element.fillColor} />
    {:else if element.type === "line"}
      <line x1={element.x} y1={element.y} x2={element.endX} y2={element.endY} stroke={element.color} stroke-width={element.thickness} />
    {:else if element.type === "icon"}
      {@const path = PHOSPHOR_ICON_PATHS[element.icon]?.[element.style ?? "filled"]}
      {#if path}<path d={path} fill={element.color} transform={`translate(${element.x - element.size / 2} ${element.y - element.size / 2}) scale(${element.size / 256})`} />{/if}
    {:else if element.type === "time" && ["analog", "analog-digital"].includes(representation)}
      <circle cx={element.x} cy={element.y} r="52" fill="none" stroke={element.color} stroke-opacity="0.35" stroke-width="1" />
      {#each Array(12) as _, index}
        <line x1={element.x} y1={element.y - 46} x2={element.x} y2={element.y - (index % 3 === 0 ? 39 : 42)} stroke={element.color} stroke-width={index % 3 === 0 ? 2 : 1} transform={`rotate(${index * 30} ${element.x} ${element.y})`} />
      {/each}
      <line x1={element.x} y1={element.y} x2={element.x - 18} y2={element.y - 18} stroke={element.color} stroke-width="4" stroke-linecap="round" />
      <line x1={element.x} y1={element.y} x2={element.x + 23} y2={element.y - 34} stroke={element.color} stroke-width="2" stroke-linecap="round" />
      {#if element.showSeconds}<line x1={element.x} y1={element.y + 8} x2={element.x + 34} y2={element.y + 25} stroke="#FF715B" stroke-width="1" stroke-linecap="round" />{/if}
      <circle cx={element.x} cy={element.y} r="4" fill={element.color} />
      {#if representation === "analog-digital"}<text x={element.x} y={element.y + 66} fill={element.color} text-anchor="middle" dominant-baseline="middle" font-size="17" font-family="system-ui, sans-serif" font-weight="650">10:28</text>{/if}
    {:else if element.type === "time" && representation === "seconds-ring"}
      <circle cx={element.x} cy={element.y} r="68" fill="none" stroke="#29201E" stroke-width="4" />
      <circle cx={element.x} cy={element.y} r="68" fill="none" stroke={element.color} stroke-width="4" stroke-linecap="round" stroke-dasharray="271 427" transform={`rotate(-90 ${element.x} ${element.y})`} />
      <text x={element.x} y={element.y} fill={element.color} text-anchor="middle" dominant-baseline="middle" font-size={fontSizeFor(element)} font-family="system-ui, sans-serif" font-weight="650">10:28</text>
    {:else if element.type === "date" && representation === "calendar"}
      <rect x={element.x - 32} y={element.y - 33} width="64" height="66" rx="8" fill="#17191B" stroke={element.color} stroke-width="1" />
      <text x={element.x} y={element.y - 15} fill={element.color} text-anchor="middle" font-size="12" font-family="system-ui, sans-serif" font-weight="700">JUL</text>
      <text x={element.x} y={element.y + 18} fill="#FFFFFF" text-anchor="middle" font-size="26" font-family="system-ui, sans-serif" font-weight="700">22</text>
    {:else if representation === "goal-ring"}
      {@const left = metricWidth(element, 88)}
      <circle cx={left + 20} cy={element.y} r="18" fill="none" stroke="#242725" stroke-width="4" />
      <circle cx={left + 20} cy={element.y} r="18" fill="none" stroke={element.color} stroke-width="4" stroke-linecap="round" stroke-dasharray={`${progressFor(element) * 113} 113`} transform={`rotate(-90 ${left + 20} ${element.y})`} />
      <text x={left + 44} y={element.y} fill={element.color} dominant-baseline="middle" font-size={fontSizeFor(element)} font-family="system-ui, sans-serif" font-weight="650">{textFor(element)}</text>
    {:else if representation === "zone-gauge"}
      {@const left = metricWidth(element, 104)}
      {#each ["#5AC8FA", "#72D6B2", "#E5AD59", "#EF7E74", "#B8566F"] as color, index}
        <rect x={left + index * 21} y={element.y - 3} width="19" height="6" rx="3" fill={color} />
      {/each}
      <rect x={left + 39} y={element.y - 6} width="3" height="12" fill={element.color} />
    {:else if representation === "history-graph"}
      {@const left = metricWidth(element, 104)}
      <text x={element.x} y={element.y - 18} fill={element.color} text-anchor={anchorFor(element)} dominant-baseline="middle" font-size={fontSizeFor(element)} font-family="system-ui, sans-serif" font-weight="650">{textFor(element)}</text>
      <line x1={left} y1={element.y + 32} x2={left + 104} y2={element.y + 32} stroke="#242725" />
      <polyline points={pointsFor(element)} fill="none" stroke={element.color} stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
    {:else if representation === "progress-bar"}
      {@const left = metricWidth(element, 88)}
      <text x={element.x} y={element.y - 11} fill={element.color} text-anchor={anchorFor(element)} dominant-baseline="middle" font-size={fontSizeFor(element)} font-family="system-ui, sans-serif" font-weight="650">{textFor(element)}</text>
      <rect x={left} y={element.y + 15} width="88" height="6" rx="3" fill="#242725" />
      <rect x={left} y={element.y + 15} width={Math.max(6, 88 * progressFor(element))} height="6" rx="3" fill={element.color} />
    {:else if representation === "icon"}
      {@const iconName = metricIcons[element.type]}
      {@const path = PHOSPHOR_ICON_PATHS[iconName]?.filled}
      {@const iconX = element.align === "right" ? element.x - 18 : element.align === "center" ? element.x - 9 : element.x}
      {#if path}<path d={path} fill={element.color} transform={`translate(${iconX} ${element.y - 9}) scale(${18 / 256})`} />{/if}
    {:else if representation === "stacked"}
      {@const parts = textFor(element).split(/[/:]/)}
      <text x={element.x} y={element.y - fontSizeFor(element) * 0.48} fill={element.color} text-anchor={anchorFor(element)} dominant-baseline="middle" font-size={fontSizeFor(element)} font-family="system-ui, sans-serif" font-weight="650">{parts[0]}</text>
      <text x={element.x} y={element.y + fontSizeFor(element) * 0.48} fill={element.color} text-anchor={anchorFor(element)} dominant-baseline="middle" font-size={fontSizeFor(element)} font-family="system-ui, sans-serif" font-weight="650">{parts.slice(1).join(":")}</text>
    {:else if element.type === "time" && representation === "split"}
      <text x={element.x - 48} y={element.y} fill={element.color} text-anchor="middle" dominant-baseline="middle" font-size={fontSizeFor(element)} font-family="system-ui, sans-serif" font-weight="650">10</text>
      <line x1={element.x} y1={element.y - 24} x2={element.x} y2={element.y + 24} stroke={element.color} stroke-width="2" />
      <text x={element.x + 48} y={element.y} fill={element.color} text-anchor="middle" dominant-baseline="middle" font-size={fontSizeFor(element)} font-family="system-ui, sans-serif" font-weight="650">28</text>
    {:else}
      <text x={element.x} y={element.y} fill={element.color} text-anchor={anchorFor(element)} dominant-baseline="middle" font-size={fontSizeFor(element)} font-family="system-ui, sans-serif" font-weight={element.type === "time" ? 650 : 500}>{textFor(element)}</text>
    {/if}
  {/each}
</svg>
