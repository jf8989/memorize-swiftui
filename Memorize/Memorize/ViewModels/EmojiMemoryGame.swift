// ViewModels/EmojiMemoryGame
// imports both Theme and Model.   View Model

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    @Published private var model: MemoryGame<String>
    private(set) var theme: Theme
    
    init() {  // variables that start in a specific order as they're dependant on one another
        let randomTheme = themes.randomElement() ?? themes[0]
        theme = randomTheme
        model = MemoryGame<String>(cards: )
    }
    
    // Intent functions
    
    // computed properties for views
    var cards: [MemoryGame<String>.Card] {
        model.cards
    }
}
