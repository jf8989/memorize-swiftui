//  View/Components/HeaderView.swift

import SwiftUI

/// Title + score/time header.
struct HeaderView: View {
    let isGameStarted: Bool
    let score: Int
    let timeRemaining: Int
    let themeName: String
    let themeColor: Color

    @Environment(\.colorScheme) private var colorScheme

    private var displayColor: Color {
        (themeColor == .black && colorScheme == .dark) ? .white : themeColor
    }

    var body: some View {
        VStack(spacing: 8) {
            if isGameStarted {
                HStack {
                    Text("Score: \(score)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(score >= 0 ? .blue : .red)
                    Spacer()
                    Text("Timer: \(timeRemaining)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(timeRemaining < 10 ? .red : .blue)
                }
            }
            Text(themeName)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(displayColor)
                .shadow(color: .black.opacity(0.20), radius: 4, x: 0, y: 2)
                .padding(.top, 8)
                .padding(.bottom, 6)
                .overlay(
                    Capsule()
                        .frame(height: 4)
                        .foregroundColor(displayColor)
                        .opacity(0.25)
                        .offset(y: 26)
                )
                .animation(
                    .spring(
                        response: 0.45,
                        dampingFraction: 0.55,
                        blendDuration: 0.7
                    ),
                    value: themeName
                )
        }
    }
}
