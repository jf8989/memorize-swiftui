//  Model/RulebookModel.swift

struct RulebookModel {
    // main state
    private(set) var cards: [Card] = []
    private(set) var score: Int = 0
    
    mutating func choose(card: Card) {
        guard let chosenIndex = cards.firstIndex(where: { $0.id == card.id}),
              !cards[chosenIndex].isFaceUp,
              !cards[chosenIndex].isMatched else {
            return
        }
    }
}
