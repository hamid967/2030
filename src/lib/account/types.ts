/**
 * Phase 1 account model.
 *
 * NOTE: This is a development-only stand-in for Supabase Auth. Production
 * member routes are guarded in `src/proxy.ts` by a server-side Supabase session,
 * and this model exists only so the sign-up → verify → consent → activation
 * flow can still be demonstrated without backend credentials.
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
  authProvider?: "email" | "apple" | "admin";
  status: AccountStatus;
  emailVerified: boolean;
  consents: Consents;
  /** Human-facing activation request reference. */
  requestNumber: string;
  rejectionReason?: string;
  createdAt: string;
  submittedAt?: string;
  /** Local development only. Never render this value into the UI. */
  verificationCode: string;
}
