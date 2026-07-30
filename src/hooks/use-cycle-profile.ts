"use client";

import { useCallback, useSyncExternalStore } from "react";
import type { CycleProfile } from "@/lib/cycle-engine";

/**
 * Cycle data is sensitive health data. In this client-only MVP we deliberately
 * keep it in the browser's localStorage — it never leaves the device and is not
 * sent to any server or analytics tool (blueprint section 11). When the backend
 * lands, this hook is the single place to swap to an RLS-protected store.
 *
 * Implemented with `useSyncExternalStore` so reads are hydration-safe (the
 * server snapshot is always `null`) and stay in sync across tabs.
 */
const STORAGE_KEY = "warif.cycleProfile.v1";

let cachedRaw: string | null = null;
let cachedValue: CycleProfile | null = null;

function parseProfile(raw: string | null): CycleProfile | null {
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw) as CycleProfile;
    if (
      typeof parsed.lastPeriodStart === "string" &&
      typeof parsed.cycleLength === "number" &&
      typeof parsed.periodLength === "number"
    ) {
      return parsed;
    }
    return null;
  } catch {
    return null;
  }
}

function getSnapshot(): CycleProfile | null {
  const raw =
    typeof window === "undefined"
      ? null
      : window.localStorage.getItem(STORAGE_KEY);
  // Cache so repeated calls return a stable reference (required by the store).
  if (raw !== cachedRaw) {
    cachedRaw = raw;
    cachedValue = parseProfile(raw);
  }
  return cachedValue;
}

function getServerSnapshot(): CycleProfile | null {
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

function emit() {
  // Force the next getSnapshot to re-read from storage.
  cachedRaw = null;
  listeners.forEach((l) => l());
}

export function useCycleProfile() {
  const profile = useSyncExternalStore(
    subscribe,
    getSnapshot,
    getServerSnapshot,
  );
  // Hydration-safe "is on client" flag: false on the server, true after mount.
  const hydrated = useSyncExternalStore(
    subscribe,
    () => true,
    () => false,
  );

  const saveProfile = useCallback((next: CycleProfile) => {
    // Keep periodStarts in sync so predictions have history to work with.
    const starts = Array.from(
      new Set([...(next.periodStarts ?? []), next.lastPeriodStart]),
    ).sort();
    const withHistory: CycleProfile = { ...next, periodStarts: starts };
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(withHistory));
    emit();
  }, []);

  /** Record a new period start ("بدأت الدورة") — appends to history. */
  const logPeriodStart = useCallback((dateIso: string) => {
    const current = getSnapshot();
    if (!current) return;
    const starts = Array.from(
      new Set([
        ...(current.periodStarts ?? [current.lastPeriodStart]),
        dateIso,
      ]),
    ).sort();
    const lastPeriodStart = starts[starts.length - 1];
    const next: CycleProfile = {
      ...current,
      lastPeriodStart,
      periodStarts: starts,
    };
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
    emit();
  }, []);

  const clearProfile = useCallback(() => {
    window.localStorage.removeItem(STORAGE_KEY);
    emit();
  }, []);

  return { profile, hydrated, saveProfile, logPeriodStart, clearProfile };
}
