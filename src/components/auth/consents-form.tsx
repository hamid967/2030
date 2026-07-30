"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import { Check } from "lucide-react";
import { useAccount } from "@/hooks/use-account";
import { useRouter } from "@/i18n/navigation";
import {
  CONSENT_KEYS,
  EMPTY_CONSENTS,
  allConsentsGiven,
  type Consents,
  type ConsentKey,
} from "@/lib/account";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { cn } from "@/lib/utils";

function ConsentItem({
  checked,
  onToggle,
  title,
  body,
}: {
  checked: boolean;
  onToggle: () => void;
  title: string;
  body: string;
}) {
  return (
    <button
      type="button"
      role="checkbox"
      aria-checked={checked}
      onClick={onToggle}
      className={cn(
        "flex w-full items-start gap-3 rounded-2xl border p-4 text-start transition-colors",
        checked ? "border-primary bg-primary/5" : "border-border bg-surface",
      )}
    >
      <span
        aria-hidden
        className={cn(
          "mt-0.5 flex size-6 shrink-0 items-center justify-center rounded-md border",
          checked
            ? "border-transparent bg-primary text-white"
            : "border-border bg-surface",
        )}
      >
        {checked && <Check className="size-4" />}
      </span>
      <span>
        <span className="block font-semibold text-text">{title}</span>
        <span className="block text-sm text-muted">{body}</span>
      </span>
    </button>
  );
}

export function ConsentsForm() {
  const t = useTranslations("Consents");
  const router = useRouter();
  const { account, hydrated, submitActivation } = useAccount();
  const [consents, setConsents] = useState<Consents>({ ...EMPTY_CONSENTS });

  const needsVerification = Boolean(account && !account.emailVerified);
  useEffect(() => {
    if (hydrated && needsVerification) {
      router.replace("/auth/verify");
    }
  }, [hydrated, needsVerification, router]);

  if (!hydrated) {
    return (
      <div className="h-96 w-full animate-pulse rounded-card bg-border/40" />
    );
  }

  if (!account) {
    return (
      <Card className="text-center">
        <p className="text-muted">{t("noSession")}</p>
      </Card>
    );
  }

  const toggle = (key: ConsentKey) =>
    setConsents((prev) => ({ ...prev, [key]: !prev[key] }));

  const complete = allConsentsGiven(consents);

  return (
    <Card className="flex flex-col gap-4">
      <div>
        <h1 className="text-2xl font-bold text-text">{t("title")}</h1>
        <p className="mt-1 text-muted">{t("subtitle")}</p>
      </div>

      <div className="flex flex-col gap-3">
        {CONSENT_KEYS.map((key) => (
          <ConsentItem
            key={key}
            checked={consents[key]}
            onToggle={() => toggle(key)}
            title={t(`${key}Title`)}
            body={t(`${key}Body`)}
          />
        ))}
      </div>

      <Button
        size="lg"
        className="w-full"
        disabled={!complete}
        onClick={() => {
          if (submitActivation(consents)) {
            router.push("/pending-activation");
          }
        }}
      >
        {t("submit")}
      </Button>
      {!complete && (
        <p className="text-center text-sm text-muted">{t("allRequired")}</p>
      )}
    </Card>
  );
}
