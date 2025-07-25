// Model/ThemeModel.swift

import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let content: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
    var hasBeenSeen: Bool = false
}

struct EmojiThemeModel: Identifiable {  // main struct for the theme and its properties
    let id = UUID()
    let name: String
    let emojis: [String]
    let numberOfPairs: Int?
    let color: String
    
    // Main emoji array for the themes, extending its properties using the struct
    static let themes: [EmojiThemeModel] = [
        EmojiThemeModel(
            name: "Halloween",
            emojis: halloweenEmojis,
            numberOfPairs: 10,
            color: "orange"
        ),
        EmojiThemeModel(
            name: "Animals",
            emojis: animalEmojis,
            numberOfPairs: nil,
            color: "gray"
        ),
        EmojiThemeModel(
            name: "Vehicles",
            emojis: vehicleEmojis,
            numberOfPairs: 9,
            color: "green"
        ),
        EmojiThemeModel(
            name: "Space",
            emojis: spaceEmojis,
            numberOfPairs: nil,
            color: "black"
        ),
        EmojiThemeModel(
            name: "Christmas",
            emojis: christmasEmojis,
            numberOfPairs: 7,
            color: "red"
        ),
        EmojiThemeModel(
            name: "Technology",
            emojis: techEmojis,
            numberOfPairs: nil,
            color: "purple"
        ),
        EmojiThemeModel(
            name: "Music",
            emojis: musicEmojis,
            numberOfPairs: 10,
            color: "yellow"
        ),
        EmojiThemeModel(
            name: "Emotions",
            emojis: emotionEmojis,
            numberOfPairs: nil,
            color: "pink"
        ),
        EmojiThemeModel(
            name: "Food",
            emojis: foodEmojis,
            numberOfPairs: 10,
            color: "brown"
        ),
        EmojiThemeModel(
            name: "Fantasy",
            emojis: fantasyEmojis,
            numberOfPairs: nil,
            color: "teal"
        ),
        EmojiThemeModel(
            name: "Sports",
            emojis: sportsEmojis,
            numberOfPairs: 10,
            color: "blue"
        ),
        EmojiThemeModel(
            name: "Nature",
            emojis: natureEmojis,
            numberOfPairs: nil,
            color: "cyan"
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

// 🎶 Music theme
let musicEmojis = [
    "🎵", "🎶", "🎸", "🥁", "🎷", "🎺", "🎹", "🎧", "🎤", "📻", "🪕", "🪘",
]

// 😊 Emotions theme
let emotionEmojis = [
    "😀", "😂", "😅", "😍", "😭", "😡", "😱", "🥰", "🤔", "😴", "🥺", "🤯", "😎",
]

// 🍕 Food theme
let foodEmojis = [
    "🍕", "🍔", "🍟", "🌭", "🍿", "🥓", "🥞", "🍣", "🍩", "🍪", "🍉", "🍇", "🍓", "🍜",
]

// ⚔️ Fantasy theme
let fantasyEmojis = [
    "🧙‍♂️", "🧝‍♀️", "🧚‍♂️", "🧛‍♀️", "🐉", "🦄", "🗡️", "⚔️", "🛡️", "📜", "🔮", "🏰", "🪄",
]

// ⚽ Sports theme
let sportsEmojis = [
    "⚽", "🏀", "🏈", "⚾", "🎾", "🏐", "🏉", "🥏", "🥊", "🥋", "⛳", "🏓", "🏸",
]

// 🌤️ Weather/Nature theme
let natureEmojis = [
    "☀️", "🌤️", "🌧️", "⛈️", "🌩️", "🌪️", "🌈", "❄️", "🌊", "🍃", "🌸", "🌻", "🌳",
]
