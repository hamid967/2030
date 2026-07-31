import { setRequestLocale, getTranslations } from "next-intl/server";
import { Link } from "@/i18n/navigation";
import { LanguageSwitcher } from "@/components/language-switcher";
import { WarifLogo } from "@/components/warif-logo";
import { BottomNav } from "@/components/app/bottom-nav";
import { MemberActions } from "@/components/app/member-actions";
import { SensitiveDataToggle } from "@/components/app/sensitive-data-toggle";

export default async function MemberLayout({
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
      <header className="mx-auto flex w-full max-w-2xl items-center justify-between px-6 py-4">
        <Link href="/today" className="flex items-center gap-2">
          <WarifLogo />
          <span className="text-xl font-bold text-primary-strong">
            {t("brand")}
          </span>
        </Link>
        <div className="flex items-center gap-2">
          <SensitiveDataToggle />
          <MemberActions />
          <LanguageSwitcher />
        </div>
      </header>

      <main className="mx-auto w-full max-w-2xl flex-1 px-6 pb-8">
        {children}
      </main>

      <BottomNav />
    </div>
  );
}
