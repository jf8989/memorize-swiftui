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

    // MARK: - ViewModel (UI + intents) and cache owner
    @StateObject private var viewModel = AppSplitViewModel()

    // MARK: - Body
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ThemeSidebarList(
                themes: store.themes,
                selection: $viewModel.selection,
                onAddNew: { viewModel.addNewTheme() },
                onRequestEdit: { viewModel.editingTheme = $0 },
                onRequestDelete: {
                    viewModel.pendingDelete = $0
                    viewModel.showDeleteConfirm = true
                },
                onDeleteOffsets: { viewModel.delete(at: $0) }
            )
        } detail: {
            GameHostView(
                themes: store.themes,
                selection: viewModel.selection,
                isSidebarVisible: sidebarIsOpen(columnVisibility, hSize: hSize),
                onToggleSidebar: { toggleSidebar() },
                cache: viewModel.cache
            )
        }
        // Persist + re-assert visibility (unchanged behavior).
        .modifier(
            SplitVisibilityPersistence(
                columnVisibility: $columnVisibility,
                sizeClass: hSize
            )
        )

        // Sheet / confirm dialog wired to VM state.
        .sheet(item: $viewModel.editingTheme) { ThemeEditorView(theme: $0) }
        .onChange(of: viewModel.editingTheme) { _, newValue in
            if newValue == nil, let id = viewModel.pendingSelectAfterEdit {
                viewModel.selection = id
                viewModel.pendingSelectAfterEdit = nil
            }
        }
        .confirmDialog(
            title: "Delete Theme?",
            isPresented: $viewModel.showDeleteConfirm,
            presenting: viewModel.pendingDelete,
            message: "This will remove the theme and its settings permanently.",
            confirmTitle: { theme in "Delete “\(theme.name)”" },
            confirmRole: .destructive
        ) { theme in
            viewModel.delete(theme: theme)
        }
        .task {
            viewModel.attach(store: store)  // inject ThemeStore once
        }
    }

    // MARK: - Helpers
    /// Sidebar is considered open on regular width when not in .detailOnly.
    private func sidebarIsOpen(
        _ v: NavigationSplitViewVisibility,
        hSize: UserInterfaceSizeClass?
    ) -> Bool {
        guard hSize == .regular else { return false }
        return v != .detailOnly
    }

    /// Toggle open/close for the sidebar on iPad-style width.
    private func toggleSidebar() {
        guard hSize == .regular else { return }  // no-op on iPhone (no persistent sidebar)
        switch columnVisibility {
        case .detailOnly: columnVisibility = .all
        case .all: columnVisibility = .detailOnly
        case .doubleColumn: columnVisibility = .detailOnly
        default: columnVisibility = .all
        }
    }
}
