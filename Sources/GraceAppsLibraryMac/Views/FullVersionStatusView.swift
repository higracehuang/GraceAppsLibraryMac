import SwiftUI

/// A clean card or row indicating that all Pro features are unlocked (e.g. for Direct / Gumroad distribution).
public struct FullVersionStatusView: View {
    private let title: String
    private let description: String

    public init(
        title: String = "Full Version Active",
        description: String = "All features are unlocked. Thank you for your support!"
    ) {
        self.title = title
        self.description = description
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.18))
                    .frame(width: 36, height: 36)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.green)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 4)
        }
        .padding(.vertical, 4)
    }
}
