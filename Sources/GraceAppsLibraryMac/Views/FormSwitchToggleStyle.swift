import SwiftUI

/// Pure SwiftUI switch row style for grouped Form sections on macOS.
///
/// AppKit's default `NSSwitch` inside a grouped SwiftUI `Form` can have an offset
/// or finicky hit target on macOS. Rendering the switch in pure SwiftUI with a
/// full-row `contentShape` ensures both the switch capsule and the entire row
/// respond immediately on the first click.
public struct FormSwitchToggleStyle: ToggleStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        LabeledContent {
            Capsule()
                .fill(configuration.isOn ? Color.accentColor : Color.secondary.opacity(0.28))
                .frame(width: 38, height: 22)
                .overlay(alignment: configuration.isOn ? .trailing : .leading) {
                    Circle()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                        .padding(2)
                }
                .animation(.easeInOut(duration: 0.15), value: configuration.isOn)
                .padding(.vertical, 2)
        } label: {
            configuration.label
        }
        .contentShape(Rectangle())
        .onTapGesture {
            configuration.isOn.toggle()
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(configuration.isOn ? "On" : "Off")
    }
}

extension ToggleStyle where Self == FormSwitchToggleStyle {
    public static var formSwitch: FormSwitchToggleStyle { FormSwitchToggleStyle() }
}
