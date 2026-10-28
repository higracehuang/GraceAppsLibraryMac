import SwiftUI

/// A reusable settings Form section for test-triggering common modal sheets and windows on macOS.
public struct DebugFlowsSection: View {
    public let presentPaywall: (() -> Void)?
    public let presentOnboarding: (() -> Void)?
    public let presentReleaseNotes: (() -> Void)?
    public let presentFeedback: (() -> Void)?
    public let presentReviewPrompt: (() -> Void)?

    public init(
        presentPaywall: (() -> Void)? = nil,
        presentOnboarding: (() -> Void)? = nil,
        presentReleaseNotes: (() -> Void)? = nil,
        presentFeedback: (() -> Void)? = nil,
        presentReviewPrompt: (() -> Void)? = nil
    ) {
        self.presentPaywall = presentPaywall
        self.presentOnboarding = presentOnboarding
        self.presentReleaseNotes = presentReleaseNotes
        self.presentFeedback = presentFeedback
        self.presentReviewPrompt = presentReviewPrompt
    }

    public var body: some View {
        Section {
            if let presentPaywall {
                LabeledContent("Paywall sheet") {
                    Button("Present Pro Paywall…") {
                        presentPaywall()
                    }
                }
            }

            if let presentOnboarding {
                LabeledContent("Welcome tour") {
                    Button("Present Welcome Window…") {
                        presentOnboarding()
                    }
                }
            }

            if let presentReleaseNotes {
                LabeledContent("What's New sheet") {
                    Button("Present Release Notes…") {
                        presentReleaseNotes()
                    }
                }
            }

            if let presentReviewPrompt {
                LabeledContent("Review prompt") {
                    Button("Present Review Prompt…") {
                        presentReviewPrompt()
                    }
                }
            }

            if let presentFeedback {
                LabeledContent("Feedback sheet") {
                    Button("Present Share Feedback…") {
                        presentFeedback()
                    }
                }
            }
        } header: {
            Text("Sheets & Flows")
        } footer: {
            Text("Trigger any application sheet or modal window directly for UI testing and layout verification.")
        }
    }
}
