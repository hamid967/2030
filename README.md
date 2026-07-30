# وريف | Warif

> افهمي دورتك. اعتني بنفسك. لستِ وحدك.
>
> _Understand your cycle. Care for yourself. You are not alone._

Warif is a privacy-first, Arabic-first (RTL) women's wellness and menstrual
cycle tracking **PWA**. It helps users track their cycle and daily symptoms,
read medically reviewed educational content, and take part in a pseudonymous,
moderated community. Warif is an educational and support tool — **not** a
diagnostic or treatment tool.

This repository currently contains **Phase 0 — Foundation**: project scaffold,
RTL/i18n, brand design tokens, Supabase client scaffolding, and a rendered
bilingual landing page. Feature phases (auth/activation, cycle tracking,
insights, articles, community, subscriptions) follow.

## Tech stack

Next.js 16 (App Router) · TypeScript (strict) · Tailwind CSS v4 ·
`next-intl` (ar/en) · Supabase (Auth + PostgreSQL + Storage, RLS) ·
React Hook Form + Zod · Vitest.

## Getting started

```bash
npm install
cp .env.example .env.local   # fill in values (placeholders are fine for Phase 0)
npm run dev                  # http://localhost:3000  → redirects to /ar
```

The default locale is Arabic (RTL) at `/ar`; English (LTR) is at `/en`.

## Scripts

| Command             | Purpose                    |
| ------------------- | -------------------------- |
| `npm run dev`       | Start the dev server       |
| `npm run build`     | Production build           |
| `npm run start`     | Serve the production build |
| `npm run lint`      | ESLint                     |
| `npm run typecheck` | `tsc --noEmit`             |
| `npm test`          | Vitest unit tests          |
| `npm run format`    | Prettier                   |

## Local Supabase (optional for Phase 0)

Running the backend locally requires **Docker** and the **Supabase CLI**:

```bash
supabase start   # boots Postgres + Auth + Storage; prints local URL + keys
```

Phase 0 screens are public and do not query the database, so the app runs with
placeholder Supabase values.

## Documentation

- `docs/architecture.md` — architecture decisions (ADR 0001)
- `docs/privacy-model.md` — privacy & medical-safety model (ADR 0002)
