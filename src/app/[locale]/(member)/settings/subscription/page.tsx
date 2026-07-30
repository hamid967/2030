import { getTranslations, setRequestLocale } from "next-intl/server";
import { Sparkles } from "lucide-react";
import { Card } from "@/components/ui/card";

export default async function SubscriptionSettingsPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Subscription");

  return (
    <>
      <div className="mb-6 text-center">
        <h1 className="text-3xl font-bold text-text">{t("title")}</h1>
        <p className="mt-1 text-muted">{t("subtitle")}</p>
      </div>

      <Card className="flex flex-col items-center gap-3 text-center">
        <span className="flex size-12 items-center justify-center rounded-full bg-primary/10 text-primary">
          <Sparkles className="size-6" strokeWidth={1.75} aria-hidden />
        </span>
        <p className="text-muted">{t("localModeNote")}</p>
        <p className="text-sm text-muted">{t("trialNote")}</p>
      </Card>
    </>
  );
}
