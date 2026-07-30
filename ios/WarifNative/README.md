# Warif Native (iOS)

A native SwiftUI iPhone app for Warif (وريف), living alongside the existing
Next.js web app (which stays as the landing page + admin portal). Not a WebView
wrapper — this is a native client.

- Swift 6, SwiftUI, iOS 18+, `@Observable`, structured concurrency.
- Arabic-first with full RTL; English parity.
- 13 Saudi regional themes; region chosen at sign-up (location optional).
- Optional, read-only HealthKit connection (on-device aggregation).
- Repositories are protocol-based with mock/local implementations; a
  Supabase-backed layer (Auth + RLS) is the next batch.

## Generate & build (macOS + Xcode required)

This project uses **Continuous Native Generation** via XcodeGen (the
`.xcodeproj` is not committed).

```bash
brew install xcodegen
cd ios/WarifNative
cp Configuration/Secrets.example.xcconfig Configuration/Secrets.xcconfig  # fill public values
xcodegen generate
open WarifNative.xcodeproj
```

Run tests:

```bash
xcodegen generate
xcodebuild \
  -project WarifNative.xcodeproj \
  -scheme WarifNative \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  test
```

## Verification status

⚠️ This scaffold was authored in a Linux CI environment with **no macOS / Xcode
/ Swift toolchain**, so it has **not** been compiled, run, or screenshotted
here. Build, run the XCTest suite, and capture the 13-theme previews on macOS.
Per Apple + this pack's guidance, **HealthKit must be validated on a physical
iPhone** — automated tests use `MockHealthDataProvider` only.

## Privacy invariants

- Coordinates are never stored/uploaded — only the region slug + how it was
  chosen. Location permission is always optional (manual picker is equal).
- HealthKit is read-only and requested from a dedicated screen (not at sign-up);
  raw samples stay on device.
- No secrets in the app; only the public Supabase URL + publishable key via a
  git-ignored xcconfig.

## Layout

- `project.yml` — XcodeGen spec (app + unit + UI test targets).
- `WarifNative/App` — entry point, environment, router, root view.
- `WarifNative/Core` — DesignSystem, RegionTheme (13 regions), Cycle engine,
  Health, Location, Security, API (protocols + mocks).
- `WarifNative/Features` — Onboarding, Activation, Today, Calendar, CheckIn,
  Insights, Learn, Community, Settings.
- `WarifNativeTests` — regions, prediction confidence, Riyadh date boundaries,
  administrative-area normalization.

## Deferred (next batches)

Supabase live repositories + Auth/RLS, admin activation + server-side 14-day
trial, HealthKit daily aggregation (HKStatisticsCollectionQuery) + Swift Charts
overlays, calendar day-details/period editor, notifications, subscription,
menstrual-flow HealthKit write (Phase 2), optional watchOS companion.
