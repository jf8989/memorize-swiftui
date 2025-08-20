// View/Components/AspectVGrid.swift

import SwiftUI

/// A vertical grid that lays out items with a fixed aspect ratio.
/// Supports `minimumCellWidth` and an optional `availableHeight` override (useful inside ScrollView).
struct AspectVGrid<Item, ItemView>: View
where ItemView: View, Item: Identifiable {
    let items: [Item]
    let aspectRatio: CGFloat
    let minimumCellWidth: CGFloat?
    let availableHeight: CGFloat?
    let content: (Item) -> ItemView

    // MARK: - Initialization
    init(
        items: [Item],
        aspectRatio: CGFloat,
        minimumCellWidth: CGFloat? = nil,
        availableHeight: CGFloat? = nil,
        @ViewBuilder content: @escaping (Item) -> ItemView
    ) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.minimumCellWidth = minimumCellWidth
        self.availableHeight = availableHeight
        self.content = content
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let height = availableHeight ?? geometry.size.height  // Prefer explicit height
            let fittedWidth = widthThatFits(
                itemCount: items.count,
                in: CGSize(width: geometry.size.width, height: height),
                itemAspectRatio: aspectRatio
            )
            let cellWidth = max(fittedWidth, minimumCellWidth ?? 0)

            LazyVGrid(columns: [adaptiveGridItem(width: cellWidth)], spacing: 0)
            {
                ForEach(items) { item in
                    content(item)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                }
            }
        }
    }

    // MARK: - Private
    private func adaptiveGridItem(width: CGFloat) -> GridItem {
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }

    private func widthThatFits(
        itemCount: Int,
        in size: CGSize,
        itemAspectRatio: CGFloat
    ) -> CGFloat {
        var columnCount = 1
        var rowCount = itemCount
        if itemCount == 0 { return size.width }
        repeat {
            let itemWidth = size.width / CGFloat(columnCount)
            let itemHeight = itemWidth / itemAspectRatio
            if CGFloat(rowCount) * itemHeight < size.height {
                return itemWidth
            }
            columnCount = columnCount + 1
            rowCount = (itemCount + columnCount - 1) / columnCount
        } while columnCount < itemCount
        return size.width / CGFloat(columnCount)
    }
}
