//  Model/EmojiThemeModel.swift

import SwiftUI

/// A theme definition for the pre-A6 version of the app (static built-ins).
struct EmojiThemeModel: Identifiable {
    let id = UUID()
    let name: String
    let emojis: [String]
    let numberOfPairs: Int?
    let color: String
    let colorG: String?

    /// Built-in themes used by the current implementation.
    static let themes: [EmojiThemeModel] = [
        // Existing
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

        // New (at least 10 more)
        EmojiThemeModel(
            name: "Sea Life",
            emojis: seaEmojis,
            numberOfPairs: nil,
            color: "teal",
            colorG: "blue"
        ),
        EmojiThemeModel(
            name: "Birds",
            emojis: birdEmojis,
            numberOfPairs: nil,
            color: "cyan",
            colorG: "pink"
        ),
        EmojiThemeModel(
            name: "Reptiles",
            emojis: reptileEmojis,
            numberOfPairs: nil,
            color: "green",
            colorG: "gray"
        ),
        EmojiThemeModel(
            name: "Fruits",
            emojis: fruitEmojis,
            numberOfPairs: 12,
            color: "pink",
            colorG: "red"
        ),
        EmojiThemeModel(
            name: "Vegetables",
            emojis: vegetableEmojis,
            numberOfPairs: 10,
            color: "green",
            colorG: "yellow"
        ),
        EmojiThemeModel(
            name: "Beverages",
            emojis: beverageEmojis,
            numberOfPairs: nil,
            color: "brown",
            colorG: "cyan"
        ),
        EmojiThemeModel(
            name: "Tools",
            emojis: toolEmojis,
            numberOfPairs: nil,
            color: "gray",
            colorG: "orange"
        ),
        EmojiThemeModel(
            name: "Household",
            emojis: householdEmojis,
            numberOfPairs: nil,
            color: "purple",
            colorG: "teal"
        ),
        EmojiThemeModel(
            name: "Office",
            emojis: officeEmojis,
            numberOfPairs: nil,
            color: "blue",
            colorG: "yellow"
        ),
        EmojiThemeModel(
            name: "Clothing",
            emojis: clothingEmojis,
            numberOfPairs: nil,
            color: "pink",
            colorG: "purple"
        ),
        EmojiThemeModel(
            name: "Desserts",
            emojis: dessertEmojis,
            numberOfPairs: 9,
            color: "orange",
            colorG: "yellow"
        ),
        EmojiThemeModel(
            name: "Travel",
            emojis: travelEmojis,
            numberOfPairs: nil,
            color: "cyan",
            colorG: "blue"
        ),
        EmojiThemeModel(
            name: "Plants",
            emojis: plantEmojis,
            numberOfPairs: nil,
            color: "green",
            colorG: "teal"
        ),
        EmojiThemeModel(
            name: "Science",
            emojis: scienceEmojis,
            numberOfPairs: nil,
            color: "purple",
            colorG: "blue"
        ),
    ]
}
