# Warif — Batch 2+ plan (deferred work)

This documents work intentionally deferred after the Saudi Batch 1 upgrade. It
is a plan only — no code here.

## Delivered in Batch 1 (this branch)

- Timezone-safe local dates (`getLocalDateISO`, Riyadh default) across Today,
  Check-in, Calendar, Insights, Week summary.
- Prediction engine `predictCycle` (Median + MAD, confidence
  insufficient/low/medium/high, sampleCount, ranges) surfaced on Today.
- Visual "states" (السكون/التجدد/التوازن/الاحتواء) + semantic phase tokens; a
  "show visual personas" setting.
- 5-tab mobile shell (يومي / التقويم / تسجيل center / دليل وريف / المجتمع),
  `SensitiveDataToggle`, safe-area.
- New routes: `/insights`, `/reports` (flagged), `/learn` + `/learn/[slug]`,
  `/community` + `/community/[space]`, `/settings/privacy`,
  `/settings/subscription`.
- Repository interfaces + Local adapters (`src/lib/repositories`).
- Saudi visual identity integrated; all ar/en translations.

## Batch 2 — richer daily flows

- **Check-in wizard** as a bottom sheet with the full category set (pain 0–10 +
  location, discharge, digestion/appetite, skin, movement, optional BBT,
  medication, private note), per-category skip, local draft, Zod validation of
  legacy data.
- **Calendar**: month + week views, actual vs estimated period styling, fertile
  "تقديري" pattern, Day Details sheet, period start/end editor sheet.
- **Cycle Recap** after each completed cycle; 3-vs-6 cycle comparison on
  Insights.

## Batch 3 — reports & sharing

- **PDF report** generation on explicit request, section selection, short-lived
  signed link, admins cannot download.
- **دائرة الثقة (Sharing)** behind a flag: single-use, short-lived invites,
  read-only derived snapshot (estimated phase, next-period range, approved care
  card only), instant revoke, access log. Never grant partners RLS on health
  tables.

## Batch 4 — backend (Supabase) with Auth + RLS

- Schema separation: `public` / `private` / `health` / `sharing` schemas.
- Health operations only via `SECURITY DEFINER` RPCs with fixed `search_path`;
  RPCs derive `auth.uid()` server-side and never accept client-provided
  `user_id`/`health_identity_id`.
- deny-by-default RLS; admins/moderators/support have no `SELECT` on health.
- `SupabaseCycleRepository` / `SupabaseCheckinRepository` adapters.
- `HealthSyncConsentDialog` to migrate local data with `client_migration_id`
  idempotency; option to keep data on-device only; never delete local data
  before a fully successful, consented sync.

## Batch 5 — activation, trial, subscriptions, community moderation

- Admin activation console + RBAC + audit logs.
- 14-day trial starting at server-side activation time (idempotent), reminders,
  no hidden renewal, no data deletion on expiry.
- Community moderation queue, reports, verified expert badges, pre-moderation.

## Later

- Medical content CMS with real medical review workflow.
- Apple Health / Health Connect / Oura integrations.
- Trying-to-conceive / pregnancy modes.

## Negative DB tests to add with Supabase

- User A cannot read user B's data.
- Admin cannot read health tables.
- Moderator cannot resolve a community identity to an account or health data.
- Client cannot change trial dates or role.
- Revoked sharing blocks reads immediately.
