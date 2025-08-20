//  Extensions/Collection+Safe.swift

import Foundation

/// Safe subscript for any collection (returns nil if out of bounds).
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
