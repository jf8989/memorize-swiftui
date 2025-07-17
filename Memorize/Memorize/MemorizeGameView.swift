import SwiftUI

struct MemorizeGameView: View {
    
    let emojis = ["🦄", "🐇", "🐰", "🐹", "🐻", "🐼", "🐨", "🐿️", "🐇", "🦄", "🐰", "🐹", "🐻", "🐼", "🐨", "🐿️"]
    
    @State var cardCount: Int = 4
    
    var body: some View {
        VStack {
            cards
            cardCountAdjusters
        }
        .padding()
    }
    
    var cardCountAdjusters: some View {
        HStack {
            cardRemover
            Spacer()
            cardAdder
        }
        .imageScale(.large)
        .font(.title)
    }
    
    var cards: some View {
        HStack {
            ForEach(0..<cardCount, id: \.self) { index in
                CardView(content: emojis[index])
            }
        }
    }
    
    var cardRemover: some View {
        Button(action: {
            if cardCount > 1  {
                cardCount -= 1
            }
        }, label: {
            Image(systemName: "rectangle.stack.fill.badge.minus")
        })
    }
    
    var cardAdder: some View {
        Button(action: {
            if cardCount < emojis.count {
                cardCount += 1
            }
        }, label: {
            Image(systemName: "rectangle.stack.fill.badge.plus")
        })
    }
}

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




















#Preview {
    MemorizeGameView()
}
