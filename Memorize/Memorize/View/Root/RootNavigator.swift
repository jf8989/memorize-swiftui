//  View/Root/MemorizeRootView.swift

import SwiftUI

struct MemorizeRootView: View {
    @Environment(\.horizontalSizeClass) private var hSize
    @EnvironmentObject private var store: ThemeStore
    @State private var selectedID: UUID?
    private let cache = GameVMCache.shared

    var body: some View {
        if hSize == .regular {
            // iPad: Sidebar → Detail
            NavigationSplitView {
                List(selection: $selectedID) {
                    ForEach(store.themes) { theme in
                        TextRow(theme)  // compact row; reuse your ThemeRowView if you prefer
                            .tag(theme.id)
                            .swipeActions(edge: .leading) {
                                Button("Edit") { editingTheme = theme }
                            }
                            .swipeActions {
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
                    }
                }
            } detail: {
                if let id = selectedID,
                    let theme = store.themes.first(where: { $0.id == id })
                {
                    MemorizeGameView(viewModel: cache.vm(for: theme))
                } else {
                    ContentUnavailableView(
                        "Pick a Theme",
                        systemImage: "square.grid.2x2"
                    )
                }
            }
            // Shared modals/confirm (so we don’t duplicate logic)
            .sheet(item: $editingTheme) { ThemeEditorView(theme: $0) }
            .confirmDialog(
                title: "Delete Theme?",
                isPresented: $showDeleteConfirm,
                presenting: pendingDelete,
                message: "This cannot be undone.",
                confirmTitle: { "Delete “\($0.name)”" },
                confirmRole: .destructive
            ) { theme in delete(theme: theme) }
            .task {
                if store.themes.isEmpty {
                    store.seedIfEmpty(from: EmojiThemeModel.themes)
                }
            }
        } else {
            // iPhone: original chooser-in-stack
            NavigationStack { ThemeChooserView() }
        }
    }

    // MARK: - Local UI state (iPad only)
    @State private var editingTheme: Theme?
    @State private var pendingDelete: Theme?
    @State private var showDeleteConfirm = false

    // MARK: - Helpers
    private func addNewTheme() {
        let name = NameUniquifier.unique(
            base: "New Theme",
            existing: store.themes.map(\.name)
        )
        let newTheme = Theme(name: name, emojis: [], pairs: 2, rgba: .gray)
        store.upsert(newTheme)
        editingTheme = newTheme
        selectedID = newTheme.id
    }

    private func delete(theme: Theme) {
        withAnimation {
            GameVMCache.shared.remove(id: theme.id)
            store.delete(id: theme.id)
            if selectedID == theme.id { selectedID = nil }
            pendingDelete = nil
        }
    }

    private func delete(at offsets: IndexSet) {
        withAnimation {
            for id in offsets.map({ store.themes[$0].id }) {
                GameVMCache.shared.remove(id: id)
                if selectedID == id { selectedID = nil }
                store.delete(id: id)
            }
        }
    }

    // Tiny inline row to keep split view tidy
    @ViewBuilder private func TextRow(_ theme: Theme) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(rgba: theme.rgba))
                .frame(width: 14, height: 14)
                .accessibilityLabel("Theme color")
            Text(theme.name).lineLimit(1)
            Spacer()
            Text("Cards: \(theme.pairs * 2)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}
