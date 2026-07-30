import { describe, expect, it } from "vitest";
import { predictCycle } from "@/lib/cycle-engine/predict";

const generatedAt = "2026-06-20T00:00:00.000Z";

describe("predictCycle", () => {
  it("returns insufficient with fewer than two starts", () => {
    const p = predictCycle({
      periodStarts: ["2026-01-01"],
      today: "2026-01-10",
      generatedAt,
    });
    expect(p.confidence).toBe("insufficient");
    expect(p.estimatedDate).toBeNull();
    expect(p.cyclesUsed).toBe(1);
  });

  it("is low confidence with a single interval", () => {
    const p = predictCycle({
      periodStarts: ["2026-01-01", "2026-01-29"],
      today: "2026-02-10",
      generatedAt,
    });
    expect(p.confidence).toBe("low");
    expect(p.medianCycleLength).toBe(28);
    expect(p.estimatedDate).not.toBeNull();
  });

  it("is high confidence for a long regular history", () => {
    const starts = [
      "2026-01-01",
      "2026-01-29",
      "2026-02-26",
      "2026-03-26",
      "2026-04-23",
      "2026-05-21",
      "2026-06-18",
    ];
    const p = predictCycle({
      periodStarts: starts,
      today: "2026-06-20",
      generatedAt,
    });
    expect(p.medianCycleLength).toBe(28);
    expect(p.sampleCount).toBe(6);
    expect(p.confidence).toBe("high");
    // Next start rolls past today.
    expect(p.estimatedDate).toBe("2026-07-16");
    expect(p.earliestDate! < p.estimatedDate!).toBe(true);
    expect(p.latestDate! > p.estimatedDate!).toBe(true);
  });

  it("is medium confidence with small variability", () => {
    // intervals 27, 29, 28 -> median 28, MAD 1
    const p = predictCycle({
      periodStarts: ["2026-01-01", "2026-01-28", "2026-02-26", "2026-03-26"],
      today: "2026-03-28",
      generatedAt,
    });
    expect(p.medianCycleLength).toBe(28);
    expect(p.sampleCount).toBe(3);
    expect(p.confidence).toBe("medium");
  });

  it("ignores unsorted duplicates and keeps outputs as estimates", () => {
    const p = predictCycle({
      periodStarts: ["2026-01-29", "2026-01-01", "2026-01-29"],
      today: "2026-02-10",
      generatedAt,
    });
    expect(p.cyclesUsed).toBe(2);
    expect(p.isEstimate).toBe(true);
  });
});
