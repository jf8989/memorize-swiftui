//  View/Components/AspectVGrid.swift

import SwiftUI

/// A vertical grid that lays out items with a fixed aspect ratio and **fits everything**
/// inside `containerSize` (no scroll). It increases column count until the total height fits.
struct AspectVGrid<Item, ItemView>: View
where ItemView: View, Item: Identifiable {
    let items: [Item]
    let aspectRatio: CGFloat
    let containerSize: CGSize
    let fitAll: Bool
    let content: (Item) -> ItemView

    // MARK: - Init
    init(
        items: [Item],
        aspectRatio: CGFloat,
        containerSize: CGSize,
        fitAll: Bool = true,
        @ViewBuilder content: @escaping (Item) -> ItemView
    ) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.containerSize = containerSize
        self.fitAll = fitAll
        self.content = content
    }

    // MARK: - Body
    var body: some View {
        let cellWidth: CGFloat = widthThatFitsAll(
            itemCount: items.count,
            in: containerSize,
            itemAspectRatio: aspectRatio
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
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }

    /// Fit-all strategy: increase columns until all rows fit within the available height.
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
            if CGFloat(rows) * h <= size.height {
                return w
            }
            columns += 1
            rows = (itemCount + columns - 1) / columns
        } while columns < itemCount
        return size.width / CGFloat(columns)
    }
}
