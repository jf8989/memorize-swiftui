//  View/Root/AppSplitView.swift

import SwiftUI

/// Unified split root for iPhone & iPad.
/// - Sidebar: themes with Edit / Add / Delete.
/// - Detail: game for selected theme.
/// - Sidebar visibility preference is kept per size class and re-applied after width changes.
struct AppSplitView: View {
    // MARK: - Environment
    @EnvironmentObject private var store: ThemeStore
    @Environment(\.horizontalSizeClass) private var hSize

    // MARK: - Split state (live binding)
    @State private var columnVisibility: NavigationSplitViewVisibility =
        .automatic

    // MARK: - UI-only state
    @StateObject private var uiState = AppSplitUIState()

    // MARK: - Cache (preserves game state per theme)
    @StateObject private var cache = GameVMCache()

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ThemeSidebarList(
                selection: $uiState.selection,
                onAddNew: addNewTheme,
                onRequestEdit: { uiState.editingTheme = $0 },
                onRequestDelete: { theme in
                    uiState.pendingDelete = theme
                    uiState.showDeleteConfirm = true
                },
                onDeleteOffsets: delete(at:)
            )
        } detail: {
            GameDetail(
                themes: store.themes,
                selection: uiState.selection,
                cache: cache
            )
        }
        // Persist + re-assert visibility (unchanged behavior).
        .modifier(
            SplitVisibilityPersistence(
                columnVisibility: $columnVisibility,
                sizeClass: hSize
            )
        )

        // Sheet / confirm dialog wired to UI state.
        .sheet(item: $uiState.editingTheme) { ThemeEditorView(theme: $0) }
        .onChange(of: uiState.editingTheme) { _, newValue in
            if newValue == nil, let id = uiState.pendingSelectAfterEdit {
                uiState.selection = id
                uiState.pendingSelectAfterEdit = nil
            }
        }
        .confirmDialog(
            title: "Delete Theme?",
            isPresented: $uiState.showDeleteConfirm,
            presenting: uiState.pendingDelete,
            message: "This will remove the theme and its settings permanently.",
            confirmTitle: { theme in "Delete “\(theme.name)”" },
            confirmRole: .destructive
        ) { theme in
            delete(theme: theme)
        }
        .task {
            if store.themes.isEmpty {
                store.seedIfEmpty(from: EmojiThemeModel.themes)
            }
        }
    }

    // MARK: - Intents

    private func addNewTheme() {
        let name = NameUniquifier.unique(
            base: "New Theme",
            existing: store.themes.map(\.name)
        )
        let newTheme = Theme(name: name, emojis: [], pairs: 2, rgba: .gray)
        store.upsert(newTheme)
        uiState.pendingSelectAfterEdit = newTheme.id
        uiState.editingTheme = newTheme
    }

    private func delete(theme: Theme) {
        withAnimation {
            if uiState.editingTheme?.id == theme.id {
                uiState.editingTheme = nil
            }
            if uiState.selection == theme.id { uiState.selection = nil }
            cache.remove(for: theme.id)
            store.delete(id: theme.id)
            uiState.pendingDelete = nil
        }
    }

    private func delete(at offsets: IndexSet) {
        withAnimation {
            let ids = offsets.map { store.themes[$0].id }
            for id in ids {
                if uiState.editingTheme?.id == id { uiState.editingTheme = nil }
                if uiState.selection == id { uiState.selection = nil }
                cache.remove(for: id)
                store.delete(id: id)
            }
        }
    }
}
