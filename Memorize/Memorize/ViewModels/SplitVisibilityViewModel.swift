//  ViewModel/SplitVisibilityViewModel.swift

import SwiftUI

/// Persists iPad NavigationSplitView visibility across rotations/app launches.
@MainActor
final class SplitVisibilityViewModel: ObservableObject {
    @Published private(set) var visibility: NavigationSplitViewVisibility

    private let key = "ui.splitVisibility.raw"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let raw = defaults.string(forKey: key)
        self.visibility = Self.decode(raw) ?? .all  // default: sidebar visible
    }

    func set(_ newValue: NavigationSplitViewVisibility) {
        visibility = newValue
        defaults.set(Self.encode(newValue), forKey: key)
    }

    // MARK: - Codec

    private static func encode(_ v: NavigationSplitViewVisibility) -> String {
        switch v {
        case .all: return "all"
        case .detailOnly: return "detailOnly"
        case .doubleColumn: return "doubleColumn"
        default: return "automatic"
        }
    }

    private static func decode(_ raw: String?) -> NavigationSplitViewVisibility?
    {
        switch raw {
        case "all": return .all
        case "detailOnly": return .detailOnly
        case "doubleColumn": return .doubleColumn
        case "automatic": return .automatic
        default: return nil
        }
    }
}
