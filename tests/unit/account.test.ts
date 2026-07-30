import { describe, expect, it } from "vitest";
import {
  type Account,
  EMPTY_CONSENTS,
  allConsentsGiven,
  verifyEmail,
  canSubmit,
  submitActivation,
  approve,
  reject,
  resubmit,
} from "@/lib/account";

function baseAccount(overrides: Partial<Account> = {}): Account {
  return {
    id: "acc-1",
    email: "test@example.com",
    displayName: "Test",
    status: "email_unverified",
    emailVerified: false,
    consents: { ...EMPTY_CONSENTS },
    requestNumber: "WRF-000000",
    createdAt: "2026-01-01T00:00:00.000Z",
    verificationCode: "123456",
    ...overrides,
  };
}

const allConsents = {
  terms: true,
  privacy: true,
  health: true,
  community: true,
};

describe("consents", () => {
  it("requires all four consents", () => {
    expect(allConsentsGiven(EMPTY_CONSENTS)).toBe(false);
    expect(allConsentsGiven({ ...allConsents, community: false })).toBe(false);
    expect(allConsentsGiven(allConsents)).toBe(true);
  });
});

describe("verifyEmail", () => {
  it("sets emailVerified with the correct code", () => {
    const acc = verifyEmail(baseAccount(), "123456");
    expect(acc.emailVerified).toBe(true);
  });
  it("throws on wrong code", () => {
    expect(() => verifyEmail(baseAccount(), "000000")).toThrow();
  });
});

describe("submitActivation", () => {
  it("is not eligible before verification/consents", () => {
    expect(canSubmit(baseAccount(), allConsents)).toBe(false);
    expect(
      canSubmit(baseAccount({ emailVerified: true }), EMPTY_CONSENTS),
    ).toBe(false);
  });

  it("moves a verified, fully-consented account to pending_activation", () => {
    const acc = submitActivation(
      baseAccount({ emailVerified: true }),
      allConsents,
      "2026-01-02T00:00:00.000Z",
    );
    expect(acc.status).toBe("pending_activation");
    expect(acc.submittedAt).toBe("2026-01-02T00:00:00.000Z");
  });

  it("throws when consents are incomplete", () => {
    expect(() =>
      submitActivation(
        baseAccount({ emailVerified: true }),
        { ...allConsents, health: false },
        "2026-01-02T00:00:00.000Z",
      ),
    ).toThrow();
  });
});

describe("admin decisions", () => {
  const pending = baseAccount({
    emailVerified: true,
    status: "pending_activation",
    consents: allConsents,
  });

  it("approve flips status WITHOUT starting any trial", () => {
    const acc = approve(pending);
    expect(acc.status).toBe("approved");
    // Phase 1 must not start the 14-day trial.
    expect(acc).not.toHaveProperty("trialStartedAt");
    expect(acc).not.toHaveProperty("trialEndsAt");
  });

  it("reject records a reason", () => {
    const acc = reject(pending, "needs more info");
    expect(acc.status).toBe("rejected");
    expect(acc.rejectionReason).toBe("needs more info");
  });

  it("resubmit returns a rejected account to pending", () => {
    const rejected = reject(pending, "x");
    const acc = resubmit(rejected, "2026-01-03T00:00:00.000Z");
    expect(acc.status).toBe("pending_activation");
    expect(acc.rejectionReason).toBeUndefined();
  });

  it("cannot approve a non-pending account", () => {
    expect(() => approve(baseAccount())).toThrow();
  });
});
