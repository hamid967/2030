import type { Account, Consents } from "./types";
import { CONSENT_KEYS } from "./types";

export * from "./types";

/** All four separate consents (terms, privacy, health data, community). */
export function allConsentsGiven(consents: Consents): boolean {
  return CONSENT_KEYS.every((key) => consents[key] === true);
}

export function verifyEmail(account: Account, code: string): Account {
  if (account.verificationCode !== code.trim()) {
    throw new Error("invalid_code");
  }
  return { ...account, emailVerified: true };
}

/** Eligible to submit an activation request. */
export function canSubmit(account: Account, consents: Consents): boolean {
  return account.emailVerified && allConsentsGiven(consents);
}

export function submitActivation(
  account: Account,
  consents: Consents,
  now: string,
): Account {
  if (!account.emailVerified) throw new Error("email_unverified");
  if (!allConsentsGiven(consents)) throw new Error("consents_incomplete");
  return {
    ...account,
    consents,
    status: "pending_activation",
    submittedAt: now,
    rejectionReason: undefined,
  };
}

/**
 * Admin approval. Deliberately only flips status — it does NOT start any trial
 * (Phase 1 constraint). The trial lifecycle is introduced in Phase 2.
 */
export function approve(account: Account): Account {
  if (account.status !== "pending_activation") {
    throw new Error("not_pending");
  }
  return { ...account, status: "approved", rejectionReason: undefined };
}

export function reject(account: Account, reason: string): Account {
  if (account.status !== "pending_activation") {
    throw new Error("not_pending");
  }
  return { ...account, status: "rejected", rejectionReason: reason };
}

export function resubmit(account: Account, now: string): Account {
  if (account.status !== "rejected") {
    throw new Error("not_rejected");
  }
  return {
    ...account,
    status: "pending_activation",
    submittedAt: now,
    rejectionReason: undefined,
  };
}
