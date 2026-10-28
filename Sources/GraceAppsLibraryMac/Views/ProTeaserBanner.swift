import SwiftUI

/// A reusable teaser card promoting a Pro upgrade inside a grouped Form.
public struct ProTeaserBanner: View {
    private let title: String
    private let description: String
    private let buttonTitle: String
    private let badgeText: String?
    private let onAction: () -> Void

    public init(
        title: String,
        description: String,
        buttonTitle: String = "Upgrade to Pro",
        badgeText: String? = "PRO",
        onAction: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.badgeText = badgeText
        self.onAction = onAction
    }

    public var body: some View {
        Section {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.35), .pink.opacity(0.30)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.purple)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                        if let badgeText {
                            ProBadge(title: badgeText)
                        }
                    }
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                Button(buttonTitle) {
                    onAction()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
            }
            .padding(.vertical, 4)
        }
    }
}
