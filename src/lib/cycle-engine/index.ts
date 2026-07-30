import type { CyclePhase, CycleProfile, CycleStatus } from "./types";

export * from "./types";

export const CYCLE_ENGINE_VERSION = "cycle-engine@0.2.0";

/** Luteal phase is biologically fairly constant (~14 days). */
const LUTEAL_LENGTH = 14;
/** How many days before/after estimated ovulation to treat as fertile. */
const FERTILE_BEFORE = 5;
const FERTILE_AFTER = 1;

const MS_PER_DAY = 24 * 60 * 60 * 1000;

function clamp(value: number, min: number, max: number): number {
  return Math.min(Math.max(value, min), max);
}

export function normalizeCycleLength(value: number): number {
  return clamp(Math.round(value), 21, 45);
}

export function normalizePeriodLength(value: number): number {
  return clamp(Math.round(value), 1, 10);
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

export function addDays(iso: string, days: number): string {
  return toIsoDate(new Date(parseUtcDate(iso).getTime() + days * MS_PER_DAY));
}

export function diffInDays(from: string, to: string): number {
  return Math.floor(
    (parseUtcDate(to).getTime() - parseUtcDate(from).getTime()) / MS_PER_DAY,
  );
}

interface FertileWindow {
  ovulationDay: number;
  startDay: number;
  endDay: number;
}

function fertileWindow(cycleLength: number): FertileWindow {
  const ovulationDay = clamp(cycleLength - LUTEAL_LENGTH, 1, cycleLength);
  return {
    ovulationDay,
    startDay: clamp(ovulationDay - FERTILE_BEFORE, 1, cycleLength),
    endDay: clamp(ovulationDay + FERTILE_AFTER, 1, cycleLength),
  };
}

export function phaseForCycleDay(
  cycleDay: number,
  periodLength: number,
  cycleLength: number,
): CyclePhase {
  const fw = fertileWindow(cycleLength);
  if (cycleDay <= periodLength) return "menstruation";
  if (cycleDay >= fw.startDay && cycleDay <= fw.endDay) return "ovulation";
  if (cycleDay < fw.startDay) return "follicular";
  return "luteal";
}

export interface DayClassification {
  cycleDay: number;
  phase: CyclePhase;
  isPeriod: boolean;
  isFertile: boolean;
  isOvulation: boolean;
}

/**
 * Classify any calendar date (past, present or future) against the cycle
 * pattern. Used by the calendar; future days are projections/estimates.
 */
export function getDayClassification(
  profile: CycleProfile,
  dateIso: string,
): DayClassification {
  const cycleLength = normalizeCycleLength(profile.cycleLength);
  const periodLength = normalizePeriodLength(profile.periodLength);

  const daysSince = diffInDays(profile.lastPeriodStart, dateIso);
  // Positive modulo so dates before the last period project backwards too.
  const daysIntoCycle = ((daysSince % cycleLength) + cycleLength) % cycleLength;
  const cycleDay = daysIntoCycle + 1;

  const fw = fertileWindow(cycleLength);

  return {
    cycleDay,
    phase: phaseForCycleDay(cycleDay, periodLength, cycleLength),
    isPeriod: cycleDay <= periodLength,
    isFertile: cycleDay >= fw.startDay && cycleDay <= fw.endDay,
    isOvulation: cycleDay === fw.ovulationDay,
  };
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
  const cycleLength = normalizeCycleLength(profile.cycleLength);
  const periodLength = normalizePeriodLength(profile.periodLength);

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

  const fw = fertileWindow(cycleLength);

  // Wider ranges for longer cycles, since variability grows with length.
  const margin = clamp(Math.round(cycleLength * 0.07), 1, 4);

  return {
    algorithmVersion: CYCLE_ENGINE_VERSION,
    generatedAt: new Date().toISOString(),
    cycleDay,
    cycleLength,
    phase: phaseForCycleDay(cycleDay, periodLength, cycleLength),
    daysUntilNextPeriod,
    nextPeriodStart,
    nextPeriodRange: {
      earliest: addDays(nextPeriodStart, -margin),
      latest: addDays(nextPeriodStart, margin),
    },
    ovulationEstimateDay: fw.ovulationDay,
    fertileWindowEstimate: { startDay: fw.startDay, endDay: fw.endDay },
    isEstimate: true,
  };
}
