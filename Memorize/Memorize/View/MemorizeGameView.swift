//  View/MemorizeGameView.swift

import SwiftUI

/// Game screen for a single Theme. Parent owns the VM (ObservedObject in split view).
struct MemorizeGameView: View {
    @ObservedObject var viewModel: MemorizeGameViewModel

    init(viewModel: MemorizeGameViewModel) {
        self.viewModel = viewModel
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
            .safeAreaInset(edge: .bottom) {
                NewGameButton(action: viewModel.newGame)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
            }
            .navigationTitle(viewModel.themeName)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let demo = Theme(
        name: "Demo",
        emojis: Array("😀🐶🍕⚽🏀🎧").map { String($0) },
        pairs: 3,
        rgba: .gray
    )
    return MemorizeGameView(viewModel: MemorizeGameViewModel(theme: demo))
}
