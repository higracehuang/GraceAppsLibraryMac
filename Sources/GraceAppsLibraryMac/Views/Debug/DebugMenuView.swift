import SwiftUI

/// A full-featured macOS settings Form pane for QA testing and developer debugging.
///
/// Bundles `DebugFlowsSection`, `DebugReviewPromptSection`, `DebugReleaseNotesSection`,
/// and `DebugResetSection`, while allowing app-specific sections via `@ViewBuilder customContent`.
public struct DebugMenuView<CustomContent: View>: View {
    public let releaseNotes: [ReleaseNote]?
    public let isPaidUser: Bool
    public let presentPaywall: (() -> Void)?
    public let presentOnboarding: (() -> Void)?
    public let presentReleaseNotes: (() -> Void)?
    public let presentFeedback: (() -> Void)?
    public let presentReviewPrompt: (() -> Void)?
    public let onResetAppDefaults: (() -> Void)?
    private let customContent: CustomContent

    public init(
        releaseNotes: [ReleaseNote]? = nil,
        isPaidUser: Bool = false,
        presentPaywall: (() -> Void)? = nil,
        presentOnboarding: (() -> Void)? = nil,
        presentReleaseNotes: (() -> Void)? = nil,
        presentFeedback: (() -> Void)? = nil,
        presentReviewPrompt: (() -> Void)? = nil,
        onResetAppDefaults: (() -> Void)? = nil,
        @ViewBuilder customContent: () -> CustomContent = { EmptyView() }
    ) {
        self.releaseNotes = releaseNotes
        self.isPaidUser = isPaidUser
        self.presentPaywall = presentPaywall
        self.presentOnboarding = presentOnboarding
        self.presentReleaseNotes = presentReleaseNotes
        self.presentFeedback = presentFeedback
        self.presentReviewPrompt = presentReviewPrompt
        self.onResetAppDefaults = onResetAppDefaults
        self.customContent = customContent()
    }

    public var body: some View {
        Form {
            customContent

            DebugFlowsSection(
                presentPaywall: presentPaywall,
                presentOnboarding: presentOnboarding,
                presentReleaseNotes: presentReleaseNotes,
                presentFeedback: presentFeedback,
                presentReviewPrompt: presentReviewPrompt
            )

            DebugReviewPromptSection(
                onNegativeFeedback: presentFeedback
            )

            if let releaseNotes, !releaseNotes.isEmpty {
                DebugReleaseNotesSection(
                    releaseNotes: releaseNotes,
                    isPaidUser: isPaidUser
                )
            }

            DebugResetSection(
                onResetAppDefaults: onResetAppDefaults
            )
        }
    }
}

extension DebugMenuView where CustomContent == EmptyView {
    public init(
        releaseNotes: [ReleaseNote]? = nil,
        isPaidUser: Bool = false,
        presentPaywall: (() -> Void)? = nil,
        presentOnboarding: (() -> Void)? = nil,
        presentReleaseNotes: (() -> Void)? = nil,
        presentFeedback: (() -> Void)? = nil,
        presentReviewPrompt: (() -> Void)? = nil,
        onResetAppDefaults: (() -> Void)? = nil
    ) {
        self.init(
            releaseNotes: releaseNotes,
            isPaidUser: isPaidUser,
            presentPaywall: presentPaywall,
            presentOnboarding: presentOnboarding,
            presentReleaseNotes: presentReleaseNotes,
            presentFeedback: presentFeedback,
            presentReviewPrompt: presentReviewPrompt,
            onResetAppDefaults: onResetAppDefaults
        ) {
            EmptyView()
        }
    }
}
