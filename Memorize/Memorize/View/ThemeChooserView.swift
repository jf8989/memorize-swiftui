//  View/ThemeChooserView.swift

import SwiftUI

/// Root chooser list for themes.
struct ThemeChooserView: View {
    @EnvironmentObject private var store: ThemeStore
    @State private var editingTheme: Theme?

    var body: some View {
        List(store.themes) { theme in
            ThemeRowView(theme: theme)
                .contentShape(Rectangle())
                .onTapGesture { editingTheme = theme }
                .swipeActions {
                    Button("Edit") { editingTheme = theme }
                }
        }
        .navigationTitle("Themes")
        .sheet(item: $editingTheme) { theme in
            ThemeEditorView(theme: theme)
        }
        .task {
            if store.themes.isEmpty {
                store.seedIfEmpty(from: EmojiThemeModel.themes)
            }
        }
    }
}
