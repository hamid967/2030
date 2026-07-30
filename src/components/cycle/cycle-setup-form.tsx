"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useTranslations } from "next-intl";
import type { CycleProfile } from "@/lib/cycle-engine";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";

function todayIso(): string {
  return new Date().toISOString().slice(0, 10);
}

const schema = z.object({
  lastPeriodStart: z
    .string()
    .min(1, { message: "required" })
    .refine((v) => v <= todayIso(), { message: "future" }),
  cycleLength: z.coerce.number().int().min(21, "cycle").max(45, "cycle"),
  periodLength: z.coerce.number().int().min(1, "period").max(10, "period"),
});

type FormValues = z.input<typeof schema>;

const errorMessageKey: Record<string, string> = {
  required: "errorRequired",
  future: "errorFuture",
  cycle: "errorCycleRange",
  period: "errorPeriodRange",
};

export function CycleSetupForm({
  defaultValues,
  onSubmit,
}: {
  defaultValues?: CycleProfile;
  onSubmit: (profile: CycleProfile) => void;
}) {
  const t = useTranslations("CycleSetup");

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: defaultValues ?? {
      lastPeriodStart: "",
      cycleLength: 28,
      periodLength: 5,
    },
  });

  const errorText = (code?: string) =>
    code ? t(errorMessageKey[code] ?? "errorRequired") : null;

  return (
    <Card className="mx-auto w-full max-w-md">
      <h2 className="text-2xl font-bold text-text">{t("title")}</h2>
      <p className="mt-1 text-muted">{t("intro")}</p>

      <form
        className="mt-6 flex flex-col gap-5"
        onSubmit={handleSubmit((values) =>
          onSubmit({
            lastPeriodStart: values.lastPeriodStart,
            cycleLength: Number(values.cycleLength),
            periodLength: Number(values.periodLength),
          }),
        )}
        noValidate
      >
        <div className="flex flex-col gap-1.5">
          <Label htmlFor="lastPeriodStart">{t("lastPeriodLabel")}</Label>
          <Input
            id="lastPeriodStart"
            type="date"
            max={todayIso()}
            {...register("lastPeriodStart")}
          />
          {errors.lastPeriodStart && (
            <p className="text-sm text-danger">
              {errorText(errors.lastPeriodStart.message)}
            </p>
          )}
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="cycleLength">{t("cycleLengthLabel")}</Label>
          <Input
            id="cycleLength"
            type="number"
            min={21}
            max={45}
            inputMode="numeric"
            {...register("cycleLength")}
          />
          {errors.cycleLength && (
            <p className="text-sm text-danger">
              {errorText(errors.cycleLength.message)}
            </p>
          )}
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="periodLength">{t("periodLengthLabel")}</Label>
          <Input
            id="periodLength"
            type="number"
            min={1}
            max={10}
            inputMode="numeric"
            {...register("periodLength")}
          />
          {errors.periodLength && (
            <p className="text-sm text-danger">
              {errorText(errors.periodLength.message)}
            </p>
          )}
        </div>

        <Button type="submit" size="lg" className="w-full">
          {t("submit")}
        </Button>
      </form>
    </Card>
  );
}
