<script>
  import { tick } from "svelte";

  let { value, options = [], oninput, onchange } = $props();

  let open = $state(false);
  let triggerEl = $state(null);
  let menuEl = $state(null);
  let activeIndex = $state(-1);
  let menuStyle = $state("");

  let selectedIndex = $derived(options.findIndex((option) => option[0] === value));
  let selectedLabel = $derived(options[selectedIndex]?.[1] ?? options[0]?.[1] ?? "");

  function place() {
    if (!triggerEl) return;
    const r = triggerEl.getBoundingClientRect();
    const rows = Math.min(options.length, 7);
    const estimated = rows * 34 + 8;
    const below = window.innerHeight - r.bottom - 10;
    const above = r.top - 10;
    const flip = below < estimated && above > below;
    const maxHeight = Math.max(120, Math.min(260, flip ? above : below));
    const top = flip ? r.top - Math.min(estimated, maxHeight) - 6 : r.bottom + 6;
    menuStyle = `left:${r.left}px;top:${top}px;width:${r.width}px;max-height:${maxHeight}px;`;
  }

  async function openMenu() {
    activeIndex = selectedIndex >= 0 ? selectedIndex : 0;
    open = true;
    await tick();
    place();
    menuEl?.focus();
    menuEl?.querySelector(".select-option.active")?.scrollIntoView({ block: "nearest" });
  }

  function closeMenu() {
    open = false;
    activeIndex = -1;
    triggerEl?.focus();
  }

  function choose(option) {
    oninput?.(option[0]);
    onchange?.(option[0]);
    open = false;
    activeIndex = -1;
    triggerEl?.focus();
  }

  function onTriggerKey(event) {
    if (open) return;
    if (event.key === "ArrowDown" || event.key === "ArrowUp" || event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      openMenu();
    }
  }

  function onMenuKey(event) {
    if (event.key === "Escape") {
      event.preventDefault();
      closeMenu();
    } else if (event.key === "ArrowDown") {
      event.preventDefault();
      activeIndex = (activeIndex + 1) % options.length;
    } else if (event.key === "ArrowUp") {
      event.preventDefault();
      activeIndex = (activeIndex - 1 + options.length) % options.length;
    } else if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      if (options[activeIndex]) choose(options[activeIndex]);
    } else if (event.key === "Home") {
      event.preventDefault();
      activeIndex = 0;
    } else if (event.key === "End") {
      event.preventDefault();
      activeIndex = options.length - 1;
    }
  }

  $effect(() => {
    if (!open) return;
    const onDocPointer = (event) => {
      if (!triggerEl?.contains(event.target) && !menuEl?.contains(event.target)) closeMenu();
    };
    const onReflow = () => place();
    window.addEventListener("pointerdown", onDocPointer, true);
    window.addEventListener("resize", onReflow);
    window.addEventListener("scroll", onReflow, true);
    return () => {
      window.removeEventListener("pointerdown", onDocPointer, true);
      window.removeEventListener("resize", onReflow);
      window.removeEventListener("scroll", onReflow, true);
    };
  });
</script>

<button
  bind:this={triggerEl}
  type="button"
  class="select-trigger"
  class:open
  aria-haspopup="listbox"
  aria-expanded={open}
  onclick={() => (open ? closeMenu() : openMenu())}
  onkeydown={onTriggerKey}
>
  <span class="select-value">{selectedLabel}</span>
  <svg class="select-caret" width="11" height="11" viewBox="0 0 24 24" fill="none" aria-hidden="true">
    <path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" />
  </svg>
</button>

{#if open}
  <div
    bind:this={menuEl}
    class="select-menu"
    role="listbox"
    tabindex="-1"
    style={menuStyle}
    onkeydown={onMenuKey}
  >
    {#each options as option, index}
      <button
        type="button"
        role="option"
        aria-selected={option[0] === value}
        class="select-option"
        class:active={index === activeIndex}
        class:selected={option[0] === value}
        onpointerenter={() => (activeIndex = index)}
        onclick={() => choose(option)}
      >
        <span>{option[1]}</span>
        {#if option[0] === value}
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" aria-hidden="true">
            <path d="M5 12.5l4 4 10-10" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" />
          </svg>
        {/if}
      </button>
    {/each}
  </div>
{/if}

<style>
  .select-trigger {
    display: flex;
    width: 100%;
    min-width: 0;
    height: var(--row-height);
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    padding: 0 9px 0 11px;
    color: var(--ink);
    background: var(--surface);
    border: 1px solid var(--line);
    border-radius: 8px;
    cursor: pointer;
    font-size: 10px;
    font-weight: 550;
    transition-property: background-color, border-color, box-shadow;
    transition-duration: 140ms;
    transition-timing-function: ease-out;
  }
  .select-trigger:hover { background: var(--surface-hover); border-color: var(--line-strong); }
  .select-trigger.open,
  .select-trigger:focus-visible {
    background: var(--surface-hover);
    border-color: var(--accent-line);
    box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.08);
    outline: none;
  }
  .select-value { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .select-caret {
    flex: 0 0 auto;
    color: var(--muted);
    transition: transform 180ms cubic-bezier(0.2, 0, 0, 1), color 140ms;
  }
  .select-trigger:hover .select-caret { color: var(--muted-strong); }
  .select-trigger.open .select-caret { color: var(--ink); transform: rotate(180deg); }

  .select-menu {
    position: fixed;
    z-index: 80;
    display: flex;
    flex-direction: column;
    gap: 1px;
    padding: 4px;
    overflow-y: auto;
    overscroll-behavior: contain;
    background: var(--panel-raised);
    border: 1px solid var(--line-strong);
    border-radius: 10px;
    box-shadow: var(--shadow-panel), inset 0 1px 0 rgba(255, 255, 255, 0.05);
    scrollbar-width: thin;
    scrollbar-color: rgba(255, 255, 255, 0.16) transparent;
    animation: select-in 150ms cubic-bezier(0.2, 0, 0, 1) both;
  }

  .select-option {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    min-height: 32px;
    padding: 0 9px;
    color: var(--muted-strong);
    text-align: left;
    background: transparent;
    border-radius: 6px;
    cursor: pointer;
    font-size: 10px;
    font-weight: 560;
    transition: color 120ms, background-color 120ms;
  }
  .select-option > span { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .select-option > svg { flex: 0 0 auto; color: var(--ink); }
  .select-option.active { color: var(--ink); background: var(--surface-hover); }
  .select-option.selected { color: var(--ink); }

  @keyframes select-in {
    from { opacity: 0; transform: translateY(-4px) scale(0.98); }
    to { opacity: 1; transform: translateY(0) scale(1); }
  }

  @media (prefers-reduced-motion: reduce) {
    .select-caret, .select-menu, .select-option { transition: none; animation: none; }
  }
</style>
