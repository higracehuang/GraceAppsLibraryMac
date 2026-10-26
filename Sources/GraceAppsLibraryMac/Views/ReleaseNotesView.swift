import SwiftUI

/// A plain release-notes sheet. Marks the current version as viewed
/// on appear, which also suppresses a review prompt for this session.
public struct ReleaseNotesView: View {
    private let releaseNotes: [ReleaseNote]
    private let isPaidUser: Bool

    @Environment(\.dismiss) private var dismiss

    public init(releaseNotes: [ReleaseNote], isPaidUser: Bool = false) {
        self.releaseNotes = releaseNotes
        self.isPaidUser = isPaidUser
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's New")
                .font(.largeTitle)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(releaseNotes) { note in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(note.version)
                                .font(.headline)
                            ForEach(note.items) { item in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                    Text(item.text)
                                }
                            }
                            if let ctaTitle = note.ctaTitle, !isPaidUser || note.ctaURL != nil {
                                if let ctaURL = note.ctaURL {
                                    Link(ctaTitle, destination: ctaURL)
                                } else if let ctaAction = note.ctaAction {
                                    Button(ctaTitle, action: ctaAction)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button("Done") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding()
        .frame(minWidth: 420, minHeight: 320)
        .onAppear {
            ReleaseNotesManager.shared.markCurrentVersionAsViewed()
            ReleaseNotesManager.hasShownReleaseNotesThisSession = true
        }
    }
}
