import { setRequestLocale, getTranslations } from "next-intl/server";
import { Link } from "@/i18n/navigation";
import { LanguageSwitcher } from "@/components/language-switcher";
import { WarifLogo } from "@/components/warif-logo";

export default async function AuthLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Common");

  return (
    <div className="flex min-h-dvh flex-col">
      <header className="mx-auto flex w-full max-w-md items-center justify-between px-6 py-4">
        <Link href="/" className="flex items-center gap-2">
          <WarifLogo />
          <span className="text-xl font-bold text-primary-strong">
            {t("brand")}
          </span>
        </Link>
        <LanguageSwitcher />
      </header>
      <main className="mx-auto flex w-full max-w-md flex-1 flex-col justify-center px-6 py-6">
        {children}
      </main>
    </div>
  );
}
