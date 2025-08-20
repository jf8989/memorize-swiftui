// View/Components/CardsGrid.swift

import SwiftUI

/// Cards grid using AspectVGrid.
struct CardsGrid: View {
    let cards: [Card]
    let themeColor: Color
    let themeGradient: LinearGradient?
    let isTapEnabled: Bool
    let onTap: (Card) -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                AspectVGrid(
                    items: cards,
                    aspectRatio: 2.0 / 3.0,
                    minimumCellWidth: 90,  // tweak to taste (80–110 usually feels right on iPad)
                    availableHeight: proxy.size.height  // KEY: use the actual available height
                ) { card in
                    CardView(
                        card: card,
                        themeColor: themeColor,
                        themeGradient: themeGradient
                    )
                    .onTapGesture { onTap(card) }
                    .allowsHitTesting(isTapEnabled)
                    .padding(8)
                }
                .padding(.horizontal, 12)
            }
            .contentMargins(.top, 12)  // if you need iOS 15, use .padding(.top, 12)
            .scrollIndicators(.automatic)
        }
    }
}
