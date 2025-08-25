//  Engine/ThemeStore.swift

import Foundation

/// UserDefaults-backed Theme store (JSON). Engine-only; no UI types.
@MainActor
final class ThemeStore: ObservableObject, ThemeStoreProtocol {

    // MARK: - Errors

    enum ThemeStoreError: LocalizedError, Equatable {
        case encodeFailed(underlying: String)
        case decodeFailed(underlying: String)
        case persistenceFailed(description: String)

        var errorDescription: String? {
            switch self {
            case .encodeFailed(let u): return "Failed to encode themes. \(u)"
            case .decodeFailed(let u): return "Failed to decode themes. \(u)"
            case .persistenceFailed(let d): return d
            }
        }
    }

    /// Most recent error (nil when clear). Useful for showing a toast/banner in UI.
    @Published private(set) var lastError: ThemeStoreError?

    // MARK: - Singleton

    static let shared = ThemeStore()

    // MARK: - Keys

    private let themesKey = "com.ravn.memorize.themeStore.themes.v1"
    private let seededKey = "com.ravn.memorize.themeStore.seeded.v1"

    // MARK: - Published State

    @Published private(set) var themes: [Theme] = []

    // MARK: - Deps

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.themes = load()
    }

    // MARK: - ThemeStoreProtocol

    @discardableResult
    func refresh() -> [Theme] {
        themes = load()
        return themes
    }

    func replaceAll(with themes: [Theme]) {
        self.themes = themes
        save(themes)
    }

    func upsert(_ theme: Theme) {
        if let idx = themes.firstIndex(where: { $0.id == theme.id }) {
            themes[idx] = theme
        } else {
            themes.append(theme)
        }
        save(themes)
    }

    func delete(id: UUID) {
        themes.removeAll { $0.id == id }
        save(themes)
    }

    func randomTheme() -> Theme? {
        themes.randomElement()
    }

    func seedIfEmpty(from legacy: [EmojiThemeModel]) {
        guard themes.isEmpty, defaults.bool(forKey: seededKey) == false else {
            return
        }
        let seeded = legacy.map { ThemeAdapter.adapt(from: $0) }
        replaceAll(with: seeded)
        defaults.set(true, forKey: seededKey)
    }

    // MARK: - Persistence

    private func load() -> [Theme] {
        clearError()
        guard let data = defaults.data(forKey: themesKey) else { return [] }
        do {
            return try decoder.decode([Theme].self, from: data)
        } catch {
            // Corrupted payload → wipe and report
            defaults.removeObject(forKey: themesKey)
            report(.decodeFailed(underlying: String(describing: error)))
            return []
        }
    }

    private func save(_ themes: [Theme]) {
        clearError()
        do {
            let data = try encoder.encode(themes)
            defaults.set(data, forKey: themesKey)
        } catch {
            report(.encodeFailed(underlying: String(describing: error)))
        }
    }

    // MARK: - Error helpers

    private func clearError() {
        lastError = nil
    }

    private func report(_ err: ThemeStoreError) {
        lastError = err
        #if DEBUG
            print(
                "ThemeStore error:",
                err.errorDescription ?? String(describing: err)
            )
        #endif
    }
}
