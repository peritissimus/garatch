<script>
  import { onMount } from "svelte";
  import Topbar from "./components/Topbar.svelte";
  import ComponentPalette from "./components/ComponentPalette.svelte";
  import LayersPanel from "./components/LayersPanel.svelte";
  import InspectorPanel from "./components/InspectorPanel.svelte";
  import ProjectHealth from "./components/ProjectHealth.svelte";
  import Stage from "./components/Stage.svelte";
  import Icon from "./components/Icon.svelte";
  import TemplateGallery from "./components/TemplateGallery.svelte";
  import { TYPE_NAMES } from "./lib/catalog.js";
  import { WATCH_HEIGHT, WATCH_WIDTH, clampPosition, createSampleProject, duplicateElement, elementFactory, loadProject, saveProject, slugify } from "./lib/project.js";
  import { loadGaratchCore } from "./lib/wasm.js";
  import { prepareProjectForExport } from "./lib/textLayout.js";
  import { tactile } from "./lib/motion.js";
  import { roleForElement } from "./lib/bmfont.js";
  import { createProjectFromTemplate } from "./lib/templates.js";

  const initialProject = loadProject();
  let project = $state(initialProject);
  let selectedId = $state(initialProject.elements.find((element) => element.type === "time")?.id ?? initialProject.elements.at(-1)?.id ?? null);
  let core = $state.raw(null);
  let coreState = $state({ state: "loading", label: "Preparing", detail: "" });
  let validation = $state(null);
  let showGrid = $state(true);
  let aod = $state(false);
  let validationOpen = $state(false);
  let downloadState = $state("idle");
  let templatesOpen = $state(false);
  let toast = $state(null);
  let validationTimer;
  let toastTimer;
  let DialTuner = $state(null);
  let tuning = $state({ panelRadius: 14, leftRail: 232, rightRail: 296, stageGlow: 0.12, hoverLift: -1, pressScale: 0.96, springStiffness: 520, springDamping: 36, accent: "#72D6B2" });

  let selected = $derived(project.elements.find((element) => element.id === selectedId) ?? null);

  function notify(message) {
    toast = message;
    window.clearTimeout(toastTimer);
    toastTimer = window.setTimeout(() => { toast = null; }, 2200);
  }

  function scheduleValidation() {
    window.clearTimeout(validationTimer);
    if (!core) return;
    validationTimer = window.setTimeout(() => {
      try {
        validation = core.validate(project);
      } catch (error) {
        validation = { valid: false, issues: [{ field: "$", message: error.message }] };
      }
    }, 100);
  }

  $effect(() => {
    JSON.stringify(project);
    saveProject(project);
    scheduleValidation();
  });

  function addElement(type) {
    const element = elementFactory(type);
    project.elements.push(element);
    selectedId = element.id;
    notify(`${TYPE_NAMES[type]} added`);
  }

  function deleteSelected() {
    const index = project.elements.findIndex((element) => element.id === selectedId);
    if (index < 0) return;
    project.elements.splice(index, 1);
    selectedId = project.elements[Math.min(index, project.elements.length - 1)]?.id ?? null;
  }

  function duplicateSelected() {
    if (!selected) return;
    const copy = duplicateElement(selected);
    project.elements.push(copy);
    selectedId = copy.id;
    notify("Layer duplicated");
  }

  function moveLayer(direction) {
    const index = project.elements.findIndex((element) => element.id === selectedId);
    const target = index + direction;
    if (index < 0 || target < 0 || target >= project.elements.length) return;
    [project.elements[index], project.elements[target]] = [project.elements[target], project.elements[index]];
  }

  function updateSelected(property, value) {
    if (!selected || !property || (typeof value === "number" && Number.isNaN(value))) return;
    if (property === "x" || property === "y") {
      const next = clampPosition(selected, property === "x" ? value : selected.x, property === "y" ? value : selected.y);
      if (selected.type === "line") {
        selected.endX += next.x - selected.x;
        selected.endY += next.y - selected.y;
      }
      selected.x = next.x;
      selected.y = next.y;
      return;
    }
    selected[property] = value;
    if (selected.type === "rectangle") {
      selected.width = Math.max(1, Math.min(320, selected.width));
      selected.height = Math.max(1, Math.min(360, selected.height));
      selected.cornerRadius = Math.max(0, Math.min(selected.cornerRadius, Math.floor(Math.min(selected.width, selected.height) / 2)));
      const next = clampPosition(selected, selected.x, selected.y);
      selected.x = next.x;
      selected.y = next.y;
    }
    if (selected.type === "ellipse") {
      selected.radiusX = Math.max(1, Math.min(Math.floor((WATCH_WIDTH - 1) / 2), selected.radiusX));
      selected.radiusY = Math.max(1, Math.min(Math.floor((WATCH_HEIGHT - 1) / 2), selected.radiusY));
      const next = clampPosition(selected, selected.x, selected.y);
      selected.x = next.x;
      selected.y = next.y;
    }
    if (selected.type === "line") {
      selected.endX = Math.max(0, Math.min(WATCH_WIDTH - 1, selected.endX));
      selected.endY = Math.max(0, Math.min(WATCH_HEIGHT - 1, selected.endY));
      selected.thickness = Math.max(1, Math.min(12, selected.thickness));
    }
    if (selected.type === "icon") {
      selected.size = Math.max(12, Math.min(96, selected.size));
      const next = clampPosition(selected, selected.x, selected.y);
      selected.x = next.x;
      selected.y = next.y;
    }
  }

  function alignSelected(direction) {
    if (!selected) return;
    const horizontal = ["left", "center-x", "right"].includes(direction);
    if (!["rectangle", "ellipse", "line", "icon"].includes(selected.type)) {
      if (horizontal) {
        selected.align = direction === "center-x" ? "center" : direction;
        selected.x = direction === "left" ? 0 : direction === "right" ? WATCH_WIDTH - 1 : WATCH_WIDTH / 2;
      } else {
        const role = roleForElement(selected);
        const height = selected.type === "label" ? Math.max(project.fontHeights[role], selected.lineHeight) : project.fontHeights[role];
        selected.y = direction === "top" ? Math.ceil(height / 2) : direction === "bottom" ? WATCH_HEIGHT - 1 - Math.ceil(height / 2) : WATCH_HEIGHT / 2;
      }
      notify("Layer aligned to canvas");
      return;
    }
    let bounds;
    if (selected.type === "rectangle") bounds = { left: selected.x, right: selected.x + selected.width, top: selected.y, bottom: selected.y + selected.height };
    else if (selected.type === "ellipse") bounds = { left: selected.x - selected.radiusX, right: selected.x + selected.radiusX, top: selected.y - selected.radiusY, bottom: selected.y + selected.radiusY };
    else if (selected.type === "icon") bounds = { left: selected.x - selected.size / 2, right: selected.x + selected.size / 2, top: selected.y - selected.size / 2, bottom: selected.y + selected.size / 2 };
    else bounds = { left: Math.min(selected.x, selected.endX), right: Math.max(selected.x, selected.endX), top: Math.min(selected.y, selected.endY), bottom: Math.max(selected.y, selected.endY) };
    const dx = direction === "left" ? -bounds.left : direction === "right" ? WATCH_WIDTH - 1 - bounds.right : direction === "center-x" ? WATCH_WIDTH / 2 - (bounds.left + bounds.right) / 2 : 0;
    const dy = direction === "top" ? -bounds.top : direction === "bottom" ? WATCH_HEIGHT - 1 - bounds.bottom : direction === "center-y" ? WATCH_HEIGHT / 2 - (bounds.top + bounds.bottom) / 2 : 0;
    selected.x = Math.round(selected.x + dx); selected.y = Math.round(selected.y + dy);
    if (selected.type === "line") { selected.endX = Math.round(selected.endX + dx); selected.endY = Math.round(selected.endY + dy); }
    notify("Layer aligned to canvas");
  }

  function applyTemplate(templateId) {
    if (!window.confirm("Replace the current canvas with this watch face?")) return;
    project = createProjectFromTemplate(templateId);
    selectedId = project.elements.find((element) => element.type === "time")?.id ?? null;
    templatesOpen = false;
    notify("Watch face template applied");
  }

  function updatePosition(id, x, y) {
    const element = project.elements.find((item) => item.id === id);
    if (!element) return;
    if (element.type === "line") {
      element.endX += x - element.x;
      element.endY += y - element.y;
    }
    element.x = x;
    element.y = y;
  }

  function resetProject() {
    if (!window.confirm("Reset the canvas and replace your current project?")) return;
    project = createSampleProject();
    selectedId = null;
    notify("Sample project restored");
  }

  async function downloadProject() {
    if (!core) return;
    try {
      const exportProject = await prepareProjectForExport(project);
      const report = core.validate(exportProject);
      validation = report;
      if (!report.valid) {
        validationOpen = true;
        return;
      }
      const archive = core.exportProject(exportProject);
      const url = URL.createObjectURL(new Blob([archive], { type: "application/zip" }));
      const link = document.createElement("a");
      link.href = url;
      link.download = `${slugify(project.name)}.zip`;
      document.body.append(link);
      link.click();
      link.remove();
      window.setTimeout(() => URL.revokeObjectURL(url), 1000);
      downloadState = "success";
      notify("Complete Monkey C project downloaded");
      window.setTimeout(() => { downloadState = "idle"; }, 1400);
    } catch (error) {
      validation = { valid: false, issues: [{ field: "$", message: error.message }] };
      validationOpen = true;
    }
  }

  function handleKeydown(event) {
    if (["INPUT", "SELECT", "TEXTAREA"].includes(document.activeElement?.tagName)) return;
    if (event.key === "Escape") {
      selectedId = null;
      return;
    }
    if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "d") {
      event.preventDefault(); duplicateSelected(); return;
    }
    if (["Delete", "Backspace"].includes(event.key)) {
      event.preventDefault(); deleteSelected(); return;
    }
    const deltas = { ArrowLeft: [-1, 0], ArrowRight: [1, 0], ArrowUp: [0, -1], ArrowDown: [0, 1] };
    if (!deltas[event.key] || !selected) return;
    event.preventDefault();
    const distance = event.shiftKey ? 10 : 1;
    const [dx, dy] = deltas[event.key];
    const next = clampPosition(selected, selected.x + dx * distance, selected.y + dy * distance);
    if (selected.type === "line") { selected.endX += next.x - selected.x; selected.endY += next.y - selected.y; }
    selected.x = next.x; selected.y = next.y;
  }

  onMount(async () => {
    window.addEventListener("keydown", handleKeydown);
    if (import.meta.env.DEV) DialTuner = (await import("./components/DialTuner.svelte")).default;
    try {
      core = await loadGaratchCore();
      coreState = { state: "ready", label: "Ready", detail: "" };
      scheduleValidation();
    } catch (error) {
      coreState = { state: "error", label: "Export unavailable", detail: error.message };
      console.error(error);
    }
    return () => {
      window.removeEventListener("keydown", handleKeydown);
      window.clearTimeout(validationTimer);
      window.clearTimeout(toastTimer);
    };
  });
