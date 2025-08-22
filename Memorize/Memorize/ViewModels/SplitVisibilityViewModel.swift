//  ViewModel/SplitVisibilityViewModel.swift

import SwiftUI

/// Persists NavigationSplitView visibility per size class (compact vs regular).
@MainActor
final class SplitVisibilityViewModel: ObservableObject {
    // Live value bound to the SplitView (do NOT auto‑persist in didSet).
    @Published var liveVisibility: NavigationSplitViewVisibility

    // MARK: - Persistence
    private let defaults: UserDefaults
    private let keyCompact = "ui.splitVisibility.compact"
    private let keyRegular = "ui.splitVisibility.regular"
    private var currentSizeKey: String = "regular"  // tracks active bucket

    // MARK: - Init
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.liveVisibility = .all  // temporary; real value set by applySizeClass(_:)
    }

    // MARK: - Public
    /// Call on appear and whenever horizontal size class changes.
    func applySizeClass(_ size: UserInterfaceSizeClass?) {
        currentSizeKey = (size == .compact) ? "compact" : "regular"
        let stored = defaults.string(forKey: currentSizeKey)
        liveVisibility =
            Self.decode(stored)
            ?? ((currentSizeKey == "compact") ? .automatic : .all)
        // Note: we don't persist here; only user‑driven changes are saved.
    }

    /// Persist current liveVisibility into the active size‑class bucket.
    func persistCurrent() {
        let key = (currentSizeKey == "compact") ? keyCompact : keyRegular
        defaults.set(Self.encode(liveVisibility), forKey: key)
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
