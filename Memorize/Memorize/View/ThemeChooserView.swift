//  View/ThemeChooserView.swift

import SwiftUI

/// Root chooser list for themes with Add/Delete and stable-ID navigation.
struct ThemeChooserView: View {
    // MARK: - Environment
    @EnvironmentObject private var store: ThemeStore

    // MARK: - UI State
    @State private var editingTheme: Theme?
    @State private var pendingDelete: Theme?
    @State private var showDeleteConfirm: Bool = false

    // MARK: - Body
    var body: some View {
        List {
            ForEach(store.themes) { theme in
                NavigationLink(value: theme.id) {
                    ThemeRowView(theme: theme)
                }
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
            .onDelete(perform: delete)
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
        .sheet(item: $editingTheme) { theme in
            ThemeEditorView(theme: theme)
        }
        // Destination: resolve by ID → instantiate VM(theme:) → push game view.
        .navigationDestination(for: UUID.self) { themeID in
            if let theme = store.themes.first(where: { $0.id == themeID }) {
                MemorizeGameView(viewModel: MemorizeGameViewModel(theme: theme))
            } else {
                // Fallback if a theme was deleted while navigating.
                Text("Theme not found").foregroundStyle(.secondary)
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

    // MARK: - Intent

    private func addNewTheme() {
        let existingNames = store.themes.map(\.name)
        let name = NameUniquifier.unique(
            base: "New Theme",
            existing: existingNames
        )
        let newTheme = Theme(name: name, emojis: [], pairs: 2, rgba: .gray)
        store.upsert(newTheme)
        editingTheme = newTheme
    }

    private func delete(theme: Theme) {
        withAnimation {
            if editingTheme?.id == theme.id { editingTheme = nil }
            store.delete(id: theme.id)
            pendingDelete = nil
        }
    }

    private func delete(at offsets: IndexSet) {
        withAnimation {
            let ids = offsets.map { store.themes[$0].id }
            for id in ids {
                if editingTheme?.id == id { editingTheme = nil }
                store.delete(id: id)
            }
        }
    }
}
