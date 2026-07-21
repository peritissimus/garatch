<script>
  import Icon from "./Icon.svelte";
  import { TYPE_GLYPHS, TYPE_NAMES } from "../lib/catalog.js";
  let { elements, selectedId, onselect, onreorder } = $props();

  // The list is shown top-of-stack first, so it renders the elements reversed.
  let visual = $derived([...elements].reverse());

  let listEl;
  let dragId = $state(null);
  let dragging = $state(false);
  let overId = $state(null);
  let overAfter = $state(false);
  let startY = 0;
  let capturedEl = null;

  const DRAG_THRESHOLD = 4;

  function glyphFor(element) {
    if (element.type === "distance") return element.unit === "miles" ? "MI" : "KM";
    return TYPE_GLYPHS[element.type];
  }

  function onPointerDown(event, id) {
    if (event.button !== 0) return;
    dragId = id;
    startY = event.clientY;
    dragging = false;
    capturedEl = event.currentTarget;
    capturedEl.setPointerCapture(event.pointerId);
  }

  function onPointerMove(event) {
    if (dragId === null) return;
    if (!dragging) {
      if (Math.abs(event.clientY - startY) < DRAG_THRESHOLD) return;
      dragging = true;
      document.body.style.cursor = "grabbing";
      document.body.style.userSelect = "none";
    }
    event.preventDefault();
    const rows = [...listEl.querySelectorAll(".layer-row")];
    let matched = false;
    for (const row of rows) {
      const rect = row.getBoundingClientRect();
      if (event.clientY >= rect.top && event.clientY <= rect.bottom) {
        overId = row.dataset.id;
        overAfter = event.clientY - rect.top > rect.height / 2;
        matched = true;
        break;
      }
    }
    if (!matched && rows.length) {
      const first = rows[0].getBoundingClientRect();
      if (event.clientY < first.top) { overId = rows[0].dataset.id; overAfter = false; }
      else { overId = rows[rows.length - 1].dataset.id; overAfter = true; }
    }
  }

  function onPointerUp(event) {
    if (dragId === null) return;
    try { capturedEl.releasePointerCapture(event.pointerId); } catch { /* already released */ }
    const pressedId = dragId;
    const didDrag = dragging;
    if (didDrag) {
      commitReorder();
      document.body.style.cursor = "";
      document.body.style.userSelect = "";
    }
    dragId = null;
    dragging = false;
    overId = null;
    capturedEl = null;
    // A press without movement is a plain click → select the layer.
    if (!didDrag) onselect(pressedId);
  }

  function commitReorder() {
    if (!overId || overId === dragId) return;
    const order = visual.map((element) => element.id);
    order.splice(order.indexOf(dragId), 1);
    let to = order.indexOf(overId);
    if (to === -1) return;
    if (overAfter) to += 1;
    order.splice(to, 0, dragId);
    onreorder?.(order);
  }
</script>

<section class="rail-section layers-section">
  <header class="section-header compact">
    <div class="heading-with-icon"><Icon name="layers" size={15} /><h2>Layers</h2></div>
    <span class="count-badge">{elements.length}</span>
  </header>

  <div class="layer-list" bind:this={listEl}>
    {#each visual as element (element.id)}
      <button
        class="layer-row"
        class:selected={element.id === selectedId}
        class:dragging={element.id === dragId && dragging}
        class:drop-before={dragging && overId === element.id && !overAfter && dragId !== element.id}
        class:drop-after={dragging && overId === element.id && overAfter && dragId !== element.id}
        type="button"
        data-id={element.id}
        aria-pressed={element.id === selectedId}
        onpointerdown={(event) => onPointerDown(event, element.id)}
        onpointermove={onPointerMove}
        onpointerup={onPointerUp}
        onpointercancel={onPointerUp}
        onkeydown={(event) => { if (event.key === "Enter" || event.key === " ") { event.preventDefault(); onselect(element.id); } }}
      >
        <span class="layer-grip" aria-hidden="true"><Icon name="grip" size={13} /></span>
        <span class="layer-glyph">{glyphFor(element)}</span>
        <span class="layer-name">{element.type === "label" && element.text ? element.text : TYPE_NAMES[element.type]}</span>
        <span class="layer-position">{element.x}, {element.y}</span>
      </button>
    {/each}
  </div>
</section>
