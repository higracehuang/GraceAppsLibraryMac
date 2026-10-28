import Foundation

/// Supported languages for automated App Store screenshots across Grace's Mac apps.
public enum ScreenshotLanguage: String, CaseIterable, Identifiable {
    case auto = "auto"
    case english = "en"
    case simplifiedChinese = "zh"
    case traditionalChinese = "zh-Hant"
    case german = "de"
    case spanish = "es"
    case japanese = "ja"
    case korean = "ko"
    case french = "fr"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .auto: return "Auto (System Locale)"
        case .english: return "English"
        case .simplifiedChinese: return "简体中文 (Simplified Chinese)"
        case .traditionalChinese: return "繁體中文 (Traditional Chinese)"
        case .german: return "Deutsch (German)"
        case .spanish: return "Español (Spanish)"
        case .japanese: return "日本語 (Japanese)"
        case .korean: return "한국어 (Korean)"
        case .french: return "Français (French)"
        }
    }

    /// Language code passed to macOS `-AppleLanguages "(<code>)"`
    public var appleLanguageCode: String {
        switch self {
        case .auto, .english: return "en"
        case .simplifiedChinese: return "zh-Hans"
        case .traditionalChinese: return "zh-Hant"
        case .german: return "de"
        case .spanish: return "es"
        case .japanese: return "ja"
        case .korean: return "ko"
        case .french: return "fr"
        }
    }

    /// Locale identifier passed to macOS `-AppleLocale "<locale>"`
    public var appleLocaleIdentifier: String {
        switch self {
        case .auto, .english: return "en_US"
        case .simplifiedChinese: return "zh_CN"
        case .traditionalChinese: return "zh_TW"
        case .german: return "de_DE"
        case .spanish: return "es_ES"
        case .japanese: return "ja_JP"
        case .korean: return "ko_KR"
        case .french: return "fr_FR"
        }
    }

    /// Resolves `.auto` to the system's preferred language, or returns the explicit choice.
    public var resolved: ScreenshotLanguage {
        guard self == .auto else { return self }
        let identifier = (Locale.preferredLanguages.first ?? Locale.current.identifier).lowercased()
        if identifier.contains("hant") || identifier.contains("tw") || identifier.contains("hk") {
            return .traditionalChinese
        } else if identifier.hasPrefix("zh") {
            return .simplifiedChinese
        } else if identifier.hasPrefix("ko") {
            return .korean
        } else if identifier.hasPrefix("de") {
            return .german
        } else if identifier.hasPrefix("es") {
            return .spanish
        } else if identifier.hasPrefix("ja") {
            return .japanese
        } else if identifier.hasPrefix("fr") {
            return .french
        } else {
            return .english
        }
    }

    /// Matches a language token (e.g. "en", "zh-Hans", "zh-Hant", "korean", "ko", "japanese").
    public static func from(token: String) -> ScreenshotLanguage? {
        let normalized = token.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized.contains("hant") || normalized.contains("traditional") || normalized == "zh-tw" || normalized == "zh-hk" {
            return .traditionalChinese
        }
        if normalized.hasPrefix("zh") || normalized.contains("chinese") || normalized.contains("hans") {
            return .simplifiedChinese
        }
        if normalized.hasPrefix("ko") || normalized.contains("korean") || normalized.contains("한국어") {
            return .korean
        }
        if normalized.hasPrefix("de") || normalized.contains("german") || normalized.contains("deutsch") { return .german }
        if normalized.hasPrefix("es") || normalized.contains("spanish") || normalized.contains("español") { return .spanish }
        if normalized.hasPrefix("ja") || normalized.contains("japanese") || normalized.contains("日本語") { return .japanese }
        if normalized.hasPrefix("fr") || normalized.contains("french") || normalized.contains("français") { return .french }
        if normalized.hasPrefix("en") || normalized.contains("english") { return .english }
        if normalized == "auto" { return .auto }
        return nil
    }

    /// Reads launch arguments or environment variables for language overrides.
    public static func fromLaunchEnvironment(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> ScreenshotLanguage? {
        var rawValue: String?
        if let idx = arguments.firstIndex(where: { $0 == "-SCREENSHOT_LANG" || $0 == "-screenshotLang" }),
           idx + 1 < arguments.count {
            rawValue = arguments[idx + 1]
        } else if let envLang = environment["SCREENSHOT_LANG"] {
            rawValue = envLang
        }

        guard let raw = rawValue else { return nil }
        return from(token: raw)
    }
}
