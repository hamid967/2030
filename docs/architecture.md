# ADR 0001 — Architecture (Phase 0)

**Status:** Accepted · **Date:** 2026-07-30 · **Phase:** 0 (Foundation)

## Context

Warif (وريف) is a privacy-first Arabic (RTL) women's wellness and menstrual
cycle tracking product. Phase 0 establishes the technical foundation before any
feature work (see product blueprint sections 12 and 17).

## Decision

- **App:** Next.js (App Router) as a mobile-first PWA. A single repository hosts
  both the member app and the admin console under a `[locale]` segment.
- **Language:** TypeScript in `strict` mode.
- **Styling:** Tailwind CSS v4 with brand design tokens declared in
  `src/app/globals.css` (`@theme`). No hardcoded hex values in components.
- **UI primitives:** shadcn-style hand-authored components (`src/components/ui`)
  using `class-variance-authority` + a `cn()` helper.
- **i18n:** `next-intl` with Arabic (`ar`, default, RTL) and English (`en`, LTR).
  Direction is derived from the locale in the root layout.
- **Backend:** Supabase (Auth + PostgreSQL + Storage) with Row-Level Security.
  Browser and server clients live in `src/lib/supabase`.
- **Forms/validation:** React Hook Form + Zod (added; used from Phase 1).
- **Testing:** Vitest (unit) + Playwright (e2e, added from a later phase).

## Why PWA first

Fastest end-to-end testable model; one repo for member + admin; runs on mobile
and browser; avoids app-store/payment complexity in v1. The member app can later
move to Expo/React Native while keeping the same Supabase backend.

## Consequences

- Running the full backend locally requires Docker + the Supabase CLI
  (`supabase start`). Phase 0 screens (landing/onboarding) are public and do not
  query the database, so the app runs without a live DB.
- All authorization is enforced server-side via RLS; hiding UI is never
  treated as authorization.
