import type { CycleProfile } from "@/lib/cycle-engine";
import type { CheckIn, CheckInDraft, CheckInMap } from "@/lib/checkins";

/**
 * Repository interfaces decouple view/state code from the storage backend.
 * Today the only implementation is local (localStorage); a Supabase-backed
 * implementation (behind Auth + RLS) arrives in a later batch. View components
 * should depend on these interfaces / the existing hooks, never on a concrete
 * storage API directly.
 */
export interface CycleRepository {
  getProfile(): Promise<CycleProfile | null>;
  saveProfile(profile: CycleProfile): Promise<void>;
  logPeriodStart(dateIso: string): Promise<void>;
  clear(): Promise<void>;
}

export interface CheckinRepository {
  get(dateIso: string): Promise<CheckIn | null>;
  list(): Promise<CheckInMap>;
  save(dateIso: string, draft: CheckInDraft): Promise<void>;
}
