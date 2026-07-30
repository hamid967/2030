import { getTranslations, setRequestLocale } from "next-intl/server";
import Image from "next/image";
import { ShieldCheck } from "lucide-react";
import { communitySpaces } from "@/lib/community/fixtures";
import { Card } from "@/components/ui/card";
import { Link } from "@/i18n/navigation";

export default async function CommunityPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Community");
  const loc = locale === "en" ? "en" : "ar";

  return (
    <div className="flex flex-col gap-6">
      <div>
        <Image
          src="/illustrations/saudi-warif-community-16x9.png"
          alt={t("heroAlt")}
          width={1672}
          height={941}
          priority
          sizes="(max-width: 768px) 100vw, 640px"
          className="w-full rounded-card"
        />
        <h1 className="mt-4 text-3xl font-bold text-text">{t("title")}</h1>
        <p className="mt-1 text-muted">{t("subtitle")}</p>
      </div>

      <Card className="flex items-start gap-2 bg-renewal/10">
        <ShieldCheck
          className="mt-0.5 size-5 shrink-0"
          style={{ color: "var(--phase-follicular)" }}
          aria-hidden
        />
        <p className="text-sm text-muted">{t("disclaimer")}</p>
      </Card>

      <ul className="grid gap-4 sm:grid-cols-2">
        {communitySpaces.map((space) => (
          <li key={space.id}>
            <Link href={`/community/${space.id}`} className="block h-full">
              <Card className="flex h-full flex-col gap-1 transition-shadow hover:shadow-md">
                <h2 className="text-lg font-semibold text-text">
                  {space.name[loc]}
                </h2>
                <p className="text-sm text-muted">{space.description[loc]}</p>
              </Card>
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
}
