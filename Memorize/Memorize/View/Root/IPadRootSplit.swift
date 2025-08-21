//  View/Root/IPadRootSplit.swift

import SwiftUI

/// Split navigator with persisted sidebar visibility, edit/delete, and VM caching.
struct IPadRootSplit: View {
    @EnvironmentObject private var store: ThemeStore

    @Environment(\.horizontalSizeClass) private var hSize
    // @Environment(\.verticalSizeClass) private var vSize   // ← remove if unused

    // MARK: - Injected split VM (no @StateObject here)
    @ObservedObject var splitVM: SplitVisibilityViewModel  // ← injected

    // MARK: - Cache / Selection / Editor
    @StateObject private var cache = GameVMCache()
    @State private var selection: UUID?
    @State private var editingTheme: Theme?
    @State private var pendingDelete: Theme?
    @State private var showDeleteConfirm = false
    @State private var pendingSelectAfterEdit: UUID?

    var body: some View {
        let _ = Self._printChanges()

        Group {
            NavigationSplitView(columnVisibility: $splitVM.liveVisibility) {
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
                    if hSize == .compact {
                        ToolbarItem(placement: .cancellationAction) {
                            EditButton()
                        }
                    }
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
            .sheet(item: $editingTheme) { ThemeEditorView(theme: $0) }
            .onChange(of: editingTheme) { oldValue, newValue in
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
                confirmTitle: { "Delete “\($0.name)”" },
                confirmRole: .destructive
            ) { delete(theme: $0) }
            .task {
                if store.themes.isEmpty {
                    store.seedIfEmpty(from: EmojiThemeModel.themes)
                }
            }
        }
        .onAppear { splitVM.applySizeClass(hSize) }
        .onChange(of: hSize) { oldSize, newSize in
            splitVM.applySizeClass(newSize)
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
