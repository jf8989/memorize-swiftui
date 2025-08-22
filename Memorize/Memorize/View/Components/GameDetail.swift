//  View/Components/GameDetail.swift

import SwiftUI

/// Resolves the selected theme and shows the game or a placeholder.
/// Uses a shared cache so switching themes preserves game state.
struct GameDetail: View {
    let themes: [Theme]
    let selection: UUID?
    @ObservedObject var cache: GameVMCache

    var body: some View {
        if let id = selection, let theme = themes.first(where: { $0.id == id })
        {
            MemorizeGameView(viewModel: cache.vm(for: theme))
        } else {
            ContentPlaceholder()
        }
    }
}

// MARK: - Placeholder

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
