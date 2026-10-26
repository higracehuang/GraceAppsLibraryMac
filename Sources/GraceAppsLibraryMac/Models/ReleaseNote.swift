import SwiftUI

public struct ReleaseNoteItem: Identifiable, Hashable {
    public let id = UUID()
    public let text: LocalizedStringKey
    public let isPaidFeature: Bool

    public init(text: LocalizedStringKey, isPaidFeature: Bool = false) {
        self.text = text
        self.isPaidFeature = isPaidFeature
    }

    public static func == (lhs: ReleaseNoteItem, rhs: ReleaseNoteItem) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct ReleaseNote: Identifiable, Hashable {
    public let id = UUID()
    public let version: String
    public let items: [ReleaseNoteItem]
    public let ctaTitle: LocalizedStringKey?
    public let ctaURL: URL?
    public let ctaAction: (() -> Void)?

    public var hasPaidFeature: Bool {
        items.contains { $0.isPaidFeature }
    }

    public init(
        version: String,
        items: [ReleaseNoteItem],
        ctaTitle: LocalizedStringKey? = nil,
        ctaURL: URL? = nil,
        ctaAction: (() -> Void)? = nil
    ) {
        self.version = version
        self.items = items
        self.ctaTitle = ctaTitle
        self.ctaURL = ctaURL
        self.ctaAction = ctaAction
    }

    public static func == (lhs: ReleaseNote, rhs: ReleaseNote) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
