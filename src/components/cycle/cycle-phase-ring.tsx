import { useTranslations } from "next-intl";
import type { CyclePhase } from "@/lib/cycle-engine";
import { phaseColorVar } from "@/lib/cycle-engine/phase-visuals";

interface CyclePhaseRingProps {
  cycleDay: number;
  cycleLength: number;
  phase: CyclePhase;
}

const phaseNameKey: Record<CyclePhase, string> = {
  menstruation: "menstruationName",
  follicular: "follicularName",
  ovulation: "ovulationName",
  luteal: "lutealName",
};

/**
 * A circular progress ring showing the current day within the cycle, coloured
 * by phase. Progress is presented via both the arc and the numeric label so it
 * is never conveyed by colour alone.
 */
export function CyclePhaseRing({
  cycleDay,
  cycleLength,
  phase,
}: CyclePhaseRingProps) {
  const t = useTranslations("Phase");
  const tToday = useTranslations("Today");

  const radius = 84;
  const stroke = 12;
  const circumference = 2 * Math.PI * radius;
  const progress = Math.min(cycleDay / cycleLength, 1);
  const color = phaseColorVar[phase];

  return (
    <div
      className="relative flex size-52 items-center justify-center"
      role="img"
      aria-label={`${tToday("dayLabel", { day: cycleDay })} — ${t(
        phaseNameKey[phase],
      )}`}
    >
      <svg viewBox="0 0 200 200" className="size-52 -rotate-90">
        <circle
          cx="100"
          cy="100"
          r={radius}
          fill="none"
          stroke="var(--warif-border)"
          strokeWidth={stroke}
        />
        <circle
          cx="100"
          cy="100"
          r={radius}
          fill="none"
          stroke={color}
          strokeWidth={stroke}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={circumference * (1 - progress)}
        />
      </svg>
      <div className="absolute flex flex-col items-center text-center">
        <span className="text-5xl font-bold text-text">{cycleDay}</span>
        <span className="mt-1 max-w-28 text-sm font-medium text-muted">
          {t(phaseNameKey[phase])}
        </span>
      </div>
    </div>
  );
}
