<script>
  import Icon from "./Icon.svelte";
  import TemplatePreview from "./TemplatePreview.svelte";
  import { WATCH_TEMPLATES } from "../lib/templates.js";
  import { tactile } from "../lib/motion.js";
  let { onclose, onapply } = $props();
</script>

<div class="modal-backdrop template-backdrop" role="presentation" onclick={(event) => { if (event.target === event.currentTarget) onclose(); }}>
  <div class="template-dialog" role="dialog" aria-modal="true" aria-labelledby="templates-title">
    <header class="template-dialog-header">
      <div><span class="eyebrow">Starting points</span><h2 id="templates-title">Watch face gallery</h2><p>Choose a complete face, then customize every layer.</p></div>
      <button class="icon-button" type="button" aria-label="Close templates" onclick={onclose} use:tactile><Icon name="close" size={18} /></button>
    </header>
    <div class="template-grid">
      {#each WATCH_TEMPLATES as template}
        <article class="template-card" style={`--template-accent:${template.accent}`}>
          <div class="template-preview"><TemplatePreview {template} /></div>
          <div class="template-card-copy"><strong>{template.name}</strong><p>{template.description}</p></div>
          <button class="button secondary" type="button" onclick={() => onapply(template.id)} use:tactile>Use this face</button>
        </article>
      {/each}
    </div>
  </div>
</div>
