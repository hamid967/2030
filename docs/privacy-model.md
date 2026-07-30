# ADR 0002 — Privacy model (Phase 0)

**Status:** Accepted · **Date:** 2026-07-30 · **Phase:** 0 (Foundation)

## Context

Cycle, symptom, fertility, mood and medication data are **sensitive health
data**. Privacy is a core product feature, not a legal afterthought (blueprint
section 11). Saudi PDPL applies.

## Decision — non-negotiable principles

1. **Three separate identities**
   - Account identity (`profiles`, linked to Auth) — minimal account data.
   - Health identity (`health_identities`) — a random internal id; health tables
     reference `health_identity_id`, never email/phone.
   - Community identity (`community_identities`) — a different id + pseudonym.
   - The link between community and health is never exposed to the client or to
     community moderators.
2. **Least privilege / deny-by-default RLS** on every sensitive table.
   Ordinary admins and moderators must not have `SELECT` on health tables.
3. **No advertising SDKs / trackers** (no Meta Pixel) that could receive health
   or community content.
4. **No sensitive data** in URLs, logs, analytics event properties, push
   notification previews or error reports. Notification copy is generic by
   default ("You have an update from Warif").
5. **User rights always available:** export, correction, consent withdrawal and
   deletion — including after trial/subscription expiry. Health data is never
   held behind a paywall.
6. **Immutable audit logs** for sensitive administrative actions; not editable
   from the UI.
7. **Separate explicit consents** for Terms, Privacy, Sensitive Health Data
   processing and Community Participation.

## Medical safety

Predictions are labelled estimates; the product never diagnoses conditions,
never presents fertile-window estimates as contraception, and never produces
medication/treatment advice.

## Phase 0 status

This ADR records the model. Schema and RLS policies that enforce it are
introduced from Phase 1 onward and covered by negative RLS tests.
