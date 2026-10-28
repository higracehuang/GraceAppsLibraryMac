import SwiftUI

/// A reusable settings Form section for previewing release notes and inspecting version state on macOS.
public struct DebugReleaseNotesSection: View {
    public let releaseNotes: [ReleaseNote]?
    public let isPaidUser: Bool

    @State private var lastViewedVersion: String?
    @State private var isPresentingSheet = false

    public init(
        releaseNotes: [ReleaseNote]? = nil,
        isPaidUser: Bool = false
    ) {
        self.releaseNotes = releaseNotes
        self.isPaidUser = isPaidUser
    }

    public var body: some View {
        Section {
            LabeledContent("Last viewed version") {
                Text(lastViewedVersion ?? "None (Fresh Install)")
                    .foregroundStyle(.secondary)
            }

            if let releaseNotes, !releaseNotes.isEmpty {
                LabeledContent("What's New sheet") {
                    Button("Present Release Notes…") {
                        isPresentingSheet = true
                    }
                }
                .sheet(isPresented: $isPresentingSheet) {
                    ReleaseNotesView(
                        releaseNotes: releaseNotes,
                        isPaidUser: isPaidUser
                    )
                }
            }

            LabeledContent("Release notes state") {
                Button("Reset Release Notes State") {
                    ReleaseNotesManager.shared.resetReleaseNotesState()
                    refresh()
                }
            }
        } header: {
            Text("Release Notes (GALM)")
        } footer: {
            Text("Resetting state simulates an app upgrade so the 'What's New' sheet appears on the next launch.")
        }
        .onAppear {
            refresh()
        }
    }

    private func refresh() {
        lastViewedVersion = ReleaseNotesManager.shared.lastViewedVersion
    }
}
