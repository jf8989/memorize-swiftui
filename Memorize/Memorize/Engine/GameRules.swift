//  Engine/GameRules.swift

import Foundation

/// Core game rules for Memorize. Pure value type; owns the authoritative card array and score.
struct GameRules {
    // MARK: - State
    private(set) var cards: [Card]
    var score: Int = 0

    // MARK: - Tap Tracking
    private var tapCount: Int = 0
    private var tappedCardIndices: [Int] = []

    // MARK: - Init
    init(cards: [Card]) {
        self.cards = cards
    }

    // MARK: - Derived

    /// If two cards are face up and not matched, returns their indices (used to time a flip-back).
    var indicesOfFaceUpUnmatchedCards: [Int]? {
        if tappedCardIndices.count == 2
            && !cards[tappedCardIndices[0]].isMatched
            && !cards[tappedCardIndices[1]].isMatched
        {
            return tappedCardIndices
        }
        return nil
    }

    var isThisAmatch: Bool = false

    // MARK: - Intent

    /// Main game logic for choosing a card.
    mutating func choose(card: Card) {
        guard
            let chosenIndex = cards.firstIndex(ofID: card.id),
            !cards[chosenIndex].isFaceUp,
            !cards[chosenIndex].isMatched
        else { return }

        cards[chosenIndex].isFaceUp = true
        tapCount += 1
        tappedCardIndices.append(chosenIndex)

        if tapCount == 2 {
            let firstIndex = tappedCardIndices[0]
            let secondIndex = tappedCardIndices[1]

            if cards[firstIndex].content == cards[secondIndex].content {
                // Match
                isThisAmatch = true
                cards[firstIndex].isMatched = true
                cards[secondIndex].isMatched = true
            } else {
                // Mismatch: penalize previously seen cards and mark both as seen.
                if cards[firstIndex].hasBeenSeen { score -= 1 }
                if cards[secondIndex].hasBeenSeen { score -= 1 }
                cards[firstIndex].hasBeenSeen = true
                cards[secondIndex].hasBeenSeen = true
            }
        }
    }

    /// Flips both currently face-up, unmatched cards back down.
    mutating func flipBackUnmatchedCards() {
        for index in tappedCardIndices where !cards[index].isMatched {
            cards[index].isFaceUp = false
        }
        reset()
    }

    /// Resets transient tap state.
    mutating func reset() {
        tappedCardIndices = []
        tapCount = 0
        isThisAmatch = false
    }
}
