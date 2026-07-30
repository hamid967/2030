"use client";

import { useLocale, useTranslations } from "next-intl";
import { useCheckins } from "@/hooks/use-checkins";
import { lastNDays, averages } from "@/lib/checkins";
import { Card } from "@/components/ui/card";
import { buttonVariants } from "@/components/ui/button";
import { Link } from "@/i18n/navigation";

import { getLocalDateISO } from "@/lib/datetime";

function todayIso(): string {
  return getLocalDateISO();
}

const metrics = [
  { key: "mood", colorVar: "var(--warif-primary)" },
  { key: "energy", colorVar: "var(--phase-follicular)" },
  { key: "sleep", colorVar: "var(--phase-menstrual)" },
] as const;

export function WeekSummary() {
  const t = useTranslations("WeekSummary");
  const tc = useTranslations("CheckIn");
  const locale = useLocale();
  const { checkins, hydrated } = useCheckins();

  if (!hydrated) {
    return (
      <div className="h-40 w-full animate-pulse rounded-card bg-border/40" />
    );
  }

  const days = lastNDays(checkins, todayIso(), 7);
  const avg = averages(days.map((d) => d.entry));
  const weekday = new Intl.DateTimeFormat(locale, {
    weekday: "narrow",
    timeZone: "UTC",
  });
  const dayLabel = (iso: string) => {
    const [y, m, d] = iso.split("-").map(Number);
    return weekday.format(new Date(Date.UTC(y, m - 1, d)));
  };

  return (
    <Card>
      <h2 className="mb-4 text-lg font-bold text-text">{t("title")}</h2>

      {avg === null ? (
        <div className="flex flex-col items-center gap-3 py-4 text-center">
          <p className="text-muted">{t("empty")}</p>
          <Link href="/check-in" className={buttonVariants({ size: "md" })}>
            {t("logCta")}
          </Link>
        </div>
      ) : (
        <div className="flex flex-col gap-4">
          {metrics.map(({ key, colorVar }) => (
            <div key={key} className="flex items-end gap-3">
              <span className="w-14 shrink-0 text-sm text-muted">
                {tc(`${key}Label`)}
              </span>
              <div className="flex flex-1 items-end justify-between gap-1">
                {days.map(({ date, entry }) => {
                  const value = entry ? entry[key] : 0;
                  return (
                    <div
                      key={date}
                      className="flex flex-1 flex-col items-center gap-1"
                    >
                      <div className="flex h-10 w-full items-end justify-center">
                        <div
                          className="w-2.5 rounded-full"
                          style={{
                            height: `${(value / 5) * 100}%`,
                            backgroundColor: value ? colorVar : undefined,
                            border: value
                              ? undefined
                              : "1px dashed var(--warif-border)",
                            minHeight: value ? "4px" : "0",
                          }}
                          aria-hidden
                        />
                      </div>
                      <span className="text-[10px] text-muted">
                        {dayLabel(date)}
                      </span>
                    </div>
                  );
                })}
              </div>
            </div>
          ))}
          <p className="text-sm text-muted">
            {t("basedOn", { count: avg.count })}
          </p>
        </div>
      )}
    </Card>
  );
}
