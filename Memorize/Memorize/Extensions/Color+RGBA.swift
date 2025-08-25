//  Extensions/Color+RGBA.swift

import SwiftUI
import UIKit

/// Convert stored RGBA → SwiftUI Color (sRGB).
extension Color {
    init(rgba: RGBA) {
        self = Color(
            .sRGB,
            red: rgba.r,
            green: rgba.g,
            blue: rgba.b,
            opacity: rgba.a
        )
    }
}

/// Convert SwiftUI Color → storable RGBA using UIColor.
extension RGBA {
    init(_ color: Color) {
        let ui = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if ui.getRed(&r, green: &g, blue: &b, alpha: &a) {
            self = RGBA(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
        } else {
            self = .gray
        }
    }
}
