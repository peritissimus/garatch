<script>
  import { createDialKit, DialRoot } from "dialkit/svelte";
  let { ontune } = $props();

  const params = createDialKit("Garatch UI", {
    panelRadius: [14, 8, 24],
    leftRail: [232, 210, 280],
    rightRail: [296, 270, 340],
    stageGlow: [0.12, 0, 0.3, 0.01],
    hoverLift: [-1, -4, 0, 0.25],
    pressScale: [0.96, 0.9, 1, 0.01],
    springStiffness: [520, 200, 900, 10],
    springDamping: [36, 15, 60],
    accent: "#72D6B2",
  }, { id: "garatch-ui-tuning", persist: true });

  $effect(() => {
    ontune({
      panelRadius: params.panelRadius,
      leftRail: params.leftRail,
      rightRail: params.rightRail,
      stageGlow: params.stageGlow,
      hoverLift: params.hoverLift,
      pressScale: params.pressScale,
      springStiffness: params.springStiffness,
      springDamping: params.springDamping,
      accent: params.accent,
    });
  });
</script>

<DialRoot position="bottom-right" defaultOpen={false} theme="dark" />
