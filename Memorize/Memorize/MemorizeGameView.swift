import SwiftUI

struct MemorizeGameView: View {
    
    // We add state so that it's modifyiable from anywhere in this file.
    @State var cardCount: Int = 0
    
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
            cards // we place the card's grid at the top
            Spacer()  // we add a space to push them away from each other all the way to the edges
            //cardCountAdjusters  // we insert the button's view here, defaulting all the way to the bottom of the screen
            theme
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
    
    var theme: some View {
        HStack {
            Spacer()
            theme1
            Spacer()
            theme2
            Spacer()
            theme3
            Spacer()
        }
    }
    
    // Dynamically creating the buttons and their logic
    func themeAdjuster(emojiGroup: [String],
                       symbol: String,
                       themeName: String,
                       themeColor: Color) -> some View {
        Button(action: {
            
            selectedEmojiGroup = (emojiGroup + emojiGroup)
                .shuffled() // duplicate the array to generate "pairs"
            cardCount = selectedEmojiGroup.count // modify the card count to show the sum of the arrays
            currentThemeColor = themeColor
            
        }, label: {
            VStack {
                Image(systemName: symbol)
                    .font(.largeTitle)
                Text(themeName)
                    .font(.footnote)
            }
        })
    }
    
    var theme1: some View {
        themeAdjuster(emojiGroup: halloweenEmojis, symbol: "theatermasks.fill", themeName: "Halloween", themeColor: .orange)
            .foregroundColor(.teal)
    }
    
    var theme2: some View {
        themeAdjuster(emojiGroup: animalEmojis, symbol: "dog", themeName: "Animals", themeColor: .brown)
            .foregroundColor(.teal)
    }
    
    var theme3: some View {
        themeAdjuster(emojiGroup: carsEmojis, symbol: "truck.box", themeName: "Vehicles", themeColor: .green)
            .foregroundColor(.teal)
    }

    
    // *** CARDS ***
    
    // main grid where the cards reside
    @ViewBuilder
    var cards: some View {
        if !selectedEmojiGroup.isEmpty {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                ForEach(0..<cardCount, id: \.self) { index in
                    CardView(content: selectedEmojiGroup[index],
                             themeColor: currentThemeColor)
                }
            }
        }
    }
    
    // horizontal stack for the buttons
    var cardCountAdjusters: some View {
        HStack {
            cardRemover
            Spacer()
            cardAdder
        }
        .imageScale(.large)
        .font(.title)
    }
    
    // Dynamically creating the buttons and their logic
    func cardCountAdjuster(by offset: Int, symbol: String) -> some View {
        Button(action: {
                cardCount += offset
        }, label: {
            Image(systemName: symbol)
        })
        .disabled(cardCount + offset < 1 || cardCount + offset > halloweenEmojis.count)
    }
    
    // we're calling the function with different parameters depending on the desired action
    var cardRemover: some View {  // removes a card
        cardCountAdjuster(by: -1, symbol: "rectangle.stack.fill.badge.minus")
            .foregroundColor(.teal)
    }
    
    var cardAdder: some View {  // adds a card
        cardCountAdjuster(by: +1, symbol: "rectangle.stack.fill.badge.plus")
            .foregroundColor(.teal)
    }
}

// basic card creation using a separate struct
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
        } .onTapGesture {
            isFaceUp.toggle()
        }
    }
}

#Preview {
    MemorizeGameView()
}
