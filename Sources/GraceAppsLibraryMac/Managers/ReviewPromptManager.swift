import Foundation
import AppKit
import StoreKit

/// macOS review prompting, replacing SolicitReviewLibrary for Mac apps.
///
/// Two-step flow, borrowed from GraceAppsLibrary's iOS manager and
/// rebuilt with AppKit:
/// 1. An NSAlert asks "Are you enjoying <App>?".
/// 2. "Love it!" shows Apple's native StoreKit review prompt.
///    "Not really" runs `onNegativeFeedback` if given, and otherwise
///    does nothing — unhappy users are never sent to the App Store.
///
/// Rules that keep it polite:
/// - At most once per app version (`hasPromptYet`).
/// - Only after `checkpointCount` engagements (default 5).
/// - Never in the same session that release notes were shown
///   (`ReleaseNotesManager.hasShownReleaseNotesThisSession`).
/// - `requestReviewDaily` records at most one engagement per day.
///
/// UserDefaults keys use the `GraceAppsMac_` prefix, deliberately
/// different from SolicitReviewLibrary's and GraceAppsLibrary's keys,
/// so migrating an app to this manager starts its counters clean
/// instead of inheriting a half-counted state.
///
/// Setup, once per app, at launch:
/// ```swift
/// ReviewPromptManager.appInit()
/// ReviewPromptManager.shared.appStoreId = "6476702155"
/// ```
/// Then call `ReviewPromptManager.shared.requestReview()` at a
/// positive moment (a completed recording, an export, a first week
/// of use) — never on every launch, and never from a view's `init`,
/// which SwiftUI can call many times per launch.
@MainActor
public final class ReviewPromptManager {
    public static let shared = ReviewPromptManager()

    /// The host app's numeric App Store ID, without the "id" prefix.
    /// Used for the macOS 13 fallback (opening the review page) and
    /// for `getReviewURL` / `getShareURL`. Set it at launch.
    public var appStoreId: String?

    private let checkpointCount: Int
    private let userDefaults: UserDefaults

    private enum Keys {
        static let engagementCounter = "GraceAppsMac_Review_EngagementCounter"
        static let lastVersionPrompted = "GraceAppsMac_Review_LastVersionPromptedForReview"
        static let appVersionForStorage = "GraceAppsMac_Review_AppVersionForStorage"
        static let lastEngagementDate = "GraceAppsMac_Review_LastEngagementDate"
    }

    public init(checkpointCount: Int = 5, userDefaults: UserDefaults = .standard) {
        self.checkpointCount = checkpointCount
        self.userDefaults = userDefaults
    }

    private var appName: String { Bundle.main.appName }
    private var releaseVersionNumber: String { Bundle.main.releaseVersionNumber }

    /// Call at launch. Resets the engagement counter when the app
    /// version changes, so each version gets its own checkpoint run.
    public static func appInit(userDefaults: UserDefaults = .standard) {
        let storedVersion = userDefaults.string(forKey: Keys.appVersionForStorage) ?? ""
        let currentVersion = Bundle.main.releaseVersionNumber
        if storedVersion != currentVersion {
            userDefaults.set(0, forKey: Keys.engagementCounter)
            userDefaults.set(currentVersion, forKey: Keys.appVersionForStorage)
        }
    }

    public func hasPromptYet() -> Bool {
        userDefaults.string(forKey: Keys.lastVersionPrompted) ?? "" == releaseVersionNumber
    }

    private func recordEngagement() -> Int {
        let count = userDefaults.integer(forKey: Keys.engagementCounter) + 1
        userDefaults.set(count, forKey: Keys.engagementCounter)
        return count
    }

    private func shouldPrompt() -> Bool {
        guard !ReleaseNotesManager.hasShownReleaseNotesThisSession else { return false }
        let count = recordEngagement()
        return count >= checkpointCount && !hasPromptYet()
    }

    /// Ask for a review if the checkpoint is reached and this version
    /// has not been prompted yet. Otherwise does nothing.
    public func requestReview(onNegativeFeedback: (() -> Void)? = nil) {
        if shouldPrompt() {
            askForReview(onPositive: showNativeReviewPrompt, onNegative: onNegativeFeedback)
        }
    }

