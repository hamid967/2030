import { describe, expect, it } from "vitest";
import { getLocalDateISO } from "@/lib/datetime";

describe("getLocalDateISO", () => {
  it("uses the Riyadh calendar date (UTC+3) around midnight", () => {
    // 20:30 UTC is 23:30 in Riyadh — still the 1st.
    expect(getLocalDateISO("Asia/Riyadh", Date.UTC(2026, 0, 1, 20, 30))).toBe(
      "2026-01-01",
    );
    // 21:30 UTC is 00:30 next day in Riyadh — rolls to the 2nd.
    expect(getLocalDateISO("Asia/Riyadh", Date.UTC(2026, 0, 1, 21, 30))).toBe(
      "2026-01-02",
    );
  });

  it("differs from the UTC date near midnight (the bug we avoid)", () => {
    const instant = Date.UTC(2026, 0, 1, 21, 30);
    expect(getLocalDateISO("UTC", instant)).toBe("2026-01-01");
    expect(getLocalDateISO("Asia/Riyadh", instant)).toBe("2026-01-02");
  });

  it("handles end of month / leap day", () => {
    // 22:00 UTC on Feb 28 2028 → 01:00 Riyadh on the 29th (leap year).
    expect(getLocalDateISO("Asia/Riyadh", Date.UTC(2028, 1, 28, 22, 0))).toBe(
      "2028-02-29",
    );
  });
});
