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
                // Front
                Group {
                    RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(
                        radius: 2.5
                    )
                    RoundedRectangle(cornerRadius: 12).strokeBorder(
                        lineWidth: 2
                    ).foregroundColor(.orange)
                    Text(card.content).font(.largeTitle)
                }
                .opacity(card.isFaceUp ? 1.0 : 0.0)

                // Back
                Group {
                    if let gradient = themeGradient {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(gradient)
                            .shadow(radius: 2.5)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeColor)
                            .shadow(radius: 2.5)
                    }
                    Text("?")
                        .bold()
                        .font(.largeTitle)
                        .fontDesign(.serif)
                        .rotation3DEffect(
                            .degrees(180),
                            axis: (x: 0, y: 1, z: 0)
                        )  // correct mirroring
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
