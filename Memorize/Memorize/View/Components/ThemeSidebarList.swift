//  View/Components/ThemeSidebarList.swift

import SwiftUI

/// Sidebar list with Edit / Add / Delete and swipe actions.
/// Data is passed in (no EnvironmentObject) to keep it reusable and testable.
struct ThemeSidebarList: View {
    // MARK: - Inputs
    let themes: [Theme]
    @Binding var selection: UUID?
    let onAddNew: () -> Void
    let onRequestEdit: (Theme) -> Void
    let onRequestDelete: (Theme) -> Void
    let onDeleteOffsets: (IndexSet) -> Void

    var body: some View {
        List(selection: $selection) {
            ForEach(themes) { theme in
                ThemeRowView(theme: theme)
                    .tag(theme.id)
                    .swipeActions(edge: .leading) {
                        Button("Edit") { onRequestEdit(theme) }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            onRequestDelete(theme)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            .onDelete(perform: onDeleteOffsets)
        }
        .navigationTitle("Themes")
        .toolbar {
            // Edit on both iPhone & iPad
            ToolbarItem(placement: .cancellationAction) { EditButton() }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    onAddNew()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Theme")
            }
        }
    }
}
