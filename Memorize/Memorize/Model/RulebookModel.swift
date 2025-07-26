//  Model/RulebookModel.swift

import Foundation

struct RulebookModel {
    private(set) var cards: [Card]
    var score: Int = 0

    // Tap tracking
    private var tapCount: Int = 0
    private var tappedCardIndices: [Int] = []

    // it takes the array it just got from the ViewModel and saves it to its own "cards" property.
    // Now it can reference the active array when looking for a specific card in the future.
    init(cards: [Card]) {
        self.cards = cards
    }

    // keeps track of the 2 cards that need to be flipped down because they're not pairs
    var indicesOfFaceUpUnmatchedCards: [Int]? {
        // we must make sure there's 2 indices and they're NOT matched
        if tappedCardIndices.count == 2
            && !cards[tappedCardIndices[0]].isMatched
            && !cards[tappedCardIndices[1]].isMatched
        {
            return tappedCardIndices  // so, we return this or use it ONLY when the conditions are met, so it doesn't matter if we call it by accident
        }
        return nil
    }
    
    var isThisAmatch: Bool = false

    // The main game logic
    mutating func choose(card: Card) {
        guard let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),  // returns the index of the card the user tapped after looking for its ID within the cards array
            !cards[chosenIndex].isFaceUp,  // checking if the cards are both faced down and not matched.
            !cards[chosenIndex].isMatched
        else {
            return  // otherwise, exit
        }  // If we pass the guard, we proceed with the next logic.

        // If card exists within the array, flip it up and store its index
        cards[chosenIndex].isFaceUp = true  // flip it up
        tapCount += 1  // increase count
        tappedCardIndices.append(chosenIndex)  // store the card's ID temporarily for later comparison

        // We first check if tapCount is 2.  If so, compare, match/mismatch
        if tapCount == 2 {
            let firstIndex = tappedCardIndices[0]  // store the first card's ID
            let secondIndex = tappedCardIndices[1]  // store the second card's ID

            // It's a match:
            if cards[firstIndex].content == cards[secondIndex].content {  // if both IDs match:
                // MATCH: toggle their respective property within the array.
                isThisAmatch = true
                cards[firstIndex].isMatched = true
                cards[secondIndex].isMatched = true
            } else {
                // MISMATCH
                // Score -1 for each card previously seen.  Tags both cards as been seen before, and for each missmatch in this case, the user gets -1 score.
                if cards[firstIndex].hasBeenSeen { score -= 2 }  // checks if this is the first time they've been seen.  If not, -1 points for the user.
                if cards[secondIndex].hasBeenSeen { score -= 2 }
                // Mark both as seen
                cards[firstIndex].hasBeenSeen = true  // both cards need to get marked as seen before
                cards[secondIndex].hasBeenSeen = true
            }
        }
    }
    
    // Flips both UNMATCHEDe cards back down separately from everything else
    mutating func flipBackUnmatchedCards() {
        for idx in tappedCardIndices {
            if !cards[idx].isMatched {
                cards[idx].isFaceUp = false
            }
        }
        reset()
    }
    
    mutating func reset() {
        tappedCardIndices = []
        tapCount = 0
        isThisAmatch = false
    }
}
