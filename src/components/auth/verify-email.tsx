"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import { MailCheck } from "lucide-react";
import { useAccount } from "@/hooks/use-account";
import { useRouter } from "@/i18n/navigation";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

export function VerifyEmail() {
  const t = useTranslations("Auth");
  const router = useRouter();
  const { account, hydrated, verifyEmail } = useAccount();
  const [code, setCode] = useState("");
  const [error, setError] = useState(false);

  const alreadyVerified = Boolean(account?.emailVerified);
  useEffect(() => {
    if (hydrated && alreadyVerified) {
      router.replace("/auth/consents");
    }
  }, [hydrated, alreadyVerified, router]);

  if (!hydrated) {
    return (
      <div className="h-64 w-full animate-pulse rounded-card bg-border/40" />
    );
  }

  if (!account) {
    return (
      <Card className="text-center">
        <p className="text-muted">{t("noSession")}</p>
      </Card>
    );
  }

  return (
    <Card className="flex flex-col gap-5 text-center">
      <span className="mx-auto flex size-12 items-center justify-center rounded-full bg-primary/10 text-primary">
        <MailCheck className="size-6" strokeWidth={1.75} aria-hidden />
      </span>
      <div>
        <h1 className="text-2xl font-bold text-text">{t("verifyTitle")}</h1>
        <p className="mt-1 text-muted">
          {t("verifySubtitle", { email: account.email })}
        </p>
      </div>

      {/* Demo aid only: a real deployment emails this code / a magic link. */}
      <p className="rounded-2xl bg-lavender/15 px-4 py-2 text-sm text-primary-strong">
        {t("verifyDemoHint", { code: account.verificationCode })}
      </p>

      <div className="flex flex-col gap-1.5 text-start">
        <Label htmlFor="code">{t("verifyCodeLabel")}</Label>
        <Input
          id="code"
          inputMode="numeric"
          dir="ltr"
          value={code}
          onChange={(e) => {
            setCode(e.target.value);
            setError(false);
          }}
        />
        {error && <p className="text-sm text-danger">{t("errorCode")}</p>}
      </div>

      <Button
        size="lg"
        className="w-full"
        onClick={() => {
          if (verifyEmail(code)) {
            router.push("/auth/consents");
          } else {
            setError(true);
          }
        }}
      >
        {t("verifySubmit")}
      </Button>
    </Card>
  );
}
