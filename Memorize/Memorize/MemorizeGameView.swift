import SwiftUI

struct MemorizeGameView: View {
    var body: some View {  // "some" is there to guarantee that a "view", regardless of the type, is returned.
        HStack {
            CardView(isFaceUp: true)
            CardView()
            CardView()
            CardView()
        }
        
        .padding()
    }
}

struct CardView: View {
    var isFaceUp: Bool = false
    
    var body: some View {
        ZStack {  // this is a "computed property".
            // We declare a new variable that holds the base form that we're going to use all over the place instead of diplicating code.  It seems we have to specify the same shape or form every time we want to modify any of its parameters, which makes it using a base variable efficient.
            let base: RoundedRectangle = RoundedRectangle(cornerRadius: 12)
            if isFaceUp {
                base.foregroundColor(.white).shadow(radius: 2.5)
                base.strokeBorder(lineWidth: 2).foregroundColor(.orange)
                Text("🙈").font(.largeTitle)
            } else {
                base.foregroundColor(.yellow).shadow(radius: 2.5)
                Text("?").bold().font(.largeTitle).fontDesign(.serif)
            }
        }
    }
}




















#Preview {
    MemorizeGameView()
}
