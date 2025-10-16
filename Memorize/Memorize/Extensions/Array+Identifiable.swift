//  Extensions/Array+Identifiable.swift

import Foundation

/// Helpers for arrays of Identifiable elements.
extension Array where Element: Identifiable {
    // MARK: - Lookup
    /// Returns the first index of an element whose `id` matches `id`.
    func firstIndex(ofID id: Element.ID) -> Int? {
        firstIndex { $0.id == id }
    }
}
