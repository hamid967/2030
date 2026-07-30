"use client";

import { useTranslations } from "next-intl";
import { Sparkles, CalendarDays, ClipboardList } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { Link, usePathname } from "@/i18n/navigation";
import { cn } from "@/lib/utils";

const tabs: { href: string; icon: LucideIcon; key: string }[] = [
  { href: "/today", icon: Sparkles, key: "today" },
  { href: "/calendar", icon: CalendarDays, key: "calendar" },
  { href: "/check-in", icon: ClipboardList, key: "checkIn" },
];

export function BottomNav() {
  const t = useTranslations("Nav");
  const pathname = usePathname();

  return (
    <nav
      aria-label={t("label")}
      className="sticky bottom-0 z-10 border-t border-border bg-surface/95 backdrop-blur"
    >
      <ul className="mx-auto flex w-full max-w-2xl items-stretch justify-around">
        {tabs.map(({ href, icon: Icon, key }) => {
          const active = pathname === href;
          return (
            <li key={key} className="flex-1">
              <Link
                href={href}
                aria-current={active ? "page" : undefined}
                className={cn(
                  "flex min-h-14 flex-col items-center justify-center gap-1 text-xs font-medium transition-colors",
                  active
                    ? "text-primary"
                    : "text-muted hover:text-primary-strong",
                )}
              >
                <Icon className="size-5" aria-hidden />
                {t(key)}
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
