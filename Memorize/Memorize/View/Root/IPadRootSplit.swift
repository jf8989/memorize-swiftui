//  View/Root/IPadRootSplit.swift

import SwiftUI

/// iPad split navigator with persisted sidebar visibility, edit/delete, and VM caching.
struct IPadRootSplit: View {
    // MARK: - Environment
    @EnvironmentObject private var store: ThemeStore

    // MARK: - Split Visibility (persisted)
    @StateObject private var splitVM = SplitVisibilityViewModel()
    private var columnVisibilityBinding: Binding<NavigationSplitViewVisibility>
    {
        Binding(
            get: { splitVM.visibility },
            set: { splitVM.set($0) }
        )
    }

    // MARK: - Cache / Selection / Editor
    @StateObject private var cache = GameVMCache()
    @State private var selection: UUID?
    @State private var editingTheme: Theme?
    @State private var pendingDelete: Theme?
    @State private var showDeleteConfirm = false
    @State private var pendingSelectAfterEdit: UUID?

    var body: some View {
        NavigationSplitView(columnVisibility: columnVisibilityBinding) {
            List(store.themes, selection: $selection) { theme in
                ThemeRowView(theme: theme)
                    .tag(theme.id)
                    .swipeActions(edge: .leading) {
                        Button("Edit") { editingTheme = theme }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            pendingDelete = theme
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .navigationTitle("Themes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        addNewTheme()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Theme")
                }
            }
        } detail: {
            if let id = selection,
                let theme = store.themes.first(where: { $0.id == id })
            {
                MemorizeGameView(viewModel: cache.vm(for: theme))
            } else {
                ContentPlaceholder()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(item: $editingTheme) { theme in
            ThemeEditorView(theme: theme)
        }
        .onChange(of: editingTheme) { _, newValue in
            // After the editor dismisses, auto-select the newly created theme once (prevents early timer).
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
}

// MARK: - Placeholder (iPad detail)

private struct ContentPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 44, weight: .regular))
                .foregroundStyle(.secondary)
            Text("Select a Theme")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
