//  View/Components/CardsGrid.swift

import SwiftUI

/// Cards grid that fits all when possible; otherwise switches to scroll with a minimum cell size.
struct CardsGrid: View {
    // MARK: - Inputs
    let cards: [Card]
    let themeColor: Color
    let themeGradient: LinearGradient?
    let isTapEnabled: Bool
    let onTap: (Card) -> Void

    // MARK: - Layout constants (keep math == layout)
    private let perCellPadding: CGFloat = 6
    private let gridTopPadding: CGFloat = 8
    private let aspect: CGFloat = 2.0 / 3.0
    private let minCellWidth: CGFloat = 70

    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            let computed = widthThatFitsAll(
                itemCount: cards.count,
                in: proxy.size,
                itemAspectRatio: aspect,
                cellPaddingY: perCellPadding,
                outerTopPadding: gridTopPadding
            )
            let needsScroll = computed < minCellWidth

            Group {
                if needsScroll {
                    ScrollView {
                        LazyVGrid(
                            columns: [
                                GridItem(
                                    .adaptive(
                                        minimum: minCellWidth,
                                        maximum: minCellWidth
                                    ),
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
                                .aspectRatio(aspect, contentMode: .fit)
                                .padding(perCellPadding)
                            }
                        }
                        .padding(.top, gridTopPadding)
                    }
                } else {
                    AspectVGrid(
                        items: cards,
                        aspectRatio: aspect,
                        containerSize: proxy.size,
                        fitAll: true,
                        cellPaddingY: perCellPadding,
                        outerTopPadding: gridTopPadding
                    ) { card in
                        CardView(
                            card: card,
                            themeColor: themeColor,
                            themeGradient: themeGradient
                        )
                        .onTapGesture { onTap(card) }
                        .allowsHitTesting(isTapEnabled)
                        .padding(perCellPadding)
                    }
                    .padding(.top, gridTopPadding)
                }
            }
        }
    }

    // MARK: - Layout helper (outside ViewBuilder)
    private func widthThatFitsAll(
        itemCount: Int,
        in size: CGSize,
        itemAspectRatio: CGFloat,
        cellPaddingY: CGFloat,
        outerTopPadding: CGFloat
    ) -> CGFloat {
        guard itemCount > 0 else { return size.width }
        let heightAvail = max(0, size.height - outerTopPadding)

        var best: CGFloat = 0
        for columns in 1...itemCount {
            let rows = Int(ceil(Double(itemCount) / Double(columns)))
            let maxByWidth = size.width / CGFloat(columns)
            let perRowAvail = heightAvail / CGFloat(rows)
            let maxByHeight = max(
                0,
                (perRowAvail - 2 * cellPaddingY) * itemAspectRatio
            )
            let candidate = min(maxByWidth, maxByHeight)
            if candidate > best { best = candidate }
        }
        return best
    }
}
