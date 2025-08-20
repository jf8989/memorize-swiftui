//  ViewModels/MemorizeViewModel.swift

import SwiftUI

/// ViewModel for the Memorize game. Owns UI-facing state and orchestrates moves via `RulebookModel`.
final class MemorizeViewModel: ObservableObject {
    // MARK: - Theme & Cards (UI-facing)
    @Published private(set) var selectedTheme: EmojiThemeModel?
    @Published var cards: [Card] = []
    @Published var isTapEnabled: Bool = true

    // MARK: - Timer & Scoring
    @Published var timeRemaining: Int = 120
    var score: Int { rulebook.score }

    // MARK: - Session State
    var gameStartTime: Date?
    var isGameStarted: Bool = false
    var isGameOver: Bool { cards.allSatisfy { $0.isMatched } }
    var showScore: Bool = false

    // MARK: - Private
    private var rulebook = RulebookModel(cards: [])
    private var timer: Timer?

    deinit { timer?.invalidate() }

    // MARK: - Derived Theme UI

    /// Whether the theme uses a gradient (two colors) for the card back.
    var isGradient: Bool {
        selectedTheme?.colorG != nil
    }

    /// Primary theme color as `Color`.
    var themeColor: Color {
        guard let colorName = selectedTheme?.color else { return .gray }
        return colorFromString(colorName)
    }

    /// Optional theme gradient for the card back.
    var themeGradientColor: LinearGradient? {
        guard
            let color1Name = selectedTheme?.color,
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

    /// Display name for the current theme or a welcome message if no theme is selected.
    var themeName: String {
        selectedTheme?.name
            ?? "Welcome to the Memory Game!\n\nDo you have what it takes?\n\nThen let's play!"
    }

    /// Pairs to deal for the current theme, clamped to available emojis, with sensible defaults.
    var safeNumberOfPairs: Int {
        guard let theme = selectedTheme else { return 8 }
        let emojiCount = theme.emojis.count

        if let pairs = theme.numberOfPairs {
            if emojiCount == 0 { return 2 }
            return min(max(pairs, 8), emojiCount)
        }
        return max(min(emojiCount, 10), 8)
    }

    // MARK: - Intent

    /// Starts a new game session with a random theme and a valid deck (exactly two cards per chosen emoji).
    func newGame() {
        // Reset session state.
        timer?.invalidate()
        gameStartTime = Date()
        timeRemaining = 120
        rulebook.score = 0
        isTapEnabled = true
        isGameStarted = true
        startTimer()

        // Pick a theme and build the deck.
        guard let theme = EmojiThemeModel.themes.randomElement() else { return }
        selectedTheme = theme

        // Choose N emojis and duplicate each exactly once.
        let chosenEmojis = Array(
            theme.emojis.shuffled().prefix(safeNumberOfPairs)
        )
        var newCards = chosenEmojis.flatMap {
            [Card(content: $0), Card(content: $0)]
        }
        newCards.shuffle()

        // Defensive invariant (debug): every emoji must appear exactly twice.
        #if DEBUG
            var grouped = Dictionary(grouping: newCards, by: { $0.content })
                .mapValues { $0.count }
            if grouped.values.contains(where: { $0 != 2 }) {
                // Rebuild deterministically and re-check once.
                newCards = chosenEmojis.flatMap {
                    [Card(content: $0), Card(content: $0)]
                }.shuffled()
                grouped = Dictionary(grouping: newCards, by: { $0.content })
                    .mapValues { $0.count }
                assert(
                    !grouped.values.contains { $0 != 2 },
                    "Pair generation invariant failed: \(grouped)"
                )
            }
        #endif

        cards = newCards
        rulebook = RulebookModel(cards: cards)
    }

    /// Handles a user tapping a card.
    func choose(_ card: Card) {
        rulebook.choose(card: card)
        cards = rulebook.cards

        // If two unmatched cards are face up, briefly show them before flipping back down.
        if rulebook.indicesOfFaceUpUnmatchedCards != nil {
            timeRemaining -= 5
            isTapEnabled = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.rulebook.flipBackUnmatchedCards()
                self.cards = self.rulebook.cards
                if self.timeRemaining > 0 && !self.isGameOver {
                    self.isTapEnabled = true
                }
            }
        } else if rulebook.isThisAmatch {
            // Match: award points based on elapsed time.
            let elapsed = elapsedTimeSinceStart()
            let points = pointsForElapsedTime(elapsed)
            rulebook.score += points
            rulebook.reset()

            if isGameOver { endGame() }
        }
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
            if self.timeRemaining <= 0 {
                self.endGame()
            }
        }
    }

    private func endGame() {
        timer?.invalidate()
        timer = nil
        isTapEnabled = false
        timeRemaining = 0
    }

    // MARK: - Scoring Helpers

    private func elapsedTimeSinceStart() -> Int {
        let now = Date()
        return Int(now.timeIntervalSince(gameStartTime ?? now))
    }

    private func pointsForElapsedTime(_ elapsed: Int) -> Int {
        switch elapsed {
        case 0..<20: return 4
        case 20..<40: return 3
        default: return 2
        }
    }

    // MARK: - Utilities

    /// Maps a stored color name to `Color`. Fallback is `.gray`.
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
        default: return .gray
        }
    }
}