</script>

<svelte:head><title>{project.name} · Garatch Studio</title></svelte:head>

<div
  class="app-shell"
  style={`--panel-radius:${tuning.panelRadius}px;--left-rail:${tuning.leftRail}px;--right-rail:${tuning.rightRail}px;--stage-glow:${tuning.stageGlow};--hover-lift:${tuning.hoverLift};--press-scale:${tuning.pressScale};--spring-stiffness:${tuning.springStiffness};--spring-damping:${tuning.springDamping};--mint:${tuning.accent};`}
>
  <Topbar
    projectName={project.name}
    {coreState}
    {downloadState}
    onname={(name) => { project.name = name; }}
    ontemplates={() => { templatesOpen = true; }}
    ondownload={downloadProject}
  />

  <main class="workspace">
    <aside class="left-rail" aria-label="Components and layers">
      <ComponentPalette onadd={addElement} />
      <div class="rail-divider"></div>
      <LayersPanel elements={project.elements} {selectedId} onselect={(id) => { selectedId = id; }} />
    </aside>

    <Stage
      {project}
      {selectedId}
      {showGrid}
      {aod}
      onselect={(id) => { selectedId = id; }}
      onposition={updatePosition}
      ongrid={() => { showGrid = !showGrid; }}
      onaod={() => { aod = !aod; }}
    />

    <aside class="right-rail" aria-label="Properties inspector">
      <InspectorPanel
        element={selected}
        fontFamily={project.fontFamily}
        fontFamilySecondary={project.fontFamilySecondary ?? project.fontFamily}
        fontHeights={project.fontHeights}
        letterSpacing={project.letterSpacing}
        onfontfamily={(fontFamily) => { project.fontFamily = fontFamily; }}
        onfontfamilysecondary={(fontFamilySecondary) => { project.fontFamilySecondary = fontFamilySecondary; }}
        onfontheight={(role, height) => { project.fontHeights[role] = height; }}
        onletterspacing={(role, spacing) => { project.letterSpacing[role] = spacing; }}
        onupdate={updateSelected}
        onduplicate={duplicateSelected}
        ondelete={deleteSelected}
        onmove={moveLayer}
        onalign={alignSelected}
      />
      <div class="rail-divider"></div>
      <ProjectHealth
        backgroundColor={project.backgroundColor}
        {validation}
        {coreState}
        elementCount={project.elements.length}
        onbackground={(color) => { project.backgroundColor = color; }}
        onreset={resetProject}
      />
    </aside>
  </main>
