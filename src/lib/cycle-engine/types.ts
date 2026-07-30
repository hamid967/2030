/**
 * Cycle engine types (blueprint sections 8 & 13).
 *
 * IMPORTANT: everything this engine produces is an ESTIMATE derived from
 * self-reported averages. It must never be presented as a diagnosis, and the
 * fertile-window estimate must never be presented as a contraception method.
 */

export type CyclePhase = "menstruation" | "follicular" | "ovulation" | "luteal";

export interface CycleProfile {
  /** First day of the most recent period, as an ISO date string (YYYY-MM-DD). */
  lastPeriodStart: string;
  /** Typical full cycle length in days. */
  cycleLength: number;
  /** Typical period (bleeding) length in days. */
  periodLength: number;
  /**
   * History of observed period start dates (YYYY-MM-DD), ascending. Used by the
   * prediction engine to compute confidence. Optional for backward
   * compatibility — defaults to `[lastPeriodStart]` when absent.
   */
  periodStarts?: string[];
}

export interface DayRange {
  /** 1-based day-of-cycle. */
  startDay: number;
  endDay: number;
}

export interface CycleStatus {
  /** Stored so results can be re-interpreted later (blueprint section 8). */
  algorithmVersion: string;
  generatedAt: string;
  /** 1-based current day of the cycle. */
  cycleDay: number;
  cycleLength: number;
  phase: CyclePhase;
  daysUntilNextPeriod: number;
  /** ISO date of the estimated next period start. */
  nextPeriodStart: string;
  /** Widened range for the next period, since predictions are estimates. */
  nextPeriodRange: { earliest: string; latest: string };
  /** 1-based estimated ovulation day. */
  ovulationEstimateDay: number;
  /** Estimated fertile window (NOT a contraception method). */
  fertileWindowEstimate: DayRange;
  /** Always true — outputs are estimates, never certainties. */
  isEstimate: true;
}
