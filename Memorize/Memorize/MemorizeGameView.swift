import SwiftUI

struct MemorizeGameView: View {
    
    // We add state so that it's modifyiable from anywhere in this file.
    @State var cardCount: Int = 0
    
    @State var selectedEmojiGroup: [String] = []
    
    // This is my hardcoded array of emojis.
    let halloweenEmojis = ["👻", "🎃", "🕷️", "💀", "🧙‍♀️", "🦇", "🌕", "⚰️", "👻", "🎃", "🕷️", "💀", "🧙‍♀️", "🦇", "🌕", "⚰️"]
    let animalEmojis = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼"]
    let carsEmojis = ["🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑"]
    
    let gameTitle: String = "Memorize!"
    
    var body: some View {
        VStack {  // we're aligning all of our views vertically in order to organize the UI
            title
            Spacer()
            cards // we place the card's grid at the top
            Spacer()  // we add a space to push them away from each other all the way to the edges
            cardCountAdjusters  // we insert the button's view here, defaulting all the way to the bottom of the screen
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
    func themeAdjuster(emojiGroup: [String], symbol: String, themeName: String) -> some View {
        Button(action: {
            selectedEmojiGroup = emojiGroup.shuffled()
            if emojiGroup == halloweenEmojis {
                cardCount = 8
            } else if emojiGroup == animalEmojis {
                cardCount = 16
            } else if emojiGroup == carsEmojis {
                cardCount = 10
            }
        }, label: {
            VStack {
                Image(systemName: symbol)
                    .font(.largeTitle)
                Text(themeName)
            }
        })
    }
    
    var theme1: some View {
        themeAdjuster(emojiGroup: halloweenEmojis, symbol: "1.lane", themeName: "Halloween")
            .foregroundColor(.teal)
    }
    
    var theme2: some View {
        themeAdjuster(emojiGroup: animalEmojis, symbol: "2.lane", themeName: "Animals")
            .foregroundColor(.teal)
    }
    
    var theme3: some View {
        themeAdjuster(emojiGroup: carsEmojis, symbol: "3.lane", themeName: "Vehicles")
            .foregroundColor(.teal)
    }

    
    // *** CARDS ***
    
    // main grid where the cards reside
    @ViewBuilder
    var cards: some View {
        if !selectedEmojiGroup.isEmpty {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                ForEach(0..<cardCount, id: \.self) { index in
                    CardView(content: selectedEmojiGroup[index])
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
    @State var isFaceUp = false
    
    var body: some View {
        ZStack {
            let base = RoundedRectangle(cornerRadius: 12)
            
            if isFaceUp {
                base.foregroundColor(.white).shadow(radius: 2.5)
                base.strokeBorder(lineWidth: 2).foregroundColor(.orange)
                Text(content).font(.largeTitle)
            } else {
                base.foregroundColor(.yellow).shadow(radius: 2.5)
                Text("?").bold().font(.largeTitle).fontDesign(.serif)
            }
        } .onTapGesture {
            isFaceUp.toggle()
        }
    }
}

// Notes:  I'm confused as to why we need to create a different struct CardView instead of simply creating a view within the main struct, MemorizeGameView.  Is it that, in order to create a visual element, we must use a struct?  One view per struct?

#Preview {
    MemorizeGameView()
}
