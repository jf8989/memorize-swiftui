//  MemorizeApp.swift

import SwiftUI

@main
struct MemorizeApp: App {
    @StateObject private var store = ThemeStore()
    @StateObject private var settings = AppSettingsStore.shared

    var body: some Scene {
        WindowGroup {
            AppSplitView()
                .environmentObject(store)
                .environmentObject(settings)
                .task {
                    #if DEBUG
                        SoundEffects.shared.debugInventory()
                    #endif
                }
        }
    }
}
