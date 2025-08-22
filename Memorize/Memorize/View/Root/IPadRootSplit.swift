//  View/Root/IPadRootSplit.swift

import SwiftUI

/// Split navigator (used on iPhone & iPad) with per‑size‑class sidebar persistence.
struct IPadRootSplit: View {
    // MARK: - Environment
    @EnvironmentObject private var store: ThemeStore
    @Environment(\.horizontalSizeClass) private var hSize
    // If unused, keep vSize out to avoid warnings.

    // MARK: - Injected Split Visibility VM
    @ObservedObject var splitVM: SplitVisibilityViewModel

    // MARK: - Cache / Selection / Editor
    @StateObject private var cache = GameVMCache()
    @State private var selection: UUID?
    @State private var editingTheme: Theme?
    @State private var pendingDelete: Theme?
    @State private var showDeleteConfirm = false
    @State private var pendingSelectAfterEdit: UUID?

    // MARK: - System write gating
    @State private var isApplyingSizeClass = false

    // MARK: - Filtered binding (blocks system write‑backs during applySizeClass)
    private var filteredVisibility: Binding<NavigationSplitViewVisibility> {
        Binding(
            get: { splitVM.liveVisibility },
            set: { newValue in
                if isApplyingSizeClass { return }  // ignore system flips during apply
                splitVM.liveVisibility = newValue  // user change → accept
            }
        )
    }

    // MARK: - Body
    var body: some View {
        let _ = Self._printChanges()

        Group {
            NavigationSplitView(columnVisibility: filteredVisibility) {
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
                    if hSize == .compact {  // iPhone only
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
        // Lifecycle – set the per‑size‑class value, while gating system write‑backs
        .onAppear {
            isApplyingSizeClass = true
            splitVM.applySizeClass(hSize)
            DispatchQueue.main.async { isApplyingSizeClass = false }
        }
        .onChange(of: hSize) { _, newSize in
            isApplyingSizeClass = true
            splitVM.applySizeClass(newSize)
            DispatchQueue.main.async { isApplyingSizeClass = false }
        }
        // Persist only real user changes (not our own programmatic apply)
        .onChange(of: splitVM.liveVisibility) { oldValue, newValue in
            if !isApplyingSizeClass { splitVM.persistCurrent() }
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
