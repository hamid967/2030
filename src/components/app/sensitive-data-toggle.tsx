"use client";

import { useEffect } from "react";
import { useTranslations } from "next-intl";
import { Eye, EyeOff } from "lucide-react";
import { useSensitiveHidden } from "@/hooks/use-sensitive-hidden";
import { cn } from "@/lib/utils";

/** Header control that blurs on-screen sensitive values (`.sensitive`). */
export function SensitiveDataToggle({ className }: { className?: string }) {
  const t = useTranslations("Shell");
  const { hidden, toggle } = useSensitiveHidden();

  // Reflect the persisted flag onto the document on mount / when it changes.
  useEffect(() => {
    document.documentElement.dataset.sensitiveHidden = hidden
      ? "true"
      : "false";
  }, [hidden]);

  const Icon = hidden ? EyeOff : Eye;

  return (
    <button
      type="button"
      onClick={toggle}
      aria-pressed={hidden}
      aria-label={hidden ? t("showSensitive") : t("hideSensitive")}
      title={hidden ? t("showSensitive") : t("hideSensitive")}
      className={cn(
        "flex size-11 items-center justify-center rounded-full border border-border bg-surface text-primary-strong transition-colors hover:bg-ivory focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/50",
        className,
      )}
    >
      <Icon className="size-5" strokeWidth={1.75} aria-hidden />
    </button>
  );
}
