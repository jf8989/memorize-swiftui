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
        selectedTheme?.name ?? "Please, select your theme!"
    }

    // *** FUNCTIONS ***
    // These is a reference to my themes array.  I'm declaring "themes" with the same name as my array just for the sake of clarity while working.
    func newGame() {
        guard let theme = EmojiThemeModel.themes.randomElement() else { return }  // picks a random theme
        selectedTheme = theme  // assigns the theme to a variable
        let chosenEmojis = theme.emojis.shuffled().prefix(theme.numberOfPairs)  // grab the emojis propery from the selected theme, shuffles them, and fetches them based on the number of pairs for that theme.  Every single emoji gets the same chance to show up.
        shuffledEmojis = (chosenEmojis + chosenEmojis).shuffled()  // we create the pairs based on the ready-to-go emoji set
    }

}
