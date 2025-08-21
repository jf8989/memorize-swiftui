//  ViewModel/GameVMCache.swift

import Foundation

/// Simple per-theme cache so iPad detail preserves game state when switching themes.
@MainActor
final class GameVMCache: ObservableObject {
    private var storage: [UUID: MemorizeGameViewModel] = [:]

    func vm(for theme: Theme) -> MemorizeGameViewModel {
        if let existing = storage[theme.id] { return existing }
        let fresh = MemorizeGameViewModel(theme: theme)
        storage[theme.id] = fresh
        return fresh
    }

    func remove(for id: UUID) {
        storage[id] = nil
    }
}
