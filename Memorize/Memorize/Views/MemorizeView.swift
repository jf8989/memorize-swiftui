// Views/MemorizeView

import SwiftUI

struct MemorizeView: View {
    @Environment(\.colorScheme) var colorScheme  // This allows me to decide what happens when the Color Scheme is "dark", preventing color-masking.

    @ObservedObject var viewModel = MemorizeViewModel()  // @ObservedObject means SwiftUI watches for changes and updates the View automatically.

    var body: some View {
        VStack {  // we're aligning all of our views vertically in order to organize the UI
            scoreView
            themeName
            Spacer()
            cards  // we place the card's grid at the top
            Spacer()  // we add a space to push them away from each other all the way to the edges
            newGameButton
        }
        .padding()
    }

    // Title of each theme
    private var themeName: some View {
        let color =
            (viewModel.themeColor == .black && colorScheme == .dark)
            ? Color.white
            : viewModel.themeColor

        return Text(viewModel.themeName)
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundColor(color)
            .shadow(color: .black.opacity(0.20), radius: 4, x: 0, y: 2)
            .padding(.top)
            .padding(.bottom, 6)
            .overlay(
                Capsule()
                    .frame(height: 4)
                    .foregroundColor(color)
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
            .foregroundColor(.blue)
    }

    // NEW GAME button (I'll use private var because the View is the only one that should be able to use this.
    private var newGameButton: some View {  // This is just the visual side of the button
        Button(action: newGameAction) {
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

    // This is the button's action.
    private func newGameAction() {
        viewModel.newGame()
    }

    // *** CARDS ***

    // main grid where the cards reside
    @ViewBuilder
    var cards: some View {
        if !viewModel.cards.isEmpty {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                ForEach(viewModel.cards) { card in  // Receives the entire array of cards set in the ViewModel.
                    CardView(
                        card: card,
                        themeColor: viewModel.themeColor,
                        themeGradient: viewModel.themeGradientColor
                    )
                        .onTapGesture {
                            viewModel.choose(card)
                        }
                        .allowsHitTesting(viewModel.isTapEnabled)
                }
            }
        }
    }
}

// basic card creation using a separate struct.  This is a reusable component, and represents a single card
// in the game.  It can be used in multiple places, and is a good example of how to create reusable components
// in SwiftUI.
struct CardView: View {
    let card: Card
    let themeColor: Color
    let themeGradient: LinearGradient?  // it could be null

    var body: some View {
        ZStack {
            let base = RoundedRectangle(cornerRadius: 12)

            if card.isFaceUp {
                base.foregroundColor(.white)
                    .shadow(radius: 2.5)
                base.strokeBorder(lineWidth: 2)
                    .foregroundColor(.orange)
                Text(card.content)
                    .font(.largeTitle)
            } else if card.isMatched {
                base.opacity(0)
            } else {
                if let gradient = themeGradient {  // if gradient is given
                    base.fill(gradient)
                        .shadow(radius: 2.5)
                } else {
                    base.foregroundColor(themeColor)  // use themeColor if gradient not given
                        .shadow(radius: 2.5)
                }
                Text("?")
                    .bold()
                    .font(.largeTitle)
                    .fontDesign(.serif)
            }
        }
        .allowsHitTesting(!card.isMatched)
    }
}


#Preview {
    MemorizeView()
}
