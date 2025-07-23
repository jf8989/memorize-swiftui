// Model/MemoryGame.swift

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable {
    struct Card: Identifiable {
        var id: Int
        var content: CardContent
        var isFaceUp: Bool = false
        var isMatched: Bool = false
    }
    
    var cards: [Card]
}


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


// main grid where the cards reside
@ViewBuilder
var cards: some View {
    if !shuffledEmojis.isEmpty, let selectedTheme {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
            ForEach(0..<shuffledEmojis.count, id: \.self) { index in
                CardView(
                    content: shuffledEmojis[index],
                    themeColor: selectedTheme.color
                )
            }
        }
    }
}