    /// Like `requestReview`, returning whether the prompt was shown.
    @discardableResult
    public func requestReviewIfNecessary(onNegativeFeedback: (() -> Void)? = nil) -> Bool {
        if shouldPrompt() {
            askForReview(onPositive: showNativeReviewPrompt, onNegative: onNegativeFeedback)
            return true
        }
        return false
    }

    /// At most one engagement recorded per calendar day, so the
    /// checkpoint counts usage days rather than raw calls.
    public func requestReviewDaily(onNegativeFeedback: (() -> Void)? = nil) {
        let lastDate = userDefaults.object(forKey: Keys.lastEngagementDate) as? Date
        if lastDate == nil || !Calendar.current.isDateInToday(lastDate!) {
            userDefaults.set(Date(), forKey: Keys.lastEngagementDate)
            requestReview(onNegativeFeedback: onNegativeFeedback)
        }
    }

    /// Show Apple's native review prompt immediately, with no
    /// pre-filter alert and no checkpoint check. Marks the version
    /// as prompted.
    public func requestDirectNativeReview() {
        showNativeReviewPrompt()
    }

    /// Show the two-step pre-filter alert directly, for QA.
    public func debugPresentReviewPrompt(onNegativeFeedback: (() -> Void)? = nil) {
        askForReview(onPositive: showNativeReviewPrompt, onNegative: onNegativeFeedback)
    }

    /// Reset all review state. For debug and tests only.
    public func debugResetReviewState() {
        ReleaseNotesManager.hasShownReleaseNotesThisSession = false
        userDefaults.set(0, forKey: Keys.engagementCounter)
        userDefaults.removeObject(forKey: Keys.lastVersionPrompted)
        userDefaults.removeObject(forKey: Keys.lastEngagementDate)
    }

    private func markPromptedForCurrentVersion() {
        userDefaults.set(releaseVersionNumber, forKey: Keys.lastVersionPrompted)
    }

    private func askForReview(onPositive: @escaping () -> Void, onNegative: (() -> Void)?) {
        markPromptedForCurrentVersion()
        let alert = NSAlert()
        alert.messageText = "Are you enjoying \(appName)?"
        alert.informativeText = "Please let us know what you think!"
        alert.addButton(withTitle: "Love it!")
        alert.addButton(withTitle: "Not really")
        alert.buttons.first?.keyEquivalent = "\r"
        if alert.runModal() == .alertFirstButtonReturn {
            onPositive()
        } else {
            onNegative?()
        }
    }

    private func showNativeReviewPrompt() {
        markPromptedForCurrentVersion()
        if #available(macOS 14, *) {
            SKStoreReviewController.requestReview()
        } else if let appStoreId, let url = Self.getReviewURL(appStoreId: appStoreId) {
            NSWorkspace.shared.open(url)
        }
    }

    /// App Store review page for an app, from a bare numeric ID or one
    /// already prefixed with "id".
    public static func getReviewURL(appStoreId: String) -> URL? {
        let cleanId = appStoreId.hasPrefix("id") ? appStoreId : "id\(appStoreId)"
        return URL(string: "https://apps.apple.com/app/\(cleanId)?action=write-review")
    }

    /// App Store page for an app, from a bare numeric ID or one
    /// already prefixed with "id".
    public static func getShareURL(appStoreId: String) -> URL? {
        let cleanId = appStoreId.hasPrefix("id") ? appStoreId : "id\(appStoreId)"
        return URL(string: "https://apps.apple.com/app/\(cleanId)")
    }

    /// Pre-filled feedback email, with app version and macOS version
    /// in the body so replies don't need a round of "which version?".
    public static func getFeedbackMailURL() -> URL? {
        let appName = Bundle.main.appName
        let appVersion = Bundle.main.releaseVersionNumber
        let appBuild = Bundle.main.buildVersionNumber
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        let subject = "Feedback: \(appName)"
        let body = """


        ---
        App: \(appName)
        Version: \(appVersion) (\(appBuild))
        macOS: \(osVersion)
        """
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.replacingOccurrences(of: "\n", with: "\r\n")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "mailto:higracehuang@gmail.com?subject=\(encodedSubject)&body=\(encodedBody)")
    }
}
