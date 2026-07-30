"use client";

import { useState } from "react";
import Image from "next/image";
import { useTranslations } from "next-intl";
import { HeartPulse, ShieldCheck, UsersRound } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { Button, buttonVariants } from "@/components/ui/button";
import { Link } from "@/i18n/navigation";
import { cn } from "@/lib/utils";

const steps: { key: string; icon: LucideIcon }[] = [
  { key: "step1", icon: HeartPulse },
  { key: "step2", icon: ShieldCheck },
  { key: "step3", icon: UsersRound },
];

export function OnboardingFlow() {
  const t = useTranslations("Onboarding");
  const [index, setIndex] = useState(0);
  const step = steps[index];
  const Icon = step.icon;
  const isLast = index === steps.length - 1;

  return (
    <div className="flex flex-col items-center gap-6 text-center">
      <Image
        src="/illustrations/onboarding-privacy-4x5.png"
        alt={t("imageAlt")}
        width={1122}
        height={1402}
        priority
        sizes="(max-width: 768px) 80vw, 320px"
        className="w-56 rounded-card"
      />

      <span className="flex size-12 items-center justify-center rounded-full bg-primary/10 text-primary">
        <Icon className="size-6" strokeWidth={1.75} aria-hidden />
      </span>

      <div className="space-y-2">
        <h1 className="text-2xl font-bold text-text">
          {t(`${step.key}Title`)}
        </h1>
        <p className="text-muted">{t(`${step.key}Body`)}</p>
      </div>

      <div className="flex items-center gap-2" aria-hidden>
        {steps.map((s, i) => (
          <span
            key={s.key}
            className={cn(
              "h-2 rounded-full transition-all",
              i === index ? "w-6 bg-primary" : "w-2 bg-border",
            )}
          />
        ))}
      </div>

      <div className="flex w-full flex-col gap-3">
        {isLast ? (
          <Link
            href="/auth/sign-up"
            className={buttonVariants({ size: "lg", className: "w-full" })}
          >
            {t("getStarted")}
          </Link>
        ) : (
          <Button
            size="lg"
            className="w-full"
            onClick={() => setIndex(index + 1)}
          >
            {t("next")}
          </Button>
        )}

        <div className="flex items-center justify-between text-sm">
          {index > 0 ? (
            <button
              type="button"
              onClick={() => setIndex(index - 1)}
              className="text-muted hover:text-primary-strong"
            >
              {t("back")}
            </button>
          ) : (
            <span />
          )}
          <Link
            href="/auth/login"
            className="font-medium text-primary hover:text-primary-strong"
          >
            {t("haveAccount")}
          </Link>
        </div>
      </div>
    </div>
  );
}
