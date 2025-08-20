//  ViewModel/MemorizeGameViewModel.swift

import SwiftUI

/// ViewModel for the Memorize game. Owns UI-facing state and orchestrates moves via `GameRules`.
@MainActor
final class MemorizeGameViewModel: ObservableObject {

    // MARK: - Theme (fixed for session)
    let theme: Theme

    // MARK: - Cards & UI State
    @Published var cards: [Card] = []
    @Published var isTapEnabled: Bool = true

    // MARK: - Timer & Scoring
    @Published var timeRemaining: Int = 120
    @Published private(set) var score: Int = 0

    // MARK: - Session State
    @Published var isGameStarted: Bool = false
    @Published var showScore: Bool = false

    // MARK: - Private
    private var gameRules = GameRules(cards: [])
    private var timer: Timer?
    private var gameStartTime: Date?

    // MARK: - Init
    init(theme: Theme) {
        self.theme = theme
        newGame()  // start immediately with provided theme
    }

    deinit { timer?.invalidate() }

    // MARK: - Derived Theme UI

    var themeName: String { theme.name }
    var themeColor: Color { Color(rgba: theme.rgba) }
    var themeGradientColor: LinearGradient? { nil }  // gradients not in persisted model

    // MARK: - Intent

    /// Starts/restarts a game using this instance's theme (no random selection).
    func newGame() {
        timer?.invalidate()
        gameStartTime = Date()
        timeRemaining = 120
        isTapEnabled = true
        isGameStarted = true

        // Build deck from theme (pairs clamped by editor; still guard for safety).
        let pairs = max(2, min(theme.pairs, theme.emojis.count))
        let chosen = Array(theme.emojis.shuffled().prefix(pairs))
        let newCards = DeckFactory.makeDeck(from: chosen)

        gameRules = GameRules(cards: newCards)
        gameRules.score = 0
        syncFromRules()

        startTimer()
    }

    /// Handles a user tapping a card.
    func choose(_ card: Card) {
        gameRules.choose(card: card)
        syncFromRules()

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

    private func syncFromRules() {
        cards = gameRules.cards
        score = gameRules.score
    }

    // MARK: - Derived Flags

    private var isGameOver: Bool {
        cards.allSatisfy { $0.isMatched }
    }
}
