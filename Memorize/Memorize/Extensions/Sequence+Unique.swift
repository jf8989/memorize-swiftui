//  Extensions/Sequence+Uniqued.swift

import Foundation

/// Keeps the first occurrence of each element, preserving order.
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
