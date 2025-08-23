//  Engine/ThemeAdapter.swift

import Foundation

/// Translates legacy `EmojiThemeModel` into the new `Theme` plus an optional UI gradient.
enum ThemeAdapter {
    static func adapt(from legacy: EmojiThemeModel) -> (
        theme: Theme, gradient: (RGBA, RGBA)?
    ) {
        let base = rgba(forName: legacy.color)
        let grad: (RGBA, RGBA)? = {
            if let g = legacy.colorG { return (base, rgba(forName: g)) }
            return nil
        }()
        let desiredPairs = legacy.numberOfPairs ?? 8
        let theme = Theme(
            name: legacy.name,
            emojis: legacy.emojis,
            pairs: desiredPairs,
            rgba: base
        )
        return (theme, grad)
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
