//  View/Components/ThemeRowView.swift

import SwiftUI

/// Single row in the theme chooser.
struct ThemeRowView: View {
    let theme: Theme

    var body: some View {
        HStack(spacing: 12) {
            // Swatch
            Color(rgba: theme.rgba)
                .frame(width: 28, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.black.opacity(0.10), lineWidth: 1)
                )

            // Title + meta
            VStack(alignment: .leading, spacing: 4) {
                Text(theme.name)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text("Cards: \(theme.pairs * 2)")  // was "Pairs: N"
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(theme.emojis.joined())
                        .font(.title3)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}
