import SwiftUI

/// A reusable settings Form section for resetting UserDefaults and app states on macOS.
public struct DebugResetSection: View {
    public let onResetAppDefaults: (() -> Void)?
    public let includeReviewReset: Bool
    public let includeReleaseNotesReset: Bool

    @State private var showingConfirmation = false

    public init(
        includeReviewReset: Bool = true,
        includeReleaseNotesReset: Bool = true,
        onResetAppDefaults: (() -> Void)? = nil
    ) {
        self.includeReviewReset = includeReviewReset
        self.includeReleaseNotesReset = includeReleaseNotesReset
        self.onResetAppDefaults = onResetAppDefaults
    }

    public var body: some View {
        Section {
            Button(role: .destructive) {
                showingConfirmation = true
            } label: {
                Text("Reset All Settings to Defaults")
            }
            .confirmationDialog(
                "Reset All Settings to Defaults?",
                isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset to Defaults", role: .destructive) {
                    performReset()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will restore default settings. This action cannot be undone.")
            }
        } header: {
            Text("State & UserDefaults")
        }
    }

    private func performReset() {
        if includeReviewReset {
            ReviewPromptManager.shared.debugResetReviewState()
        }
        if includeReleaseNotesReset {
            ReleaseNotesManager.shared.resetReleaseNotesState()
        }
        onResetAppDefaults?()
    }
}
