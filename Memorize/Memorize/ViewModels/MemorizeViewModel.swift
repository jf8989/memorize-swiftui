// ViewModels/MemorizeViewModel.swift
// We use @Published so the View will update automatically on change.
// We use private(set) for selectedTheme so the View can read it but only the VM can change it.
// The View should never mutate state directly; it just asks the ViewModel to act.
import SwiftUI

class MemorizeViewModel: ObservableObject {
    // This is my theme in use
    @Published private(set) var selectedTheme: EmojiThemeModel?

    // We'll let the View see the array of cards it needs to display.  In other words, this is the "deck" of cards.
    @Published var cards: [Card] = []
    
    @Published var isTapEnabled: Bool = true

    private var rulebook = RulebookModel(
        cards: []
    )  // reference to the Rulebook struct in the model

    // We need to tell the View what color to use in Color type.
    var themeColor: Color {
        guard let colorName = selectedTheme?.color else { return .gray }
        switch colorName {
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "black": return .black
        case "red": return .red
        case "purple": return .purple
        case "gray": return .gray
        case "pink": return .pink
        case "brown": return .brown
        case "teal": return .teal
        case "blue": return .blue
        case "cyan": return .cyan
        default:
            return .gray
        }
    }

    // We also need to return the theme's name
    var themeName: String {
        selectedTheme?.name
            ?? "Welcome to the Memory Game!\n\nDo you have what it takes?\n\nThen let's play!"
    }
    
    var score: Int {
        rulebook.score
    }

    // *** FUNCTIONS ***
    // These is a reference to my themes array.  I'm declaring "themes" with the same name as my array just for the sake of clarity while working.
    func newGame() {
        guard let theme = EmojiThemeModel.themes.randomElement() else { return }  // 1. Picks a random theme
        selectedTheme = theme  // assigns the theme to a variable
        let chosenEmojis = theme.emojis.shuffled().prefix(theme.numberOfPairs)  // 2. Grabs the emojis propery from the selected theme, shuffles them, and fetches them based on the number of pairs for that theme.  Every single emoji gets the same chance to show up.
        var newCards: [Card] = []  // we create the array that will hold the newly formed array of cards that will get rendered b y the view
        for emoji in chosenEmojis {  // for every emoji, we'll create a duplicate so that we get pairs
            newCards.append(Card(content: emoji))  // E1 is created with the right emoji, and appended to newCards array
            newCards.append(Card(content: emoji))  // E1's clone, same process
        }
        cards = newCards.shuffled()  // our array gets shuffled and stored into the main cards array, which has been waiting for it all along
        rulebook = RulebookModel(cards: cards)  // creating an instance of RulebookModel with its own copy of the Card array, its latest version.
    }

    func choose(_ card: Card) {
        rulebook.choose(card: card)  // passing the intent to the rulebook model
        cards = rulebook.cards  // we assign the modified array to the ViewModel's version to trigger the view change immediately
        
        // we need to check if the two face up cards are unmatched so we can add a slight delay before we flip them down
        if rulebook.indicesOfFaceUpUnmatchedCards != nil {  // if this returns anything other than nill, it moves on
            // block any taps for now
            isTapEnabled = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.rulebook.flipBackUnmatchedCards()  // to flip both cards down after the delay
                self.cards = self.rulebook.cards // to refresh the UI
                self.isTapEnabled = true
            }
        }
    }
}
