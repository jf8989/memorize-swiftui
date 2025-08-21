//  View/Root/RootNavigator.swift

import SwiftUI
import UIKit

struct RootNavigator: View {
    @EnvironmentObject private var store: ThemeStore
    @StateObject private var cache = GameVMCache()

    // Control initial visibility so the sidebar is shown
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    // Selection + editor
    @State private var selection: UUID?
    @State private var editingTheme: Theme?
    @State private var pendingDelete: Theme?
    @State private var showDeleteConfirm = false

    // Defer selection until editor dismisses (prevents early timer)
    @State private var pendingSelectAfterEdit: UUID?

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            NavigationSplitView(columnVisibility: $columnVisibility) {  // ⬅️ force sidebar visible
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
                    // REMOVED: EditButton() on iPad to avoid detail clearing
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
            .navigationSplitViewStyle(.balanced)  // ⬅️ nicer default sizing
            .sheet(item: $editingTheme) { theme in
                ThemeEditorView(theme: theme)
            }
            .onChange(of: editingTheme) { _, newValue in
                // After editor dismisses, select the newly created theme exactly once
                if newValue == nil, let id = pendingSelectAfterEdit {
                    selection = id
                    pendingSelectAfterEdit = nil
                }
            }
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
                // Optional: keep sidebar shown on first appear
                columnVisibility = .all
            }
        } else {
            // iPhone unchanged: stack + chooser (with EditButton inside ThemeChooserView)
            NavigationStack { ThemeChooserView() }
        }
    }

    // MARK: - iPad intents

    private func addNewTheme() {
        let name = NameUniquifier.unique(
            base: "New Theme",
            existing: store.themes.map(\.name)
        )
        let newTheme = Theme(name: name, emojis: [], pairs: 2, rgba: .gray)
        store.upsert(newTheme)
        pendingSelectAfterEdit = newTheme.id  // ⬅️ select after editor closes
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
