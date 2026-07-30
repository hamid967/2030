import type { CyclePhase, CycleProfile, CycleStatus } from "./types";

export * from "./types";

export const CYCLE_ENGINE_VERSION = "cycle-engine@0.1.0";

/** Luteal phase is biologically fairly constant (~14 days). */
const LUTEAL_LENGTH = 14;
/** How many days before/after estimated ovulation to treat as fertile. */
const FERTILE_BEFORE = 5;
const FERTILE_AFTER = 1;

const MS_PER_DAY = 24 * 60 * 60 * 1000;

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

/** Parse an ISO date-only string as UTC midnight (timezone-safe). */
function parseUtcDate(iso: string): Date {
  const [y, m, d] = iso.split("-").map(Number);
  if (!y || !m || !d) {
    throw new Error(`Invalid ISO date: "${iso}"`);
  }
  return new Date(Date.UTC(y, m - 1, d));
}

function toIsoDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function addDays(iso: string, days: number): string {
  return toIsoDate(new Date(parseUtcDate(iso).getTime() + days * MS_PER_DAY));
}

function diffInDays(from: string, to: string): number {
  return Math.floor(
    (parseUtcDate(to).getTime() - parseUtcDate(from).getTime()) / MS_PER_DAY,
  );
}

function determinePhase(
  cycleDay: number,
  periodLength: number,
  fertile: { startDay: number; endDay: number },
): CyclePhase {
  if (cycleDay <= periodLength) return "menstruation";
  if (cycleDay >= fertile.startDay && cycleDay <= fertile.endDay) {
    return "ovulation";
  }
  if (cycleDay < fertile.startDay) return "follicular";
  return "luteal";
}

/**
 * Compute the current cycle status from a self-reported profile.
 *
 * Pure and deterministic: `today` is injected so the result is testable and
 * never depends on ambient time. All outputs are estimates.
 */
export function computeCycleStatus(
  profile: CycleProfile,
  today: string,
): CycleStatus {
  const cycleLength = clamp(Math.round(profile.cycleLength), 21, 45);
  const periodLength = clamp(Math.round(profile.periodLength), 1, 10);

  const daysSince = diffInDays(profile.lastPeriodStart, today);
  if (daysSince < 0) {
    throw new Error("lastPeriodStart cannot be in the future");
  }

  const cyclesElapsed = Math.floor(daysSince / cycleLength);
  const daysIntoCycle = daysSince % cycleLength;
  const cycleDay = daysIntoCycle + 1;

  const nextPeriodStart = addDays(
    profile.lastPeriodStart,
    (cyclesElapsed + 1) * cycleLength,
  );
  const daysUntilNextPeriod = cycleLength - daysIntoCycle;

  const ovulationEstimateDay = clamp(
    cycleLength - LUTEAL_LENGTH,
    1,
    cycleLength,
  );
  const fertileWindowEstimate = {
    startDay: clamp(ovulationEstimateDay - FERTILE_BEFORE, 1, cycleLength),
    endDay: clamp(ovulationEstimateDay + FERTILE_AFTER, 1, cycleLength),
  };

  // Wider ranges for longer cycles, since variability grows with length.
  const margin = clamp(Math.round(cycleLength * 0.07), 1, 4);

  return {
    algorithmVersion: CYCLE_ENGINE_VERSION,
    generatedAt: new Date().toISOString(),
    cycleDay,
    cycleLength,
    phase: determinePhase(cycleDay, periodLength, fertileWindowEstimate),
    daysUntilNextPeriod,
    nextPeriodStart,
    nextPeriodRange: {
      earliest: addDays(nextPeriodStart, -margin),
      latest: addDays(nextPeriodStart, margin),
    },
    ovulationEstimateDay,
    fertileWindowEstimate,
    isEstimate: true,
  };
}
