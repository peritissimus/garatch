<script>
  import Select from "./Select.svelte";

  let { label, type = "text", value, min, max, maxlength, options = null, oninput, onchange } = $props();
</script>

{#if options}
  <div class="field">
    <span>{label}</span>
    <Select {value} {options} {oninput} {onchange} />
  </div>
{:else}
  <label class="field">
    <span>{label}</span>
    <input
      {type}
      {value}
      {min}
      {max}
      {maxlength}
      oninput={(event) => oninput(type === "number" ? Number(event.currentTarget.value) : event.currentTarget.value)}
      onchange={(event) => onchange?.(type === "number" ? Number(event.currentTarget.value) : event.currentTarget.value)}
    />
  </label>
{/if}
