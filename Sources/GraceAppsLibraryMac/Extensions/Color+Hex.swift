import AppKit
import SwiftUI

extension Color {
    /// Initializes a SwiftUI `Color` from a hex string (e.g. `"#FF0000"`, `"FF0000"`).
    ///
    /// By default parses 6-character `#RRGGBB` strings with full opacity.
    /// If `includeAlpha` is true, 8-character `#RRGGBBAA` strings are also accepted.
    /// Returns `nil` if the string contains invalid hex characters or unrecognized length.
    public init?(hex: String, includeAlpha: Bool = false) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") {
            cleaned.removeFirst()
        }

        if includeAlpha && cleaned.count == 8 {
            guard let value = UInt64(cleaned, radix: 16) else { return nil }
            let red = Double((value >> 24) & 0xFF) / 255.0
            let green = Double((value >> 16) & 0xFF) / 255.0
            let blue = Double((value >> 8) & 0xFF) / 255.0
            let alpha = Double(value & 0xFF) / 255.0
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
        } else if cleaned.count == 6 {
            guard let value = UInt64(cleaned, radix: 16) else { return nil }
            let red = Double((value >> 16) & 0xFF) / 255.0
            let green = Double((value >> 8) & 0xFF) / 255.0
            let blue = Double(value & 0xFF) / 255.0
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
        } else {
            return nil
        }
    }

    /// Converts the SwiftUI `Color` to a uppercase `#RRGGBB` hex string (or `#RRGGBBAA` if `includeAlpha` is true).
    ///
    /// Returns `nil` if the color cannot be converted to the sRGB color space.
    public func toHex(includeAlpha: Bool = false) -> String? {
        guard let rgb = NSColor(self).usingColorSpace(.sRGB) else { return nil }
        let red = Int(round(rgb.redComponent * 255))
        let green = Int(round(rgb.greenComponent * 255))
        let blue = Int(round(rgb.blueComponent * 255))

        if includeAlpha {
            let alpha = Int(round(rgb.alphaComponent * 255))
            return String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
        } else {
            return String(format: "#%02X%02X%02X", red, green, blue)
        }
    }
}

extension NSColor {
    /// Initializes an `NSColor` from a hex string (e.g. `"#FF0000"`, `"FF0000"`).
    ///
    /// By default parses 6-character `#RRGGBB` strings with full opacity.
    /// If `includeAlpha` is true, 8-character `#RRGGBBAA` strings are also accepted.
    /// Returns `nil` if the string contains invalid hex characters or unrecognized length.
    public convenience init?(hex: String, includeAlpha: Bool = false) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") {
            cleaned.removeFirst()
        }

        if includeAlpha && cleaned.count == 8 {
            guard let value = UInt64(cleaned, radix: 16) else { return nil }
            let red = CGFloat((value >> 24) & 0xFF) / 255.0
            let green = CGFloat((value >> 16) & 0xFF) / 255.0
            let blue = CGFloat((value >> 8) & 0xFF) / 255.0
            let alpha = CGFloat(value & 0xFF) / 255.0
            self.init(srgbRed: red, green: green, blue: blue, alpha: alpha)
        } else if cleaned.count == 6 {
            guard let value = UInt64(cleaned, radix: 16) else { return nil }
            let red = CGFloat((value >> 16) & 0xFF) / 255.0
            let green = CGFloat((value >> 8) & 0xFF) / 255.0
            let blue = CGFloat(value & 0xFF) / 255.0
            self.init(srgbRed: red, green: green, blue: blue, alpha: 1.0)
        } else {
            return nil
        }
    }

    /// Converts the `NSColor` to a uppercase `#RRGGBB` hex string (or `#RRGGBBAA` if `includeAlpha` is true).
    ///
    /// Returns `nil` if the color cannot be converted to the sRGB color space.
    public func toHex(includeAlpha: Bool = false) -> String? {
        guard let rgb = self.usingColorSpace(.sRGB) else { return nil }
        let red = Int(round(rgb.redComponent * 255))
        let green = Int(round(rgb.greenComponent * 255))
        let blue = Int(round(rgb.blueComponent * 255))

        if includeAlpha {
            let alpha = Int(round(rgb.alphaComponent * 255))
            return String(format: "#%02X%02X%02X%02X", red, green, blue, alpha)
        } else {
            return String(format: "#%02X%02X%02X", red, green, blue)
        }
    }
}
