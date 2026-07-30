"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useTranslations } from "next-intl";
import { useAccount } from "@/hooks/use-account";
import { useRouter, Link } from "@/i18n/navigation";
import type { AccountStatus } from "@/lib/account";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const schema = z.object({
  email: z.string().trim().email("email"),
  password: z.string().min(1, "password"),
});

type FormValues = z.infer<typeof schema>;

const destinationFor: Record<AccountStatus, string> = {
  email_unverified: "/auth/verify",
  pending_activation: "/pending-activation",
  approved: "/today",
  rejected: "/pending-activation",
};

export function LoginForm() {
  const t = useTranslations("Auth");
  const router = useRouter();
  const { account } = useAccount();
  const [notFound, setNotFound] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { email: "", password: "" },
  });

  return (
    <Card>
      <h1 className="text-2xl font-bold text-text">{t("loginTitle")}</h1>
      <p className="mt-1 text-muted">{t("loginSubtitle")}</p>

      <form
        className="mt-6 flex flex-col gap-5"
        noValidate
        onSubmit={handleSubmit((values) => {
          if (account && account.email === values.email.trim()) {
            setNotFound(false);
            router.push(destinationFor[account.status]);
          } else {
            setNotFound(true);
          }
        })}
      >
        <div className="flex flex-col gap-1.5">
          <Label htmlFor="email">{t("emailLabel")}</Label>
          <Input
            id="email"
            type="email"
            autoComplete="email"
            dir="ltr"
            {...register("email")}
          />
          {errors.email && (
            <p className="text-sm text-danger">{t("errorEmail")}</p>
          )}
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="password">{t("passwordLabel")}</Label>
          <Input
            id="password"
            type="password"
            autoComplete="current-password"
            {...register("password")}
          />
        </div>

        {notFound && (
          <p className="text-sm text-danger">{t("errorNoAccount")}</p>
        )}

        <Button type="submit" size="lg" className="w-full">
          {t("loginSubmit")}
        </Button>
      </form>

      <p className="mt-4 text-center text-sm text-muted">
        {t("noAccount")}{" "}
        <Link
          href="/auth/sign-up"
          className="font-medium text-primary hover:text-primary-strong"
        >
          {t("signUpLink")}
        </Link>
      </p>
    </Card>
  );
}
