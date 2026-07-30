import { getTranslations, setRequestLocale } from "next-intl/server";
import { FileText, Lock } from "lucide-react";
import { Card } from "@/components/ui/card";

// The PDF health report is intentionally behind a flag until the medical
// content review and short-lived signed links are in place (later batch).
const REPORTS_ENABLED = false;

export default async function ReportsPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  const t = await getTranslations("Reports");

  return (
    <>
      <div className="mb-6 text-center">
        <h1 className="text-3xl font-bold text-text">{t("title")}</h1>
        <p className="mt-1 text-muted">{t("subtitle")}</p>
      </div>

      <Card className="flex flex-col items-center gap-3 text-center">
        <span className="flex size-12 items-center justify-center rounded-full bg-lavender/20 text-primary-strong">
          {REPORTS_ENABLED ? (
            <FileText className="size-6" strokeWidth={1.75} aria-hidden />
          ) : (
            <Lock className="size-6" strokeWidth={1.75} aria-hidden />
          )}
        </span>
        <p className="text-muted">{t("comingSoon")}</p>
        <ul className="mt-2 space-y-1 text-start text-sm text-muted">
          <li>• {t("point1")}</li>
          <li>• {t("point2")}</li>
          <li>• {t("point3")}</li>
        </ul>
      </Card>
    </>
  );
}
