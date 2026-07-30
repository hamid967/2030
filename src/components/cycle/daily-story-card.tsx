import { useTranslations } from "next-intl";
import { Sparkles, HeartHandshake } from "lucide-react";
import type { CyclePhase } from "@/lib/cycle-engine";
import { phaseTintClass } from "@/lib/cycle-engine/phase-visuals";
import { Card } from "@/components/ui/card";

const storyKey: Record<CyclePhase, string> = {
  menstruation: "menstruationStory",
  follicular: "follicularStory",
  ovulation: "ovulationStory",
  luteal: "lutealStory",
};

const tipKey: Record<CyclePhase, string> = {
  menstruation: "menstruationTip",
  follicular: "follicularTip",
  ovulation: "ovulationTip",
  luteal: "lutealTip",
};

/** Calm, non-diagnostic daily story tied to the cycle phase. */
export function DailyStoryCard({ phase }: { phase: CyclePhase }) {
  const t = useTranslations("Phase");
  const tToday = useTranslations("Today");

  return (
    <div className="grid gap-4 sm:grid-cols-2">
      <Card className={phaseTintClass[phase]}>
        <div className="mb-2 flex items-center gap-2 text-primary-strong">
          <Sparkles className="size-5" aria-hidden />
          <h3 className="text-lg font-semibold">{tToday("storyTitle")}</h3>
        </div>
        <p className="text-muted">{t(storyKey[phase])}</p>
      </Card>

      <Card>
        <div className="mb-2 flex items-center gap-2 text-primary-strong">
          <HeartHandshake className="size-5" aria-hidden />
          <h3 className="text-lg font-semibold">{tToday("tipTitle")}</h3>
        </div>
        <p className="text-muted">{t(tipKey[phase])}</p>
      </Card>
    </div>
  );
}
