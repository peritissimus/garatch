<script>
  import Icon from "./Icon.svelte";
  import { tactile } from "../lib/motion.js";

  let { projectName, coreState, downloadState, onname, ontemplates, ondownload } = $props();
</script>

<header class="topbar">
  <div class="brand" aria-label="Garatch Studio">
    <div class="brand-mark" aria-hidden="true"><span></span><span></span><span></span><span></span></div>
    <div class="brand-copy">
      <strong>Garatch</strong>
      <span>Watchface studio</span>
    </div>
  </div>

  <label class="project-name-field">
    <span>Project</span>
    <input
      value={projectName}
      oninput={(event) => onname(event.currentTarget.value)}
      maxlength="48"
      autocomplete="off"
      aria-label="Project name"
    />
  </label>

  <div class="topbar-actions">
    <button class="button secondary templates-button" type="button" onclick={ontemplates} use:tactile>
      <Icon name="templates" size={16} /><span>Templates</span>
    </button>
    <button
      class="button primary download-button"
      data-state={downloadState}
      type="button"
      disabled={coreState.state !== "ready"}
      onclick={ondownload}
      use:tactile
    >
      <span class="contextual-icon">
        <span class="download-icon"><Icon name="download" size={17} /></span>
        <span class="success-icon"><Icon name="check" size={17} /></span>
      </span>
      <span>{downloadState === "success" ? "Downloaded" : "Download project"}</span>
    </button>
  </div>
</header>
