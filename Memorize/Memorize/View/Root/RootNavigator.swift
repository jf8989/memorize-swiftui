//  View/Root/RootNavigator.swift

import SwiftUI

/// Top-level navigator.
/// - iPhone: NavigationStack with the chooser
/// - iPad:   Split view hosted in a separate, modular file
struct RootNavigator: View {
    @EnvironmentObject private var store: ThemeStore

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            IPadRootSplit()
                .environmentObject(store)
        } else {
            NavigationStack { ThemeChooserView() }
        }
    }
}
