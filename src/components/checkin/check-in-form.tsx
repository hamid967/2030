"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";
import { Check, ShieldCheck } from "lucide-react";
import { useCheckins } from "@/hooks/use-checkins";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

function todayIso(): string {
  return new Date().toISOString().slice(0, 10);
}

function RatingScale({
  label,
  value,
  onChange,
  color,
}: {
  label: string;
  value: number;
  onChange: (v: number) => void;
  color: string;
}) {
  return (
    <div>
      <p className="mb-2 text-sm font-medium text-text">{label}</p>
      <div
        role="radiogroup"
        aria-label={label}
        className="flex items-center gap-2"
      >
        {[1, 2, 3, 4, 5].map((n) => {
          const active = value === n;
          return (
            <button
              key={n}
              type="button"
              role="radio"
              aria-checked={active}
              onClick={() => onChange(n)}
              className={cn(
                "flex size-11 items-center justify-center rounded-full border text-base font-medium transition-colors",
                active
                  ? "border-transparent text-white"
                  : "border-border bg-surface text-muted hover:bg-ivory",
              )}
              style={active ? { backgroundColor: color } : undefined}
            >
              {n}
            </button>
          );
        })}
      </div>
    </div>
  );
}

export function CheckInForm() {
  const t = useTranslations("CheckIn");
  const { getCheckIn, saveCheckIn, hydrated } = useCheckins();

  const existing = hydrated ? getCheckIn(todayIso()) : null;

  const [mood, setMood] = useState(existing?.mood ?? 3);
  const [energy, setEnergy] = useState(existing?.energy ?? 3);
  const [sleep, setSleep] = useState(existing?.sleep ?? 3);
  const [flow, setFlow] = useState(existing?.flow ?? 0);
  const [saved, setSaved] = useState(false);

  if (!hydrated) {
    return (
      <div className="h-96 w-full animate-pulse rounded-card bg-border/40" />
    );
  }

  const flowOptions = [
    { value: 0, key: "flowNone" },
    { value: 1, key: "flowLight" },
    { value: 2, key: "flowMedium" },
    { value: 3, key: "flowHeavy" },
  ];

  const handleSave = () => {
    saveCheckIn(todayIso(), { mood, energy, sleep, flow });
    setSaved(true);
    window.setTimeout(() => setSaved(false), 2500);
  };

  return (
    <Card className="flex flex-col gap-6">
      <RatingScale
        label={t("moodLabel")}
        value={mood}
        onChange={setMood}
        color="var(--warif-primary)"
      />
      <RatingScale
        label={t("energyLabel")}
        value={energy}
        onChange={setEnergy}
        color="var(--warif-sage)"
      />
      <RatingScale
        label={t("sleepLabel")}
        value={sleep}
        onChange={setSleep}
        color="var(--warif-lavender)"
      />

      <div>
        <p className="mb-2 text-sm font-medium text-text">{t("flowLabel")}</p>
        <div className="flex flex-wrap gap-2">
          {flowOptions.map(({ value, key }) => {
            const active = flow === value;
            return (
              <button
                key={value}
                type="button"
                aria-pressed={active}
                onClick={() => setFlow(value)}
                className={cn(
                  "min-h-11 rounded-full border px-4 text-sm font-medium transition-colors",
                  active
                    ? "border-transparent bg-rose text-white"
                    : "border-border bg-surface text-muted hover:bg-ivory",
                )}
              >
                {t(key)}
              </button>
            );
          })}
        </div>
      </div>

      <Button size="lg" className="w-full" onClick={handleSave}>
        {saved ? (
          <>
            <Check className="size-5" aria-hidden />
            {t("saved")}
          </>
        ) : (
          t("save")
        )}
      </Button>

      <div className="flex items-center gap-2 text-sm text-muted">
        <ShieldCheck className="size-4 shrink-0 text-sage" aria-hidden />
        <p>{t("privacyNote")}</p>
      </div>
    </Card>
  );
}
