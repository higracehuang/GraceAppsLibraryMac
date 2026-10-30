# Direct Distribution & Notarization Guide (GraceAppsLibraryMac)

This guide documents the standardized process for creating a direct distribution build (e.g., for **Gumroad**, **GitHub Releases**, or direct website downloads) alongside your existing **Mac App Store** target.

---

## 1. Architecture Overview

| Feature | Mac App Store Build | Direct Distribution Build (Gumroad / Web) |
| :--- | :--- | :--- |
| **Scheme** | `<AppName>` | `<AppName> Direct` |
| **Configurations** | `Debug`, `Release` | `Direct Debug`, `Direct Release` |
| **Compiler Flag** | *None* | `DIRECT_DISTRIBUTION=1` |
| **Code Signing** | Apple Development / Apple Distribution | Developer ID Application |
| **Verification** | App Store Review & In-App Purchase | Apple Notary Service (`xcrun notarytool`) |
| **In-App Purchases** | RevenueCat / StoreKit | Unlocked (`FullVersionStatusView`) |
| **Review Prompt** | Native App Store dialog (`SKStoreReviewController`) | Suppressed or custom feedback/review URL |

---

## 2. Setting Up Your Xcode Project

### A. Add Direct Build Configurations
1. In Xcode, select your project in the Project Navigator.
2. Under **Project** → **Info** → **Configurations**:
   - Duplicate `Debug` → Name it `Direct Debug`.
   - Duplicate `Release` → Name it `Direct Release`.
3. Under **Build Settings**:
   - In `SWIFT_ACTIVE_COMPILATION_CONDITIONS` for `Direct Debug` and `Direct Release`, add `DIRECT_DISTRIBUTION`.
   - Set `GCC_PREPROCESSOR_DEFINITIONS` to include `DIRECT_DISTRIBUTION=1`.
   - In `Direct Release`, ensure `SWIFT_OPTIMIZATION_LEVEL = -O` and `DEAD_CODE_STRIPPING = YES`.

### B. Create the Shared Scheme
1. Create a scheme named `<AppName> Direct` (or create a dedicated lightweight target).
2. Set Build, Run, and Archive to use `Direct Debug` / `Direct Release`.
3. Check **Shared** under **Product** → **Scheme** → **Manage Schemes...** so it is saved in `xcshareddata/xcschemes/`.

---

## 3. Using GraceAppsLibraryMac Components

### A. DistributionChannel in App Launch
```swift
import SwiftUI
import GraceAppsLibraryMac

@main
struct MyApp: App {
    init() {
        // Automatically selects .direct or .appStore based on DIRECT_DISTRIBUTION
        let channel = DistributionChannel.current(
            appStoreId: "6476702155",
            directURL: URL(string: "https://gumroad.com/l/yourproduct")
        )
        ReviewPromptManager.shared.channel = channel
        ReviewPromptManager.appInit()
    }

    var body: some Scene { ... }
}
```

### B. AboutAppSectionView
`AboutAppSectionView` automatically adapts to `DistributionChannel`:
```swift
AboutAppSectionView(
    channel: ReviewPromptManager.shared.channel,
    releaseNotes: currentNotes,
    isPaidUser: true
)
```
- In App Store mode: shows `"Rate on the App Store"`.
- In Direct mode: shows `"Rate or Review"` (if a direct URL is configured) or hides the store link, leaving `"Share Feedback…"`.

### C. Displaying Full Version Status
For direct builds where all features are unlocked with no paywall:
```swift
#if DIRECT_DISTRIBUTION
FullVersionStatusView(
    title: "Full Version Active",
    description: "All features unlocked. Thank you for your support!"
)
#else
ProTeaserBanner(...)
#endif
```

---

## 4. One-Time Developer ID & Notary Setup

1. **Developer ID Certificate**:
   - Xcode → Settings (`⌘,`) → Accounts → Manage Certificates → `+` → **Developer ID Application**.
2. **Store Notary Credentials in Keychain**:
   - Generate an App-Specific Password at [account.apple.com](https://account.apple.com).
   - Run:
     ```bash
     xcrun notarytool store-credentials "notarytool-profile" \
       --apple-id "your-apple-id@email.com" \
       --team-id "YOUR_TEAM_ID" \
       --password "xxxx-xxxx-xxxx-xxxx"
     ```

---

## 5. Building & Packaging the DMG

Use the universal packaging script provided in `Scripts/build-dmg.sh`:

```bash
# Basic local build (testing)
./Scripts/build-dmg.sh

# Production release with Developer ID signing, symbol stripping, Apple notarization, and stapling
./Scripts/build-dmg.sh --notarize
```

The script:
1. Builds with the `<AppName> Direct` scheme and `Direct Release` configuration.
2. Strips debug symbol tables (`strip -rSTx`) to reduce DMG size by ~90%.
3. Signs with your `Developer ID Application` certificate.
4. Generates an installer DMG with an `/Applications` symlink.
5. Submits to Apple Notary Service, staples the ticket, and validates with Gatekeeper (`spctl`).
