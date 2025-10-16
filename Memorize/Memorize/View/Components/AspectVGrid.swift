//  View/Components/AspectVGrid.swift

import SwiftUI

/// A vertical grid that lays out items with a fixed aspect ratio and **fits everything**
/// inside `containerSize` (no scroll). It increases column count until the total height fits.
struct AspectVGrid<Item, ItemView>: View
where ItemView: View, Item: Identifiable {
    // MARK: - Inputs
    let items: [Item]
    let aspectRatio: CGFloat
    let containerSize: CGSize
    let fitAll: Bool
    let cellPaddingY: CGFloat  // vertical padding inside each cell (top+bottom)
    let outerTopPadding: CGFloat  // extra top padding applied to the grid
    let content: (Item) -> ItemView

    // MARK: - Init
    init(
        items: [Item],
        aspectRatio: CGFloat,
        containerSize: CGSize,
        fitAll: Bool = true,
        cellPaddingY: CGFloat = 0,
        outerTopPadding: CGFloat = 0,
        @ViewBuilder content: @escaping (Item) -> ItemView
    ) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.containerSize = containerSize
        self.fitAll = fitAll
        self.cellPaddingY = cellPaddingY
        self.outerTopPadding = outerTopPadding
        self.content = content
    }

    // MARK: - Body
    var body: some View {
        let cellWidth: CGFloat = widthThatFitsAll(
            itemCount: items.count,
            in: containerSize,
            itemAspectRatio: aspectRatio,
            cellPaddingY: cellPaddingY,
            outerTopPadding: outerTopPadding
        )

        LazyVGrid(columns: [adaptiveGridItem(width: cellWidth)], spacing: 0) {
            ForEach(items) { item in
                content(item)
                    .aspectRatio(aspectRatio, contentMode: .fit)
            }
        }
    }

    // MARK: - Private

    private func adaptiveGridItem(width: CGFloat) -> GridItem {
        var gridItem = GridItem(.adaptive(minimum: width, maximum: width))  // cap width
        gridItem.spacing = 0
        return gridItem
    }

    /// Fit-all strategy: increase columns until all rows fit within the available height.
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
            // rows * (w/aspect + 2*pad) <= heightAvail  ⇒  w <= (perRowAvail - 2*pad) * aspect
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
