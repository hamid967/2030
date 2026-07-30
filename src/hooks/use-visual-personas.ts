"use client";

import { useCallback, useSyncExternalStore } from "react";

/**
 * Setting: "إظهار الشخصيات البصرية" (show the calm visual states/personas).
 * When off, the app uses a plainer numeric interface. Defaults to on.
 */
const STORAGE_KEY = "warif.visualPersonas.v1";

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
  if (typeof window === "undefined") return true;
  // Default on unless explicitly disabled.
  return window.localStorage.getItem(STORAGE_KEY) !== "0";
}

export function useVisualPersonas() {
  const enabled = useSyncExternalStore(subscribe, getSnapshot, () => true);

  const setEnabled = useCallback((value: boolean) => {
    window.localStorage.setItem(STORAGE_KEY, value ? "1" : "0");
    listeners.forEach((l) => l());
  }, []);

  return { enabled, setEnabled };
}
