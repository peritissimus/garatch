<script>
  import Select from "./Select.svelte";
  import NumberInput from "./NumberInput.svelte";

  let { label, type = "text", value, min, max, maxlength, options = null, oninput, onchange } = $props();
</script>

{#if options}
  <div class="field">
    <span>{label}</span>
    <Select {value} {options} {oninput} {onchange} />
  </div>
{:else if type === "number"}
  <label class="field">
    <span>{label}</span>
    <NumberInput {value} {min} {max} {oninput} {onchange} />
  </label>
{:else}
  <label class="field">
    <span>{label}</span>
    <input
      {type}
      {value}
      {min}
      {max}
      {maxlength}
      oninput={(event) => oninput(event.currentTarget.value)}
      onchange={(event) => onchange?.(event.currentTarget.value)}
    />
  </label>
{/if}
