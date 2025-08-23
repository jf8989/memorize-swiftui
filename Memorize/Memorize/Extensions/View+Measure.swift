//  Extensions/View+Measure.swift

import SwiftUI

// MARK: - Height measuring via preference
private struct HeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())  // use the largest we see
    }
}

extension View {
    /// Writes this view's height into `binding` once laid out.
    func measureHeight(_ binding: Binding<CGFloat>) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: HeightKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(HeightKey.self) { binding.wrappedValue = $0 }
    }
}
