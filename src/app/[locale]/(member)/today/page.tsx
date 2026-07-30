import { getTranslations, setRequestLocale } from "next-intl/server";
import { TodayExperience } from "@/components/cycle/today-experience";
import { WeekSummary } from "@/components/checkin/week-summary";

export default async function TodayPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations();

  return (
    <>
      <div className="mb-6 text-center">
        <h1 className="text-3xl font-bold text-text">{t("Today.title")}</h1>
        <p className="mt-1 text-muted">{t("Today.subtitle")}</p>
      </div>
      <TodayExperience />
      <div className="mt-6">
        <WeekSummary />
      </div>
    </>
  );
}
