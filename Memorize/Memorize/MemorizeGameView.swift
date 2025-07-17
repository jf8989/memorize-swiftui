import SwiftUI

struct MemorizeGameView: View {
    
    // This is my hardcoded array of emojis.  The idea later will be to have at least 4 sets of these that get picked randomly.
    let emojis = ["🦄", "🐇", "🐰", "🐹", "🐻", "🐼", "🐨", "🐿️", "🐇", "🦄", "🐰", "🐹", "🐻", "🐼", "🐨", "🐿️"]
    
    // We add state so that it's modifyiable from anywhere in this file.
    @State var cardCount: Int = 4
    
    var body: some View {
        VStack {  // we're aligning all of our views vertically in order to organize the UI
            title
            cards // we place the card's grid at the top
            Spacer()  // we add a space to push them away from each other all the way to the edges
            cardCountAdjusters  // we insert the button's view here, defaulting all the way to the bottom of the screen
        }
        .padding()
    }
    
    let gameTitle: String = "Memorize"
    var title: some View {
        Text(gameTitle)
            .font(.largeTitle)
            .fontWeight(.bold)
            .fontDesign(.rounded)
            .foregroundColor(.teal)
    }
    
    // main grid where the cards reside
    var cards: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
            ForEach(0..<cardCount, id: \.self) { index in
                CardView(content: emojis[index])
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
        .disabled(cardCount + offset < 1 || cardCount + offset > emojis.count)
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
