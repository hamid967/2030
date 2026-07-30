"use client";

import { useState } from "react";
import { useLocale, useTranslations } from "next-intl";
import { ChevronRight, ChevronLeft, Droplet, Egg } from "lucide-react";
import { useCycleProfile } from "@/hooks/use-cycle-profile";
import { getDayClassification } from "@/lib/cycle-engine";
import { Card } from "@/components/ui/card";
import { buttonVariants } from "@/components/ui/button";
import { Link } from "@/i18n/navigation";
import { cn } from "@/lib/utils";
import { getLocalDateISO } from "@/lib/datetime";

function iso(y: number, m: number, d: number): string {
  return `${y}-${String(m + 1).padStart(2, "0")}-${String(d).padStart(2, "0")}`;
}

function todayIso(): string {
  return getLocalDateISO();
}

export function CycleCalendar() {
  const t = useTranslations("Calendar");
  const locale = useLocale();
  const { profile, hydrated } = useCycleProfile();

  const now = new Date();
  const [view, setView] = useState({
    year: now.getUTCFullYear(),
    month: now.getUTCMonth(),
  });

  if (!hydrated) {
    return (
      <div className="h-96 w-full animate-pulse rounded-card bg-border/40" />
    );
  }

  if (!profile) {
    return (
      <Card className="flex flex-col items-center gap-3 py-8 text-center">
        <p className="text-muted">{t("needSetup")}</p>
        <Link href="/today" className={buttonVariants({ size: "md" })}>
          {t("goSetup")}
        </Link>
      </Card>
    );
  }

  const monthLabel = new Intl.DateTimeFormat(locale, {
    month: "long",
    year: "numeric",
    timeZone: "UTC",
  }).format(new Date(Date.UTC(view.year, view.month, 1)));

  const firstWeekday = new Date(Date.UTC(view.year, view.month, 1)).getUTCDay();
  const daysInMonth = new Date(
    Date.UTC(view.year, view.month + 1, 0),
  ).getUTCDate();

  const weekdayFmt = new Intl.DateTimeFormat(locale, {
    weekday: "narrow",
    timeZone: "UTC",
  });
  const weekdayHeaders = Array.from({ length: 7 }, (_, i) =>
    weekdayFmt.format(new Date(Date.UTC(2024, 0, 7 + i))),
  );

  const cells: (number | null)[] = [
    ...Array<null>(firstWeekday).fill(null),
    ...Array.from({ length: daysInMonth }, (_, i) => i + 1),
  ];

  const today = todayIso();

  const shiftMonth = (delta: number) =>
    setView(({ year, month }) => {
      const next = new Date(Date.UTC(year, month + delta, 1));
      return { year: next.getUTCFullYear(), month: next.getUTCMonth() };
    });

  return (
    <Card>
      <div className="mb-4 flex items-center justify-between">
        <button
          type="button"
          onClick={() => shiftMonth(-1)}
          aria-label={t("prevMonth")}
          className="flex size-10 items-center justify-center rounded-full text-primary-strong hover:bg-ivory"
        >
          <ChevronRight className="size-5 rtl:hidden" aria-hidden />
          <ChevronLeft className="hidden size-5 rtl:block" aria-hidden />
        </button>
        <h2 className="text-lg font-bold text-text">{monthLabel}</h2>
        <button
          type="button"
          onClick={() => shiftMonth(1)}
          aria-label={t("nextMonth")}
          className="flex size-10 items-center justify-center rounded-full text-primary-strong hover:bg-ivory"
        >
          <ChevronLeft className="size-5 rtl:hidden" aria-hidden />
          <ChevronRight className="hidden size-5 rtl:block" aria-hidden />
        </button>
      </div>

      <div className="grid grid-cols-7 gap-1 text-center">
        {weekdayHeaders.map((w, i) => (
          <span key={i} className="pb-1 text-xs font-medium text-muted">
            {w}
          </span>
        ))}
        {cells.map((day, i) => {
          if (day === null) return <span key={`e${i}`} />;
          const dateIso = iso(view.year, view.month, day);
          const c = getDayClassification(profile, dateIso);
          const isToday = dateIso === today;
          return (
            <div
              key={dateIso}
              className={cn(
                "flex aspect-square flex-col items-center justify-center rounded-2xl text-sm",
                c.isPeriod && "bg-rose/20 text-primary-strong",
                !c.isPeriod &&
                  c.isFertile &&
                  "bg-lavender/25 text-primary-strong",
                isToday && "ring-2 ring-primary",
              )}
            >
              <span className={cn(isToday && "font-bold text-primary")}>
                {day}
              </span>
              <span className="flex h-3 items-center gap-0.5">
                {c.isPeriod && (
                  <Droplet className="size-3 fill-rose text-rose" aria-hidden />
                )}
                {c.isOvulation && (
                  <Egg className="size-3 text-lavender" aria-hidden />
                )}
              </span>
            </div>
          );
        })}
      </div>

      <div className="mt-4 flex flex-wrap items-center gap-4 text-sm text-muted">
        <span className="flex items-center gap-1.5">
          <span className="inline-block size-3 rounded-full bg-rose/60" />
          {t("legendPeriod")}
        </span>
        <span className="flex items-center gap-1.5">
          <span className="inline-block size-3 rounded-full bg-lavender/60" />
          {t("legendFertile")}
        </span>
        <span className="flex items-center gap-1.5">
          <span className="inline-block size-3 rounded-full ring-2 ring-primary" />
          {t("legendToday")}
        </span>
      </div>

      <p className="mt-3 text-sm text-danger">{t("estimateNote")}</p>
    </Card>
  );
}
