import Foundation

/// Tracks which release notes version the user has already seen.
///
/// Ported from GraceAppsLibrary's iOS manager, minus its logger.
/// The session flag is what lets `ReviewPromptManager` suppress a
/// review prompt in the same session release notes were shown.
public final class ReleaseNotesManager {
    public static let shared = ReleaseNotesManager()

    private let lastViewedVersionKey = "GraceAppsMac_LastViewedReleaseNotesVersion"
    private let userDefaults: UserDefaults

    /// True once release notes have been presented in this app run.
    public static var hasShownReleaseNotesThisSession: Bool = false

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public var currentVersion: String {
        Bundle.main.releaseVersionNumber
    }

    public var lastViewedVersion: String? {
        userDefaults.string(forKey: lastViewedVersionKey)
    }

    public var isFirstInstall: Bool {
        lastViewedVersion == nil
    }

    /// Whether the current version's notes should be shown.
    /// With no notes, or no note for the current version, never.
    ///
    /// When `lastViewedVersion == nil`:
    /// - If `isReturningUser` is `true`, the user is upgrading from a legacy version that
    ///   predated GALM adoption. Release notes are shown for the new version.
    /// - If `suppressOnFirstInstall` is `true` (and not a returning user), release notes are
    ///   suppressed and marked as viewed so fresh installs see onboarding instead of a changelog.
    ///
    /// Once a version has been viewed previously (`lastViewedVersion != nil`), release notes
    /// are shown whenever `lastViewed != currentVersion`.
    public func shouldShow(
        releaseNotes: [ReleaseNote],
        suppressOnFirstInstall: Bool = true,
        isReturningUser: Bool = false
    ) -> Bool {
        guard !releaseNotes.isEmpty else { return false }
        guard releaseNotes.contains(where: { $0.version == currentVersion }) else { return false }
        guard let lastViewed = lastViewedVersion else {
            if isReturningUser {
                return true
            }
            if suppressOnFirstInstall {
                markAsViewed(version: currentVersion)
                return false
            }
            return true
        }
        return lastViewed != currentVersion
    }

    /// Closure overload for `shouldShow(releaseNotes:suppressOnFirstInstall:isReturningUser:)`.
    public func shouldShow(
        releaseNotes: [ReleaseNote],
        suppressOnFirstInstall: Bool = true,
        isReturningUser: () -> Bool
    ) -> Bool {
        shouldShow(
            releaseNotes: releaseNotes,
            suppressOnFirstInstall: suppressOnFirstInstall,
            isReturningUser: isReturningUser()
        )
    }

    public func markCurrentVersionAsViewed() {
        markAsViewed(version: currentVersion)
    }

    public func markAsViewed(version: String) {
        userDefaults.set(version, forKey: lastViewedVersionKey)
    }

    public func resetReleaseNotesState() {
        Self.hasShownReleaseNotesThisSession = false
        userDefaults.removeObject(forKey: lastViewedVersionKey)
    }
}
