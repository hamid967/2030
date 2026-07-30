import { describe, expect, it } from "vitest";
import { locales, defaultLocale, localeDirection } from "@/i18n/routing";

describe("i18n routing", () => {
  it("supports Arabic and English", () => {
    expect(locales).toContain("ar");
    expect(locales).toContain("en");
  });

  it("defaults to Arabic", () => {
    expect(defaultLocale).toBe("ar");
  });

  it("renders Arabic RTL and English LTR", () => {
    expect(localeDirection.ar).toBe("rtl");
    expect(localeDirection.en).toBe("ltr");
  });
});
