<script>
  import WatchIconPreview from "./WatchIconPreview.svelte";
  import { ICON_OPTIONS, ICON_STYLE_OPTIONS } from "../lib/iconDrawing.js";
  import { tactile } from "../lib/motion.js";

  let { icon, style = "filled", color, onicon, onstyle } = $props();
</script>

<div class="visual-picker">
  <div class="visual-picker-heading">
    <span>Symbol</span><small>Choose by sight</small>
  </div>
  <div class="icon-choice-grid" role="group" aria-label="Choose icon symbol">
    {#each ICON_OPTIONS as [value, label]}
      <button class:selected={icon === value} type="button" aria-pressed={icon === value} onclick={() => onicon(value)} use:tactile>
        <span class="icon-choice-preview"><WatchIconPreview icon={value} {style} {color} size={40} /></span>
        <span>{label}</span>
      </button>
    {/each}
  </div>

  <div class="visual-picker-heading appearance-heading">
    <span>Appearance</span><small>Previewed exactly</small>
  </div>
  <div class="appearance-choice-grid" role="group" aria-label="Choose icon appearance">
    {#each ICON_STYLE_OPTIONS as [value, label]}
      <button class:selected={style === value} type="button" aria-pressed={style === value} onclick={() => onstyle(value)} use:tactile>
        <span class="appearance-preview"><WatchIconPreview {icon} style={value} {color} size={42} /></span>
        <span><strong>{label}</strong><small>{value === "filled" ? "Solid and bold" : "Light and open"}</small></span>
      </button>
    {/each}
  </div>
</div>
