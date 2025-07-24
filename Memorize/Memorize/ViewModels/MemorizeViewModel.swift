// ViewModels/MemorizeViewModel.swift
// We use @Published so the View will update automatically on change.
// We use private(set) for selectedTheme so the View can read it but only the VM can change it.
// The View should never mutate state directly; it just asks the ViewModel to act.
import SwiftUI

class MemorizeViewModel: ObservableObject {
    // This is my theme in use
    @Published private(set) var selectedTheme: EmojiThemeModel?

    // The list of shuffled emojis; whenever this changes, the View will update.
    @Published var shuffledEmojis: [String] = []

    // We'll let the View see the array of cards it needs to display.  In other words, this is the "deck" of cards.
    @Published private(set) var cards: [Card] = []

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
        default:
            return .gray
        }
    }

    // We also need to return the theme's name
    var themeName: String {
        selectedTheme?.name ?? "Welcome to the Memory Game!\n\nDo you have what it takes?\n\nThen let's play!"
    }

    // *** FUNCTIONS ***
    // These is a reference to my themes array.  I'm declaring "themes" with the same name as my array just for the sake of clarity while working.
    func newGame() {
        print("newGame() called")
        guard let theme = EmojiThemeModel.themes.randomElement() else { return }  // 1. Picks a random theme
        selectedTheme = theme  // assigns the theme to a variable
        let chosenEmojis = theme.emojis.shuffled().prefix(theme.numberOfPairs)  // 2. Grabs the emojis propery from the selected theme, shuffles them, and fetches them based on the number of pairs for that theme.  Every single emoji gets the same chance to show up.
        var newCards: [Card] = []
        for emoji in chosenEmojis {
            newCards.append(Card(content: emoji))
            newCards.append(Card(content: emoji))
        }
        cards = newCards.shuffled()
        print("\(theme.name)")
    }

}
