//  MemorizeApp.swift

import SwiftUI

@main
struct MemorizeApp: App {
    //MARK: - Stores
    @StateObject private var store = ThemeStore()
    @StateObject private var settings = AppSettingsStore.shared

    //MARK: - Body
    var body: some Scene {
        WindowGroup {
            AppSplitView()
                .environmentObject(store)
                .environmentObject(settings)
        }
    }
}
