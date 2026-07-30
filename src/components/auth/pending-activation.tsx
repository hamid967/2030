"use client";

import { useState } from "react";
import Image from "next/image";
import { useLocale, useTranslations } from "next-intl";
import { Clock, CheckCircle2, XCircle, ShieldCheck } from "lucide-react";
import { useAccount } from "@/hooks/use-account";
import { Link } from "@/i18n/navigation";
import { Button, buttonVariants } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";

function formatDate(iso: string | undefined, locale: string): string {
  if (!iso) return "—";
  return new Intl.DateTimeFormat(locale, {
    dateStyle: "medium",
  }).format(new Date(iso));
}

export function PendingActivation() {
  const t = useTranslations("Pending");
  const locale = useLocale();
  const { account, hydrated, simulateDecision, resubmit } = useAccount();
  const [reason, setReason] = useState("");

  if (!hydrated) {
    return (
      <div className="h-96 w-full animate-pulse rounded-card bg-border/40" />
    );
  }

  if (!account) {
    return (
      <Card className="text-center">
        <p className="text-muted">{t("noSession")}</p>
        <Link
          href="/auth/sign-up"
          className={buttonVariants({ className: "mt-4" })}
        >
          {t("goSignUp")}
        </Link>
      </Card>
    );
  }

  if (account.status === "approved") {
    return (
      <Card className="flex flex-col items-center gap-4 text-center">
        <span className="flex size-14 items-center justify-center rounded-full bg-sage/20 text-sage">
          <CheckCircle2 className="size-8" strokeWidth={1.75} aria-hidden />
        </span>
        <h1 className="text-2xl font-bold text-text">{t("approvedTitle")}</h1>
        <p className="text-muted">{t("approvedBody")}</p>
        <Link
          href="/today"
          className={buttonVariants({ size: "lg", className: "w-full" })}
        >
          {t("enterApp")}
        </Link>
      </Card>
    );
  }

  if (account.status === "rejected") {
    return (
      <div className="flex flex-col gap-4">
        <Card className="flex flex-col items-center gap-4 text-center">
          <span className="flex size-14 items-center justify-center rounded-full bg-danger/10 text-danger">
            <XCircle className="size-8" strokeWidth={1.75} aria-hidden />
          </span>
          <h1 className="text-2xl font-bold text-text">{t("rejectedTitle")}</h1>
          <p className="text-muted">{t("rejectedBody")}</p>
          {account.rejectionReason && (
            <p className="w-full rounded-2xl border border-danger/30 bg-danger/5 px-4 py-3 text-sm text-danger">
              {t("reasonLabel")}: {account.rejectionReason}
            </p>
          )}
          <Button size="lg" className="w-full" onClick={() => resubmit()}>
            {t("resubmit")}
          </Button>
        </Card>
      </div>
    );
  }

  // pending_activation
  return (
    <div className="flex flex-col gap-4">
      <Card className="flex flex-col items-center gap-4 text-center">
        <Image
          src="/illustrations/onboarding-privacy-4x5.png"
          alt={t("imageAlt")}
          width={1122}
          height={1402}
          priority
          sizes="(max-width: 768px) 60vw, 240px"
          className="w-40 rounded-card"
        />
        <span className="flex items-center gap-2 rounded-full bg-lavender/15 px-4 py-1 text-sm font-medium text-primary-strong">
          <Clock className="size-4" strokeWidth={1.75} aria-hidden />
          {t("statusPending")}
        </span>
        <h1 className="text-2xl font-bold text-text">{t("title")}</h1>
        <p className="text-muted">{t("body")}</p>

        <dl className="w-full space-y-2 text-start text-sm">
          <div className="flex justify-between">
            <dt className="text-muted">{t("requestNumber")}</dt>
            <dd className="font-medium text-text" dir="ltr">
              {account.requestNumber}
            </dd>
          </div>
          <div className="flex justify-between">
            <dt className="text-muted">{t("submittedAt")}</dt>
            <dd className="font-medium text-text">
              {formatDate(account.submittedAt, locale)}
            </dd>
          </div>
        </dl>

        <p className="flex items-center gap-2 text-sm text-muted">
          <ShieldCheck className="size-4 shrink-0 text-sage" aria-hidden />
          {t("support")}
        </p>
      </Card>

      {/* Temporary demo panel — replaced by the Phase 2 admin console. */}
      <Card className="border-dashed">
        <p className="mb-3 text-xs font-medium uppercase tracking-wide text-muted">
          {t("demoTitle")}
        </p>
        <div className="flex flex-col gap-3">
          <Button variant="outline" onClick={() => simulateDecision("approve")}>
            {t("demoApprove")}
          </Button>
          <div className="flex flex-col gap-2">
            <Input
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              placeholder={t("demoReasonPlaceholder")}
            />
            <Button
              variant="ghost"
              onClick={() =>
                simulateDecision("reject", reason || t("demoDefaultReason"))
              }
            >
              {t("demoReject")}
            </Button>
          </div>
        </div>
      </Card>
    </div>
  );
}
