//  View/Support/GameVMCache.swift

import Foundation

@MainActor
final class GameVMCache: ObservableObject {
    private var cache: [UUID: MemorizeGameViewModel] = [:]

    func vm(for theme: Theme) -> MemorizeGameViewModel {
        if let vm = cache[theme.id] { return vm }
        let vm = MemorizeGameViewModel(theme: theme)
        cache[theme.id] = vm
        return vm
    }

    func remove(for id: UUID) {
        cache[id] = nil
    }
}
