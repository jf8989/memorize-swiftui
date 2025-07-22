// each theme is a single data object

import Foundation

struct Theme {
    let name: String
    let emojis: [String]
    let numberOfPairs: Int
    let color: String
}

let themes: [Theme] = [
    Theme(
        name: "Christmas",
        emojis: [
            "🎄", "🎅", "🤶", "❄️", "⛄", "🎁", "🦌", "🔔", "🌟", "🕯️", "🍪", "🥛", "🧦",
            "🛷",
        ],
        numberOfPairs: 12,
        color: "green"
    ),  // 14 emojis, 12 pairs

    Theme(
        name: "Space",
        emojis: ["🛸", "🚀", "🤖", "🧔‍♂️", "🧙‍♂️", "⚔️", "👽", "🌌", "🛰️", "🔫"],
        numberOfPairs: 8,
        color: "black"
    ),  // 10 emojis, 8 pairs

    Theme(
        name: "Emotions",
        emojis: ["😀", "😂", "😢", "😡", "🥰", "😱", "😴", "🤔", "🤢"],
        numberOfPairs: 6,
        color: "yellow"
    ),  // 9 emojis, 6 pairs

    Theme(
        name: "Anime",
        emojis: ["🧑‍🎤", "💥", "🌸", "🌀", "⚔️", "👺", "👘", "😈", "🧞", "🧝", "🎌"],
        numberOfPairs: 8,
        color: "pink"
    ),  // 11 emojis, 8 pairs

    Theme(
        name: "Technology",
        emojis: [
            "💻", "🖥️", "📱", "📡", "🧠", "🕹️", "🔌", "🔋", "💾", "📀", "🧬", "🤖", "🔧",
        ],
        numberOfPairs: 10,
        color: "gray"
    ),  // 13 emojis, 10 pairs

    Theme(
        name: "Music",
        emojis: ["🎹", "🎸", "🥁", "🎻", "🎤", "🎧", "📯", "🎼", "🎷", "🪗"],
        numberOfPairs: 9,
        color: "indigo"
    ),  // 10 emojis, 9 pairs
]
