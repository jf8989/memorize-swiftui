// Model/ThemeModel.swift

import SwiftUI

struct EmojiThemeModel: Identifiable {  // main struct for the theme and its properties
    let id = UUID()
    let name: String
    let emojis: [String]
    let numberOfPairs: Int
    let color: String

    // Main emoji array for the themes, extending its properties using the struct
    static let themes: [EmojiThemeModel] = [
        EmojiThemeModel(
            name: "Halloween",
            emojis: halloweenEmojis,
            numberOfPairs: 14,
            color: "orange"
        ),
        EmojiThemeModel(
            name: "Animals",
            emojis: animalEmojis,
            numberOfPairs: 13,
            color: "yellow"
        ),
        EmojiThemeModel(
            name: "Vehicles",
            emojis: vehicleEmojis,
            numberOfPairs: 12,
            color: "green"
        ),
        EmojiThemeModel(
            name: "Space",
            emojis: spaceEmojis,
            numberOfPairs: 11,
            color: "black"
        ),
        EmojiThemeModel(
            name: "Christmas",
            emojis: christmasEmojis,
            numberOfPairs: 10,
            color: "red"
        ),
        EmojiThemeModel(
            name: "Technology",
            emojis: techEmojis,
            numberOfPairs: 9,
            color: "purple"
        ),
    ]
}

// Arrays of emojis to be used
let halloweenEmojis = [
    "👻", "🎃", "🕷️", "💀", "🧟‍♂️", "🦇", "🧙‍♀️", "🍬", "🍭", "🪦", "🧛‍♂️", "🧞‍♂️", "☠️", "🧹", "🕸️",
]
let animalEmojis = [
    "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🦁", "🐸", "🐵", "🦄", "🦉",
]
let vehicleEmojis = [
    "🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "🚚", "🚜", "🛻", "🚲",
]
let spaceEmojis = [
    "🚀", "🪐", "🌑", "🛸", "👽", "🌟", "☄️", "🛰️", "🌌", "🔭", "🌠", "🛕",
]
let christmasEmojis = [
    "🎄", "🎅", "🤶", "🦌", "⛄", "❄️", "🛷", "🎁", "🕯️", "🔔", "🌟",
]
let techEmojis = [
    "💻", "🖥️", "🖨️", "🕹️", "🧑‍💻", "📱", "📡", "🛰️", "⌨️", "💾",
]
