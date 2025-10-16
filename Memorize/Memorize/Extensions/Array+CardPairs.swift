//  Extensions/Array+CardPairs.swift

import Foundation

/// Diagnostics & helpers for arrays of `Card`.
extension Array where Element == Card {
    /// True if every distinct `content` appears exactly twice.
    var hasValidPairs: Bool {
        let counts = Dictionary(grouping: self, by: { $0.content }).mapValues {
            $0.count
        }
        return !counts.values.contains { $0 != 2 }
    }
}