</div>

{#if validationOpen}
  <div class="modal-backdrop" role="presentation" onclick={(event) => { if (event.target === event.currentTarget) validationOpen = false; }}>
    <div class="validation-dialog" role="dialog" aria-modal="true" aria-labelledby="validation-title">
      <span class="dialog-icon"><Icon name="alert" size={20} /></span>
      <div>
        <span class="eyebrow">Export blocked</span>
        <h2 id="validation-title">Resolve project issues</h2>
        <p>The generator found values that would produce an invalid Connect IQ project.</p>
      </div>
      <ul class="validation-list">
        {#each validation?.issues ?? [] as issue}
          <li><code>{issue.field}</code><span>{issue.message}</span></li>
        {/each}
      </ul>
      <button class="button secondary full-width" type="button" onclick={() => { validationOpen = false; }} use:tactile>Return to editor</button>
    </div>
  </div>
{/if}

{#if templatesOpen}
  <TemplateGallery onclose={() => { templatesOpen = false; }} onapply={applyTemplate} />
{/if}

{#if toast}
  <div class="toast" role="status" aria-live="polite">
    <span><Icon name="check" size={15} /></span>{toast}
  </div>
{/if}

{#if DialTuner}
  <DialTuner ontune={(values) => { tuning = values; }} />
{/if}
