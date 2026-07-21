<script>
  import { REPRESENTATION_OPTIONS } from "../lib/catalog.js";
  import { tactile } from "../lib/motion.js";

  let { type, value = "value", onselect } = $props();
  let options = $derived(REPRESENTATION_OPTIONS[type] ?? []);
</script>

<div class="representation-grid" class:format-grid={type === "time" || type === "date"} role="radiogroup" aria-label="Visual representation">
  {#each options as option (option.id)}
    <button
      class="representation-card"
      class:selected={value === option.id}
      type="button"
      role="radio"
      aria-checked={value === option.id}
      onclick={() => onselect(option.id)}
      use:tactile
    >
      <span class="representation-preview">{option.preview}</span>
      <span class="representation-copy"><strong>{option.name}</strong><small>{option.description}</small></span>
      <span class="representation-check" aria-hidden="true"></span>
    </button>
  {/each}
</div>
