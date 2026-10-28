import Foundation
import SwiftUI

/// Base coordinator engine for macOS App Store screenshot automation and in-app QA preview.
@MainActor
open class ScreenshotEngine<Preset: ScreenshotPresetProvider>: ObservableObject {
    @Published open var activePreset: Preset?
    @Published open var selectedLanguage: ScreenshotLanguage = .auto

    open var onApply: ((Preset) -> Void)?
    open var onReset: (() -> Void)?

    public init(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        if let launchLang = ScreenshotLanguage.fromLaunchEnvironment(arguments: arguments, environment: environment) {
            self.selectedLanguage = launchLang
        }
        if let launchPreset = Preset.fromLaunchEnvironment(arguments: arguments, environment: environment) {
            self.activePreset = launchPreset
        }
    }

    /// Whether screenshot capture mode is active.
    open var isScreenshotCaptureActive: Bool {
        activePreset != nil || Self.isScreenshotCaptureActive()
    }

    /// Checks if `-SCREENSHOT_PRESET` or `SCREENSHOT_PRESET` was passed in the environment.
    public static func isScreenshotCaptureActive(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> Bool {
        arguments.contains("-SCREENSHOT_PRESET") ||
        arguments.contains("-screenshotPreset") ||
        environment["SCREENSHOT_PRESET"] != nil
    }

    /// The effective language for screenshot copy.
    open var effectiveLanguage: ScreenshotLanguage {
        selectedLanguage.resolved
    }

    open func apply(preset: Preset) {
        activePreset = preset
        onApply?(preset)
    }

    open func reset() {
        activePreset = nil
        onReset?()
    }
}
