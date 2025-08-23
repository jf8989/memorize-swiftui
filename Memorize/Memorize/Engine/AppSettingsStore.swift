//  Engine/AppSettingsStore.swift

import Foundation

/// Global, app-wide settings (UserDefaults-backed).
@MainActor
final class AppSettingsStore: ObservableObject {
    static let shared = AppSettingsStore()

    /// Persistent difficulty mode used by newly created games.
    @Published var timeMode: GameTimeMode {
        didSet { defaults.set(timeMode.rawValue, forKey: modeKey) }
    }

    // MARK: - Private
    private let defaults: UserDefaults
    private let modeKey = "com.ravn.memorize.settings.timeMode.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let raw = defaults.string(forKey: modeKey),
            let mode = GameTimeMode(rawValue: raw)
        {
            self.timeMode = mode
        } else {
            self.timeMode = .medium
        }
    }
}
