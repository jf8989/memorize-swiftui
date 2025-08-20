//  View/Components/CardsGrid.swift

import SwiftUI

/// Cards grid that **always** fits all cards in the given space (no scrolling).
struct CardsGrid: View {
    let cards: [Card]
    let themeColor: Color
    let themeGradient: LinearGradient?
    let isTapEnabled: Bool
    let onTap: (Card) -> Void

    var body: some View {
        GeometryReader { proxy in
            AspectVGrid(
                items: cards,
                aspectRatio: 2.0 / 3.0,
                containerSize: proxy.size,
                fitAll: true
            ) { card in
                CardView(
                    card: card,
                    themeColor: themeColor,
                    themeGradient: themeGradient
                )
                .onTapGesture { onTap(card) }
                .allowsHitTesting(isTapEnabled)
                .padding(6)
            }
            .padding(.top, 8)
        }
    }
}
