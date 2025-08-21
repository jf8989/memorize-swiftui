//  ViewModel/SplitVisibilityViewModel.swift

import SwiftUI

/// Persists NavigationSplitView visibility across rotations/app launches.
@MainActor
final class SplitVisibilityViewModel: ObservableObject {
    @Published var liveVisibility: NavigationSplitViewVisibility {
        didSet { persistGuarded(liveVisibility) }
    }

    private let defaults: UserDefaults
    private let keyCompact = "ui.splitVisibility.compact"
    private let keyRegular = "ui.splitVisibility.regular"
    private var currentSizeKey: String = "regular"
    private var suppressPersistence = false
    private var lastSizeClassChangeAt: Date?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.liveVisibility = .all
        print("SplitVM init")  // ← debug
    }
    deinit { print("SplitVM deinit") }  // ← debug

    func applySizeClass(_ size: UserInterfaceSizeClass?) {
        currentSizeKey = (size == .compact) ? "compact" : "regular"
        lastSizeClassChangeAt = Date()
        let stored = defaults.string(forKey: currentSizeKey)
        let target =
            Self.decode(stored)
            ?? ((currentSizeKey == "compact") ? .automatic : .all)
        suppressPersistence = true
        liveVisibility = target
        suppressPersistence = false
    }

    private func persistGuarded(_ v: NavigationSplitViewVisibility) {
        if suppressPersistence { return }
        if let t = lastSizeClassChangeAt, Date().timeIntervalSince(t) < 0.5 {
            return
        }
        defaults.set(
            Self.encode(v),
            forKey: (currentSizeKey == "compact") ? keyCompact : keyRegular
        )
        print("SplitVM persisted \(v) for \(currentSizeKey)")  // ← debug
    }

    // MARK: - Codec (unchanged)
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
