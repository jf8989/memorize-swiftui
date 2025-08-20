//  View/MemorizeGameView.swift

import SwiftUI

/// Game screen for a single Theme. Owns its VM via StateObject.
struct MemorizeGameView: View {
    @StateObject private var viewModel: MemorizeGameViewModel

    init(viewModel: MemorizeGameViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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
        .navigationTitle(viewModel.themeName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let demo = Theme(
        name: "Demo",
        emojis: ["😀", "🐶", "🍕", "⚽"],
        pairs: 4,
        rgba: .gray
    )
    return MemorizeGameView(viewModel: MemorizeGameViewModel(theme: demo))
}
