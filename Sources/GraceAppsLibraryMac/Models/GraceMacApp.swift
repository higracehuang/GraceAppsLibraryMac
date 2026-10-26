import Foundation

/// One of Grace's macOS apps, as listed on the Mac App Store.
///
/// App Store IDs were verified against the live Mac App Store listings
/// on 2026-10-26 (FaceCam) and the store catalog for the other three.
/// Prices change; the catalog intentionally carries no price, so a
/// price change never makes this library stale.
public struct GraceMacApp: Hashable, Identifiable {
    public let name: String
    public let shortDescription: String
    public let appStoreId: String
    public let bundleId: String
    public let category: String

    public var id: String { appStoreId }

    public var appStoreURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appStoreId)")!
    }

    public var reviewURL: URL? {
        ReviewPromptManager.getReviewURL(appStoreId: appStoreId)
    }

    public init(
        name: String,
        shortDescription: String,
        appStoreId: String,
        bundleId: String,
        category: String
    ) {
        self.name = name
        self.shortDescription = shortDescription
        self.appStoreId = appStoreId
        self.bundleId = bundleId
        self.category = category
    }

    /// All of Grace's macOS apps.
    public static let all: [GraceMacApp] = [
        GraceMacApp(
            name: "FaceCam",
            shortDescription: "Your face, floating over any recording.",
            appStoreId: "6476702155",
            bundleId: "com.deelightfullabs.FloatingCamera",
            category: "Photo & Video"
        ),
        GraceMacApp(
            name: "ResizeGenius",
            shortDescription: "Resize images quickly, in batches.",
            appStoreId: "6463165079",
            bundleId: "com.deelightfullabs.ImageResizePro",
            category: "Productivity"
        ),
        GraceMacApp(
            name: "RedacApp",
            shortDescription: "Redact text in images before sharing.",
            appStoreId: "6443662043",
            bundleId: "com.deelightfullabs.Redacted",
            category: "Productivity"
        ),
        GraceMacApp(
            name: "RGB Exporter",
            shortDescription: "Convert images between color spaces.",
            appStoreId: "6756548374",
            bundleId: "com.deelightfullabs.PhotoColorSpace",
            category: "Graphics & Design"
        ),
    ]

    /// All Mac apps except the one with the given App Store ID
    /// (use the host app's own ID to exclude it from cross-promo).
    public static func all(excludingAppStoreId appStoreId: String?) -> [GraceMacApp] {
        guard let appStoreId else { return all }
        return all.filter { $0.appStoreId != appStoreId }
    }
}
