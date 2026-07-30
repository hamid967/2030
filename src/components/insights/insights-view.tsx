"use client";

import { useTranslations } from "next-intl";
import { CalendarDays, Activity, NotebookPen, Info } from "lucide-react";
import { useCheckins } from "@/hooks/use-checkins";
import { useCycleProfile } from "@/hooks/use-cycle-profile";
import { lastNDays, averages } from "@/lib/checkins";
import { predictCycle } from "@/lib/cycle-engine/predict";
import { getLocalDateISO } from "@/lib/datetime";
import { Card } from "@/components/ui/card";

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-2xl border border-border bg-surface p-4">
      <p className="text-sm text-muted">{label}</p>
      <p className="mt-1 text-2xl font-bold text-text">{value}</p>
    </div>
  );
}

export function InsightsView() {
  const t = useTranslations("Insights");
  const { checkins, hydrated } = useCheckins();
  const { profile, hydrated: profileHydrated } = useCycleProfile();

  if (!hydrated || !profileHydrated) {
    return (
      <div className="h-64 w-full animate-pulse rounded-card bg-border/40" />
    );
  }

  const today = getLocalDateISO();
  const days = lastNDays(checkins, today, 30);
  const entries = days.map((d) => d.entry);
  const avg = averages(entries);
  const loggedCount = entries.filter(Boolean).length;
  const bleedingDays = entries.filter((e) => e && e.flow > 0).length;

  const prediction = profile
    ? predictCycle({
        periodStarts: profile.periodStarts ?? [profile.lastPeriodStart],
        today,
        generatedAt: new Date().toISOString(),
      })
    : null;

  const oneDecimal = (n: number) => n.toFixed(1);

  return (
    <div className="flex flex-col gap-5">
      <Card className="flex items-start gap-2 bg-lavender/10">
        <Info
          className="mt-0.5 size-5 shrink-0 text-primary-strong"
          aria-hidden
        />
        <p className="text-sm text-muted">{t("dataSourceNote")}</p>
      </Card>

      <section>
        <h2 className="mb-3 flex items-center gap-2 text-lg font-bold text-text">
          <CalendarDays className="size-5" strokeWidth={1.75} aria-hidden />
          {t("cycleSection")}
        </h2>
        <div className="grid grid-cols-2 gap-3">
          <Stat
            label={t("medianCycle")}
            value={
              prediction?.medianCycleLength
                ? t("days", { n: prediction.medianCycleLength })
                : "—"
            }
          />
          <Stat
            label={t("cyclesLogged")}
            value={String(prediction?.cyclesUsed ?? 0)}
          />
        </div>
        <p className="mt-2 text-sm text-muted">
          {t("confidenceNote", {
            level: t(`confidence_${prediction?.confidence ?? "insufficient"}`),
          })}
        </p>
      </section>

      <section>
        <h2 className="mb-3 flex items-center gap-2 text-lg font-bold text-text">
          <Activity className="size-5" strokeWidth={1.75} aria-hidden />
          {t("wellbeingSection")}
        </h2>
        {avg === null ? (
          <Card className="text-muted">{t("noCheckins")}</Card>
        ) : (
          <div className="grid grid-cols-3 gap-3">
            <Stat label={t("avgMood")} value={oneDecimal(avg.mood)} />
            <Stat label={t("avgEnergy")} value={oneDecimal(avg.energy)} />
            <Stat label={t("avgSleep")} value={oneDecimal(avg.sleep)} />
          </div>
        )}
      </section>

      <section>
        <h2 className="mb-3 flex items-center gap-2 text-lg font-bold text-text">
          <NotebookPen className="size-5" strokeWidth={1.75} aria-hidden />
          {t("loggingSection")}
        </h2>
        <div className="grid grid-cols-2 gap-3">
          <Stat
            label={t("loggedDays")}
            value={t("ofDays", { n: loggedCount })}
          />
          <Stat label={t("bleedingDays")} value={String(bleedingDays)} />
        </div>
      </section>

      <p className="text-center text-xs text-muted">{t("notDiagnosis")}</p>
    </div>
  );
}
