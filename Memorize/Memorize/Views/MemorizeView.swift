//  Views/MemorizeView.swift

import SwiftUI

/// Root view for the Memorize game.
struct MemorizeView: View {
    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - State
    @StateObject private var viewModel = MemorizeViewModel()

    // MARK: - Body
    var body: some View {
        VStack {
            if viewModel.isGameStarted {
                HStack {
                    scoreView
                    Spacer()
                    timeView
                }
            }
            themeName
            Spacer()
            cards
            Spacer()
            newGameButton
        }
        .padding()
    }

    // MARK: - Header

    private var themeName: some View {
        // Ensure readable title in dark mode when theme color is black.
        let displayColor =
            (viewModel.themeColor == .black && colorScheme == .dark)
            ? Color.white : viewModel.themeColor

        return Text(viewModel.themeName)
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundColor(displayColor)
            .shadow(color: .black.opacity(0.20), radius: 4, x: 0, y: 2)
            .padding(.top)
            .padding(.bottom, 6)
            .overlay(
                Capsule()
                    .frame(height: 4)
                    .foregroundColor(displayColor)
                    .opacity(0.25)
                    .offset(y: 26)
            )
            .animation(
                .spring(
                    response: 0.45,
                    dampingFraction: 0.55,
                    blendDuration: 0.7
                ),
                value: viewModel.themeName
            )
    }

    private var scoreView: some View {
        Text("Score: \(viewModel.score)")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(viewModel.score >= 0 ? .blue : .red)
    }

    private var timeView: some View {
        Text("Timer: \(viewModel.timeRemaining)")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(viewModel.timeRemaining < 10 ? .red : .blue)
    }

    // MARK: - Controls

    private var newGameButton: some View {
        Button(action: viewModel.newGame) {
            Text("New Game")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 40)
        }
        .padding(.bottom)
    }

    // MARK: - Cards Grid

    @ViewBuilder
    private var cards: some View {
        if !viewModel.cards.isEmpty {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 70), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(viewModel.cards) { card in
                        CardView(
                            card: card,
                            themeColor: viewModel.themeColor,
                            themeGradient: viewModel.themeGradientColor
                        )
                        .onTapGesture { viewModel.choose(card) }
                        .allowsHitTesting(viewModel.isTapEnabled)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}

/// A single card view.
struct CardView: View {
    let card: Card
    let themeColor: Color
    let themeGradient: LinearGradient?

    private var rotation: Double { card.isFaceUp ? 0 : 180 }

    var body: some View {
        ZStack {
            if card.isMatched {
                EmptyView()
            } else {
                // Front
                Group {
                    RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(
                        radius: 2.5
                    )
                    RoundedRectangle(cornerRadius: 12).strokeBorder(
                        lineWidth: 2
                    ).foregroundColor(.orange)
                    Text(card.content).font(.largeTitle)
                }
                .opacity(card.isFaceUp ? 1.0 : 0.0)

                // Back
                Group {
                    if let gradient = themeGradient {
                        RoundedRectangle(cornerRadius: 12).fill(gradient)
                            .shadow(radius: 2.5)
                    } else {
                        RoundedRectangle(cornerRadius: 12).fill(themeColor)
                            .shadow(radius: 2.5)
                    }
                    Text("?")
                        .bold()
                        .font(.largeTitle)
                        .fontDesign(.serif)
                        .rotation3DEffect(
                            .degrees(180),
                            axis: (x: 0, y: 1, z: 0)
                        )  // correct mirroring
                }
                .opacity(card.isFaceUp ? 0.0 : 1.0)
            }
        }
        .aspectRatio(2 / 3, contentMode: .fit)
        .opacity(card.isMatched ? 0 : 1)
        .allowsHitTesting(!card.isMatched)
        .scaleEffect(card.isFaceUp ? 1.08 : 1.0)
        .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut(duration: 0.35), value: card.isFaceUp)
    }
}

#Preview {
    MemorizeView()
}
