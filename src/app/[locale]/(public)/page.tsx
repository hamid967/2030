import { getTranslations, setRequestLocale } from "next-intl/server";
import { HeartPulse, CalendarRange, BookOpenCheck, Users } from "lucide-react";
import { buttonVariants } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { LanguageSwitcher } from "@/components/language-switcher";
import { WarifLogo } from "@/components/warif-logo";
import { Link } from "@/i18n/navigation";

export default async function LandingPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations();

  const features = [
    { icon: CalendarRange, key: "feature1" as const },
    { icon: HeartPulse, key: "feature2" as const },
    { icon: BookOpenCheck, key: "feature3" as const },
    { icon: Users, key: "feature4" as const },
  ];

  return (
    <>
      <a
        href="#main"
        className="sr-only focus:not-sr-only focus:absolute focus:m-4 focus:rounded-full focus:bg-primary focus:px-4 focus:py-2 focus:text-white"
      >
        {t("Common.skipToContent")}
      </a>

      <header className="mx-auto flex w-full max-w-5xl items-center justify-between px-6 py-5">
        <div className="flex items-center gap-2">
          <WarifLogo />
          <span className="text-xl font-bold text-primary-strong">
            {t("Common.brand")}
          </span>
        </div>
        <LanguageSwitcher />
      </header>

      <main id="main" className="mx-auto w-full max-w-5xl flex-1 px-6">
        <section className="flex flex-col items-center gap-6 py-14 text-center sm:py-20">
          <p className="rounded-full bg-lavender/15 px-4 py-1 text-sm font-medium text-primary-strong">
            {t("Landing.heroEyebrow")}
          </p>
          <h1 className="max-w-2xl text-4xl font-bold leading-tight text-text sm:text-5xl">
            {t("Landing.heroTitle")}
          </h1>
          <p className="max-w-xl text-lg text-muted">
            {t("Landing.heroSubtitle")}
          </p>
          <p className="text-base font-medium text-primary">
            {t("Common.tagline")}
          </p>
          <div className="flex flex-wrap items-center justify-center gap-3 pt-2">
            <Link href="/today" className={buttonVariants({ size: "lg" })}>
              {t("Common.getStarted")}
            </Link>
            <Link
              href="/today"
              className={buttonVariants({ size: "lg", variant: "outline" })}
            >
              {t("Common.learnMore")}
            </Link>
          </div>
        </section>

        <section className="py-8">
          <h2 className="mb-8 text-center text-2xl font-bold text-text">
            {t("Landing.featuresTitle")}
          </h2>
          <div className="grid gap-5 sm:grid-cols-2">
            {features.map(({ icon: Icon, key }) => (
              <Card key={key} className="flex flex-col gap-3">
                <span className="flex size-11 items-center justify-center rounded-full bg-primary/10 text-primary">
                  <Icon className="size-5" aria-hidden />
                </span>
                <h3 className="text-lg font-semibold text-text">
                  {t(`Landing.${key}Title`)}
                </h3>
                <p className="text-muted">{t(`Landing.${key}Body`)}</p>
              </Card>
            ))}
          </div>
        </section>

        <section className="py-8">
          <Card className="bg-sage/10">
            <h2 className="mb-2 text-xl font-bold text-primary-strong">
              {t("Landing.privacyTitle")}
            </h2>
            <p className="text-muted">{t("Landing.privacyBody")}</p>
          </Card>
        </section>

        <section className="py-8">
          <Card className="border-danger/30 bg-danger/5">
            <h2 className="mb-2 text-lg font-bold text-danger">
              {t("Landing.disclaimerTitle")}
            </h2>
            <p className="text-muted">{t("Landing.disclaimerBody")}</p>
          </Card>
        </section>
      </main>

      <footer className="mx-auto w-full max-w-5xl px-6 py-8 text-center text-sm text-muted">
        <p>{t("Landing.privacyTitle")}</p>
        <p className="mt-1">
          {t("Common.brand")} — {t("Footer.phase")} · {new Date().getFullYear()}{" "}
          © {t("Footer.rights")}
        </p>
      </footer>
    </>
  );
}
