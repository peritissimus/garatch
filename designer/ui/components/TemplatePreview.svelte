<script>
  let { template } = $props();
  const samples = { time: "10:28", date: "22/07", steps: "8421", "heart-rate": "72", battery: "83%", calories: "356", distance: "4.2" };
</script>

<svg viewBox="0 0 320 360" role="img" aria-label={`${template.name} preview`}>
  <rect width="320" height="360" fill={template.backgroundColor ?? "#000000"} />
  {#each template.elements as element}
    {#if element.type === "rectangle"}
      <rect x={element.x} y={element.y} width={element.width} height={element.height} rx={element.cornerRadius} fill={element.fillColor} />
    {:else if element.type === "ellipse"}
      <ellipse cx={element.x} cy={element.y} rx={element.radiusX} ry={element.radiusY} fill={element.fillColor} />
    {:else if element.type === "line"}
      <line x1={element.x} y1={element.y} x2={element.endX} y2={element.endY} stroke={element.color} stroke-width={element.thickness} />
    {:else if element.type === "icon"}
      <circle cx={element.x} cy={element.y} r={element.size / 3} fill={element.color} opacity=".92" />
    {:else}
      {@const value = element.type === "label" ? element.text : samples[element.type]}
      {@const anchor = element.align === "left" ? "start" : element.align === "right" ? "end" : "middle"}
      <text x={element.x} y={element.y} fill={element.color} text-anchor={anchor} dominant-baseline="middle" font-size={element.type === "time" ? 62 : element.type === "label" ? 14 : 24} font-family="Arial Narrow, sans-serif" font-weight={element.type === "time" ? 650 : 500}>{value}</text>
    {/if}
  {/each}
</svg>
