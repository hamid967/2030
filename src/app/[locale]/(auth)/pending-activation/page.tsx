import { setRequestLocale } from "next-intl/server";
import { PendingActivation } from "@/components/auth/pending-activation";

export default async function PendingActivationPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  return <PendingActivation />;
}
