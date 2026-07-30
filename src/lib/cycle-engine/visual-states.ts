import type { CyclePhase } from "./types";

/**
 * Warif's optional visual "states" — a calm, non-diagnostic framing of the
 * cycle phase (blueprint / Saudi prompt section 2). These are NOT medical
 * classifications and NEVER describe the user's mood or personality. Users can
 * turn the visual personas off in settings.
 */
export type VisualState = "stillness" | "renewal" | "balance" | "containment";

export const phaseToVisualState: Record<CyclePhase, VisualState> = {
  menstruation: "stillness", // السكون — أيام الدورة، راحة وهدوء
  follicular: "renewal", // التجدد — الأيام التالية، بداية خفيفة
  ovulation: "balance", // التوازن — منتصف الدورة التقديري
  luteal: "containment", // الاحتواء — الأيام السابقة، مساحة وعناية
};

/** CSS custom property (semantic token) for each phase's accent color. */
export const phaseTokenVar: Record<CyclePhase, string> = {
  menstruation: "var(--phase-menstrual)",
  follicular: "var(--phase-follicular)",
  ovulation: "var(--phase-ovulation-estimate)",
  luteal: "var(--phase-luteal)",
};
