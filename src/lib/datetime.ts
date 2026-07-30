/**
 * Timezone-safe local date helpers.
 *
 * IMPORTANT: never use `new Date().toISOString().slice(0, 10)` as a *local*
 * date — it returns the UTC date, which is wrong near midnight in Riyadh
 * (UTC+3). Always derive the local calendar date through this helper.
 */
export const DEFAULT_TIME_ZONE = "Asia/Riyadh";

/** Returns the calendar date (YYYY-MM-DD) in `timeZone` for the given instant. */
export function getLocalDateISO(
  timeZone: string = DEFAULT_TIME_ZONE,
  instant: number | Date = Date.now(),
): string {
  const date = typeof instant === "number" ? new Date(instant) : instant;
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(date);

  const get = (type: string) => parts.find((p) => p.type === type)?.value ?? "";
  return `${get("year")}-${get("month")}-${get("day")}`;
}

/** Today's local date (YYYY-MM-DD), Riyadh by default. Client/runtime use only. */
export function todayLocalISO(timeZone: string = DEFAULT_TIME_ZONE): string {
  return getLocalDateISO(timeZone, Date.now());
}
