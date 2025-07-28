// Views/MemorizeView

import SwiftUI

struct MemorizeView: View {
    @Environment(\.colorScheme) var colorScheme  // This allows me to decide what happens when the Color Scheme is "dark", preventing color-masking.

    @StateObject var viewModel = MemorizeViewModel()  // @ObservedObject means SwiftUI watches for changes and updates the View automatically.

    var body: some View {
        VStack {  // we're aligning all of our views vertically in order to organize the UI
            HStack {
                scoreView
                Spacer()
                timeView
            }
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
            .foregroundColor(viewModel.score >= 0 ? .blue : .red)
    }

    private var timeView: some View {
        Text("Timer: \(viewModel.timeRemaining)")
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(viewModel.timeRemaining < 10 ? .red : .blue)
    }

    // NEW GAME button (I'll use private var because the View is the only one that should be able to use this.
    private var newGameButton: some View {  // This is just the visual side of the button
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

    // *** CARDS ***

    // main grid where the cards reside
    @ViewBuilder
    var cards: some View {
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

// basic card creation using a separate struct.  This is a reusable component, and represents a single card
// in the game.  It can be used in multiple places, and is a good example of how to create reusable components
// in SwiftUI.
struct CardView: View {
    let card: Card
    let themeColor: Color
    let themeGradient: LinearGradient?

    // Compute the rotation
    var rotation: Double {
        card.isFaceUp ? 0 : 180
    }

    var body: some View {
        ZStack {
            if card.isMatched {
                // Hide matched cards
                EmptyView()
            } else {
                // The card front (shows emoji)
                Group {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(radius: 2.5)
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(lineWidth: 2)
                        .foregroundColor(.orange)
                    Text(card.content)
                        .font(.largeTitle)
                }
                .opacity(card.isFaceUp ? 1.0 : 0.0)
                // The card back (shows ?)
                Group {
                    if let gradient = themeGradient {
                        RoundedRectangle(cornerRadius: 12).fill(gradient)
                            .shadow(radius: 2.5)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeColor)
                            .shadow(radius: 2.5)
                    }
                    Text("?")
                        .bold()
                        .font(.largeTitle)
                        .fontDesign(.serif)
                        // Rotate the "?" 180° on the Y axis to correct mirroring
                        .rotation3DEffect(
                            .degrees(180),
                            axis: (x: 0, y: 1, z: 0)
                        )
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
