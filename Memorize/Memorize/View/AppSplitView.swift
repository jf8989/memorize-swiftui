//  View/Root/AppSplitView.swift

import SwiftUI

/// Unified split root for iPhone & iPad.
/// - Sidebar is the theme list (with Edit, Add, Delete).
/// - Detail shows the game for the selected theme.
/// - Sidebar visibility preference is kept per size class (compact vs regular),
///   and re-applied after rotations/resizes so the system doesn't override it.
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
    @State private var lastWidthChangeAt: Date? = nil

    // MARK: - Body
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
        } detail: {
            detail
        }
        // Keep default style (dropping `.balanced` reduces "force show both columns" bias)
        .overlay(widthProbe)

        // Apply preference on first appear & size-class changes
        .task { applyFromStorage(reason: "onAppear") }
        .onChange(of: hSize) { _, _ in
            applyFromStorage(reason: "sizeClass change")
        }

        // Persist only when outside the rotation/resize window (likely a user gesture)
        .onChange(of: columnVisibility) { _, newValue in
            guard !isWithinWidthWindow else { return }
            persist(newValue, for: hSize)
        }

        // Housekeeping (same UX you had before)
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
        .onDelete(perform: delete(at:))  // ← brings back chooser’s delete behavior
        .navigationTitle("Themes")
        .toolbar {
            // ← Edit button on BOTH iPhone and iPad (same placement as chooser)
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

    // MARK: - Rotation / resize handling
    private var isWithinWidthWindow: Bool {
        if let t = lastWidthChangeAt {
            return Date().timeIntervalSince(t) < 0.40
        }
        return false
    }

    private var widthProbe: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            Color.clear.preference(key: WidthKey.self, value: w)
        }
        .onPreferenceChange(WidthKey.self) { newWidth in
            guard abs(newWidth - measuredWidth) > 0.5 else { return }
            measuredWidth = newWidth
            lastWidthChangeAt = Date()
            // Re-assert stored preference after the system finishes its own flip.
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
    private func applyFromStorage(reason: String) {
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

    // MARK: - Intents (copied behavior from chooser + iPad specifics)
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
