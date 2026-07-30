import { beforeEach, describe, expect, it } from "vitest";
import {
  LocalCycleRepository,
  LocalCheckinRepository,
} from "@/lib/repositories/local";

beforeEach(() => {
  window.localStorage.clear();
});

describe("LocalCycleRepository", () => {
  it("returns null when empty and tolerates corrupt data", async () => {
    const repo = new LocalCycleRepository();
    expect(await repo.getProfile()).toBeNull();
    window.localStorage.setItem("warif.cycleProfile.v1", "{not json");
    expect(await repo.getProfile()).toBeNull();
  });

  it("saves a profile and keeps period history in sync", async () => {
    const repo = new LocalCycleRepository();
    await repo.saveProfile({
      lastPeriodStart: "2026-01-01",
      cycleLength: 28,
      periodLength: 5,
    });
    await repo.logPeriodStart("2026-01-29");
    const profile = await repo.getProfile();
    expect(profile?.lastPeriodStart).toBe("2026-01-29");
    expect(profile?.periodStarts).toEqual(["2026-01-01", "2026-01-29"]);
  });
});

describe("LocalCheckinRepository", () => {
  it("returns an empty map for corrupt data and round-trips a save", async () => {
    const repo = new LocalCheckinRepository();
    window.localStorage.setItem("warif.checkins.v1", "broken");
    expect(await repo.list()).toEqual({});

    await repo.save("2026-01-05", { mood: 4, energy: 3, sleep: 5, flow: 1 });
    const entry = await repo.get("2026-01-05");
    expect(entry?.mood).toBe(4);
    expect(entry?.date).toBe("2026-01-05");
  });
});
