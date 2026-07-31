"use client";

import { useLocale } from "next-intl";
import { Sparkles } from "lucide-react";
import { Card } from "@/components/ui/card";

export function ThreeDCompanion() {
  const locale = useLocale();
  const isArabic = locale === "ar";

  return (
    <Card className="warif-3d-stage overflow-hidden p-0">
      <div className="relative min-h-56 px-6 py-6">
        <div className="warif-orbit" aria-hidden>
          <span className="warif-orbit-dot warif-orbit-dot-a" />
          <span className="warif-orbit-dot warif-orbit-dot-b" />
          <span className="warif-orbit-dot warif-orbit-dot-c" />
        </div>

        <div className="relative z-10 flex min-h-44 items-center justify-between gap-5">
          <div className="max-w-[58%]">
            <span className="inline-flex items-center gap-1 rounded-full bg-surface/80 px-3 py-1 text-xs font-medium text-primary-strong ring-1 ring-border">
              <Sparkles className="size-3.5" aria-hidden />
              {isArabic ? "تجربة تفاعلية" : "Interactive mode"}
            </span>
            <h2 className="mt-3 text-2xl font-bold text-text">
              {isArabic ? "وريف يتحرك مع يومك" : "Warif moves with your day"}
            </h2>
            <p className="mt-2 text-sm leading-6 text-muted">
              {isArabic
                ? "شخصية هادئة ومشهد ثلاثي الأبعاد يضيفان حياة للتطبيق دون تشتيت."
                : "A calm companion and 3D scene bring the app to life without distraction."}
            </p>
          </div>

          <div className="warif-persona-wrap" aria-hidden>
            <div className="warif-persona">
              <span className="warif-persona-hair" />
              <span className="warif-persona-face" />
              <span className="warif-persona-body" />
              <span className="warif-persona-phone" />
            </div>
          </div>
        </div>
      </div>
    </Card>
  );
}
