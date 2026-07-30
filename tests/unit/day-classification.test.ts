import { describe, expect, it } from "vitest";
import { getDayClassification } from "@/lib/cycle-engine";

const profile = {
  lastPeriodStart: "2026-01-01",
  cycleLength: 28,
  periodLength: 5,
};

describe("getDayClassification", () => {
  it("marks the first period day", () => {
    const c = getDayClassification(profile, "2026-01-01");
    expect(c.cycleDay).toBe(1);
    expect(c.isPeriod).toBe(true);
    expect(c.phase).toBe("menstruation");
  });

  it("marks the ovulation day as fertile ovulation", () => {
    const c = getDayClassification(profile, "2026-01-14");
    expect(c.cycleDay).toBe(14);
    expect(c.isOvulation).toBe(true);
    expect(c.isFertile).toBe(true);
    expect(c.phase).toBe("ovulation");
  });

  it("wraps into the next cycle", () => {
    const c = getDayClassification(profile, "2026-01-29");
    expect(c.cycleDay).toBe(1);
    expect(c.isPeriod).toBe(true);
  });

  it("projects backwards for dates before the last period", () => {
    const c = getDayClassification(profile, "2025-12-31");
    expect(c.cycleDay).toBe(28);
    expect(c.isPeriod).toBe(false);
    expect(c.phase).toBe("luteal");
  });
});
