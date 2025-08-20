//  Engine/ThemeStoreProtocol.swift

import Foundation

/// Protocol-first store for Themes (Codable, UI-free).
protocol ThemeStoreProtocol: AnyObject {
    var themes: [Theme] { get }
    /// Reloads from persistence and returns the fresh list.
    @discardableResult
    func refresh() -> [Theme]
    /// Replaces all themes and persists.
    func replaceAll(with themes: [Theme])
    /// Inserts or updates a theme by id and persists.
    func upsert(_ theme: Theme)
    /// Deletes by id and persists.
    func delete(id: UUID)
    /// Returns a random theme, or nil if empty.
    func randomTheme() -> Theme?
    /// Seeds from legacy themes if store is empty (idempotent).
    func seedIfEmpty(from legacy: [EmojiThemeModel])
}
