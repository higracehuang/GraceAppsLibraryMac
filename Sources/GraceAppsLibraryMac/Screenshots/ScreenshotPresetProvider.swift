import Foundation

/// Protocol that each app conforms to for defining its App Store screenshot presets.
///
/// Follows GraceAppsLibrary's screenshot automation framework.
/// Example:
/// ```swift
/// enum AppScreenshotPreset: String, CaseIterable, ScreenshotPresetProvider {
///     case mainBenefit = "1"
///     case topFeature = "2"
/// }
/// ```
public protocol ScreenshotPresetProvider: Identifiable, CaseIterable, RawRepresentable where RawValue == String {
    var id: String { get }
    var slotLabel: String { get }
    var title: String { get }
    var subtitle: String { get }
    var suggestedFilename: String { get }
    var systemImage: String { get }
    var cliArgumentExample: String { get }

    static func from(token: String) -> Self?
    static func fromLaunchEnvironment(arguments: [String], environment: [String: String]) -> Self?
}

public extension ScreenshotPresetProvider {
    var id: String { rawValue }
    var subtitle: String { "" }

    var cliArgumentExample: String {
        "-SCREENSHOT_PRESET \(rawValue)"
    }

    /// Matches a token against rawValue, id, title, or filename.
    static func from(token: String) -> Self? {
        let normalized = token.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let direct = Self(rawValue: normalized) ?? Self(rawValue: token) {
            return direct
        }
        return Self.allCases.first { preset in
            preset.rawValue.lowercased() == normalized ||
            preset.id.lowercased() == normalized ||
            preset.title.lowercased().contains(normalized) ||
            preset.suggestedFilename.lowercased().contains(normalized)
        }
    }

    /// Detects `-SCREENSHOT_PRESET <token>`, `-screenshotPreset <token>`, or env `SCREENSHOT_PRESET`.
    static func fromLaunchEnvironment(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> Self? {
        if let idx = arguments.firstIndex(where: { $0 == "-SCREENSHOT_PRESET" || $0 == "-screenshotPreset" }),
           idx + 1 < arguments.count {
            return from(token: arguments[idx + 1])
        }
        if let envVal = environment["SCREENSHOT_PRESET"] {
            return from(token: envVal)
        }
        return nil
    }
}
