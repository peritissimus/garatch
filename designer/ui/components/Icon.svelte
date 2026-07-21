<script>
  let { name, size = 18, strokeWidth = 1.8 } = $props();
</script>

<svg
  class="icon"
  width={size}
  height={size}
  viewBox="0 0 24 24"
  fill="none"
  stroke="currentColor"
  stroke-width={strokeWidth}
  stroke-linecap="round"
  stroke-linejoin="round"
  aria-hidden="true"
>
  {#if name === "download"}
    <path d="M12 3v11m0 0 4-4m-4 4-4-4M5 18v2h14v-2" />
  {:else if name === "check"}
    <path d="m5 12 4 4L19 6" />
  {:else if name === "grid"}
    <path d="M4 4h6v6H4zM14 4h6v6h-6zM4 14h6v6H4zM14 14h6v6h-6z" />
  {:else if name === "moon"}
    <path d="M20 15.3A8.5 8.5 0 0 1 8.7 4 8.5 8.5 0 1 0 20 15.3Z" />
  {:else if name === "trash"}
    <path d="M4 7h16M9 7V4h6v3m-8 0 1 13h8l1-13M10 11v5m4-5v5" />
  {:else if name === "copy"}
    <rect x="8" y="8" width="11" height="11" rx="2" />
    <path d="M16 8V6a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h2" />
  {:else if name === "plus"}
    <path d="M12 5v14M5 12h14" />
  {:else if name === "alert"}
    <path d="M12 3 2.7 20h18.6L12 3Zm0 6v5m0 3v.01" />
  {:else if name === "chevron-up"}
    <path d="m7 14 5-5 5 5" />
  {:else if name === "chevron-down"}
    <path d="m7 10 5 5 5-5" />
  {:else if name === "layers"}
    <path d="m12 3-9 5 9 5 9-5-9-5Z" /><path d="m3 12 9 5 9-5M3 16l9 5 9-5" />
  {:else if name === "sliders"}
    <path d="M4 7h10M18 7h2M4 17h2M10 17h10M14 4v6M10 14v6" />
  {:else if name === "sparkles"}
    <path d="m12 3 1.2 3.8L17 8l-3.8 1.2L12 13l-1.2-3.8L7 8l3.8-1.2L12 3ZM5 14l.7 2.3L8 17l-2.3.7L5 20l-.7-2.3L2 17l2.3-.7L5 14Zm13-1 .8 2.2L21 16l-2.2.8L18 19l-.8-2.2L15 16l2.2-.8L18 13Z" />
  {:else if name === "command"}
    <path d="M9 6v12M15 6v12M6 9h12M6 15h12" />
    <path d="M6 3a3 3 0 0 0 0 6h3V6a3 3 0 0 0-3-3ZM18 3a3 3 0 0 1 0 6h-3V6a3 3 0 0 1 3-3ZM6 21a3 3 0 0 1 0-6h3v3a3 3 0 0 1-3 3ZM18 21a3 3 0 0 0 0-6h-3v3a3 3 0 0 0 3 3Z" />
  {:else if name === "close"}
    <path d="m6 6 12 12M18 6 6 18" />
  {:else if name === "templates"}
    <path d="M4 5h7v6H4zM14 5h6v6h-6zM4 14h7v5H4zM14 14h6v5h-6z" />
  {:else if name === "align-left"}
    <path d="M4 4v16M7 7h11M7 17h8" />
  {:else if name === "align-center"}
    <path d="M12 4v16M6 7h12M8 17h8" />
  {:else if name === "align-right"}
    <path d="M20 4v16M6 7h11M9 17h8" />
  {:else if name === "align-top"}
    <path d="M4 4h16M7 7v11M17 7v8" />
  {:else if name === "align-middle"}
    <path d="M4 12h16M7 6v12M17 8v8" />
  {:else if name === "align-bottom"}
    <path d="M4 20h16M7 6v11M17 9v8" />
  {/if}
</svg>
