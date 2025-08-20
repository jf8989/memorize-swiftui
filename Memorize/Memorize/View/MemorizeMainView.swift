//  View/MemorizeMainView.swift

import SwiftUI

/// Root view for the Memorize game.
struct MemorizeMainView: View {
    // MARK: - State
    @StateObject private var viewModel = MemorizeGameViewModel()

    // MARK: - Body
    var body: some View {
        VStack {
            HeaderView(
                isGameStarted: viewModel.isGameStarted,
                score: viewModel.score,
                timeRemaining: viewModel.timeRemaining,
                themeName: viewModel.themeName,
                themeColor: viewModel.themeColor
            )
            Spacer(minLength: 0)
            CardsGrid(
                cards: viewModel.cards,
                themeColor: viewModel.themeColor,
                themeGradient: viewModel.themeGradientColor,
                isTapEnabled: viewModel.isTapEnabled,
                onTap: { viewModel.choose($0) }
            )
            Spacer(minLength: 0)
            NewGameButton(action: viewModel.newGame)
                .padding(.bottom)
        }
        .padding()
    }
}

#Preview {
    MemorizeMainView()
}
