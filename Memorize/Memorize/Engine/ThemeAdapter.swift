//  Engine/ThemeAdapter.swift

import Foundation
import SwiftUI

/// Translates legacy `EmojiThemeModel` into the new `Theme` plus an optional UI gradient.
enum ThemeAdapter {
    /// Adapts a legacy theme to `Theme` and an optional gradient as two `RGBA`s.
    static func adapt(from legacy: EmojiThemeModel) -> (
        theme: Theme, gradient: (RGBA, RGBA)?
    ) {
        let base = rgba(forName: legacy.color)
        let grad: (RGBA, RGBA)? = {
            if let g = legacy.colorG {
                return (base, rgba(forName: g))
            }
            return nil
        }()

        // Default to 8 pairs when unspecified, then clamp to 2...emojis.count.
        let desiredPairs = legacy.numberOfPairs ?? 8
        let theme = Theme(
            name: legacy.name,
            emojis: legacy.emojis,
            pairs: desiredPairs,
            rgba: base
        )
        return (theme, grad)
    }

    /// Name → RGBA mapping (kept small; mirrors previous color set).
    private static func rgba(forName name: String) -> RGBA {
        let color: Color
        switch name {
        case "orange": color = .orange
        case "yellow": color = .yellow
        case "green": color = .green
        case "black": color = .black
        case "red": color = .red
        case "purple": color = .purple
        case "gray": color = .gray
        case "pink": color = .pink
        case "brown": color = .brown
        case "teal": color = .teal
        case "blue": color = .blue
        case "cyan": color = .cyan
        default: color = .gray
        }
        return RGBA(color)
    }
}
