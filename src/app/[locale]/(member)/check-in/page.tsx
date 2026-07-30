import { getTranslations, setRequestLocale } from "next-intl/server";
import { CheckInForm } from "@/components/checkin/check-in-form";

export default async function CheckInPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("CheckIn");

  return (
    <>
      <div className="mb-6 text-center">
        <h1 className="text-3xl font-bold text-text">{t("title")}</h1>
        <p className="mt-1 text-muted">{t("subtitle")}</p>
      </div>
      <CheckInForm />
    </>
  );
}
