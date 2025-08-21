//  View/Root/RootNavigator.swift

import SwiftUI
import UIKit

struct RootNavigator: View {
    @EnvironmentObject private var store: ThemeStore
    @StateObject private var cache = GameVMCache()  // optional caching (Phase 10)
    @State private var selection: UUID?  // iPad sidebar selection

    // Shared edit/delete state (reused in iPad)
    @State private var editingTheme: Theme?
    @State private var pendingDelete: Theme?
    @State private var showDeleteConfirm = false
    @State private var pendingSelectAfterEdit: UUID?

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad: NavigationSplitView (no nested stacks in columns)
            NavigationSplitView {
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
                    ToolbarItem(placement: .cancellationAction) { EditButton() }
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
                    MemorizeGameView(viewModel: cache.vm(for: theme))  // cached VM per theme
                } else {
                    ContentPlaceholder()
                }
            }
            // Sheet editor (modal over split)
            .sheet(item: $editingTheme) { theme in
                ThemeEditorView(theme: theme)
            }
            .onChange(of: editingTheme) { _, newValue in
                // when the editor is dismissed, select the newly created theme (once)
                if newValue == nil, let id = pendingSelectAfterEdit {
                    selection = id
                    pendingSelectAfterEdit = nil
                }
            }
            // Platform-aware confirm (alert on iPad)
            .confirmDialog(
                title: "Delete Theme?",
                isPresented: $showDeleteConfirm,
                presenting: pendingDelete,
                message:
                    "This will remove the theme and its settings permanently.",
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
        } else {
            // iPhone: keep your existing stack + chooser untouched
            NavigationStack {
                ThemeChooserView()
            }
        }
    }

    // MARK: - iPad intents

    private func addNewTheme() {
        let existingNames = store.themes.map(\.name)
        let name = NameUniquifier.unique(
            base: "New Theme",
            existing: existingNames
        )
        let newTheme = Theme(name: name, emojis: [], pairs: 2, rgba: .gray)
        store.upsert(newTheme)
        editingTheme = newTheme
        pendingSelectAfterEdit = newTheme.id
        editingTheme = newTheme  // keep opening the editor as before
    }

    private func delete(theme: Theme) {
        withAnimation {
            if editingTheme?.id == theme.id { editingTheme = nil }
            if selection == theme.id { selection = nil }
            cache.remove(for: theme.id)  // drop cached VM if present
            store.delete(id: theme.id)
            pendingDelete = nil
        }
    }
}

// MARK: - Slim placeholder for right column
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
    }
}
