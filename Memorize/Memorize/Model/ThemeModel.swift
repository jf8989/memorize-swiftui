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
    let colorG: String?
    
    // Main emoji array for the themes, extending its properties using the struct
    static let themes: [EmojiThemeModel] = [
        EmojiThemeModel(
            name: "Halloween",
            emojis: halloweenEmojis,
            numberOfPairs: 0,
            color: "orange",
            colorG: "purple"
        ),
        EmojiThemeModel(
            name: "Animals",
            emojis: animalEmojis,
            numberOfPairs: nil,
            color: "gray",
            colorG: "green"
        ),
        EmojiThemeModel(
            name: "Vehicles",
            emojis: vehicleEmojis,
            numberOfPairs: 9,
            color: "green",
            colorG: nil
        ),
        EmojiThemeModel(
            name: "Space",
            emojis: spaceEmojis,
            numberOfPairs: nil,
            color: "black",
            colorG: "blue"
        ),
        EmojiThemeModel(
            name: "Christmas",
            emojis: christmasEmojis,
            numberOfPairs: 2,
            color: "red",
            colorG: "green"
        ),
        EmojiThemeModel(
            name: "Technology",
            emojis: techEmojis,
            numberOfPairs: nil,
            color: "purple",
            colorG: "blue"
        ),
        EmojiThemeModel(
            name: "Music",
            emojis: musicEmojis,
            numberOfPairs: 20,
            color: "yellow",
            colorG: "purple"
        ),
        EmojiThemeModel(
            name: "Emotions",
            emojis: emotionEmojis,
            numberOfPairs: nil,
            color: "pink",
            colorG: "yellow"
        ),
        EmojiThemeModel(
            name: "Food",
            emojis: foodEmojis,
            numberOfPairs: 20,
            color: "brown",
            colorG: "orange"
        ),
        EmojiThemeModel(
            name: "Fantasy",
            emojis: fantasyEmojis,
            numberOfPairs: nil,
            color: "teal",
            colorG: "purple"
        ),
        EmojiThemeModel(
            name: "Sports",
            emojis: sportsEmojis,
            numberOfPairs: 10,
            color: "blue",
            colorG: "green"
        ),
        EmojiThemeModel(
            name: "Nature",
            emojis: natureEmojis,
            numberOfPairs: nil,
            color: "cyan",
            colorG: "green"
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
