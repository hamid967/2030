"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useTranslations } from "next-intl";
import { useAccount } from "@/hooks/use-account";
import { useRouter, Link } from "@/i18n/navigation";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

const schema = z.object({
  displayName: z.string().trim().min(2, "name"),
  email: z.string().trim().email("email"),
  password: z.string().min(8, "password"),
});

type FormValues = z.infer<typeof schema>;

const errorKey: Record<string, string> = {
  name: "errorName",
  email: "errorEmail",
  password: "errorPassword",
};

export function SignUpForm() {
  const t = useTranslations("Auth");
  const router = useRouter();
  const { signUp, signInWithApple } = useAccount();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { displayName: "", email: "", password: "" },
  });

  const err = (code?: string) =>
    code ? t(errorKey[code] ?? "errorName") : null;

  return (
    <Card>
      <h1 className="text-2xl font-bold text-text">{t("signUpTitle")}</h1>
      <p className="mt-1 text-muted">{t("signUpSubtitle")}</p>

      <form
        className="mt-6 flex flex-col gap-5"
        noValidate
        onSubmit={handleSubmit((values) => {
          signUp({ email: values.email, displayName: values.displayName });
          router.push("/today");
        })}
      >
        <div className="flex flex-col gap-1.5">
          <Label htmlFor="displayName">{t("nameLabel")}</Label>
          <Input
            id="displayName"
            autoComplete="name"
            {...register("displayName")}
          />
          {errors.displayName && (
            <p className="text-sm text-danger">
              {err(errors.displayName.message)}
            </p>
          )}
        </div>

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
            <p className="text-sm text-danger">{err(errors.email.message)}</p>
          )}
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="password">{t("passwordLabel")}</Label>
          <Input
            id="password"
            type="password"
            autoComplete="new-password"
            {...register("password")}
          />
          {errors.password && (
            <p className="text-sm text-danger">
              {err(errors.password.message)}
            </p>
          )}
        </div>

        <Button type="submit" size="lg" className="w-full">
          {t("signUpSubmit")}
        </Button>
      </form>

      <div className="my-5 flex items-center gap-3 text-xs text-muted">
        <span className="h-px flex-1 bg-border" />
        <span>{t("dividerOr")}</span>
        <span className="h-px flex-1 bg-border" />
      </div>

      <Button
        type="button"
        variant="outline"
        size="lg"
        className="w-full"
        onClick={() => {
          signInWithApple();
          router.push("/today");
        }}
      >
        {t("continueWithApple")}
      </Button>

      <p className="mt-4 text-center text-sm text-muted">
        {t("haveAccount")} {" "}
        <Link
          href="/auth/login"
          className="font-medium text-primary hover:text-primary-strong"
        >
          {t("loginLink")}
        </Link>
      </p>
    </Card>
  );
}
