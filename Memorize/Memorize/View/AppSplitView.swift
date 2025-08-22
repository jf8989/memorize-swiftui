//  View/Root/AppSplitView.swift

import SwiftUI

/// Unified split root for iPhone & iPad.
/// - Sidebar: themes with Edit / Add / Delete.
/// - Detail: game for selected theme.
/// - Sidebar visibility preference is kept per size class and re-applied after width changes.
struct AppSplitView: View {
    // MARK: - Environment
    @EnvironmentObject private var store: ThemeStore
    @Environment(\.horizontalSizeClass) private var hSize

    // MARK: - Split state (live binding)
    @State private var columnVisibility: NavigationSplitViewVisibility =
        .automatic

    // MARK: - Per-size-class persistence (scene-scoped)
    @SceneStorage("ui.splitVisibility.compact") private var compactRaw: String?
    @SceneStorage("ui.splitVisibility.regular") private var regularRaw: String?

    // MARK: - Cache / Selection / Editor
    @StateObject private var cache = GameVMCache()
    @State private var selection: UUID?
    @State private var editingTheme: Theme?
    @State private var pendingDelete: Theme?
    @State private var showDeleteConfirm = false
    @State private var pendingSelectAfterEdit: UUID?

    // MARK: - Rotation/resize tracking
    @State private var measuredWidth: CGFloat = 0

    // MARK: - Body
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
        } detail: {
            detail
        }
        // Default style; avoids nudging to show both columns.
        .overlay(widthProbe)

        // Apply preference on first appear & size-class change.
        .task { applyFromStorage() }
        .onChange(of: hSize) { _, _ in applyFromStorage() }

        // Persist only when likely user-driven (outside width-change handling).
        .onChange(of: columnVisibility) { _, newValue in
            persist(newValue, for: hSize)
        }

        // Housekeeping
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

    // MARK: - Sidebar (Theme list with Edit / Add / Delete)
    private var sidebar: some View {
        List(selection: $selection) {
            ForEach(store.themes) { theme in
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
            .onDelete(perform: delete(at:))
        }
        .navigationTitle("Themes")
        .toolbar {
            // Edit on both iPhone & iPad
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
    }

    // MARK: - Detail
    @ViewBuilder private var detail: some View {
        if let id = selection,
            let theme = store.themes.first(where: { $0.id == id })
        {
            MemorizeGameView(viewModel: cache.vm(for: theme))
        } else {
            ContentPlaceholder()
        }
    }

    // MARK: - Width probe (re-apply stored preference after width changes)
    private var widthProbe: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            Color.clear.preference(key: WidthKey.self, value: w)
        }
        .onPreferenceChange(WidthKey.self) { newWidth in
            guard abs(newWidth - measuredWidth) > 0.5 else { return }
            measuredWidth = newWidth
            // Re-assert stored preference on next runloop.
            DispatchQueue.main.async {
                reapplyStoredForCurrentSize()
            }
        }
    }

    private func reapplyStoredForCurrentSize() {
        let target =
            storedVisibility(for: hSize) ?? defaultVisibility(for: hSize)
        if columnVisibility != target { columnVisibility = target }
    }

    // MARK: - Apply / Persist helpers
    private func applyFromStorage() {
        columnVisibility =
            storedVisibility(for: hSize) ?? defaultVisibility(for: hSize)
    }

    private func persist(
        _ v: NavigationSplitViewVisibility,
        for size: UserInterfaceSizeClass?
    ) {
        let key = bucketKey(for: size)
        let raw = encode(v)
        if key == "compact" { compactRaw = raw } else { regularRaw = raw }
    }

    private func storedVisibility(for size: UserInterfaceSizeClass?)
        -> NavigationSplitViewVisibility?
    {
        let raw = (bucketKey(for: size) == "compact") ? compactRaw : regularRaw
        return decode(raw)
    }

    private func bucketKey(for size: UserInterfaceSizeClass?) -> String {
        (size == .compact) ? "compact" : "regular"
    }

    private func defaultVisibility(for size: UserInterfaceSizeClass?)
        -> NavigationSplitViewVisibility
    {
        (size == .compact) ? .automatic : .all
    }

    // MARK: - Codec
    private func encode(_ v: NavigationSplitViewVisibility) -> String {
        switch v {
        case .all: return "all"
        case .detailOnly: return "detailOnly"
        case .doubleColumn: return "doubleColumn"
        default: return "automatic"
        }
    }
    private func decode(_ raw: String?) -> NavigationSplitViewVisibility? {
        switch raw {
        case "all": return .all
        case "detailOnly": return .detailOnly
        case "doubleColumn": return .doubleColumn
        case "automatic": return .automatic
        default: return nil
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

    private func delete(at offsets: IndexSet) {
        withAnimation {
            let ids = offsets.map { store.themes[$0].id }
            for id in ids {
                if editingTheme?.id == id { editingTheme = nil }
                if selection == id { selection = nil }
                cache.remove(for: id)
                store.delete(id: id)
            }
        }
    }
}

// MARK: - Helpers

private struct WidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct ContentPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("Select a Theme")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
