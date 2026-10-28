import SwiftUI

/// A compact gradient pill badge indicating a Pro / premium feature.
public struct ProBadge: View {
    private let title: String

    public init(title: String = "PRO") {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(
                LinearGradient(
                    colors: [.blue, .purple, .pink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
    }
}
