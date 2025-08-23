//  MemorizeApp.swift

import SwiftUI

@main
struct MemorizeApp: App {
    // MARK: - Stores
    @StateObject private var store = ThemeStore()
    @StateObject private var settings = AppSettingsStore.shared

    // MARK: - Launch SFX gate
    @Environment(\.scenePhase) private var scenePhase
    @State private var didPlayLaunchSfx = false

    var body: some Scene {
        WindowGroup {
            AppSplitView()
                .environmentObject(store)
                .environmentObject(settings)
        }
        .onChange(of: scenePhase) { _, phase in
            // Play exactly once when app first becomes active
            if phase == .active && !didPlayLaunchSfx {
                SoundEffects.shared.play(.launch)
                didPlayLaunchSfx = true
            }
        }
    }
}
