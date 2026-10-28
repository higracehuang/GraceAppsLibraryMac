import Foundation

/// Standard 5-slot macOS App Store screenshot framework used across Grace's Mac apps.
///
/// Follows GraceAppsLibrary's 5-screen desktop App Store framework:
/// 1. Slot #1 • Main Benefit (Hero feature in action)
/// 2. Slot #2 • Top Feature (Core productivity differentiator)
/// 3. Slot #3 • Secondary Feature (Integration / Shortcuts / Workflow)
/// 4. Slot #4 • Realistic Result (Studio quality / Exported output)
/// 5. Slot #5 • Differentiator (Customization, Settings & Pro Overview)
public enum StandardMacScreenshotPreset: String, CaseIterable, Identifiable, ScreenshotPresetProvider {
    case slot1Benefit = "1"
    case slot2Feature = "2"
    case slot3SecondFeature = "3"
    case slot4Result = "4"
    case slot5Customization = "5"

    public var slotLabel: String {
        switch self {
        case .slot1Benefit: return "Slot #1 • Main Benefit"
        case .slot2Feature: return "Slot #2 • Top Feature"
        case .slot3SecondFeature: return "Slot #3 • Second Feature"
        case .slot4Result: return "Slot #4 • Realistic Result"
        case .slot5Customization: return "Slot #5 • Customization & Settings"
        }
    }

    public var title: String {
        switch self {
        case .slot1Benefit: return "Main Benefit"
        case .slot2Feature: return "Top Feature"
        case .slot3SecondFeature: return "Second Feature"
        case .slot4Result: return "Realistic Result"
        case .slot5Customization: return "Customization & Settings"
        }
    }

    public var subtitle: String {
        switch self {
        case .slot1Benefit: return "Instant, friction-free utility"
        case .slot2Feature: return "Engineered for macOS workflows"
        case .slot3SecondFeature: return "Keyboard shortcuts & background efficiency"
        case .slot4Result: return "Professional results without the learning curve"
        case .slot5Customization: return "Fine-tune behavior to match your setup"
        }
    }

    public var suggestedFilename: String {
        switch self {
        case .slot1Benefit: return "01 - Main Benefit"
        case .slot2Feature: return "02 - Top Feature"
        case .slot3SecondFeature: return "03 - Second Feature"
        case .slot4Result: return "04 - Realistic Result"
        case .slot5Customization: return "05 - Customization and Settings"
        }
    }

    public var systemImage: String {
        switch self {
        case .slot1Benefit: return "sparkles"
        case .slot2Feature: return "wand.and.stars"
        case .slot3SecondFeature: return "command"
        case .slot4Result: return "checkmark.seal.fill"
        case .slot5Customization: return "slider.horizontal.3"
        }
    }
}
