// Views/MemorizeView

import SwiftUI

struct MemorizeView: View {
    @ObservedObject var viewModel = MemorizeViewModel()  // @ObservedObject means SwiftUI watches for changes and updates the View automatically.
    let gameTitle: String = "Memorize!"

    var body: some View {
        VStack {  // we're aligning all of our views vertically in order to organize the UI
            title
            Spacer()
            cards  // we place the card's grid at the top
            Spacer()  // we add a space to push them away from each other all the way to the edges
            cardThemes
        }
        .padding()
    }

    var title: some View {
        Text(gameTitle)
            .font(.largeTitle)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .foregroundColor(.teal)
    }

    // *** THEME ***

    var cardThemes: some View {  // dynamically generating card theme buttons using ForEach
        HStack {
            Spacer()
            ForEach(EmojiTheme.allCases, id: \.self) { theme in
                Button(action: {
                    viewModel.selectTheme(theme)
                }) {
                    VStack {
                        Image(systemName: theme.symbol)
                            .font(.largeTitle)
                        Text(theme.name)
                            .font(.footnote)
                    }
                }
                .foregroundColor(theme.color)
                Spacer()
            }
        }
    }

    // *** CARDS ***

    // main grid where the cards reside
    @ViewBuilder
    var cards: some View {
        if !viewModel.shuffledEmojis.isEmpty {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                ForEach(0..<viewModel.shuffledEmojis.count, id: \.self) {
                    index in
                    CardView(
                        content: viewModel.shuffledEmojis[index],
                        themeColor: viewModel.themeColor
                    )
                }
            }
        }
    }
}

// basic card creation using a separate struct.  This is a reusable component, and represents a single card
// in the game.  It can be used in multiple places, and is a good example of how to create reusable components
// in SwiftUI.
struct CardView: View {
    let content: String
    let themeColor: Color
    @State var isFaceUp = false

    var body: some View {
        ZStack {
            let base = RoundedRectangle(cornerRadius: 12)

            if isFaceUp {
                base.foregroundColor(.white)
                    .shadow(radius: 2.5)
                base.strokeBorder(lineWidth: 2)
                    .foregroundColor(.orange)
                Text(content)
                    .font(.largeTitle)
            } else {
                base.foregroundColor(themeColor)
                    .shadow(radius: 2.5)
                Text("?")
                    .bold()
                    .font(.largeTitle)
                    .fontDesign(.serif)
            }
        }.onTapGesture {
            isFaceUp.toggle()
        }
    }
}

#Preview {
    MemorizeView()
}
