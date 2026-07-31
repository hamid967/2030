"use client";

import { useCallback, useSyncExternalStore } from "react";
import {
  type Account,
  type Consents,
  approve as approveAccount,
  reject as rejectAccount,
  resubmit as resubmitAccount,
  submitActivation as submitActivationTx,
  verifyEmail as verifyEmailTx,
} from "@/lib/account";

/**
 * Client-side account store (localStorage) — a stand-in for Supabase Auth in
 * this pre-backend MVP. Single local account. See `src/lib/account` for the
 * pure, tested transition logic.
 */
const STORAGE_KEY = "warif.account.v1";
const ADMIN_EMAIL = (
  process.env.NEXT_PUBLIC_WARIF_ADMIN_EMAIL ?? "abs005599@gmail.com"
)
  .trim()
  .toLowerCase();
const ADMIN_PASSWORD = process.env.NEXT_PUBLIC_WARIF_ADMIN_PASSWORD ?? "";
const APPLE_DEMO_EMAIL = "apple-user@warif.local";

let cachedRaw: string | null = null;
let cachedValue: Account | null = null;

function parse(raw: string | null): Account | null {
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw) as Account;
    return parsed && typeof parsed.email === "string" ? parsed : null;
  } catch {
    return null;
  }
}

function getSnapshot(): Account | null {
  const raw =
    typeof window === "undefined"
      ? null
      : window.localStorage.getItem(STORAGE_KEY);
  if (raw !== cachedRaw) {
    cachedRaw = raw;
    cachedValue = parse(raw);
  }
  return cachedValue;
}

function getServerSnapshot(): Account | null {
  return null;
}

const listeners = new Set<() => void>();

function subscribe(onStoreChange: () => void): () => void {
  listeners.add(onStoreChange);
  window.addEventListener("storage", onStoreChange);
  return () => {
    listeners.delete(onStoreChange);
    window.removeEventListener("storage", onStoreChange);
  };
}

function persist(account: Account | null) {
  if (account) {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(account));
  } else {
    window.localStorage.removeItem(STORAGE_KEY);
  }
  cachedRaw = null;
  listeners.forEach((l) => l());
}

function randomDigits(n: number): string {
  let out = "";
  for (let i = 0; i < n; i++) out += Math.floor(Math.random() * 10);
  return out;
}

function approvedAccount(input: {
  email: string;
  displayName: string;
  authProvider: NonNullable<Account["authProvider"]>;
}): Account {
  return {
    id:
      typeof crypto !== "undefined" && "randomUUID" in crypto
        ? crypto.randomUUID()
        : randomDigits(12),
    email: input.email.trim(),
    displayName: input.displayName.trim(),
    authProvider: input.authProvider,
    status: "approved",
    emailVerified: true,
    consents: {
      terms: true,
      privacy: true,
      health: true,
      community: true,
    },
    requestNumber:
      input.authProvider === "admin" ? "WRF-ADMIN" : `WRF-${randomDigits(6)}`,
    createdAt: new Date().toISOString(),
    verificationCode: "",
  };
}

function isAdminLogin(email: string, password: string): boolean {
  return (
    Boolean(ADMIN_EMAIL && ADMIN_PASSWORD) &&
    email.trim().toLowerCase() === ADMIN_EMAIL &&
    password === ADMIN_PASSWORD
  );
}

export function useAccount() {
  const account = useSyncExternalStore(
    subscribe,
    getSnapshot,
    getServerSnapshot,
  );
  const hydrated = useSyncExternalStore(
    subscribe,
    () => true,
    () => false,
  );

  const signUp = useCallback(
    (input: { email: string; displayName: string }): Account => {
      const next = approvedAccount({
        email: input.email.trim(),
        displayName: input.displayName.trim(),
        authProvider: "email",
      });
      persist(next);
      return next;
    },
    [],
  );

  const signIn = useCallback(
    (input: { email: string; password: string }): Account | null => {
      const email = input.email.trim();
      const current = getSnapshot();
      if (current && current.email.toLowerCase() === email.toLowerCase()) {
        return current;
      }
      if (!isAdminLogin(email, input.password)) return null;
      const next = approvedAccount({
        email,
        displayName: "Warif Admin",
        authProvider: "admin",
      });
      persist(next);
      return next;
    },
    [],
  );

  const signInWithApple = useCallback((): Account => {
    const next = approvedAccount({
      email: APPLE_DEMO_EMAIL,
      displayName: "Apple User",
      authProvider: "apple",
    });
    persist(next);
    return next;
  }, []);

  const verifyEmail = useCallback((code: string): boolean => {
    const current = getSnapshot();
    if (!current) return false;
    try {
      persist(verifyEmailTx(current, code));
      return true;
    } catch {
      return false;
    }
  }, []);

  const saveConsents = useCallback((consents: Consents) => {
    const current = getSnapshot();
    if (!current) return;
    persist({ ...current, consents });
  }, []);

  const submitActivation = useCallback((consents: Consents): boolean => {
    const current = getSnapshot();
    if (!current) return false;
    try {
      persist(submitActivationTx(current, consents, new Date().toISOString()));
      return true;
    } catch {
      return false;
    }
  }, []);

  // Temporary demo control standing in for the Phase 2 admin console.
  const simulateDecision = useCallback(
    (decision: "approve" | "reject", reason?: string) => {
      const current = getSnapshot();
      if (!current) return;
      persist(
        decision === "approve"
          ? approveAccount(current)
          : rejectAccount(current, reason ?? ""),
      );
    },
    [],
  );

  const resubmit = useCallback(() => {
    const current = getSnapshot();
    if (!current) return;
    persist(resubmitAccount(current, new Date().toISOString()));
  }, []);

  const signOut = useCallback(() => persist(null), []);

  return {
    account,
    hydrated,
    signUp,
    signIn,
    signInWithApple,
    verifyEmail,
    saveConsents,
    submitActivation,
    simulateDecision,
    resubmit,
    signOut,
  };
}
