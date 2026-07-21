<script>
  import { onMount } from "svelte";
  import { drawCanvasIcon } from "../lib/iconDrawing.js";

  let { icon, style = "filled", color = "#72D6B2", size = 44 } = $props();
  let canvas;

  function render() {
    if (!canvas) return;
    const context = canvas.getContext("2d");
    context.clearRect(0, 0, 96, 96);
    drawCanvasIcon(context, { type: "icon", x: 48, y: 48, icon, style, color, size });
  }

  $effect(() => { icon; style; color; size; render(); });
  onMount(render);
</script>

<canvas bind:this={canvas} width="96" height="96" aria-hidden="true"></canvas>
