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
    @StateObject private var vm = AppSplitViewModel()

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ThemeSidebarList(
                themes: store.themes,
                selection: $vm.selection,
                onAddNew: { vm.addNewTheme() },
                onRequestEdit: { vm.editingTheme = $0 },
                onRequestDelete: {
                    vm.pendingDelete = $0
                    vm.showDeleteConfirm = true
                },
                onDeleteOffsets: { vm.delete(at: $0) }
            )
        } detail: {
            GameDetail(
                themes: store.themes,
                selection: vm.selection,
                cache: vm.cache
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
        .sheet(item: $vm.editingTheme) { ThemeEditorView(theme: $0) }
        .onChange(of: vm.editingTheme) { _, newValue in
            if newValue == nil, let id = vm.pendingSelectAfterEdit {
                vm.selection = id
                vm.pendingSelectAfterEdit = nil
            }
        }
        .confirmDialog(
            title: "Delete Theme?",
            isPresented: $vm.showDeleteConfirm,
            presenting: vm.pendingDelete,
            message: "This will remove the theme and its settings permanently.",
            confirmTitle: { theme in "Delete “\(theme.name)”" },
            confirmRole: .destructive
        ) { theme in
            vm.delete(theme: theme)
        }
        .task {
            vm.attach(store: store)  // inject ThemeStore once
        }
    }
}
