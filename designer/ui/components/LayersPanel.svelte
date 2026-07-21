<script>
  import Icon from "./Icon.svelte";
  import { TYPE_GLYPHS, TYPE_NAMES } from "../lib/catalog.js";
  import { tactile } from "../lib/motion.js";
  let { elements, selectedId, onselect } = $props();

  function glyphFor(element) {
    if (element.type === "distance") return element.unit === "miles" ? "MI" : "KM";
    return TYPE_GLYPHS[element.type];
  }
</script>

<section class="rail-section layers-section">
  <header class="section-header compact">
    <div class="heading-with-icon"><Icon name="layers" size={15} /><h2>Layers</h2></div>
    <span class="count-badge">{elements.length}</span>
  </header>

  <div class="layer-list">
    {#each [...elements].reverse() as element (element.id)}
      <button
        class="layer-row"
        class:selected={element.id === selectedId}
        type="button"
        aria-pressed={element.id === selectedId}
        onclick={() => onselect(element.id)}
        use:tactile={{ hoverY: 0, pressScale: 0.98 }}
      >
        <span class="layer-glyph">{glyphFor(element)}</span>
        <span class="layer-name">{element.type === "label" && element.text ? element.text : TYPE_NAMES[element.type]}</span>
        <span class="layer-position">{element.x}, {element.y}</span>
      </button>
    {/each}
  </div>
</section>
