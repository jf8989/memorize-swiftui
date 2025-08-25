//  Model/Theme.swift

import Foundation

/// App Theme — UI-free and Codable.
struct Theme: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var emojis: [String]
    var pairs: Int
    /// clamped to 2...emojis.count
    var rgba: RGBA
    var rgbaG: RGBA?

    /// Designated initializer clamps pairs to valid range and uniques emojis.
    init(
        id: UUID = UUID(),
        name: String,
        emojis: [String],
        pairs: Int,
        rgba: RGBA,
        rgbaG: RGBA? = nil
    ) {
        let unique = Array(NSOrderedSet(array: emojis)).compactMap {
            $0 as? String
        }
        let maxPairs = max(2, unique.count)
        let clampedPairs = min(max(pairs, 2), maxPairs)
        self.id = id
        self.name = name
        self.emojis = unique
        self.pairs = clampedPairs
        self.rgba = rgba
        self.rgbaG = rgbaG
    }
}
