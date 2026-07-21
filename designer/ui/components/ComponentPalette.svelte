<script>
  import Icon from "./Icon.svelte";
  import { DYNAMIC_CATALOG, ELEMENT_CATALOG, STATIC_CATALOG } from "../lib/catalog.js";
  import { tactile } from "../lib/motion.js";
  let { onadd } = $props();
</script>

<section class="rail-section palette-section">
  <header class="section-header">
    <div>
      <span class="eyebrow">Build</span>
      <h2>Components</h2>
    </div>
    <span class="count-badge">{ELEMENT_CATALOG.length}</span>
  </header>

  {#each [["dynamic", "Dynamic", "Live watch data", DYNAMIC_CATALOG], ["static", "Static", "Design building blocks", STATIC_CATALOG]] as [id, name, description, items]}
    <section class="component-group" aria-labelledby={`${id}-components`}>
      <header class="component-group-heading">
        <div><strong id={`${id}-components`}>{name}</strong><span>{description}</span></div>
        <span>{items.length}</span>
      </header>
      <div class="component-grid">
        {#each items as item (item.type)}
          <button class="component-tile" type="button" onclick={() => onadd(item.type)} use:tactile={{ hoverY: -2 }}>
            <span class="component-glyph" data-tone={item.tone}>{item.glyph}</span>
            <span class="component-copy">
              <strong>{item.name}</strong>
              <small>{item.description}</small>
            </span>
            <span class="add-indicator"><Icon name="plus" size={14} /></span>
          </button>
        {/each}
      </div>
    </section>
  {/each}
</section>
