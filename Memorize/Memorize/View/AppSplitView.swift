//  View/Root/AppSplitView.swift

import SwiftUI

/// Unified split root for iPhone & iPad.
/// Delegates:
/// - Sidebar UI to `ThemeSidebarList`
/// - Detail UI to `GameDetail`
/// - Visibility persistence to `SplitVisibilityPersistence` modifier
struct AppSplitView: View {
    // MARK: - Environment
    @EnvironmentObject private var store: ThemeStore
    @Environment(\.horizontalSizeClass) private var hSize

    // MARK: - Split state
    @State private var columnVisibility: NavigationSplitViewVisibility =
        .automatic

    // MARK: - Cache / Selection / Editor
    @StateObject private var cache = GameVMCache()
    @State private var selection: UUID?
    @State private var editingTheme: Theme?
    @State private var pendingDelete: Theme?
    @State private var showDeleteConfirm = false
    @State private var pendingSelectAfterEdit: UUID?

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ThemeSidebarList(
                selection: $selection,
                onAddNew: addNewTheme,
                onRequestEdit: { editingTheme = $0 },
                onRequestDelete: { theme in
                    pendingDelete = theme
                    showDeleteConfirm = true
                },
                onDeleteOffsets: delete(at:)
            )
        } detail: {
            GameDetail(
                themes: store.themes,
                selection: selection,
                cache: cache
            )
        }
        // Persist + re-assert visibility without logs, same behavior as before.
        .modifier(
            SplitVisibilityPersistence(
                columnVisibility: $columnVisibility,
                sizeClass: hSize
            )
        )

        // Sheet and confirm dialog remain here to keep state centralized.
        .sheet(item: $editingTheme) { ThemeEditorView(theme: $0) }
        .onChange(of: editingTheme) { _, newValue in
            if newValue == nil, let id = pendingSelectAfterEdit {
                selection = id
                pendingSelectAfterEdit = nil
            }
        }
        .confirmDialog(
            title: "Delete Theme?",
            isPresented: $showDeleteConfirm,
            presenting: pendingDelete,
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
        pendingSelectAfterEdit = newTheme.id
        editingTheme = newTheme
    }

    private func delete(theme: Theme) {
        withAnimation {
            if editingTheme?.id == theme.id { editingTheme = nil }
            if selection == theme.id { selection = nil }
            cache.remove(for: theme.id)
            store.delete(id: theme.id)
            pendingDelete = nil
        }
    }

    private func delete(at offsets: IndexSet) {
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
