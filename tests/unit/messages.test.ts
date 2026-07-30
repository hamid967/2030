import { describe, expect, it } from "vitest";
import ar from "@/messages/ar.json";
import en from "@/messages/en.json";

/** Recursively collect the dot-paths of every leaf string in a messages tree. */
function leafKeys(obj: Record<string, unknown>, prefix = ""): string[] {
  return Object.entries(obj).flatMap(([key, value]) => {
    const path = prefix ? `${prefix}.${key}` : key;
    return typeof value === "object" && value !== null
      ? leafKeys(value as Record<string, unknown>, path)
      : [path];
  });
}

describe("translation messages", () => {
  it("Arabic and English expose identical keys", () => {
    expect(leafKeys(ar).sort()).toEqual(leafKeys(en).sort());
  });

  it("has no empty strings", () => {
    for (const messages of [ar, en]) {
      const flat = JSON.stringify(messages);
      expect(flat).not.toContain('""');
    }
  });
});
