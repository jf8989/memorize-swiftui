//  View/ThemeChooserView.swift

import SwiftUI

/// Root chooser list for themes.
struct ThemeChooserView: View {
    // MARK: - Environment
    @EnvironmentObject private var store: ThemeStore

    // MARK: - Body
    var body: some View {
        List(store.themes) { theme in
            NavigationLink(value: theme.id) {
                ThemeRowView(theme: theme)
            }
        }
        .navigationTitle("Themes")
        .navigationDestination(for: UUID.self) { themeID in
            ThemeDetailPlaceholderView(themeID: themeID)
        }
        .task {
            /// One-time seed on first run if empty (idempotent).
            if store.themes.isEmpty {
                store.seedIfEmpty(from: EmojiThemeModel.themes)
            }
        }
    }
}
