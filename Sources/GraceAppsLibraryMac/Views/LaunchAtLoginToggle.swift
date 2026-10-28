import SwiftUI

/// A toggle control for managing launch-at-login in macOS applications.
///
/// Automatically stays synchronized with `LaunchAtLoginManager.shared`, displays helpful
/// warnings when login item approval is pending in System Settings, and supports optional
/// subtitles and customizable toggle styling.
@MainActor
public struct LaunchAtLoginToggle<Label: View>: View {
    @ObservedObject private var manager: LaunchAtLoginManager
    private let label: Label
    private let subtitle: Text?
    private let useFormSwitchStyle: Bool

    /// Creates a launch-at-login toggle with a custom label view.
    public init(
        subtitle: Text? = nil,
        useFormSwitchStyle: Bool = true,
        manager: LaunchAtLoginManager? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.subtitle = subtitle
        self.useFormSwitchStyle = useFormSwitchStyle
        self._manager = ObservedObject(wrappedValue: manager ?? .shared)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if useFormSwitchStyle {
                Toggle(isOn: manager.binding) {
                    label
                }
                .toggleStyle(FormSwitchToggleStyle())
            } else {
                Toggle(isOn: manager.binding) {
                    label
                }
            }

            if manager.requiresApproval {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                    Text("Requires approval in System Settings.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Open Settings…") {
                        manager.openSystemSettings()
                    }
                    .font(.caption)
                    .buttonStyle(.link)
                }
            } else if let subtitle {
                subtitle
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onAppear {
            manager.refresh()
        }
    }
}

extension LaunchAtLoginToggle where Label == Text {
    /// Creates a launch-at-login toggle with a localized title and optional localized subtitle.
    public init(
        _ titleKey: LocalizedStringKey = "Open at login",
        subtitle: LocalizedStringKey? = nil,
        useFormSwitchStyle: Bool = true,
        manager: LaunchAtLoginManager? = nil
    ) {
        self.init(
            subtitle: subtitle != nil ? Text(subtitle!) : nil,
            useFormSwitchStyle: useFormSwitchStyle,
            manager: manager
        ) {
            Text(titleKey)
        }
    }

    /// Creates a launch-at-login toggle with a string title and optional string subtitle.
    public init<S: StringProtocol>(
        _ title: S,
        subtitle: S? = nil,
        useFormSwitchStyle: Bool = true,
        manager: LaunchAtLoginManager? = nil
    ) {
        self.init(
            subtitle: subtitle != nil ? Text(subtitle!) : nil,
            useFormSwitchStyle: useFormSwitchStyle,
            manager: manager
        ) {
            Text(title)
        }
    }
}
