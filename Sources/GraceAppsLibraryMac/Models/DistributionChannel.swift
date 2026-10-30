import Foundation

/// Represents how a Grace Mac app is distributed (Mac App Store vs Direct distribution e.g. Gumroad/website DMG).
public enum DistributionChannel: Equatable, Sendable {
    /// Distributed via the Mac App Store with its numeric Apple ID (e.g. "6476702155").
    case appStore(id: String)

    /// Distributed directly (e.g. Gumroad, website DMG, GitHub Releases) with an optional review or feedback URL.
    case direct(reviewOrFeedbackURL: URL? = nil)

    /// True if the current channel is direct distribution.
    public var isDirect: Bool {
        switch self {
        case .direct: return true
        case .appStore: return false
        }
    }

    /// True if the current channel is Mac App Store.
    public var isAppStore: Bool {
        !isDirect
    }

    /// The App Store numeric ID if running under App Store distribution.
    public var appStoreId: String? {
        switch self {
        case .appStore(let id): return id
        case .direct: return nil
        }
    }

    /// Helper to select distribution channel based on the compile-time flag `DIRECT_DISTRIBUTION`.
    /// When `DIRECT_DISTRIBUTION` is defined, returns `.direct(reviewOrFeedbackURL: directURL)`.
    /// Otherwise, returns `.appStore(id: appStoreId)`.
    public static func current(appStoreId: String, directURL: URL? = nil) -> DistributionChannel {
        #if DIRECT_DISTRIBUTION
        return .direct(reviewOrFeedbackURL: directURL)
        #else
        return .appStore(id: appStoreId)
        #endif
    }
}
