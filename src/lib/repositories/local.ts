import type { CycleProfile } from "@/lib/cycle-engine";
import type { CheckIn, CheckInDraft, CheckInMap } from "@/lib/checkins";
import type { CycleRepository, CheckinRepository } from "./types";

/**
 * Local (on-device) repository adapters backed by localStorage. These mirror
 * the storage used by the `use-cycle-profile` / `use-checkins` hooks and exist
 * so non-React code and future Supabase adapters share one interface. Health
 * data never leaves the device here.
 */
const CYCLE_KEY = "warif.cycleProfile.v1";
const CHECKINS_KEY = "warif.checkins.v1";

function readJSON<T>(key: string): T | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(key);
    return raw ? (JSON.parse(raw) as T) : null;
  } catch {
    return null;
  }
}

export class LocalCycleRepository implements CycleRepository {
  async getProfile(): Promise<CycleProfile | null> {
    return readJSON<CycleProfile>(CYCLE_KEY);
  }
  async saveProfile(profile: CycleProfile): Promise<void> {
    const starts = Array.from(
      new Set([...(profile.periodStarts ?? []), profile.lastPeriodStart]),
    ).sort();
    window.localStorage.setItem(
      CYCLE_KEY,
      JSON.stringify({ ...profile, periodStarts: starts }),
    );
  }
  async logPeriodStart(dateIso: string): Promise<void> {
    const current = await this.getProfile();
    if (!current) return;
    const starts = Array.from(
      new Set([
        ...(current.periodStarts ?? [current.lastPeriodStart]),
        dateIso,
      ]),
    ).sort();
    await this.saveProfile({
      ...current,
      lastPeriodStart: starts[starts.length - 1],
      periodStarts: starts,
    });
  }
  async clear(): Promise<void> {
    window.localStorage.removeItem(CYCLE_KEY);
  }
}

export class LocalCheckinRepository implements CheckinRepository {
  async list(): Promise<CheckInMap> {
    return readJSON<CheckInMap>(CHECKINS_KEY) ?? {};
  }
  async get(dateIso: string): Promise<CheckIn | null> {
    const all = await this.list();
    return all[dateIso] ?? null;
  }
  async save(dateIso: string, draft: CheckInDraft): Promise<void> {
    const all = await this.list();
    all[dateIso] = { date: dateIso, ...draft };
    window.localStorage.setItem(CHECKINS_KEY, JSON.stringify(all));
  }
}
