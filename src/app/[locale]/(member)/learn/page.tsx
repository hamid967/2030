import { getTranslations, setRequestLocale } from "next-intl/server";
import { LearnLibrary } from "@/components/learn/learn-library";

export default async function LearnPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Learn");

  return (
    <>
      <div className="mb-6 text-center">
        <h1 className="text-3xl font-bold text-text">{t("title")}</h1>
        <p className="mt-1 text-muted">{t("subtitle")}</p>
      </div>
      <LearnLibrary />
    </>
  );
}
