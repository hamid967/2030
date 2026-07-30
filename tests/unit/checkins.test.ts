import { describe, expect, it } from "vitest";
import { lastNDays, averages, type CheckInMap } from "@/lib/checkins";

const map: CheckInMap = {
  "2026-01-05": { date: "2026-01-05", mood: 4, energy: 2, sleep: 3, flow: 0 },
  "2026-01-07": { date: "2026-01-07", mood: 2, energy: 4, sleep: 5, flow: 1 },
};

describe("lastNDays", () => {
  it("returns n days oldest-first ending on today", () => {
    const days = lastNDays(map, "2026-01-07", 7);
    expect(days).toHaveLength(7);
    expect(days[0].date).toBe("2026-01-01");
    expect(days[6].date).toBe("2026-01-07");
  });

  it("attaches entries where present and null otherwise", () => {
    const days = lastNDays(map, "2026-01-07", 7);
    expect(days[6].entry?.sleep).toBe(5);
    expect(days[0].entry).toBeNull();
  });
});

describe("averages", () => {
  it("averages only present entries", () => {
    const days = lastNDays(map, "2026-01-07", 7);
    const avg = averages(days.map((d) => d.entry));
    expect(avg?.count).toBe(2);
    expect(avg?.mood).toBe(3); // (4 + 2) / 2
    expect(avg?.energy).toBe(3); // (2 + 4) / 2
    expect(avg?.sleep).toBe(4); // (3 + 5) / 2
  });

  it("returns null with no entries", () => {
    expect(averages([null, null])).toBeNull();
  });
});
