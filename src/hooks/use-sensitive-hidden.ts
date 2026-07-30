"use client";

import { useCallback, useSyncExternalStore } from "react";

/**
 * A tiny local flag to blur sensitive values on screen (e.g. when someone is
 * looking over the user's shoulder). Persisted per-device in localStorage.
 */
const STORAGE_KEY = "warif.sensitiveHidden.v1";

const listeners = new Set<() => void>();

function subscribe(cb: () => void): () => void {
  listeners.add(cb);
  window.addEventListener("storage", cb);
  return () => {
    listeners.delete(cb);
    window.removeEventListener("storage", cb);
  };
}

function getSnapshot(): boolean {
  return (
    typeof window !== "undefined" &&
    window.localStorage.getItem(STORAGE_KEY) === "1"
  );
}

function applyToDom(hidden: boolean) {
  if (typeof document !== "undefined") {
    document.documentElement.dataset.sensitiveHidden = hidden
      ? "true"
      : "false";
  }
}

export function useSensitiveHidden() {
  const hidden = useSyncExternalStore(subscribe, getSnapshot, () => false);

  const toggle = useCallback(() => {
    const next = !getSnapshot();
    window.localStorage.setItem(STORAGE_KEY, next ? "1" : "0");
    applyToDom(next);
    listeners.forEach((l) => l());
  }, []);

  return { hidden, toggle };
}
