//  Extensions/EmojiParsing.swift

import Foundation

extension Character {
    /// Heuristic: any scalar flagged as emoji, or multi-scalar cluster.
    var isEmojiLike: Bool {
        unicodeScalars.first?.properties.isEmoji == true
            || unicodeScalars.count > 1
    }
}

/// Extracts unique emoji grapheme clusters (order preserved).
func extractUniqueEmojis(from input: String) -> [String] {
    var seen = Set<String>()
    var result: [String] = []
    for ch in input {
        if ch.isEmojiLike {
            let s = String(ch)
            if !seen.contains(s) {
                seen.insert(s)
                result.append(s)
            }
        }
    }
    return result
}
