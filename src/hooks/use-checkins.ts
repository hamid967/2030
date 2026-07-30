"use client";

import { useCallback, useSyncExternalStore } from "react";
import type { CheckIn, CheckInDraft, CheckInMap } from "@/lib/checkins";

/**
 * Daily check-ins are sensitive health data and are kept client-side only in
 * localStorage (blueprint section 11), mirroring `use-cycle-profile`.
 */
const STORAGE_KEY = "warif.checkins.v1";

let cachedRaw: string | null = null;
let cachedValue: CheckInMap = {};

function parse(raw: string | null): CheckInMap {
  if (!raw) return {};
  try {
    const parsed = JSON.parse(raw);
    return parsed && typeof parsed === "object" ? (parsed as CheckInMap) : {};
  } catch {
    return {};
  }
}

function getSnapshot(): CheckInMap {
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

const EMPTY: CheckInMap = {};
function getServerSnapshot(): CheckInMap {
  return EMPTY;
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
  cachedRaw = null;
  listeners.forEach((l) => l());
}

export function useCheckins() {
  const checkins = useSyncExternalStore(
    subscribe,
    getSnapshot,
    getServerSnapshot,
  );
  const hydrated = useSyncExternalStore(
    subscribe,
    () => true,
    () => false,
  );

  const saveCheckIn = useCallback((date: string, draft: CheckInDraft) => {
    const current = getSnapshot();
    const next: CheckInMap = {
      ...current,
      [date]: { date, ...draft },
    };
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
    emit();
  }, []);

  const getCheckIn = useCallback(
    (date: string): CheckIn | null => checkins[date] ?? null,
    [checkins],
  );

  return { checkins, hydrated, saveCheckIn, getCheckIn };
}
