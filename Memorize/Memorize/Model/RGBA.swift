//  Model/RGBA.swift

import Foundation

/// RGBA color in linear 0...1 components. Codable and UI-free.
struct RGBA: Codable, Equatable, Hashable {
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    /// Clamps components to 0...1.
    init(r: Double, g: Double, b: Double, a: Double = 1.0) {
        self.r = r.clamped01()
        self.g = g.clamped01()
        self.b = b.clamped01()
        self.a = a.clamped01()
    }

    /// Neutral fallback gray.
    static let gray = RGBA(r: 0.5, g: 0.5, b: 0.5, a: 1.0)
}

extension Double {
    fileprivate func clamped01() -> Double { min(max(self, 0.0), 1.0) }
}
