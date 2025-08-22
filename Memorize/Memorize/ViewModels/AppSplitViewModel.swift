//  ViewModel/AppSplitUIStateViewModel.swift

import SwiftUI

/// UI-only state for AppSplitView (transient; no domain logic).
@MainActor
final class AppSplitUIStateViewModel: ObservableObject {
    // MARK: - Selection
    @Published var selection: UUID?

    // MARK: - Edit sheet
    @Published var editingTheme: Theme?

    // MARK: - Delete confirmation
    @Published var pendingDelete: Theme?
    @Published var showDeleteConfirm: Bool = false

    // MARK: - Post-create auto-select
    @Published var pendingSelectAfterEdit: UUID?
}
