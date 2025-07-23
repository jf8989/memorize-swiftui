// Model/Theme.swift

import SwiftUI

enum EmojiTheme: CaseIterable {
    case halloween, animal, vehicles

    var emojis: [String] {
        switch self {
        case .halloween: return ["👻", "🎃", "🕷️", "💀", "🧙‍♀️", "🦇", "🌕", "⚰️"]
        case .animal: return ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻"]
        case .vehicles: return ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎️"]
        }
    }

    var name: String {
        switch self {
        case .halloween: return "Halloween"
        case .animal: return "Animals"
        case .vehicles: return "Vehicles"
        }
    }

    var symbol: String {
        switch self {
        case .halloween: return "theatermasks.fill"
        case .animal: return "dog"
        case .vehicles: return "truck.box"
        }
    }

    var color: Color {
        switch self {
        case .halloween: return .orange
        case .animal: return .brown
        case .vehicles: return .green
        }
    }
}
