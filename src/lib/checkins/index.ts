import { addDays } from "@/lib/cycle-engine";

/**
 * A daily check-in. Scales are 1–5 (mood/energy/sleep) and 0–3 for flow
 * (none/light/medium/heavy). This is sensitive health data and is stored only
 * on the user's device (see `use-checkins`), never sent to a server.
 */
export interface CheckIn {
  date: string;
  mood: number;
  energy: number;
  sleep: number;
  flow: number;
}

export type CheckInDraft = Omit<CheckIn, "date">;
export type CheckInMap = Record<string, CheckIn>;

export interface DayEntry {
  date: string;
  entry: CheckIn | null;
}

export interface WeekAverages {
  mood: number;
  energy: number;
  sleep: number;
  count: number;
}

/** The last `n` days (oldest → newest), each with its check-in or null. */
export function lastNDays(map: CheckInMap, today: string, n = 7): DayEntry[] {
  const days: DayEntry[] = [];
  for (let i = n - 1; i >= 0; i--) {
    const date = addDays(today, -i);
    days.push({ date, entry: map[date] ?? null });
  }
  return days;
}

/** Average mood/energy/sleep over the present entries, or null if none. */
export function averages(entries: Array<CheckIn | null>): WeekAverages | null {
  const present = entries.filter((e): e is CheckIn => e !== null);
  if (present.length === 0) return null;
  const mean = (key: "mood" | "energy" | "sleep") =>
    present.reduce((sum, e) => sum + e[key], 0) / present.length;
  return {
    mood: mean("mood"),
    energy: mean("energy"),
    sleep: mean("sleep"),
    count: present.length,
  };
}
