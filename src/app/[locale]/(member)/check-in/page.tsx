import { getTranslations, setRequestLocale } from "next-intl/server";
import Image from "next/image";
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
      <Image
        src="/illustrations/check-in-square.png"
        alt={t("imageAlt")}
        width={1254}
        height={1254}
        sizes="(max-width: 768px) 100vw, 640px"
        className="mb-6 aspect-square w-full rounded-card object-cover"
      />
      <CheckInForm />
    </>
  );
}
