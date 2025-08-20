//  View/Components/CardsGrid.swift

import SwiftUI

/// Cards grid using AspectVGrid.
struct CardsGrid: View {
    let cards: [Card]
    let themeColor: Color
    let themeGradient: LinearGradient?
    let isTapEnabled: Bool
    let onTap: (Card) -> Void

    var body: some View {
        ScrollView {
            AspectVGrid(
                items: cards,
                aspectRatio: 2.0 / 3.0,
                minimumCellWidth: 70/// stop shrinking below 70pt; allow vertical scroll instead
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
            .padding(.horizontal, 8)
        }
        .contentMargins(.top, 12)
        /// space under header (iOS 16+). If supporting iOS 15, use `.padding(.top, 12)` instead.
        .scrollIndicators(.automatic)
    }
}
