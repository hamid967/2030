import type { CyclePhase } from "./types";

/**
 * Visual identity per cycle phase (Stardust-style strong personality) using the
 * Warif brand tokens only. Colors are decorative and are always paired with a
 * text label — color alone never conveys a health state (blueprint section 4).
 */
export const phaseColorVar: Record<CyclePhase, string> = {
  menstruation: "var(--phase-menstrual)",
  follicular: "var(--phase-follicular)",
  ovulation: "var(--phase-ovulation-estimate)",
  luteal: "var(--phase-luteal)",
};

export const phaseTintClass: Record<CyclePhase, string> = {
  menstruation: "bg-stillness/15",
  follicular: "bg-renewal/15",
  ovulation: "bg-balance/15",
  luteal: "bg-containment/15",
};
