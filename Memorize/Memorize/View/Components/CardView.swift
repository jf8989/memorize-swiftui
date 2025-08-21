//  View/Components/CardView.swift

import SwiftUI

/// A single card view.
struct CardView: View {
    let card: Card
    let themeColor: Color
    let themeGradient: LinearGradient?

    private var rotation: Double { card.isFaceUp ? 0 : 180 }

    var body: some View {
        ZStack {
            if card.isMatched {
                EmptyView()
            } else {
                let cardShape = RoundedRectangle(cornerRadius: 12)
                // Front
                Group {
                    cardShape
                        .fill(Color.white).shadow(
                            radius: 2.5
                        )
                    cardShape
                        .strokeBorder(
                            lineWidth: 2
                        ).foregroundColor(.orange)
                    // ⬇️ size emoji to the card’s shortest side
                    GeometryReader { geo in
                        let s = min(geo.size.width, geo.size.height) * 0.62
                        Text(card.content)
                            .font(.system(size: s))
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .opacity(card.isFaceUp ? 1.0 : 0.0)

                // Back
                Group {
                    if let gradient = themeGradient {
                        cardShape
                            .fill(gradient)
                            .shadow(radius: 2.5)
                    } else {
                        cardShape
                            .fill(themeColor)
                            .shadow(radius: 2.5)
                    }
                    // Make the "?" a bit larger than the front emoji
                    GeometryReader { geo in
                        let s = min(geo.size.width, geo.size.height) * 0.68  // slightly larger
                        Text("?")
                            .bold()
                            .font(.system(size: s))
                            .fontDesign(.serif)
                            .rotation3DEffect(
                                .degrees(180),
                                axis: (x: 0, y: 1, z: 0)
                            )  // correct mirroring
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
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
