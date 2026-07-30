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
} from "lucide-react";
import {
  computeCycleStatus,
  type CycleProfile,
  type CycleStatus,
} from "@/lib/cycle-engine";
import { useCycleProfile } from "@/hooks/use-cycle-profile";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { CyclePhaseRing } from "./cycle-phase-ring";
import { DailyStoryCard } from "./daily-story-card";
import { CycleSetupForm } from "./cycle-setup-form";

function todayIso(): string {
  return new Date().toISOString().slice(0, 10);
}

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
  const { profile, hydrated, saveProfile, clearProfile } = useCycleProfile();
  const [editing, setEditing] = useState(false);
  const formatDate = useDateFormatter();

  if (!hydrated) {
    return (
      <div className="mx-auto h-52 w-full max-w-md animate-pulse rounded-card bg-border/40" />
    );
  }

  // Computed on the client only (after `hydrated`), so no SSR mismatch.
  const now = todayIso();

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

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col items-center gap-2 text-center">
        <CyclePhaseRing
          cycleDay={status.cycleDay}
          cycleLength={status.cycleLength}
          phase={status.phase}
        />
        <p className="text-lg font-medium text-text">
          {t("dayLabel", { day: status.cycleDay })}
        </p>
        <p className="text-sm text-muted">
          {t("cycleLengthLabel", { length: status.cycleLength })}
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2">
        <Card className="flex items-start gap-3">
          <span className="mt-0.5 text-primary">
            <CalendarHeart className="size-5" aria-hidden />
          </span>
          <div>
            <p className="font-semibold text-text">{t("nextPeriodLabel")}</p>
            <p className="text-muted">
              {t("nextPeriodRange", {
                earliest: formatDate(status.nextPeriodRange.earliest),
                latest: formatDate(status.nextPeriodRange.latest),
              })}
            </p>
            <p className="mt-1 text-sm text-muted">
              {t("daysUntil", { days: status.daysUntilNextPeriod })}
            </p>
          </div>
        </Card>

        <Card className="flex items-start gap-3">
          <span className="mt-0.5 text-lavender">
            <Egg className="size-5" aria-hidden />
          </span>
          <div>
            <p className="font-semibold text-text">{t("ovulationLabel")}</p>
            <p className="text-muted">
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

      <Card className="flex items-center gap-2 bg-sage/10">
        <ShieldCheck className="size-5 shrink-0 text-sage" aria-hidden />
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
