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
