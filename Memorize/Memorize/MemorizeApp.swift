//  App/MemorizeApp.swift

import SwiftUI

@main
struct MemorizeApp: App {
    // MARK: - Store Host
    @StateObject private var themeStore = ThemeStore.shared

    // MARK: - Scene
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ThemeChooserView()
            }
            .environmentObject(themeStore)
        }
    }
}
