"use client";

import { useState } from "react";
import { useLocale, useTranslations } from "next-intl";
import {
  CalendarHeart,
  Egg,
  ShieldCheck,
  Info,
  Pencil,
  Trash2,
  Droplet,
  CalendarDays,
} from "lucide-react";
import {
  computeCycleStatus,
  type CycleProfile,
  type CycleStatus,
} from "@/lib/cycle-engine";
import { predictCycle } from "@/lib/cycle-engine/predict";
import {
  phaseToVisualState,
  type VisualState,
} from "@/lib/cycle-engine/visual-states";
import { getLocalDateISO } from "@/lib/datetime";
import { useCycleProfile } from "@/hooks/use-cycle-profile";
import { useVisualPersonas } from "@/hooks/use-visual-personas";
import { Button, buttonVariants } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Link } from "@/i18n/navigation";
import { CyclePhaseRing } from "./cycle-phase-ring";
import { DailyStoryCard } from "./daily-story-card";
import { CycleSetupForm } from "./cycle-setup-form";

const stateKey: Record<VisualState, string> = {
  stillness: "stateStillness",
  renewal: "stateRenewal",
  balance: "stateBalance",
  containment: "stateContainment",
};

function useDateFormatter() {
  const locale = useLocale();
  return (iso: string) => {
    const [y, m, d] = iso.split("-").map(Number);
    return new Intl.DateTimeFormat(locale, {
      day: "numeric",
      month: "long",
      timeZone: "UTC",
    }).format(new Date(Date.UTC(y, m - 1, d)));
  };
}

export function TodayExperience() {
  const t = useTranslations("Today");
  const { profile, hydrated, saveProfile, logPeriodStart, clearProfile } =
    useCycleProfile();
  const { enabled: showPersonas } = useVisualPersonas();
  const [editing, setEditing] = useState(false);
  const formatDate = useDateFormatter();

  if (!hydrated) {
    return (
      <div className="mx-auto h-52 w-full max-w-md animate-pulse rounded-card bg-border/40" />
    );
  }

  // Riyadh-local "today" (never the UTC date). Computed after hydration.
  const now = getLocalDateISO();

  const handleSave = (next: CycleProfile) => {
    saveProfile(next);
    setEditing(false);
  };

  if (!profile || editing) {
    return (
      <CycleSetupForm
        defaultValues={profile ?? undefined}
        onSubmit={handleSave}
      />
    );
  }

  let status: CycleStatus;
  try {
    status = computeCycleStatus(profile, now);
  } catch {
    return <CycleSetupForm defaultValues={profile} onSubmit={handleSave} />;
  }

  const prediction = predictCycle({
    periodStarts: profile.periodStarts ?? [profile.lastPeriodStart],
    today: now,
    generatedAt: new Date().toISOString(),
  });
  const visualState = phaseToVisualState[status.phase];
  const rangeEarliest =
    prediction.earliestDate ?? status.nextPeriodRange.earliest;
  const rangeLatest = prediction.latestDate ?? status.nextPeriodRange.latest;

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col items-center gap-2 text-center">
        {showPersonas && (
          <span className="rounded-full bg-primary/10 px-4 py-1 text-sm font-medium text-primary-strong">
            {t("stateLabel", { state: t(stateKey[visualState]) })}
          </span>
        )}
        <div className="sensitive">
          <CyclePhaseRing
            cycleDay={status.cycleDay}
            cycleLength={status.cycleLength}
            phase={status.phase}
          />
        </div>
        <p className="text-lg font-medium text-text">
          {t("dayLabel", { day: status.cycleDay })}
        </p>
        <span className="rounded-full bg-surface px-3 py-1 text-xs font-medium text-muted ring-1 ring-border">
          {t(`confidence_${prediction.confidence}`)} ·{" "}
          {t("cyclesUsed", { count: prediction.cyclesUsed })}
        </span>
      </div>

      <div className="flex flex-wrap justify-center gap-3">
        <Link href="/check-in" className={buttonVariants({ size: "md" })}>
          {t("logDay")}
        </Link>
        <Button variant="outline" onClick={() => logPeriodStart(now)}>
          <Droplet className="size-4" aria-hidden />
          {t("periodStarted")}
        </Button>
        <Link
          href="/calendar"
          className={buttonVariants({ size: "md", variant: "ghost" })}
        >
          <CalendarDays className="size-4" aria-hidden />
          {t("viewCalendar")}
        </Link>
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <Card className="flex items-start gap-3">
          <span className="mt-0.5 text-primary">
            <CalendarHeart className="size-5" aria-hidden />
          </span>
          <div>
            <p className="font-semibold text-text">{t("nextPeriodLabel")}</p>
            <p className="text-muted sensitive">
              {t("nextPeriodRange", {
                earliest: formatDate(rangeEarliest),
                latest: formatDate(rangeLatest),
              })}
            </p>
            <p className="mt-1 text-sm text-muted">
              {t("daysUntil", { days: status.daysUntilNextPeriod })}
            </p>
          </div>
        </Card>

        <Card className="flex items-start gap-3">
          <span
            className="mt-0.5"
            style={{ color: "var(--phase-ovulation-estimate)" }}
          >
            <Egg className="size-5" aria-hidden />
          </span>
          <div>
            <p className="font-semibold text-text">{t("ovulationLabel")}</p>
            <p className="text-muted sensitive">
              {t("fertileRange", {
                start: status.fertileWindowEstimate.startDay,
                end: status.fertileWindowEstimate.endDay,
              })}
            </p>
          </div>
        </Card>
      </div>

      <DailyStoryCard phase={status.phase} />

      <Card className="border-danger/30 bg-danger/5">
        <div className="flex items-start gap-2 text-danger">
          <Info className="mt-0.5 size-5 shrink-0" aria-hidden />
          <div className="space-y-1">
            <p className="text-sm text-muted">{t("estimateNote")}</p>
            <p className="text-sm font-medium text-danger">
              {t("notContraception")}
            </p>
          </div>
        </div>
      </Card>

      <Card className="flex items-center gap-2 bg-renewal/10">
        <ShieldCheck
          className="size-5 shrink-0"
          style={{ color: "var(--phase-follicular)" }}
          aria-hidden
        />
        <p className="text-sm text-muted">{t("privacyNote")}</p>
      </Card>

      <div className="flex flex-wrap justify-center gap-3">
        <Button variant="outline" onClick={() => setEditing(true)}>
          <Pencil className="size-4" aria-hidden />
          {t("editButton")}
        </Button>
        <Button variant="ghost" onClick={() => clearProfile()}>
          <Trash2 className="size-4" aria-hidden />
          {t("resetButton")}
        </Button>
      </div>
    </div>
  );
}
