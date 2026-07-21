<script>
  import Icon from "./Icon.svelte";
  import { tactile } from "../lib/motion.js";
  let { backgroundColor, validation, coreState, elementCount, onbackground, onreset } = $props();

  let health = $derived.by(() => {
    if (coreState.state === "error") return { state: "invalid", title: "Export unavailable", description: coreState.detail || "Reload the page and try again.", icon: "alert" };
    if (coreState.state !== "ready" || !validation) return { state: "loading", title: "Checking design", description: "Making sure the project is ready to download.", icon: "sparkles" };
    if (!validation.valid) return { state: "invalid", title: `${validation.issues.length} project issue${validation.issues.length === 1 ? "" : "s"}`, description: validation.issues[0]?.message || "Review the project settings.", icon: "alert" };
    return { state: "valid", title: "Ready to export", description: `${elementCount} layers · Complete Monkey C project`, icon: "check" };
  });
</script>

<section class="rail-section project-section">
  <header class="section-header compact">
    <h2>Project</h2>
  </header>

  <label class="canvas-color-field">
    <span><strong>Canvas color</strong><small>{backgroundColor}</small></span>
    <input type="color" value={backgroundColor} oninput={(event) => onbackground(event.currentTarget.value.toUpperCase())} />
  </label>

  <div class="health-card" data-state={health.state}>
    <span class="health-icon"><Icon name={health.icon} size={17} /></span>
    <div><strong>{health.title}</strong><p>{health.description}</p></div>
  </div>

  <button class="text-button" type="button" onclick={onreset} use:tactile={{ hoverY: 0 }}>Reset sample project</button>
</section>
