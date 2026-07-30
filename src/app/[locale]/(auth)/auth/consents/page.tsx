import { setRequestLocale } from "next-intl/server";
import { ConsentsForm } from "@/components/auth/consents-form";

export default async function ConsentsPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  return <ConsentsForm />;
}
