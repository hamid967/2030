/**
 * Phase 1 account model.
 *
 * NOTE: This is a client-side, localStorage-backed stand-in for Supabase Auth
 * (no backend runs in this MVP). It is NOT real authentication/security — it
 * exists so the sign-up → verify → consent → activation flow can be built and
 * demonstrated end to end. `use-account.ts` is the single seam to swap to
 * Supabase Auth + RLS later.
 *
 * The 14-day trial is intentionally NOT started in Phase 1, so this model has
 * no trial fields at all.
 */
export type AccountStatus =
  "email_unverified" | "pending_activation" | "approved" | "rejected";

export const CONSENT_KEYS = [
  "terms",
  "privacy",
  "health",
  "community",
] as const;

export type ConsentKey = (typeof CONSENT_KEYS)[number];

export type Consents = Record<ConsentKey, boolean>;

export const EMPTY_CONSENTS: Consents = {
  terms: false,
  privacy: false,
  health: false,
  community: false,
};

export interface Account {
  id: string;
  email: string;
  displayName: string;
  status: AccountStatus;
  emailVerified: boolean;
  consents: Consents;
  /** Human-facing activation request reference. */
  requestNumber: string;
  rejectionReason?: string;
  createdAt: string;
  submittedAt?: string;
  /** Local mock only: the code "emailed" for verification. */
  verificationCode: string;
}
