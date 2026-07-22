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
      <span class="representation-preview" class:visual-preview={["goal-ring", "zone-gauge", "history-graph", "progress-bar"].includes(option.id)}>
        {#if option.id === "history-graph"}
          <svg class="mini-history" viewBox="0 0 64 28" aria-hidden="true"><path d="M2 22 L10 17 L18 20 L27 8 L36 13 L45 5 L54 11 L62 4" /></svg>
          <span>{option.preview}</span>
        {:else if option.id === "zone-gauge"}
          <span class="mini-gauge" aria-hidden="true"><i></i><i></i><i></i><i></i><i></i><b></b></span>
        {:else if option.id === "goal-ring"}
          <span class="mini-ring" aria-hidden="true"></span><span>{option.preview}</span>
        {:else if option.id === "progress-bar"}
          <span>{option.preview}</span><span class="mini-progress" aria-hidden="true"><i></i></span>
        {:else}
          {option.preview}
        {/if}
      </span>
      <span class="representation-copy"><strong>{option.name}</strong><small>{option.description}</small></span>
      <span class="representation-check" aria-hidden="true"></span>
    </button>
  {/each}
</div>
