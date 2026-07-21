<script>
  import Field from "./Field.svelte";
  import Icon from "./Icon.svelte";
  import IconPicker from "./IconPicker.svelte";
  import RepresentationPicker from "./RepresentationPicker.svelte";
  import { ALIGN_OPTIONS, DYNAMIC_TYPES, TYPE_NAMES } from "../lib/catalog.js";
  import { FONT_FAMILIES, FONT_HEIGHT_OPTIONS, FONT_ROLE_DETAILS, normalizeFontFamily, roleForElement } from "../lib/bmfont.js";
  import { tactile } from "../lib/motion.js";
  import { defaultProgressMax, isShapeElement } from "../lib/project.js";

  let { element, fontFamily, fontFamilySecondary, fontHeights, letterSpacing, onfontfamily, onfontfamilysecondary, onfontheight, onletterspacing, onupdate, onduplicate, ondelete, onmove, onalign } = $props();
  let primaryFamily = $derived(FONT_FAMILIES.find((family) => family.id === normalizeFontFamily(fontFamily)) ?? FONT_FAMILIES[0]);
  let secondaryFamily = $derived(FONT_FAMILIES.find((family) => family.id === normalizeFontFamily(fontFamilySecondary ?? fontFamily)) ?? FONT_FAMILIES[0]);
  let selectedRole = $derived(element && !isShapeElement(element) ? roleForElement(element) : null);

  function update(property, value, commit = false) {
    onupdate(property, value, commit);
  }

</script>

