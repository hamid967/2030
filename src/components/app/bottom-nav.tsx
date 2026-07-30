"use client";

import { useTranslations } from "next-intl";
import {
  Sparkles,
  CalendarDays,
  ClipboardList,
  BookOpenText,
  UsersRound,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { Link, usePathname } from "@/i18n/navigation";
import { cn } from "@/lib/utils";

type Tab = {
  href: string;
  icon: LucideIcon;
  key: string;
  center?: boolean;
};

const tabs: Tab[] = [
  { href: "/today", icon: Sparkles, key: "today" },
  { href: "/calendar", icon: CalendarDays, key: "calendar" },
  { href: "/check-in", icon: ClipboardList, key: "checkIn", center: true },
  { href: "/learn", icon: BookOpenText, key: "learn" },
  { href: "/community", icon: UsersRound, key: "community" },
];

export function BottomNav() {
  const t = useTranslations("Nav");
  const pathname = usePathname();

  return (
    <nav
      aria-label={t("label")}
      className="sticky bottom-0 z-10 border-t border-border bg-surface/95 pb-[env(safe-area-inset-bottom)] backdrop-blur"
    >
      <ul className="mx-auto flex w-full max-w-2xl items-stretch justify-around">
        {tabs.map(({ href, icon: Icon, key, center }) => {
          const active = pathname === href || pathname.startsWith(`${href}/`);
          return (
            <li key={key} className="flex flex-1 justify-center">
              <Link
                href={href}
                aria-current={active ? "page" : undefined}
                className={cn(
                  "flex min-h-14 flex-col items-center justify-center gap-1 text-xs font-medium transition-colors",
                  center && "-mt-4",
                  active
                    ? "text-primary"
                    : "text-muted hover:text-primary-strong",
                )}
              >
                <span
                  className={cn(
                    "flex items-center justify-center",
                    center
                      ? "size-12 rounded-full bg-primary text-white shadow-md shadow-primary/30"
                      : "size-6",
                  )}
                >
                  <Icon
                    className={center ? "size-6" : "size-5"}
                    strokeWidth={1.75}
                    aria-hidden
                  />
                </span>
                {t(key)}
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
