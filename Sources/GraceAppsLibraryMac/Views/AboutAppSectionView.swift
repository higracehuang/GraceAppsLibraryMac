import SwiftUI

/// A ready-made About section for a Mac app's Settings screen:
/// version, a What's New button, a rate link, and feedback options.
/// No paywall logic lives here; pass `paywallAction` only if the
/// host app wants a CTA on its release notes, and the view handles
/// hiding it for paid users via `isPaidUser`.
public struct AboutAppSectionView: View {
    private let channel: DistributionChannel
    private let releaseNotes: [ReleaseNote]
    private let isPaidUser: Bool
    private let presentsFeedbackSheet: Bool

    @State private var showingReleaseNotes = false
    @State private var showingFeedbackSheet = false

    public init(
        channel: DistributionChannel,
        releaseNotes: [ReleaseNote] = [],
        isPaidUser: Bool = false,
        presentsFeedbackSheet: Bool = false
    ) {
        self.channel = channel
        self.releaseNotes = releaseNotes
        self.isPaidUser = isPaidUser
        self.presentsFeedbackSheet = presentsFeedbackSheet
    }

    public init(
        appStoreId: String,
        releaseNotes: [ReleaseNote] = [],
        isPaidUser: Bool = false,
        presentsFeedbackSheet: Bool = false
    ) {
        self.init(
            channel: .appStore(id: appStoreId),
            releaseNotes: releaseNotes,
            isPaidUser: isPaidUser,
            presentsFeedbackSheet: presentsFeedbackSheet
        )
    }

    public var body: some View {
        Section(String(localized: "About", bundle: .module)) {
            LabeledContent(String(localized: "Version", bundle: .module), value: Bundle.main.displayVersionString)
            if !releaseNotes.isEmpty {
                Button(String(localized: "What's New", bundle: .module)) {
                    showingReleaseNotes = true
                }
            }
            switch channel {
            case .appStore(let id):
                if !id.isEmpty, let reviewURL = ReviewPromptManager.getReviewURL(appStoreId: id) {
                    Link(String(localized: "Rate on the App Store", bundle: .module), destination: reviewURL)
                }
            case .direct(let url):
                if let url {
                    Link(String(localized: "Rate or Review", bundle: .module), destination: url)
                }
            }
            if presentsFeedbackSheet {
                Button(String(localized: "Share Feedback…", bundle: .module)) {
                    showingFeedbackSheet = true
                }
            } else if let feedbackURL = ReviewPromptManager.getFeedbackMailURL() {
                Link(String(localized: "Send Feedback", bundle: .module), destination: feedbackURL)
            }
        }
        .sheet(isPresented: $showingReleaseNotes) {
            ReleaseNotesView(releaseNotes: releaseNotes, isPaidUser: isPaidUser)
        }
        .sheet(isPresented: $showingFeedbackSheet) {
            FeedbackToGraceView()
        }
    }
}
