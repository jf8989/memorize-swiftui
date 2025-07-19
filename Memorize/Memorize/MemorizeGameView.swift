import SwiftUI

struct MemorizeGameView: View {

    var cardCount: Int { selectedEmojiGroup.count }

    @State var selectedEmojiGroup: [String] = []

    @State private var currentThemeColor: Color = .orange

    // This are my hardcoded arrays of emojis.
    let halloweenEmojis: [String] = ["👻", "🎃", "🕷️", "💀", "🧙‍♀️", "🦇", "🌕", "⚰️"]
    let animalEmojis: [String] = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻"]
    let carsEmojis: [String] = ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎️"]

    let gameTitle: String = "Memorize!"

    var body: some View {
        VStack {  // we're aligning all of our views vertically in order to organize the UI
            title
            Spacer()
            cards  // we place the card's grid at the top
            Spacer()  // we add a space to push them away from each other all the way to the edges
            gameTheme
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

    var gameTheme: some View {
        HStack {
            Spacer()
            halloweenTheme
            Spacer()
            animalTheme
            Spacer()
            vehicleTheme
            Spacer()
        }
    }

    // Dynamically creating the buttons and their logic
    func themeAdjuster(
        emojiGroup: [String],
        symbol: String,
        themeName: String,
        themeColor: Color
    ) -> some View {
        Button(
            action: {
                selectedEmojiGroup = (emojiGroup + emojiGroup) // duplicate the array to generate "pairs"
                    .shuffled() // randomize them
                currentThemeColor = themeColor
            },
            label: {
                VStack {
                    Image(systemName: symbol)
                        .font(.largeTitle)
                    Text(themeName)
                        .font(.footnote)
                }
            }
        )
    }

    var halloweenTheme: some View {
        themeAdjuster(
            emojiGroup: halloweenEmojis,
            symbol: "theatermasks.fill",
            themeName: "Halloween",
            themeColor: .orange
        )
        .foregroundColor(.orange)
    }

    var animalTheme: some View {
        themeAdjuster(
            emojiGroup: animalEmojis,
            symbol: "dog",
            themeName: "Animals",
            themeColor: .brown
        )
        .foregroundColor(.brown)
    }

    var vehicleTheme: some View {
        themeAdjuster(
            emojiGroup: carsEmojis,
            symbol: "truck.box",
            themeName: "Vehicles",
            themeColor: .green
        )
        .foregroundColor(.green)
    }

    // *** CARDS ***

    // main grid where the cards reside
    @ViewBuilder
    var cards: some View {
        if !selectedEmojiGroup.isEmpty {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                ForEach(0..<cardCount, id: \.self) { index in
                    CardView(
                        content: selectedEmojiGroup[index],
                        themeColor: currentThemeColor
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
    MemorizeGameView()
}
