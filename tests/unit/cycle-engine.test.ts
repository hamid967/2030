import { describe, expect, it } from "vitest";
import { computeCycleStatus, CYCLE_ENGINE_VERSION } from "@/lib/cycle-engine";

const base = { cycleLength: 28, periodLength: 5 };

describe("computeCycleStatus", () => {
  it("day 1 of the period is menstruation", () => {
    const s = computeCycleStatus(
      { ...base, lastPeriodStart: "2026-01-01" },
      "2026-01-01",
    );
    expect(s.cycleDay).toBe(1);
    expect(s.phase).toBe("menstruation");
    expect(s.daysUntilNextPeriod).toBe(28);
    expect(s.nextPeriodStart).toBe("2026-01-29");
    expect(s.isEstimate).toBe(true);
    expect(s.algorithmVersion).toBe(CYCLE_ENGINE_VERSION);
  });

  it("last day of bleeding is still menstruation", () => {
    const s = computeCycleStatus(
      { ...base, lastPeriodStart: "2026-01-01" },
      "2026-01-05",
    );
    expect(s.cycleDay).toBe(5);
    expect(s.phase).toBe("menstruation");
  });

  it("mid follicular phase after the period", () => {
    const s = computeCycleStatus(
      { ...base, lastPeriodStart: "2026-01-01" },
      "2026-01-08",
    );
    expect(s.cycleDay).toBe(8);
    expect(s.phase).toBe("follicular");
  });

  it("estimated ovulation day falls in the ovulation window", () => {
    // 28-day cycle → ovulation estimate on day 14.
    const s = computeCycleStatus(
      { ...base, lastPeriodStart: "2026-01-01" },
      "2026-01-14",
    );
    expect(s.cycleDay).toBe(14);
    expect(s.ovulationEstimateDay).toBe(14);
    expect(s.phase).toBe("ovulation");
  });

  it("luteal phase in the second half", () => {
    const s = computeCycleStatus(
      { ...base, lastPeriodStart: "2026-01-01" },
      "2026-01-22",
    );
    expect(s.cycleDay).toBe(22);
    expect(s.phase).toBe("luteal");
  });

  it("wraps into the next cycle", () => {
    const s = computeCycleStatus(
      { ...base, lastPeriodStart: "2026-01-01" },
      "2026-01-29",
    );
    expect(s.cycleDay).toBe(1);
    expect(s.phase).toBe("menstruation");
  });

  it("produces a widened next-period range around the estimate", () => {
    const s = computeCycleStatus(
      { ...base, lastPeriodStart: "2026-01-01" },
      "2026-01-10",
    );
    expect(s.nextPeriodRange.earliest < s.nextPeriodStart).toBe(true);
    expect(s.nextPeriodRange.latest > s.nextPeriodStart).toBe(true);
  });

  it("clamps out-of-range inputs to safe bounds", () => {
    const s = computeCycleStatus(
      { lastPeriodStart: "2026-01-01", cycleLength: 999, periodLength: 999 },
      "2026-01-02",
    );
    expect(s.cycleLength).toBeLessThanOrEqual(45);
    expect(s.cycleLength).toBeGreaterThanOrEqual(21);
  });

  it("rejects a future last-period date", () => {
    expect(() =>
      computeCycleStatus(
        { ...base, lastPeriodStart: "2026-02-01" },
        "2026-01-01",
      ),
    ).toThrow();
  });
});
