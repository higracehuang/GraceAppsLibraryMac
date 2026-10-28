import SwiftUI

/// A reusable macOS settings Form section for inspecting and test-applying App Store screenshot presets.
public struct DebugScreenshotSection<Preset: ScreenshotPresetProvider>: View {
    @ObservedObject public var engine: ScreenshotEngine<Preset>
    public let onApplyPreset: ((Preset) -> Void)?
    public let onReset: (() -> Void)?

    @State private var selectedPresetId: String

    public init(
        engine: ScreenshotEngine<Preset>,
        onApplyPreset: ((Preset) -> Void)? = nil,
        onReset: (() -> Void)? = nil
    ) {
        self.engine = engine
        self.onApplyPreset = onApplyPreset
        self.onReset = onReset
        self._selectedPresetId = State(initialValue: engine.activePreset?.id ?? Preset.allCases.first?.id ?? "")
    }

    public var body: some View {
        Section {
            Picker("Preset slot", selection: $selectedPresetId) {
                ForEach(Array(Preset.allCases), id: \.id) { preset in
                    Label(preset.slotLabel, systemImage: preset.systemImage)
                        .tag(preset.id)
                }
            }

            Picker("Language", selection: $engine.selectedLanguage) {
                ForEach(ScreenshotLanguage.allCases) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }

            if let active = engine.activePreset {
                LabeledContent("Active headline") {
                    Text(active.title)
                        .fontWeight(.semibold)
                }

                if !active.subtitle.isEmpty {
                    LabeledContent("Subheadline") {
                        Text(active.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }

                LabeledContent("Suggested file") {
                    Text("\(active.suggestedFilename).png")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                Button {
                    if let preset = Preset.from(token: selectedPresetId) {
                        if let onApplyPreset {
                            engine.activePreset = preset
                            onApplyPreset(preset)
                        } else {
                            engine.apply(preset: preset)
                        }
                    }
                } label: {
                    Label("Apply Preset", systemImage: "sparkles")
                }

                Spacer()

                if engine.activePreset != nil {
                    Button("Reset Preset", role: .destructive) {
                        if let onReset {
                            engine.activePreset = nil
                            onReset()
                        } else {
                            engine.reset()
                        }
                    }
                }
            }
        } header: {
            Text("App Store Marketing & Screenshots")
        } footer: {
            Text("Configures the App Store screenshot presets. Pass '-SCREENSHOT_PRESET <id>' on launch or run automated screenshot scripts.")
        }
    }
}
