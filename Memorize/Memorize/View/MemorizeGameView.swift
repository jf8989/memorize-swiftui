//  View/MemorizeGameView.swift

import SwiftUI

/// Game screen for a single Theme. Owns its VM via StateObject.
struct MemorizeGameView: View {
    @StateObject private var viewModel: MemorizeGameViewModel

    init(viewModel: MemorizeGameViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(
                isGameStarted: viewModel.isGameStarted,
                score: viewModel.score,
                timeRemaining: viewModel.timeRemaining,
                themeName: viewModel.themeName,
                themeColor: viewModel.themeColor
            )
            // Let the grid take all remaining space between header and button.
            CardsGrid(
                cards: viewModel.cards,
                themeColor: viewModel.themeColor,
                themeGradient: viewModel.themeGradientColor,
                isTapEnabled: viewModel.isTapEnabled,
                onTap: { viewModel.choose($0) }
            )
            .frame(maxHeight: .infinity)

            NewGameButton(action: viewModel.newGame)
                .padding(.horizontal)
                .padding(.vertical, 12)
        }
        .padding(.horizontal)
        .navigationTitle(viewModel.themeName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let demo = Theme(
        name: "Demo",
        emojis: Array("😀🐶🍕⚽🏀🎧🎮🧩🚗🚀").map { String($0) },
        pairs: 10,
        rgba: .gray
    )
    return MemorizeGameView(viewModel: MemorizeGameViewModel(theme: demo))
}
