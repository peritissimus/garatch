<script>
  import Icon from "./Icon.svelte";
  import TemplatePreview from "./TemplatePreview.svelte";
  import { WATCH_TEMPLATES } from "../lib/templates.js";
  import { tactile } from "../lib/motion.js";
  let { onclose, onapply } = $props();
  const categories = ["All", "Analog", "Digital", "Data", "Wellness", "Minimal"];
  let activeCategory = $state("All");
  let visibleTemplates = $derived(activeCategory === "All" ? WATCH_TEMPLATES : WATCH_TEMPLATES.filter((template) => template.category === activeCategory));
</script>

<div class="modal-backdrop template-backdrop" role="presentation" onclick={(event) => { if (event.target === event.currentTarget) onclose(); }}>
  <div class="template-dialog" role="dialog" aria-modal="true" aria-labelledby="templates-title">
    <header class="template-dialog-header">
      <div><span class="eyebrow">{WATCH_TEMPLATES.length} starting points</span><h2 id="templates-title">Watch face gallery</h2><p>Choose a complete face, then customize every layer.</p></div>
      <button class="icon-button" type="button" aria-label="Close templates" onclick={onclose} use:tactile><Icon name="close" size={18} /></button>
    </header>
    <nav class="template-filters" aria-label="Filter watch face templates">
      {#each categories as category}
        <button type="button" class:active={activeCategory === category} aria-pressed={activeCategory === category} onclick={() => { activeCategory = category; }} use:tactile>{category}</button>
      {/each}
    </nav>
    <div class="template-grid">
      {#each visibleTemplates as template (template.id)}
        <article class="template-card" style={`--template-accent:${template.accent}`}>
          <div class="template-preview"><span class="template-category">{template.category}</span><TemplatePreview {template} /></div>
          <div class="template-card-copy"><strong>{template.name}</strong><p>{template.description}</p></div>
          <button class="button secondary" type="button" onclick={() => onapply(template.id)} use:tactile>Start with {template.name}</button>
        </article>
      {/each}
    </div>
  </div>
</div>
