//  ViewModel/GameVMCache.swift

import Foundation

/// Simple per-theme cache so detail preserves game state when switching themes.
@MainActor
final class GameVMCache: ObservableObject {
    private var storage: [UUID: MemorizeGameViewModel] = [:]

    /// Provide the current mode at call time so fresh VMs use the chosen difficulty.
    func vm(for theme: Theme, timeMode: GameTimeMode) -> MemorizeGameViewModel {
        if let existing = storage[theme.id] { return existing }
        let fresh = MemorizeGameViewModel(theme: theme, timeMode: timeMode)
        storage[theme.id] = fresh
        return fresh
    }

    func remove(for id: UUID) {
        storage[id] = nil
    }
}
