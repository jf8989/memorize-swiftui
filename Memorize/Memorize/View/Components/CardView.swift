//  View/Components/CardView.swift

import SwiftUI

/// A single playing card.
/// - Front: white face with emoji.
/// - Back: theme fill (solid or gradient) + optional image named **"CardBack"** in the bundle.
///   If the image is missing, we show a big “?” as a fallback (no logging).
struct CardView: View {
    // MARK: - Inputs
    let card: Card
    let themeColor: Color
    let themeGradient: LinearGradient?

    // MARK: - Constants
    private let cornerRadius: CGFloat = 12

    // MARK: - Derived
    private var rotationDegrees: Double { card.isFaceUp ? 0 : 180 }

    // MARK: - Body
    var body: some View {
        ZStack {
            if card.isMatched {
                EmptyView()
            } else {
                let cardShape = RoundedRectangle(cornerRadius: cornerRadius)

                // FRONT (emoji)
                Group {
                    cardShape.fill(Color.white).shadow(radius: 2.5)
                    cardShape.strokeBorder(lineWidth: 2).foregroundColor(
                        .orange
                    )

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

                // BACK (theme fill + image or fallback)
                Group {
                    if let gradient = themeGradient {
                        cardShape.fill(gradient).shadow(radius: 2.5)
                    } else {
                        cardShape.fill(themeColor).shadow(radius: 2.5)
                    }

                    backArt()  // image or "?" fallback
                        .rotation3DEffect(
                            .degrees(180),
                            axis: (x: 0, y: 1, z: 0)
                        )  // correct mirroring
                        .padding(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .opacity(card.isFaceUp ? 0.0 : 1.0)
            }
        }
        .aspectRatio(2 / 3, contentMode: .fit)
        .opacity(card.isMatched ? 0 : 1)
        .allowsHitTesting(!card.isMatched)
        .scaleEffect(card.isFaceUp ? 1.08 : 1.0)
        .rotation3DEffect(.degrees(rotationDegrees), axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut(duration: 0.35), value: card.isFaceUp)
    }

    // MARK: - Back Art
    /// Attempts to load an image named **"CardBack"** from the app bundle (Asset catalog or file).
    /// If absent, renders a big “?” as a simple fallback.
    @ViewBuilder
    private func backArt() -> some View {
        if let ui = UIImage(named: "CardBack") {
            Image(uiImage: ui)
                .resizable()
                .scaledToFit()
                // Rounded image corners so the art matches the card’s rounded shape
                .clipShape(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
        } else {
            Text("?")
                .bold()
                .font(.system(size: 64))
        }
    }
}
