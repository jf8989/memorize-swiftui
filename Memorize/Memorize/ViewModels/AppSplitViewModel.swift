//  ViewModel/AppSplitViewModel.swift

import SwiftUI

/// ViewModel for the unified split root.
/// Holds transient UI state (selection/sheets/dialogs) and routes domain intents to ThemeStore.
/// Owns GameVMCache so game state persists across selection changes.
@MainActor
final class AppSplitViewModel: ObservableObject {
    // MARK: - UI State
    @Published var selection: UUID?
    @Published var editingTheme: Theme?
    @Published var pendingDelete: Theme?
    @Published var showDeleteConfirm: Bool = false
    @Published var pendingSelectAfterEdit: UUID?

    // MARK: - Domain Dependencies
    private var store: ThemeStore?
    private(set) var cache = GameVMCache()

    // MARK: - Lifecycle
    /// Injects dependencies once; safe on re-calls.
    func attach(store: ThemeStore) {
        guard self.store !== store else { return }
        self.store = store
        if store.themes.isEmpty {
            store.seedIfEmpty(from: EmojiThemeModel.themes)
        }
    }

    // MARK: - Intents

    /// Adds a new theme, presents the editor, and schedules auto-select when the sheet dismisses.
    func addNewTheme() {
        guard let store else { return }
        let name = NameUniquifier.unique(
            base: "New Theme",
            existing: store.themes.map(\.name)
        )
        let newTheme = Theme(name: name, emojis: [], pairs: 2, rgba: .gray)
        store.upsert(newTheme)
        pendingSelectAfterEdit = newTheme.id
        editingTheme = newTheme
    }

    /// Deletes a specific theme (handles selection/editor/cache cleanup).
    func delete(theme: Theme) {
        guard let store else { return }
        withAnimation {
            if editingTheme?.id == theme.id { editingTheme = nil }
            if selection == theme.id { selection = nil }
            cache.remove(for: theme.id)
            store.delete(id: theme.id)
            pendingDelete = nil
        }
    }

    /// Deletes themes at given list offsets (batch delete).
    func delete(at offsets: IndexSet) {
        guard let store else { return }
        withAnimation {
            let ids = offsets.map { store.themes[$0].id }
            for id in ids {
                if editingTheme?.id == id { editingTheme = nil }
                if selection == id { selection = nil }
                cache.remove(for: id)
                store.delete(id: id)
            }
        }
    }
}
