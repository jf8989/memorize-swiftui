import SwiftUI

struct MemorizeGameView: View {
    var body: some View {  // "some" is there to guarantee that a "view", regardless of the type, is returned.
        HStack {
            CardView()
            CardView()
            CardView()
            CardView()
        }
        
        .padding()
    }
}

struct CardView: View {
    @State var isFaceUp = false
    
    var body: some View {
        ZStack {
            let base = RoundedRectangle(cornerRadius: 12)
            
            if isFaceUp {
                base.foregroundColor(.white).shadow(radius: 2.5)
                base.strokeBorder(lineWidth: 2).foregroundColor(.orange)
                Text("🙈").font(.largeTitle)
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
