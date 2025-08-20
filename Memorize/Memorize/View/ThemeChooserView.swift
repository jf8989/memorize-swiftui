//  View/ThemeChooserView.swift

import SwiftUI

/// Root chooser list for themes with Add/Delete flows.
struct ThemeChooserView: View {
    // MARK: - Environment
    @EnvironmentObject private var store: ThemeStore

    // MARK: - UI State
    @State private var editingTheme: Theme?

    // MARK: - Body
    var body: some View {
        List {
            ForEach(store.themes) { theme in
                ThemeRowView(theme: theme)
                    .contentShape(Rectangle())
                    .onTapGesture { editingTheme = theme }  // Auto-open editor on tap
            }
            .onDelete(perform: delete)
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
        .sheet(item: $editingTheme) { theme in
            ThemeEditorView(theme: theme)
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
        editingTheme = newTheme  // Auto-open editor
    }

    private func delete(at offsets: IndexSet) {
        withAnimation {
            let ids = offsets.map { store.themes[$0].id }
            for id in ids {
                if editingTheme?.id == id { editingTheme = nil }  // Dismiss sheet if deleting edited theme
                store.delete(id: id)
            }
        }
    }
}
