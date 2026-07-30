import { setRequestLocale } from "next-intl/server";
import { VerifyEmail } from "@/components/auth/verify-email";

export default async function VerifyPage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  setRequestLocale(locale);
  return <VerifyEmail />;
}
