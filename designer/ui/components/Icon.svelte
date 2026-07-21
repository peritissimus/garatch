<script>
  import AlignBottomSimpleIcon from "phosphor-svelte/lib/AlignBottomSimpleIcon";
  import AlignCenterHorizontalSimpleIcon from "phosphor-svelte/lib/AlignCenterHorizontalSimpleIcon";
  import AlignCenterVerticalSimpleIcon from "phosphor-svelte/lib/AlignCenterVerticalSimpleIcon";
  import AlignLeftSimpleIcon from "phosphor-svelte/lib/AlignLeftSimpleIcon";
  import AlignRightSimpleIcon from "phosphor-svelte/lib/AlignRightSimpleIcon";
  import AlignTopSimpleIcon from "phosphor-svelte/lib/AlignTopSimpleIcon";
  import CaretDownIcon from "phosphor-svelte/lib/CaretDownIcon";
  import CaretUpIcon from "phosphor-svelte/lib/CaretUpIcon";
  import CheckIcon from "phosphor-svelte/lib/CheckIcon";
  import CommandIcon from "phosphor-svelte/lib/CommandIcon";
  import CopyIcon from "phosphor-svelte/lib/CopyIcon";
  import DownloadSimpleIcon from "phosphor-svelte/lib/DownloadSimpleIcon";
  import GridFourIcon from "phosphor-svelte/lib/GridFourIcon";
  import MoonIcon from "phosphor-svelte/lib/MoonIcon";
  import PlusIcon from "phosphor-svelte/lib/PlusIcon";
  import SlidersHorizontalIcon from "phosphor-svelte/lib/SlidersHorizontalIcon";
  import SparkleIcon from "phosphor-svelte/lib/SparkleIcon";
  import SquaresFourIcon from "phosphor-svelte/lib/SquaresFourIcon";
  import StackIcon from "phosphor-svelte/lib/StackIcon";
  import TrashIcon from "phosphor-svelte/lib/TrashIcon";
  import WarningIcon from "phosphor-svelte/lib/WarningIcon";
  import XIcon from "phosphor-svelte/lib/XIcon";

  let { name, size = 18, weight = "regular" } = $props();

  const icons = {
    download: DownloadSimpleIcon,
    check: CheckIcon,
    grid: GridFourIcon,
    moon: MoonIcon,
    trash: TrashIcon,
    copy: CopyIcon,
    plus: PlusIcon,
    alert: WarningIcon,
    "chevron-up": CaretUpIcon,
    "chevron-down": CaretDownIcon,
    layers: StackIcon,
    sliders: SlidersHorizontalIcon,
    sparkles: SparkleIcon,
    command: CommandIcon,
    close: XIcon,
    templates: SquaresFourIcon,
    "align-left": AlignLeftSimpleIcon,
    "align-center": AlignCenterHorizontalSimpleIcon,
    "align-right": AlignRightSimpleIcon,
    "align-top": AlignTopSimpleIcon,
    "align-middle": AlignCenterVerticalSimpleIcon,
    "align-bottom": AlignBottomSimpleIcon,
  };

  let Glyph = $derived(icons[name] ?? SparkleIcon);
</script>

<Glyph class="icon" {size} {weight} color="currentColor" aria-hidden="true" />
