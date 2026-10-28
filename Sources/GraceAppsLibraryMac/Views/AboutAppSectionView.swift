import SwiftUI

/// A ready-made About section for a Mac app's Settings screen:
/// version, a What's New button, a rate link, and feedback options.
/// No paywall logic lives here; pass `paywallAction` only if the
/// host app wants a CTA on its release notes, and the view handles
/// hiding it for paid users via `isPaidUser`.
public struct AboutAppSectionView: View {
    private let appStoreId: String
    private let releaseNotes: [ReleaseNote]
    private let isPaidUser: Bool
    private let presentsFeedbackSheet: Bool

    @State private var showingReleaseNotes = false
    @State private var showingFeedbackSheet = false

    public init(
        appStoreId: String,
        releaseNotes: [ReleaseNote] = [],
        isPaidUser: Bool = false,
        presentsFeedbackSheet: Bool = false
    ) {
        self.appStoreId = appStoreId
        self.releaseNotes = releaseNotes
        self.isPaidUser = isPaidUser
        self.presentsFeedbackSheet = presentsFeedbackSheet
    }

    public var body: some View {
        Section("About") {
            LabeledContent("Version", value: Bundle.main.displayVersionString)
            if !releaseNotes.isEmpty {
                Button("What's New") {
                    showingReleaseNotes = true
                }
            }
            if let reviewURL = ReviewPromptManager.getReviewURL(appStoreId: appStoreId) {
                Link("Rate on the App Store", destination: reviewURL)
            }
            if presentsFeedbackSheet {
                Button("Share Feedback…") {
                    showingFeedbackSheet = true
                }
            } else if let feedbackURL = ReviewPromptManager.getFeedbackMailURL() {
                Link("Send Feedback", destination: feedbackURL)
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
