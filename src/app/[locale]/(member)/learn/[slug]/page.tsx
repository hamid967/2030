import { notFound } from "next/navigation";
import { getTranslations, setRequestLocale } from "next-intl/server";
import { Clock, FlaskConical, ArrowRight, ArrowLeft } from "lucide-react";
import { getArticle, articles } from "@/lib/content/articles";
import { Card } from "@/components/ui/card";
import { Link } from "@/i18n/navigation";

export function generateStaticParams() {
  return articles.map((a) => ({ slug: a.slug }));
}

export default async function ArticlePage({
  params,
}: {
  params: Promise<{ locale: string; slug: string }>;
}) {
  const { locale, slug } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Learn");
  const loc = locale === "en" ? "en" : "ar";

  const article = getArticle(slug);
  if (!article) notFound();

  return (
    <article className="flex flex-col gap-5">
      <Link
        href="/learn"
        className="inline-flex items-center gap-1 text-sm font-medium text-primary hover:text-primary-strong"
      >
        <ArrowRight className="size-4 rtl:block ltr:hidden" aria-hidden />
        <ArrowLeft className="size-4 ltr:block rtl:hidden" aria-hidden />
        {t("backToLibrary")}
      </Link>

      <div className="flex flex-wrap items-center gap-2 text-xs">
        <span className="rounded-full bg-lavender/20 px-2 py-0.5 font-medium text-primary-strong">
          {t(`cat_${article.category}`)}
        </span>
        <span className="flex items-center gap-1 text-muted">
          <Clock className="size-3.5" aria-hidden />
          {t("readingMinutes", { minutes: article.readingMinutes })}
        </span>
      </div>

      <h1 className="text-3xl font-bold text-text">{article.title[loc]}</h1>
      <p className="text-lg text-muted">{article.summary[loc]}</p>

      {article.experimental && (
        <Card className="flex items-start gap-2 border-balance/40 bg-balance/10">
          <FlaskConical
            className="mt-0.5 size-5 shrink-0"
            style={{ color: "var(--warif-primary-strong)" }}
            aria-hidden
          />
          <p className="text-sm text-primary-strong">{t("experimentalNote")}</p>
        </Card>
      )}

      <div className="flex flex-col gap-3 text-text">
        {article.body[loc].map((p, i) => (
          <p key={i}>{p}</p>
        ))}
      </div>

      <Card className="text-sm text-muted">
        <p>
          <span className="font-medium text-text">{t("reviewLabel")}:</span>{" "}
          {article.reviewer ?? t("notReviewed")}
        </p>
        <p className="mt-1">
          <span className="font-medium text-text">{t("sourcesLabel")}:</span>{" "}
          {article.sources.length > 0
            ? article.sources.join("، ")
            : t("noSources")}
        </p>
      </Card>
    </article>
  );
}
