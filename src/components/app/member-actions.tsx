"use client";

import { useState } from "react";
import { Bell, LogOut } from "lucide-react";
import { useLocale } from "next-intl";
import { useRouter } from "@/i18n/navigation";
import { useAccount } from "@/hooks/use-account";
import { cn } from "@/lib/utils";

export function MemberActions({ className }: { className?: string }) {
  const locale = useLocale();
  const router = useRouter();
  const { signOut } = useAccount();
  const [noticeOpen, setNoticeOpen] = useState(false);
  const isArabic = locale === "ar";

  return (
    <div className={cn("relative flex items-center gap-2", className)}>
      <button
        type="button"
        onClick={() => setNoticeOpen((open) => !open)}
        aria-label={isArabic ? "الإشعارات" : "Notifications"}
        className="relative flex size-11 items-center justify-center rounded-full border border-border bg-surface text-primary-strong transition-colors hover:bg-ivory focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/50"
      >
        <Bell className="size-5" strokeWidth={1.75} aria-hidden />
        <span className="absolute right-2 top-2 size-2 rounded-full bg-danger" />
      </button>

      {noticeOpen && (
        <div className="absolute top-13 z-20 w-64 rounded-card border border-border bg-surface p-4 text-sm shadow-lg shadow-primary/10 ltr:right-0 rtl:left-0">
          <p className="font-semibold text-text">
            {isArabic ? "مرحباً بك في وريف" : "Welcome to Warif"}
          </p>
          <p className="mt-1 text-muted">
            {isArabic
              ? "يمكنك الآن التسجيل اليومي والمشاركة في المجتمع مباشرة."
              : "You can now check in daily and join the community instantly."}
          </p>
        </div>
      )}

      <button
        type="button"
        onClick={() => {
          signOut();
          router.push("/auth/login");
        }}
        aria-label={isArabic ? "تسجيل الخروج" : "Log out"}
        className="flex size-11 items-center justify-center rounded-full border border-border bg-surface text-primary-strong transition-colors hover:bg-ivory focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/50"
      >
        <LogOut className="size-5" strokeWidth={1.75} aria-hidden />
      </button>
    </div>
  );
}
