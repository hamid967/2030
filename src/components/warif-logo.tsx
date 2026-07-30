import { cn } from "@/lib/utils";

/**
 * Warif brand mark: an abstract petal/leaf holding the Arabic letter "و",
 * wrapped by a light circular path symbolising the cycle (blueprint section 4).
 * Kept legible at app-icon size.
 */
export function WarifLogo({ className }: { className?: string }) {
  return (
    <span className={cn("inline-flex items-center gap-2", className)}>
      <svg
        viewBox="0 0 48 48"
        role="img"
        aria-hidden
        className="size-9"
        fill="none"
      >
        <circle
          cx="24"
          cy="24"
          r="20"
          stroke="var(--warif-rose)"
          strokeWidth="1.5"
          strokeDasharray="4 5"
        />
        <path
          d="M24 6c7 6 11 12 11 19a11 11 0 1 1-22 0c0-7 4-13 11-19Z"
          fill="var(--warif-primary)"
        />
        <path
          d="M19 22c0 4 1.5 6.5 4 6.5s4-2.5 4-6.5"
          stroke="var(--warif-ivory)"
          strokeWidth="2"
          strokeLinecap="round"
        />
        <circle cx="28.5" cy="20.5" r="1.6" fill="var(--warif-ivory)" />
      </svg>
    </span>
  );
}
