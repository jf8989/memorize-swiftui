//  View/Components/GameHostView.swift

import SwiftUI

/// Resolves the selected theme and shows the game or a placeholder.
/// Uses a shared cache so switching themes preserves game state.
struct GameHostView: View {
    // MARK: - Input
    let themes: [Theme]
    let selection: UUID?
    let isSidebarVisible: Bool
    let onToggleSidebar: () -> Void

    // MARK: - Dependencies
    @ObservedObject var cache: GameVMCache
    @EnvironmentObject private var settings: AppSettingsStore

    // MARK: - Body
    var body: some View {
        if let id = selection,
            let theme = themes.first(where: { $0.id == id })
        {
            let vm = cache.reconfigure(for: theme, timeMode: settings.timeMode)

            MemorizeGameView(viewModel: vm)
                // iOS 17+: use two-parameter onChange
                .onChange(of: theme) { _, newTheme in
                    _ = cache.reconfigure(
                        for: newTheme,
                        timeMode: settings.timeMode
                    )
                }
                .onChange(of: settings.timeMode) { _, newMode in
                    vm.applyTimeMode(newMode)
                }

        } else {
            GameInstructionsView(
                difficulty: settings.timeMode,
                isSidebarVisible: isSidebarVisible,
                onToggleSidebar: onToggleSidebar,
                style: .image("MemorizeBG")
            )
        }
    }
}
