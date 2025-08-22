//  View/Root/RootNavigator.swift

import SwiftUI

/// Top-level navigator: single SplitView for all devices.
struct RootNavigator: View {
    @EnvironmentObject private var store: ThemeStore
    @StateObject private var splitVM = SplitVisibilityViewModel()

    var body: some View {
        let _ = Self._printChanges()
        IPadRootSplit(splitVM: splitVM)
            .environmentObject(store)
    }
}
