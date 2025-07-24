// ViewModels/MemorizeViewModel.swift
// We use @Published so the View will update automatically on change.
// We use private(set) for selectedTheme so the View can read it but only the VM can change it.
// The View should never mutate state directly; it just asks the ViewModel to act.
import SwiftUI

class MemorizeViewModel: ObservableObject {
    // The list of shuffled emojis; whenever this changes, the View will update.
    @Published var shuffledEmojis: [String] = []
    // The selected theme; internal to the VM so the View can't change it directly.
//    private(set) var selectedTheme: EmojiTheme? = nil

    // Expose the theme's color for use in the View. Default to clear if none picked.
//    var themeColor: Color {
//        selectedTheme?.color ?? .clear
//    }

    // Called by the View when the user taps a theme button.
//    func selectTheme(_ theme: EmojiTheme) {
//        selectedTheme = theme
//        // Shuffle a pair of all emojis to fill the grid.
//        shuffledEmojis = (theme.emojis + theme.emojis).shuffled()
//    }
}
