import { notFound } from "next/navigation";
import { getTranslations, setRequestLocale } from "next-intl/server";
import Image from "next/image";
import { ArrowRight, ArrowLeft } from "lucide-react";
import {
  getSpace,
  postsForSpace,
  communitySpaces,
} from "@/lib/community/fixtures";
import { CommunitySpaceClient } from "@/components/community/community-space-client";
import { Card } from "@/components/ui/card";
import { Link } from "@/i18n/navigation";

export function generateStaticParams() {
  return communitySpaces.map((s) => ({ space: s.id }));
}

export default async function SpacePage({
  params,
}: {
  params: Promise<{ locale: string; space: string }>;
}) {
  const { locale, space: spaceId } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Community");
  const loc = locale === "en" ? "en" : "ar";

  const space = getSpace(spaceId);
  if (!space) notFound();
  const posts = postsForSpace(spaceId);

  return (
    <div className="flex flex-col gap-5">
      <Link
        href="/community"
        className="inline-flex items-center gap-1 text-sm font-medium text-primary hover:text-primary-strong"
      >
        <ArrowRight className="size-4 rtl:block ltr:hidden" aria-hidden />
        <ArrowLeft className="size-4 ltr:block rtl:hidden" aria-hidden />
        {t("backToSpaces")}
      </Link>

      <div>
        <h1 className="text-3xl font-bold text-text">{space.name[loc]}</h1>
        <p className="mt-1 text-muted">{space.description[loc]}</p>
      </div>

      {posts.length === 0 ? (
        <Card className="flex flex-col items-center gap-3 py-6 text-center">
          <Image
            src="/illustrations/hero-community-16x9.png"
            alt={t("emptyAlt")}
            width={1672}
            height={941}
            sizes="(max-width: 768px) 100vw, 480px"
            className="w-full rounded-card"
          />
          <p className="text-muted">{t("empty")}</p>
        </Card>
      ) : (
        <CommunitySpaceClient spaceId={spaceId} seedPosts={posts} />
      )}

      <p className="text-center text-xs text-muted">{t("disclaimer")}</p>
    </div>
  );
}
