//  View/ThemeDetailPlaceholderView.swift

import SwiftUI

/// Temporary detail screen (navigation target) until the Editor/Game phases land.
struct ThemeDetailPlaceholderView: View {
    // MARK: - Environment
    @EnvironmentObject private var store: ThemeStore

    // MARK: - Input
    let themeID: UUID

    // MARK: - Derived
    private var theme: Theme? {
        store.themes.first { $0.id == themeID }
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            if let theme {
                Text(theme.name)
                    .font(.largeTitle)
                    .bold()

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(rgba: theme.rgba))
                    .frame(height: 44)
                    .overlay(Text("Color").foregroundColor(.white.opacity(0.9)))

                Text("Cards: \(theme.pairs * 2)")
                    .font(.title3)

                Text(theme.emojis.joined())
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .font(.title3)
            } else {
                Text("Theme not found")
            }

            Button("Play (Phase 7+)") {}
                .buttonStyle(.borderedProminent)
                .disabled(true)
        }
        .padding()
        .navigationTitle("Theme")
    }
}
