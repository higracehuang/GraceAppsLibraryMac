import SwiftUI

/// A clean card or row indicating that all Pro features are unlocked (e.g. for Direct / Gumroad distribution).
public struct FullVersionStatusView: View {
    private let title: String
    private let description: String

    public init(
        title: String? = nil,
        description: String? = nil
    ) {
        self.title = title ?? String(localized: "Full Version Active", bundle: .module)
        self.description = description ?? String(localized: "All features unlocked.", bundle: .module)
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
