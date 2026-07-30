import { addDays, diffInDays } from "./index";

export const PREDICT_ENGINE_VERSION = "predict@0.1.0";

export type PredictionConfidence = "insufficient" | "low" | "medium" | "high";

export interface PredictionInput {
  /** ISO date strings (YYYY-MM-DD) of observed period starts. */
  periodStarts: string[];
  /** Local "today" (YYYY-MM-DD) — injected, never read from the clock. */
  today: string;
  /** ISO timestamp when this prediction was generated. */
  generatedAt: string;
  algorithmVersion?: string;
}

export interface CyclePrediction {
  algorithmVersion: string;
  generatedAt: string;
  confidence: PredictionConfidence;
  /** Number of complete cycles (intervals between starts) the model used. */
  sampleCount: number;
  /** Number of logged period starts. */
  cyclesUsed: number;
  medianCycleLength: number | null;
  /** Latest period start the prediction is based on. */
  dataThroughDate: string | null;
  estimatedDate: string | null;
  earliestDate: string | null;
  latestDate: string | null;
  isEstimate: true;
}

function median(values: number[]): number {
  const sorted = [...values].sort((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0
    ? (sorted[mid - 1] + sorted[mid]) / 2
    : sorted[mid];
}

/** Median absolute deviation — a robust spread measure. */
function mad(values: number[], center: number): number {
  return median(values.map((v) => Math.abs(v - center)));
}

function uniqueSortedDates(dates: string[]): string[] {
  return Array.from(new Set(dates)).sort();
}

/**
 * Predict the next period as an ESTIMATE with an explicit confidence level.
 *
 * Pure and deterministic (no clock access). Uses the median cycle length and
 * MAD over a rolling window of recent cycles. All outputs are estimates and
 * must never be presented as diagnosis or contraception.
 */
export function predictCycle(input: PredictionInput): CyclePrediction {
  const algorithmVersion = input.algorithmVersion ?? PREDICT_ENGINE_VERSION;
  const starts = uniqueSortedDates(
    input.periodStarts.filter((d) => /^\d{4}-\d{2}-\d{2}$/.test(d)),
  );

  const base: CyclePrediction = {
    algorithmVersion,
    generatedAt: input.generatedAt,
    confidence: "insufficient",
    sampleCount: 0,
    cyclesUsed: starts.length,
    medianCycleLength: null,
    dataThroughDate: starts.at(-1) ?? null,
    estimatedDate: null,
    earliestDate: null,
    latestDate: null,
    isEstimate: true,
  };

  if (starts.length < 2) {
    return base;
  }

  // Rolling window: use at most the 12 most recent cycles.
  const recent = starts.slice(-13);
  const intervals: number[] = [];
  for (let i = 1; i < recent.length; i++) {
    intervals.push(diffInDays(recent[i - 1], recent[i]));
  }
  const valid = intervals.filter((n) => n >= 15 && n <= 60);
  if (valid.length === 0) {
    return base;
  }

  const med = Math.round(median(valid));
  const spread = mad(valid, med);
  const sampleCount = valid.length;

  let confidence: PredictionConfidence;
  if (sampleCount <= 2) {
    confidence = "low";
  } else if (sampleCount <= 5) {
    confidence = spread <= 2 ? "medium" : "low";
  } else {
    confidence = spread <= 1 ? "high" : spread <= 3 ? "medium" : "low";
  }

  // Range widens when data is noisier / confidence lower.
  const marginByConfidence: Record<PredictionConfidence, number> = {
    insufficient: 7,
    low: 6,
    medium: 3,
    high: 2,
  };
  const margin = Math.max(marginByConfidence[confidence], Math.round(spread));

  const lastStart = recent.at(-1)!;
  // Roll forward from the last start in median-length steps until after today.
  let estimated = addDays(lastStart, med);
  let guard = 0;
  while (diffInDays(estimated, input.today) >= 0 && guard < 60) {
    estimated = addDays(estimated, med);
    guard++;
  }

  return {
    ...base,
    confidence,
    sampleCount,
    medianCycleLength: med,
    estimatedDate: estimated,
    earliestDate: addDays(estimated, -margin),
    latestDate: addDays(estimated, margin),
  };
}
