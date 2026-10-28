import SwiftUI
import AppKit

/// A warm, personal feedback sheet for Grace's macOS apps.
/// Mirrors `GraceAppsLibrary.FeedbackToGraceView` from iOS:
/// personal message from Grace, prominent email button (prefilled with app and OS details),
/// clipboard copy helper for webmail users, appreciation note, and `DeveloperSignatureView`.
public struct FeedbackToGraceView: View {
    public static var feedbackEmail: String = "higracehuang@gmail.com"
    public static var feedbackMessage: String = "I'd love to hear your honest thoughts! Whether it's a feature idea, a bug, or just telling me what's working (and what isn't)—your feedback helps me improve. Please write to me at:"
    public static var feedbackAppreciation: String = "Thank you for helping me improve! ❤️"
    public static var feedbackSignature: String = "Grace"

    @Environment(\.dismiss) private var dismiss
    @State private var copiedEmail = false

    private let customEmail: String?
    private let customMessage: String?
    private let customAppreciation: String?
    private let customSignature: String?

    public init(
        email: String? = nil,
        message: String? = nil,
        appreciation: String? = nil,
        signature: String? = nil
    ) {
        self.customEmail = email
        self.customMessage = message
        self.customAppreciation = appreciation
        self.customSignature = signature
    }

    public var effectiveEmail: String {
        customEmail ?? Self.feedbackEmail
    }

    public var effectiveMessage: String {
        customMessage ?? Self.feedbackMessage
    }

    public var effectiveAppreciation: String {
        customAppreciation ?? Self.feedbackAppreciation
    }

    public var effectiveSignature: String {
        customSignature ?? Self.feedbackSignature
    }

    public var feedbackURL: URL {
        ReviewPromptManager.getFeedbackMailURL()
            ?? URL(string: "mailto:\(effectiveEmail)")!
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Sheet header bar matching macOS sheets ("Share Feedback" + "Done")
            HStack {
                Text("Share Feedback")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(effectiveMessage)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)

                        Link(destination: feedbackURL) {
                            HStack(spacing: 8) {
                                Image(systemName: "envelope.fill")
                                Text(effectiveEmail)
                                    .fontWeight(.semibold)
                            }
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        HStack {
                            Spacer()
                            Button {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(effectiveEmail, forType: .string)
                                copiedEmail = true
                            } label: {
                                Label(
                                    copiedEmail ? "Copied to Clipboard" : "Copy Email Address",
                                    systemImage: copiedEmail ? "checkmark.circle.fill" : "doc.on.doc"
                                )
                                .font(.caption)
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(copiedEmail ? .green : .secondary)
                            Spacer()
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(effectiveAppreciation)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text(effectiveSignature)
                                .font(.subheadline.italic())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    )

                    DeveloperSignatureView()
                }
                .padding(24)
            }
        }
        .frame(width: 460, height: 430)
    }
}
