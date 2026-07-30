"use client";

import { useState } from "react";
import { useTranslations } from "next-intl";
import { Eye, Sparkles, Download, Trash2, ShieldCheck } from "lucide-react";
import { useVisualPersonas } from "@/hooks/use-visual-personas";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { cn } from "@/lib/utils";

function Toggle({
  checked,
  onChange,
  label,
}: {
  checked: boolean;
  onChange: (v: boolean) => void;
  label: string;
}) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      onClick={() => onChange(!checked)}
      className={cn(
        "relative h-7 w-12 shrink-0 rounded-full transition-colors",
        checked ? "bg-primary" : "bg-border",
      )}
    >
      <span
        className={cn(
          "absolute top-1 size-5 rounded-full bg-white transition-all",
          checked ? "ltr:left-6 rtl:right-6" : "ltr:left-1 rtl:right-1",
        )}
      />
    </button>
  );
}

export function PrivacyCenter() {
  const t = useTranslations("PrivacyCenter");
  const { enabled: personas, setEnabled } = useVisualPersonas();
  const [cleared, setCleared] = useState(false);

  const exportData = () => {
    const data: Record<string, unknown> = {};
    for (let i = 0; i < window.localStorage.length; i++) {
      const key = window.localStorage.key(i);
      if (key && key.startsWith("warif.")) {
        try {
          data[key] = JSON.parse(window.localStorage.getItem(key) ?? "null");
        } catch {
          data[key] = window.localStorage.getItem(key);
        }
      }
    }
    const blob = new Blob([JSON.stringify(data, null, 2)], {
      type: "application/json",
    });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "warif-data.json";
    a.click();
    URL.revokeObjectURL(url);
  };

  const clearData = () => {
    const keys: string[] = [];
    for (let i = 0; i < window.localStorage.length; i++) {
      const key = window.localStorage.key(i);
      if (key && key.startsWith("warif.")) keys.push(key);
    }
    keys.forEach((k) => window.localStorage.removeItem(k));
    setCleared(true);
    window.dispatchEvent(new Event("storage"));
  };

  return (
    <div className="flex flex-col gap-4">
      <Card className="flex items-start gap-2 bg-renewal/10">
        <ShieldCheck
          className="mt-0.5 size-5 shrink-0"
          style={{ color: "var(--phase-follicular)" }}
          aria-hidden
        />
        <p className="text-sm text-muted">{t("intro")}</p>
      </Card>

      <Card className="flex items-center justify-between gap-4">
        <div className="flex items-start gap-3">
          <Sparkles className="mt-0.5 size-5 text-primary" aria-hidden />
          <div>
            <p className="font-semibold text-text">{t("personasTitle")}</p>
            <p className="text-sm text-muted">{t("personasBody")}</p>
          </div>
        </div>
        <Toggle
          checked={personas}
          onChange={setEnabled}
          label={t("personasTitle")}
        />
      </Card>

      <Card className="flex items-start gap-3">
        <Eye className="mt-0.5 size-5 text-primary" aria-hidden />
        <div>
          <p className="font-semibold text-text">{t("sensitiveTitle")}</p>
          <p className="text-sm text-muted">{t("sensitiveBody")}</p>
        </div>
      </Card>

      <Card className="flex flex-col gap-3">
        <p className="font-semibold text-text">{t("dataTitle")}</p>
        <p className="text-sm text-muted">{t("keepOnDevice")}</p>
        <div className="flex flex-wrap gap-3">
          <Button variant="outline" onClick={exportData}>
            <Download className="size-4" aria-hidden />
            {t("exportData")}
          </Button>
          <Button variant="ghost" onClick={clearData}>
            <Trash2 className="size-4" aria-hidden />
            {t("clearData")}
          </Button>
        </div>
        {cleared && (
          <p className="text-sm font-medium text-primary">{t("cleared")}</p>
        )}
      </Card>
    </div>
  );
}
