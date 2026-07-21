<script>
  // dialkit-style scrubbable number: drag horizontally to change the value,
  // click to place a caret and type. Holding Shift scrubs finely.
  let { value, min = null, max = null, step = 1, oninput, onchange } = $props();

  let inputEl;
  let dragging = $state(false);
  let pointerId = null;
  let startX = 0;
  let startValue = 0;
  let lastEmitted = null;

  const DRAG_THRESHOLD = 3;

  function clamp(next) {
    let result = next;
    if (min !== null && min !== undefined) result = Math.max(min, result);
    if (max !== null && max !== undefined) result = Math.min(max, result);
    return result;
  }

  function onPointerDown(event) {
    if (event.button !== 0) return;
    pointerId = event.pointerId;
    startX = event.clientX;
    startValue = Number(inputEl.value) || 0;
    lastEmitted = startValue;
    inputEl.setPointerCapture(pointerId);
  }

  function onPointerMove(event) {
    if (pointerId === null) return;
    const dx = event.clientX - startX;
    if (!dragging) {
      if (Math.abs(dx) < DRAG_THRESHOLD) return;
      dragging = true;
      inputEl.blur();
      document.body.style.cursor = "ew-resize";
      document.body.style.userSelect = "none";
    }
    event.preventDefault();
    const pixelsPerStep = event.shiftKey ? 8 : 2;
    const next = clamp(startValue + Math.round(dx / pixelsPerStep) * step);
    if (next !== lastEmitted) {
      lastEmitted = next;
      oninput?.(next);
    }
  }

  function endDrag() {
    if (pointerId === null) return;
    try { inputEl.releasePointerCapture(pointerId); } catch { /* already released */ }
    const wasDragging = dragging;
    pointerId = null;
    dragging = false;
    if (wasDragging) {
      document.body.style.cursor = "";
      document.body.style.userSelect = "";
      onchange?.(clamp(Number(inputEl.value) || 0));
    }
  }
</script>

<input
  bind:this={inputEl}
  class="scrub-input"
  class:dragging
  type="number"
  {value}
  min={min ?? undefined}
  max={max ?? undefined}
  {step}
  onpointerdown={onPointerDown}
  onpointermove={onPointerMove}
  onpointerup={endDrag}
  onpointercancel={endDrag}
  oninput={(event) => oninput?.(Number(event.currentTarget.value))}
  onchange={(event) => onchange?.(Number(event.currentTarget.value))}
/>
