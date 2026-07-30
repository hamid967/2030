import { getTranslations, setRequestLocale } from "next-intl/server";
import { Link } from "@/i18n/navigation";
import { LanguageSwitcher } from "@/components/language-switcher";
import { WarifLogo } from "@/components/warif-logo";
import { TodayExperience } from "@/components/cycle/today-experience";

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
      <header className="mx-auto flex w-full max-w-2xl items-center justify-between px-6 py-5">
        <Link href="/" className="flex items-center gap-2">
          <WarifLogo />
          <span className="text-xl font-bold text-primary-strong">
            {t("Common.brand")}
          </span>
        </Link>
        <LanguageSwitcher />
      </header>

      <main className="mx-auto w-full max-w-2xl flex-1 px-6 pb-16">
        <div className="mb-6 text-center">
          <h1 className="text-3xl font-bold text-text">{t("Today.title")}</h1>
          <p className="mt-1 text-muted">{t("Today.subtitle")}</p>
        </div>
        <TodayExperience />
      </main>
    </>
  );
}
