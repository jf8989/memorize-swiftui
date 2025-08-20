//  ViewModel/MemorizeGameViewModel.swift

import SwiftUI

/// ViewModel for the Memorize game. Owns UI-facing state and orchestrates moves via `GameRules`.
@MainActor
final class MemorizeGameViewModel: ObservableObject {

    // MARK: - Theme & Cards (UI-facing)
    @Published private(set) var selectedTheme: Theme?
    @Published var cards: [Card] = []
    @Published var isTapEnabled: Bool = true

    // MARK: - Timer & Scoring
    @Published var timeRemaining: Int = 120
    /// Published mirror of rules.score so the UI updates even if `cards` does not change.
    @Published private(set) var score: Int = 0

    // MARK: - Session State
    @Published var isGameStarted: Bool = false
    @Published var showScore: Bool = false

    // MARK: - Private
    private var gameRules = GameRules(cards: [])
    private var timer: Timer?
    private var gameStartTime: Date?
    private var gradientRGBAs: (RGBA, RGBA)?
    /// UI-only: optional gradient for card backs

    deinit { timer?.invalidate() }

    // MARK: - Derived Theme UI

    var isGradient: Bool { gradientRGBAs != nil }

    /// Primary theme color.
    var themeColor: Color {
        Color(rgba: selectedTheme?.rgba ?? .gray)
    }

    /// Optional theme gradient for the card back.
    var themeGradientColor: LinearGradient? {
        guard let pair = gradientRGBAs else { return nil }
        return LinearGradient(
            colors: [Color(rgba: pair.0), Color(rgba: pair.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Display name for the current theme or a welcome message if no theme is selected.
    var themeName: String {
        selectedTheme?.name
            ?? "Welcome to the Memory Game!\n\nDo you have what it takes?\n\nThen let's play!"
    }

    // MARK: - Intent

    /// Starts a new game session with a random theme and a valid deck (each emoji appears exactly twice).
    func newGame() {
        // Reset session state.
        timer?.invalidate()
        gameStartTime = Date()
        timeRemaining = 120
        isTapEnabled = true
        isGameStarted = true

        // Pick a legacy theme and adapt to the new Theme model.
        guard let legacy = EmojiThemeModel.themes.randomElement() else {
            return
        }
        let adapted = ThemeAdapter.adapt(from: legacy)
        selectedTheme = adapted.theme
        gradientRGBAs = adapted.gradient

        // Choose N emojis (N is already clamped in Theme).
        guard let current = selectedTheme else { return }
        let chosen = Array(current.emojis.shuffled().prefix(current.pairs))
        let newCards = DeckFactory.makeDeck(from: chosen)

        // Reset rules and publish state.
        gameRules = GameRules(cards: newCards)
        gameRules.score = 0
        syncFromRules()

        startTimer()
    }

    /// Handles a user tapping a card.
    func choose(_ card: Card) {
        gameRules.choose(card: card)
        syncFromRules()

        // If two unmatched cards are face up, briefly show them before flipping back down.
        if gameRules.indicesOfFaceUpUnmatchedCards != nil {
            timeRemaining = timeRemaining - 5
            isTapEnabled = false

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                self.gameRules.flipBackUnmatchedCards()
                self.syncFromRules()
                if self.timeRemaining > 0 && !self.isGameOver {
                    self.isTapEnabled = true
                }
            }
        } else if gameRules.isThisAmatch {
            // Match: award points based on elapsed time.
            let elapsed = elapsedTimeSinceStart()
            let points = pointsForElapsedTime(elapsed)
            gameRules.score = gameRules.score + points
            gameRules.reset()
            syncFromRules()

            if isGameOver { endGame() }
        }
    }

    // MARK: - Timer

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                guard self.timeRemaining > 0 else {
                    self.endGame()
                    return
                }
                self.timeRemaining = self.timeRemaining - 1
            }
        }
        timer?.tolerance = 0.1
    }

    private func endGame() {
        timer?.invalidate()
        timer = nil
        isTapEnabled = false
        timeRemaining = 0
        isGameStarted = false
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

    // MARK: - Sync

    /// Keeps `@Published` view state (`cards`, `score`) in sync with the engine (`gameRules`).
    private func syncFromRules() {
        cards = gameRules.cards
        score = gameRules.score
    }

    // MARK: - Derived Flags

    private var isGameOver: Bool {
        cards.allSatisfy { $0.isMatched }
    }
}
