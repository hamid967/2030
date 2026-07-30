"use client";

import { useMemo, useState } from "react";
import { useLocale, useTranslations } from "next-intl";
import { Search, Clock, FlaskConical } from "lucide-react";
import {
  articles,
  ARTICLE_CATEGORIES,
  type ArticleCategory,
} from "@/lib/content/articles";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Link } from "@/i18n/navigation";
import { cn } from "@/lib/utils";

export function LearnLibrary() {
  const t = useTranslations("Learn");
  const locale = useLocale() as "ar" | "en";
  const [query, setQuery] = useState("");
  const [category, setCategory] = useState<ArticleCategory | "all">("all");

  const results = useMemo(() => {
    const q = query.trim().toLowerCase();
    return articles.filter((a) => {
      const inCategory = category === "all" || a.category === category;
      const inQuery =
        q === "" ||
        a.title[locale].toLowerCase().includes(q) ||
        a.summary[locale].toLowerCase().includes(q);
      return inCategory && inQuery;
    });
  }, [query, category, locale]);

  return (
    <div className="flex flex-col gap-5">
      <div className="relative">
        <Search
          className="pointer-events-none absolute top-1/2 size-4 -translate-y-1/2 text-muted ltr:left-3 rtl:right-3"
          aria-hidden
        />
        <Input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder={t("searchPlaceholder")}
          className="ltr:pl-9 rtl:pr-9"
          aria-label={t("searchPlaceholder")}
        />
      </div>

      <div className="flex flex-wrap gap-2">
        {(["all", ...ARTICLE_CATEGORIES] as const).map((cat) => (
          <button
            key={cat}
            type="button"
            onClick={() => setCategory(cat)}
            aria-pressed={category === cat}
            className={cn(
              "min-h-9 rounded-full border px-3 text-sm font-medium transition-colors",
              category === cat
                ? "border-transparent bg-primary text-white"
                : "border-border bg-surface text-muted hover:bg-ivory",
            )}
          >
            {cat === "all" ? t("allCategories") : t(`cat_${cat}`)}
          </button>
        ))}
      </div>

      {results.length === 0 ? (
        <Card className="text-center text-muted">{t("noResults")}</Card>
      ) : (
        <ul className="grid gap-4 sm:grid-cols-2">
          {results.map((a) => (
            <li key={a.slug}>
              <Link href={`/learn/${a.slug}`} className="block h-full">
                <Card className="flex h-full flex-col gap-2 transition-shadow hover:shadow-md">
                  <div className="flex items-center gap-2 text-xs">
                    <span className="rounded-full bg-lavender/20 px-2 py-0.5 font-medium text-primary-strong">
                      {t(`cat_${a.category}`)}
                    </span>
                    {a.experimental && (
                      <span className="flex items-center gap-1 rounded-full bg-balance/20 px-2 py-0.5 font-medium text-primary-strong">
                        <FlaskConical className="size-3" aria-hidden />
                        {t("experimentalShort")}
                      </span>
                    )}
                  </div>
                  <h3 className="text-lg font-semibold text-text">
                    {a.title[locale]}
                  </h3>
                  <p className="text-sm text-muted">{a.summary[locale]}</p>
                  <p className="mt-auto flex items-center gap-1 text-xs text-muted">
                    <Clock className="size-3.5" aria-hidden />
                    {t("readingMinutes", { minutes: a.readingMinutes })}
                  </p>
                </Card>
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
