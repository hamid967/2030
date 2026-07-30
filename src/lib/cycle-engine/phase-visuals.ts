import type { CyclePhase } from "./types";

/**
 * Visual identity per cycle phase (Stardust-style strong personality) using the
 * Warif brand tokens only. Colors are decorative and are always paired with a
 * text label — color alone never conveys a health state (blueprint section 4).
 */
export const phaseColorVar: Record<CyclePhase, string> = {
  menstruation: "var(--warif-rose)",
  follicular: "var(--warif-sage)",
  ovulation: "var(--warif-primary)",
  luteal: "var(--warif-lavender)",
};

export const phaseTintClass: Record<CyclePhase, string> = {
  menstruation: "bg-rose/10",
  follicular: "bg-sage/10",
  ovulation: "bg-primary/10",
  luteal: "bg-lavender/15",
};
