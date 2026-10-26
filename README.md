# GraceAppsLibraryMac

A Swift package for Grace's macOS apps, in the spirit of
GraceAppsLibrary — but macOS-only, with no platform-conditional
compilation, no UIKit, and no iOS-only APIs.

## What it provides

- **Mac app catalog** (`GraceMacApp`): FaceCam, ResizeGenius,
  RedacApp, and RGB Exporter, with App Store links and a helper to
  exclude the host app from cross-promo.
- **Review prompting** (`ReviewPromptManager`): the intended
  replacement for SolicitReviewLibrary in Mac apps. Two-step
  NSAlert pre-filter ("Are you enjoying this app?"), native
  StoreKit prompt only for happy users, once per version, after a
  configurable engagement checkpoint (default 5), suppressed in
  sessions where release notes were shown, with a daily-throttled
  variant. On macOS 13, where the native prompt is unavailable, it
  falls back to opening the App Store review page.
- **Release notes** (`ReleaseNotesManager`, `ReleaseNote`,
  `ReleaseNotesView`): per-version viewed tracking, suppressed on
  fresh installs by default.
- **About section** (`AboutAppSectionView`): version, What's New,
  rate link, and feedback email for a Settings screen.
- **Cross-promo list** (`GraceAppsView`): the other Mac apps, each
  linking to its App Store page.

## What it deliberately does not do

- No UIKit, no emoji keyboard, no iOS ShareLink, no language-setting
  link — those live in GraceAppsLibrary and don't belong on macOS.
- No paywall or StoreKit purchase code. The release-notes CTA can
  point at a host app's own paywall, but this library does not sell
  anything.
- No localization resources yet. Strings are English for v1;
  localized catalog copy is a follow-up, not a silent placeholder.

## Installation

Add the package in Xcode with Swift Package Manager:

```
https://github.com/higracehuang/GraceAppsLibraryMac
```

Then:

```swift
import GraceAppsLibraryMac
```

## Usage

At launch, once per app:

```swift
ReviewPromptManager.appInit()
ReviewPromptManager.shared.appStoreId = "6476702155"
```

At a positive moment (a completed recording, an export, a week of
use) — never on every launch, and never from a view's `init`, which
SwiftUI can call many times per launch:

```swift
ReviewPromptManager.shared.requestReview()
```

Daily-throttled variant:

```swift
ReviewPromptManager.shared.requestReviewDaily()
```

About section in a Settings `Form`:

```swift
AboutAppSectionView(
    appStoreId: "6476702155",
    releaseNotes: [
        ReleaseNote(version: "1.4.0", items: [
            ReleaseNoteItem(text: "Settings now survive a relaunch.")
        ])
    ]
)
```

Other Mac apps, excluding the host app:

```swift
GraceAppsView(excludingAppStoreId: "6476702155")
```

## Migrating off SolicitReviewLibrary

SolicitReviewLibrary is still in use today (FaceCam uses it) and is
retired only after every Mac app has switched. Migration per app:

1. Add GraceAppsLibraryMac as a package dependency.
2. Replace `SolicitReviewLibrary.appInit()` with
   `ReviewPromptManager.appInit()` and set
   `ReviewPromptManager.shared.appStoreId`.
3. Replace `requestReview()` calls with the new manager's calls.
   Note the API differences: the new manager's checkpoint is
   "at least N engagements" (not "exactly N"), it suppresses
   prompts in release-notes sessions, and its UserDefaults keys
   are `GraceAppsMac_`-prefixed, so counters start clean.
4. Remove the SolicitReviewLibrary package dependency.
5. Build on macOS 13+ and check the review prompt, release notes,
   and about screen before shipping.

## Requirements

- macOS 13+
- Swift 5.9+
- Xcode with Swift Package Manager

## Development

This package cannot be built on Linux (AppKit and StoreKit are
macOS-only). Build and test it on a Mac:

```bash
swift test
```
