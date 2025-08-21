//  View/Components/CardsGrid.swift

import SwiftUI

/// Cards grid that fits all when possible; otherwise switches to scroll with a minimum cell size.
struct CardsGrid: View {
    let cards: [Card]
    let themeColor: Color
    let themeGradient: LinearGradient?
    let isTapEnabled: Bool
    let onTap: (Card) -> Void

    var body: some View {
        GeometryReader { proxy in
            let minCellWidth: CGFloat = 70

            let computed = widthThatFitsAll(
                itemCount: cards.count,
                in: proxy.size,
                itemAspectRatio: 2.0 / 3.0
            )
            let needsScroll = computed < minCellWidth

            Group {
                if needsScroll {
                    // GeometryReader wraps; ScrollView is inside.
                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(
                                    .adaptive(minimum: minCellWidth),
                                    spacing: 0
                                )
                            ],
                            spacing: 0
                        ) {
                            ForEach(cards) { card in
                                CardView(
                                    card: card,
                                    themeColor: themeColor,
                                    themeGradient: themeGradient
                                )
                                .onTapGesture { onTap(card) }
                                .allowsHitTesting(isTapEnabled)
                                .aspectRatio(2.0 / 3.0, contentMode: .fit)
                                .padding(6)
                            }
                        }
                        .padding(.top, 8)
                    }
                } else {
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
    }

    // MARK: - Layout helper (outside ViewBuilder)
    private func widthThatFitsAll(
        itemCount: Int,
        in size: CGSize,
        itemAspectRatio: CGFloat
    ) -> CGFloat {
        guard itemCount > 0 else { return size.width }
        var columns = 1
        var rows = itemCount
        repeat {
            let w = size.width / CGFloat(columns)
            let h = w / itemAspectRatio
            if CGFloat(rows) * h <= size.height { return w }
            columns += 1
            rows = (itemCount + columns - 1) / columns
        } while columns < itemCount
        return size.width / CGFloat(columns)
    }
}
