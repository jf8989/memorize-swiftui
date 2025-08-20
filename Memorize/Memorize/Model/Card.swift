//  Model/Card.swift

import Foundation

/// Identifiable card model used by the game.
struct Card: Identifiable {
    let id = UUID()
    let content: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
    var hasBeenSeen: Bool = false
}
