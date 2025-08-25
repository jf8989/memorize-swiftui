//  Engine/NameUniquifier.swift

import Foundation

/// Generates a unique name by suffixing " (n)" when needed.
enum NameUniquifier {
    static func unique(base: String, existing: [String]) -> String {
        guard existing.contains(base) else { return base }
        var n = 2
        while existing.contains("\(base) (\(n))") {
            n = n + 1
        }
        return "\(base) (\(n))"
    }
}
