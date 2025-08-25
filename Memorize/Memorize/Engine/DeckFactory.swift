//  Engine/DeckFactory.swift

import Foundation

/// Builds card decks for the Memorize game.
enum DeckFactory {
    /// Creates a shuffled deck where each emoji appears exactly twice.
    static func makeDeck(from emojis: [String]) -> [Card] {
        var deck = emojis.flatMap { [Card(content: $0), Card(content: $0)] }
        deck.shuffle()
        assert(deck.hasValidPairs, "DeckFactory produced an invalid deck")
        return deck
    }
}
