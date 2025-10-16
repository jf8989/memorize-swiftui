//  Engine/ThemeAdapter.swift

import Foundation

/// Translates legacy `EmojiThemeModel` into the new `Theme`.
enum ThemeAdapter {
    static func adapt(from legacy: EmojiThemeModel) -> Theme {
        let base = rgba(forName: legacy.color)
        let grad = legacy.colorG.map { rgba(forName: $0) }
        let desiredPairs = legacy.numberOfPairs ?? 8
        return Theme(
            name: legacy.name,
            emojis: legacy.emojis,
            pairs: desiredPairs,
            rgba: base,
            rgbaG: grad
        )
    }

    // Name → RGBA mapping without Color/SwiftUI
    private static func rgba(forName name: String) -> RGBA {
        switch name {
        case "orange": return RGBA(r: 1.00, g: 0.58, b: 0.00)
        case "yellow": return RGBA(r: 1.00, g: 0.84, b: 0.00)
        case "green": return RGBA(r: 0.20, g: 0.75, b: 0.35)
        case "black": return RGBA(r: 0.00, g: 0.00, b: 0.00)
        case "red": return RGBA(r: 0.92, g: 0.26, b: 0.23)
        case "purple": return RGBA(r: 0.56, g: 0.27, b: 0.68)
        case "gray": return RGBA(r: 0.60, g: 0.60, b: 0.62)
        case "pink": return RGBA(r: 1.00, g: 0.45, b: 0.70)
        case "brown": return RGBA(r: 0.64, g: 0.47, b: 0.33)
        case "teal": return RGBA(r: 0.25, g: 0.65, b: 0.65)
        case "blue": return RGBA(r: 0.00, g: 0.48, b: 1.00)
        case "cyan": return RGBA(r: 0.35, g: 0.78, b: 0.98)
        default: return .gray
        }
    }
}