<section class="rail-section inspector-section">
  <header class="section-header inspector-header">
    <div>
      <span class="eyebrow">Edit</span>
      <h2>Inspector</h2>
    </div>
    {#if element}
      <div class="header-actions">
        <button class="icon-button" type="button" title="Duplicate layer" aria-label="Duplicate layer" onclick={onduplicate} use:tactile>
          <Icon name="copy" size={16} />
        </button>
        <button class="icon-button danger" type="button" title="Delete layer" aria-label="Delete layer" onclick={ondelete} use:tactile>
          <Icon name="trash" size={16} />
        </button>
      </div>
    {/if}
  </header>

  {#if !element || !isShapeElement(element)}
    <section class="inspector-group face-typeface-group">
      <div class="group-heading">
        <h3>Face typefaces</h3>
        <p>Primary drives the time. Secondary drives values and labels.</p>
      </div>
      <div class="typeface-current">
        <span class="typeface-sample" style={`font-family: "${primaryFamily.cssFamily}", sans-serif`}>12:34</span>
        <span class="typeface-copy"><strong>{primaryFamily.name}</strong><small>Primary · {primaryFamily.tone}</small></span>
        <span class="typeface-indicator" aria-hidden="true"></span>
      </div>
      <Field
        label="Primary font"
        value={normalizeFontFamily(fontFamily)}
        options={FONT_FAMILIES.map((family) => [family.id, family.name])}
        oninput={(value) => onfontfamily(value)}
      />
      <div class="typeface-current">
        <span class="typeface-sample" style={`font-family: "${secondaryFamily.cssFamily}", sans-serif`}>82%</span>
        <span class="typeface-copy"><strong>{secondaryFamily.name}</strong><small>Secondary · {secondaryFamily.tone}</small></span>
        <span class="typeface-indicator" aria-hidden="true"></span>
      </div>
      <Field
        label="Secondary font"
        value={normalizeFontFamily(fontFamilySecondary ?? fontFamily)}
        options={FONT_FAMILIES.map((family) => [family.id, family.name])}
        oninput={(value) => onfontfamilysecondary(value)}
      />
    </section>
  {/if}

  {#if element}
    <div class="selection-chip">
      <span class="selection-glyph">{TYPE_NAMES[element.type].slice(0, 1)}</span>
      <div><strong>{TYPE_NAMES[element.type]}</strong><span>Selected layer</span></div>
    </div>

    {#if DYNAMIC_TYPES.has(element.type)}
      <section class="inspector-group representation-group">
        <div class="group-heading">
          <h3>Representation</h3>
          <p>Choose how this live value appears on the watch.</p>
        </div>
        <RepresentationPicker
          type={element.type}
          value={element.representation ?? "value"}
          onselect={(value) => update("representation", value, true)}
        />
        {#if element.representation === "progress-bar" && element.type !== "battery"}
          <div class="representation-target">
            <Field
              label={element.type === "heart-rate" ? "Scale maximum" : element.type === "distance" ? "Goal distance" : "Goal"}
              type="number"
              value={element.progressMax ?? defaultProgressMax(element.type)}
              min={1}
              max={1000000}
              oninput={(value) => update("progressMax", value)}
              onchange={(value) => update("progressMax", value, true)}
            />
          </div>
        {/if}
      </section>
    {/if}

    {#if element.type === "icon"}
      <section class="inspector-group icon-visual-group">
        <h3>Icon</h3>
        <IconPicker
          icon={element.icon}
          style={element.style ?? "filled"}
          color={element.color}
          onicon={(value) => update("icon", value, true)}
          onstyle={(value) => update("style", value, true)}
        />
        <div class="field-grid two icon-tuning-fields">
          <Field label="Size" type="number" value={element.size} min={12} max={96} oninput={(value) => update("size", value)} onchange={(value) => update("size", value, true)} />
          <Field label="Color" type="color" value={element.color} oninput={(value) => update("color", value.toUpperCase())} onchange={(value) => update("color", value.toUpperCase(), true)} />
        </div>
      </section>
    {/if}

    <section class="inspector-group">
      <h3>Position</h3>
      <div class="field-grid two">
        <Field label="X" type="number" value={element.x} min={0} max={319} oninput={(value) => update("x", value)} onchange={(value) => update("x", value, true)} />
        <Field label="Y" type="number" value={element.y} min={0} max={359} oninput={(value) => update("y", value)} onchange={(value) => update("y", value, true)} />
      </div>
      <div class="align-controls" aria-label="Align selected layer to canvas">
        {#each [["left", "align-left", "Left"], ["center-x", "align-center", "Center"], ["right", "align-right", "Right"], ["top", "align-top", "Top"], ["center-y", "align-middle", "Middle"], ["bottom", "align-bottom", "Bottom"]] as [direction, icon, label]}
          <button type="button" title={`Align ${label.toLowerCase()} to canvas`} aria-label={`Align ${label.toLowerCase()} to canvas`} onclick={() => onalign(direction)} use:tactile><Icon name={icon} size={15} /><span>{label}</span></button>
        {/each}
      </div>
    </section>

    {#if element.type === "rectangle"}
      <section class="inspector-group">
        <h3>Geometry</h3>
        <div class="field-grid two">
          <Field label="Width" type="number" value={element.width} min={1} max={320} oninput={(value) => update("width", value)} onchange={(value) => update("width", value, true)} />
          <Field label="Height" type="number" value={element.height} min={1} max={360} oninput={(value) => update("height", value)} onchange={(value) => update("height", value, true)} />
          <Field label="Radius" type="number" value={element.cornerRadius} min={0} max={160} oninput={(value) => update("cornerRadius", value)} onchange={(value) => update("cornerRadius", value, true)} />
          <Field label="Fill" type="color" value={element.fillColor} oninput={(value) => update("fillColor", value.toUpperCase())} onchange={(value) => update("fillColor", value.toUpperCase(), true)} />
        </div>
      </section>
    {:else if element.type === "ellipse"}
      <section class="inspector-group">
        <h3>Geometry</h3>
        <div class="field-grid two">
          <Field label="Horizontal radius" type="number" value={element.radiusX} min={1} max={159} oninput={(value) => update("radiusX", value)} onchange={(value) => update("radiusX", value, true)} />
          <Field label="Vertical radius" type="number" value={element.radiusY} min={1} max={179} oninput={(value) => update("radiusY", value)} onchange={(value) => update("radiusY", value, true)} />
          <Field label="Fill" type="color" value={element.fillColor} oninput={(value) => update("fillColor", value.toUpperCase())} onchange={(value) => update("fillColor", value.toUpperCase(), true)} />
        </div>
      </section>
    {:else if element.type === "line"}
      <section class="inspector-group">
        <h3>Line</h3>
        <div class="field-grid two">
          <Field label="End X" type="number" value={element.endX} min={0} max={319} oninput={(value) => update("endX", value)} onchange={(value) => update("endX", value, true)} />
          <Field label="End Y" type="number" value={element.endY} min={0} max={359} oninput={(value) => update("endY", value)} onchange={(value) => update("endY", value, true)} />
          <Field label="Thickness" type="number" value={element.thickness} min={1} max={12} oninput={(value) => update("thickness", value)} onchange={(value) => update("thickness", value, true)} />
          <Field label="Color" type="color" value={element.color} oninput={(value) => update("color", value.toUpperCase())} onchange={(value) => update("color", value.toUpperCase(), true)} />
        </div>
      </section>
    {:else if !isShapeElement(element)}
      {#if element.type === "label"}
        <section class="inspector-group">
          <h3>Content</h3>
          <Field label="Text" value={element.text} maxlength={48} oninput={(value) => update("text", value)} onchange={(value) => update("text", value, true)} />
        </section>
      {/if}

      <section class="inspector-group">
        <h3>Typography</h3>
        <div class="field-grid">
          <p class="font-role-note">{FONT_ROLE_DETAILS[selectedRole].name} settings apply to every {FONT_ROLE_DETAILS[selectedRole].name.toLowerCase()} layer.</p>
          <div class="field-grid two">
            <Field
              label="Font height"
              value={fontHeights[selectedRole]}
              options={FONT_HEIGHT_OPTIONS[selectedRole].map((height) => [height, `${height} px`])}
              oninput={(height) => onfontheight(selectedRole, Number(height))}
            />
            <Field
              label="Letter spacing"
              type="number"
              value={letterSpacing[selectedRole]}
              min={-2}
              max={6}
              oninput={(spacing) => onletterspacing(selectedRole, spacing)}
              onchange={(spacing) => onletterspacing(selectedRole, spacing)}
            />
          </div>
          {#if element.type === "label"}
            <div class="field-grid two">
              <Field label="Wrap width" type="number" value={element.maxWidth} min={20} max={320} oninput={(value) => update("maxWidth", value)} onchange={(value) => update("maxWidth", value, true)} />
              <Field label="Line height" type="number" value={element.lineHeight} min={8} max={80} oninput={(value) => update("lineHeight", value)} onchange={(value) => update("lineHeight", value, true)} />
            </div>
          {/if}
          <div class="field-grid two">
            <Field label="Align" value={element.align} options={ALIGN_OPTIONS} oninput={(value) => update("align", value, true)} />
            <Field label="Color" type="color" value={element.color} oninput={(value) => update("color", value.toUpperCase())} onchange={(value) => update("color", value.toUpperCase(), true)} />
          </div>
        </div>
      </section>

      {#if element.type === "time"}
        <section class="inspector-group">
          <h3>Clock</h3>
          <Field label="Format" value={element.format} options={[["device", "Use device"], ["hour12", "12 hour"], ["hour24", "24 hour"]]} oninput={(value) => update("format", value, true)} />
          <label class="switch-field">
            <span><strong>Show seconds</strong><small>Hidden in always-on mode</small></span>
            <input type="checkbox" checked={element.showSeconds} onchange={(event) => update("showSeconds", event.currentTarget.checked, true)} />
            <span class="switch-track"></span>
          </label>
        </section>
      {/if}
      {#if element.type === "distance"}
        <section class="inspector-group">
          <h3>Distance</h3>
          <Field label="Unit" value={element.unit} options={[["kilometers", "Kilometers"], ["miles", "Miles"]]} oninput={(value) => update("unit", value, true)} />
        </section>
      {/if}
    {/if}

    <section class="inspector-group order-group">
      <h3>Layer order</h3>
      <div class="segmented-actions">
        <button type="button" onclick={() => onmove(1)} use:tactile><Icon name="chevron-up" size={16} />Forward</button>
        <button type="button" onclick={() => onmove(-1)} use:tactile><Icon name="chevron-down" size={16} />Backward</button>
      </div>
    </section>
  {:else}
    <div class="empty-inspector">
      <div class="empty-icon"><Icon name="sliders" size={22} /></div>
      <strong>Select a layer</strong>
      <p>Pick an item on the canvas or in the layer list to edit its properties.</p>
    </div>
  {/if}
</section>
