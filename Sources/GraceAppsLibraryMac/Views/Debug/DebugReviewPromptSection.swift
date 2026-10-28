import SwiftUI

/// A reusable settings Form section for testing and inspecting `ReviewPromptManager` on macOS.
public struct DebugReviewPromptSection: View {
    public let onNegativeFeedback: (() -> Void)?
    @State private var engagementCount: Int = 0
    @State private var lastPromptedVersion: String?

    public init(onNegativeFeedback: (() -> Void)? = nil) {
        self.onNegativeFeedback = onNegativeFeedback
    }

    public var body: some View {
        Section {
            LabeledContent("Engagement counter") {
                Text("\(engagementCount)")
                    .foregroundStyle(.secondary)
            }

            LabeledContent("Last prompted version") {
                Text(lastPromptedVersion ?? "Never")
                    .foregroundStyle(.secondary)
            }

            LabeledContent("Two-step prompt") {
                Button("Present Review Alert…") {
                    ReviewPromptManager.shared.debugPresentReviewPrompt(onNegativeFeedback: onNegativeFeedback)
                    refresh()
                }
            }

            LabeledContent("Native review dialog") {
                Button("Present Direct Native Prompt…") {
                    ReviewPromptManager.shared.requestDirectNativeReview()
                    refresh()
                }
            }

            LabeledContent("Review state") {
                Button("Reset Review State") {
                    ReviewPromptManager.shared.debugResetReviewState()
                    refresh()
                }
            }
        } header: {
            Text("Review Prompts (GALM)")
        } footer: {
            Text("Test positive ('Love it!') native StoreKit reviews or negative ('Not really') feedback routing.")
        }
        .onAppear {
            refresh()
        }
    }

    private func refresh() {
        engagementCount = ReviewPromptManager.shared.debugEngagementCount
        lastPromptedVersion = ReviewPromptManager.shared.debugLastVersionPrompted
    }
}
