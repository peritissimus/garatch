<script>
  let { label, type = "text", value, min, max, maxlength, options = null, oninput, onchange } = $props();
</script>

<label class="field">
  <span>{label}</span>
  {#if options}
    <select value={value} oninput={(event) => oninput(event.currentTarget.value)} onchange={(event) => onchange?.(event.currentTarget.value)}>
      {#each options as option}
        <option value={option[0]}>{option[1]}</option>
      {/each}
    </select>
  {:else}
    <input
      {type}
      {value}
      {min}
      {max}
      {maxlength}
      oninput={(event) => oninput(type === "number" ? Number(event.currentTarget.value) : event.currentTarget.value)}
      onchange={(event) => onchange?.(type === "number" ? Number(event.currentTarget.value) : event.currentTarget.value)}
    />
  {/if}
</label>
