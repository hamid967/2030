# AGENTS.md

## Cursor Cloud specific instructions

### Product

Warif (وريف) is an **Arabic-first, RTL** women's wellness & menstrual cycle
tracking **PWA**. Stack: Next.js 16 (App Router), TypeScript strict, Tailwind
CSS v4, `next-intl`, Supabase (Auth/Postgres/Storage + RLS), React Hook Form +
Zod, Vitest. The repo currently holds **Phase 0 (foundation)** only; feature
phases follow the blueprint. See `README.md` for scripts and `docs/` for the
architecture + privacy ADRs.

### Running

- One service: the Next.js dev server. Standard commands are in `package.json`
  (`dev`, `build`, `lint`, `typecheck`, `test`, `format`). Dev serves on
  port `3000`.
- The app is locale-prefixed: `/` **redirects to `/ar`** (Arabic, RTL, default);
  English is at `/en` (LTR). There is no unprefixed page — hitting `/` without
  the redirect will 404, this is expected.

### Non-obvious gotchas

- The i18n routing middleware is `src/proxy.ts`, **not** `middleware.ts`. Next 16
  renamed the convention; do not re-add a `middleware.ts` (it triggers a
  deprecation warning and can conflict).
- Direction (`dir="rtl"`/`ltr"`) is derived from the locale in
  `src/app/[locale]/layout.tsx` via `localeDirection` in `src/i18n/routing.ts`.
  Don't hardcode direction in components.
- UI must use the brand design tokens declared in `src/app/globals.css`
  (`@theme`): use Tailwind classes like `bg-primary`, `text-muted`,
  `rounded-card`. Do not hardcode hex colors.
- Translation strings live in `src/messages/{ar,en}.json`. The two files **must
  expose identical keys** — a unit test (`tests/unit/messages.test.ts`) enforces
  parity, so add keys to both.
- **Local Supabase needs Docker + the Supabase CLI** (`supabase start`), and
  Docker is **not** preinstalled in this VM. Phase 0 screens are public and do
  not query the DB, so the app runs with the placeholder values in `.env.local`
  (copy from `.env.example`). Only install Docker/CLI when a task actually needs
  the database.
- Privacy is a hard product constraint (separate account/health/community
  identities, deny-by-default RLS, no health data in logs/URLs/analytics). See
  `docs/privacy-model.md` before touching data models or logging.
- The "My day with Warif" experience lives at `/[locale]/today`. The cycle math
  is a pure, tested module in `src/lib/cycle-engine/` (inject `today` — never
  read the clock inside it, so tests stay deterministic). In this pre-backend
  MVP the cycle profile is stored **client-side only** in `localStorage` via
  `src/hooks/use-cycle-profile.ts` (health data never leaves the device); this
  hook is the single seam to swap to an RLS-protected store later. All engine
  outputs are estimates and must keep the non-diagnostic / not-contraception
  disclaimers.
- Member pages share an app shell in `src/app/[locale]/(member)/layout.tsx`
  (header + bottom nav); tabs are `today`, `calendar`, `check-in`. Daily
  check-ins are also sensitive health data, stored client-side only via
  `src/hooks/use-checkins.ts` (pure helpers/tests in `src/lib/checkins`).
  Client stores use `useSyncExternalStore` for hydration safety — read
  `today`/dates only after the `hydrated` flag to avoid SSR mismatches.
- PWA/brand: `src/app/manifest.ts` uses PNG icons in `public/brand/`
  (`app-icon-192/512`, `apple-touch-icon`); brand illustrations live in
  `public/illustrations/` and are rendered with `next/image` (alt text comes
  from i18n messages). `themeColor` is set via the `viewport` export in
  `src/app/[locale]/layout.tsx`.
- Dates: never use `toISOString().slice(0,10)` for a local date. Use
  `getLocalDateISO()` from `src/lib/datetime.ts` (defaults to `Asia/Riyadh`).
  Prediction/engine functions are pure — always pass `today`/`generatedAt`.
- Prediction: `src/lib/cycle-engine/predict.ts` (`predictCycle`) returns a
  `confidence` (insufficient/low/medium/high) from Median + MAD over the logged
  `periodStarts`. The cycle profile now keeps a `periodStarts[]` history
  (append via `logPeriodStart`, the "بدأت الدورة" action).
- Design tokens are semantic: use `--phase-menstrual/follicular/
  ovulation-estimate/luteal`, `--surface-*`, `--text-*`, `--border-soft` (and
  the `stillness/renewal/balance/containment` Tailwind aliases). Do not hardcode
  hex. Visual "states" live in `src/lib/cycle-engine/visual-states.ts` and can be
  turned off via the "visual personas" setting.
- Storage seam: `src/lib/repositories` defines `CycleRepository`/
  `CheckinRepository` with Local adapters; Supabase adapters + Auth/RLS are
  Batch 2 (see `docs/batch-2-plan.md`). Learn/Community are prototypes backed by
  typed fixtures in `src/lib/content` and `src/lib/community` (seed content is
  labelled experimental — never present it as approved medical content).
- CI: `.eas/workflows/ci.yml` is an EAS Workflow (custom job) that runs
  `lint`/`typecheck`/`test`/`build` on push to `main`, PRs, or manual runs.
  When running it from the EAS dashboard, pick a **git ref that contains the
  file** (e.g. `main`). It's a generic Node CI job — no native Expo build yet.
- Phase 1 auth lives under the `(auth)` route group (`onboarding`,
  `auth/sign-up`, `auth/login`, `auth/verify`, `auth/consents`,
  `pending-activation`). It is a **client-side, localStorage-backed stand-in for
  Supabase Auth** (`src/hooks/use-account.ts`; pure transition logic + tests in
  `src/lib/account`). NOT real security — the single seam to swap to Supabase
  Auth + RLS later. The pending screen includes a clearly-labelled **demo admin
  simulator** (approve/reject) standing in for the Phase 2 admin console; the
  14-day trial is intentionally NOT started here (the account model has no trial
  fields).
