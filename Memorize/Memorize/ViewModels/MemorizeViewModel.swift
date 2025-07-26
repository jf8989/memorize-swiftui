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

    var safeNumberOfPairs: Int {
        guard let theme = selectedTheme else { return 8 }

        let emojiCount = theme.emojis.count

        if let pairs = theme.numberOfPairs {
            if pairs <= emojiCount && pairs > 4 {
                return pairs
            } else if pairs <= 4 {
                return 8
            } else if pairs > emojiCount {
                return 9
            } else {
                return 7
            }
        } else {
            let minPairs = min(6, 9)
            let maxPairs = 10
            if minPairs > maxPairs { return maxPairs }
            return Int.random(in: minPairs...maxPairs)
        }
    }

    var isGradient: Bool {  // First, let's check if we've been given a value for a gradient.
        selectedTheme?.colorG != nil
    }

    // We need to tell the View what color to use in Color type.
    var themeColor: Color {
        guard let colorName = selectedTheme?.color else { return .gray }
        return colorFromString(colorName)
    }

    var themeGradientColor: LinearGradient? {
        guard let color1Name = selectedTheme?.color,
            let color2Name = selectedTheme?.colorG
        else { return nil }
        let color1 = colorFromString(color1Name)
        let color2 = colorFromString(color2Name)

        return LinearGradient(
            colors: [color1, color2],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // We also need to return the theme's name
    var themeName: String {
        selectedTheme?.name
            ?? "Welcome to the Memory Game!\n\nDo you have what it takes?\n\nThen let's play!"
    }

    var score: Int {
        rulebook.score
    }

    @Published var timeRemaining: Int = 120

    private var timer: Timer?

    var gameStartTime: Date?

    var isGameOver: Bool {
        cards.allSatisfy { $0.isMatched }
    }

    // *** FUNCTIONS ***

    // * Model-related *

    // These is a reference to my themes array.  I'm declaring "themes" with the same name as my array just for the sake of clarity while working.
    func newGame() {
        timer?.invalidate()  // reset any leftover timer just in case
        gameStartTime = Date()
        timeRemaining = 120  // set the time remaining for the game
        rulebook.score = 0
        isTapEnabled = true

        // kickstart the timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.invalidate()
                self.timer = nil
                self.isTapEnabled = false  // freeze the game when the time is over
            }
        }

        guard let theme = EmojiThemeModel.themes.randomElement() else { return }  // 1. Picks a random theme
        selectedTheme = theme  // assigns the theme to a variable
        let chosenEmojis = theme.emojis.shuffled().prefix(safeNumberOfPairs)  // 2. Grabs the emojis propery from the selected theme, shuffles them, and fetches them based on the number of pairs for that theme.  Every single emoji gets the same chance to show up.
        var newCards: [Card] = []  // we create the array that will hold the newly formed array of cards that will get rendered b y the view
        for emoji in chosenEmojis {  // for every emoji, we'll create a duplicate so that we get pairs
            newCards.append(Card(content: emoji))  // E1 is created with the right emoji, and appended to newCards array
            newCards.append(Card(content: emoji))  // E1's clone, same process
        }
        cards = newCards.shuffled()  // our array gets shuffled and stored into the main cards array, which has been waiting for it all along
        rulebook = RulebookModel(cards: cards)  // creating an instance of RulebookModel with its own copy of the Card array, its latest version
    }

    func choose(_ card: Card) {
        rulebook.choose(card: card)  // passing the intent to the rulebook model
        cards = rulebook.cards  // we assign the modified array to the ViewModel's version to trigger the view change immediately

        // we need to check if the two face up cards are unmatched so we can add a slight delay before we flip them down
        if rulebook.indicesOfFaceUpUnmatchedCards != nil {  // if this returns anything other than nill, it moves on
            timeRemaining -= 3
            isTapEnabled = false  // block any taps for now

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.rulebook.flipBackUnmatchedCards()  // to flip both cards down after the delay
                self.cards = self.rulebook.cards  // to refresh the UI
                self.isTapEnabled = true
            }
        } else if rulebook.isThisAmatch {
            // It's a match, award bonus time and points
            let elapsed = elapsedTimeSinceStart()  // calculate how long it's been so far since the game started
            let points = pointsForElapsedTime(elapsed)  // calculate how many points we need to award for this match (time dependent)
            rulebook.score += points  // award those points to the player's score
            timeRemaining += 4  // bonus time
            rulebook.reset()
            
            if isGameOver {
                endGame()
            }
        }
    }

    // * Utility *

    // Helper that tranforms my strings to color
    func colorFromString(_ name: String) -> Color {
        switch name {
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

    func endGame() {
        timer?.invalidate()
        timer = nil
        isTapEnabled = false
    }

    func elapsedTimeSinceStart() -> Int {
        let now = Date()
        return Int(now.timeIntervalSince(gameStartTime ?? now))
    }

    // determine how many points will be given depending on the elapsed time
    func pointsForElapsedTime(_ elapsed: Int) -> Int {
        switch elapsed {
        case 0..<20: return 12
        case 20..<40: return 10
        case 40..<60: return 8
        case 60..<80: return 5
        default: return 3
        }
    }
}
