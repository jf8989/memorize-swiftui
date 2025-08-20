//  Engine/ThemeStore.swift

import Foundation

/// UserDefaults-backed Theme store (JSON). Engine-only; no UI types.
@MainActor
final class ThemeStore: ObservableObject, ThemeStoreProtocol {

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
        let seeded = legacy.map { ThemeAdapter.adapt(from: $0).theme }
        replaceAll(with: seeded)
        defaults.set(true, forKey: seededKey)
    }

    // MARK: - Persistence

    private func load() -> [Theme] {
        guard let data = defaults.data(forKey: themesKey) else { return [] }
        do {
            return try decoder.decode([Theme].self, from: data)
        } catch {
            defaults.removeObject(forKey: themesKey)
            return []
        }
    }

    private func save(_ themes: [Theme]) {
        do {
            let data = try encoder.encode(themes)
            defaults.set(data, forKey: themesKey)
        } catch {
            // Silent for now; errors will be surfaced by editor UI later.
        }
    }
}
