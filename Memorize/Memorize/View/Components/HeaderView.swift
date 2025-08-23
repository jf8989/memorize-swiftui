//  View/Components/HeaderView.swift

import SwiftUI

/// Title + score/time header.
struct HeaderView: View {
    //MARK: - Input
    let isGameStarted: Bool
    let score: Int
    let timeRemaining: Int
    let themeName: String
    let themeColor: Color
    var onTapTimer: (() -> Void)? = nil
    var difficulty: GameTimeMode? = nil

    //MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme

    //MARK: - Computed
    private var displayColor: Color {
        (themeColor == .black && colorScheme == .dark) ? .white : themeColor
    }

    //MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            if isGameStarted {
                HStack(spacing: 8) {
                    Text("Score: \(score)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(score >= 0 ? .blue : .red)
                    Spacer()
                    HStack(spacing: 6) {
                        Text("Timer: \(timeRemaining)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(timeRemaining < 10 ? .red : .blue)
                            .contentShape(Rectangle())
                            .onTapGesture { onTapTimer?() }
                            .accessibilityAddTraits(.isButton)
                        if let difficulty {
                            DifficultyBadge(mode: difficulty)
                        }
                    }
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

//MARK: - Badge
private struct DifficultyBadge: View {
    let mode: GameTimeMode
    var body: some View {
        let (label, color): (String, Color) = {
            switch mode {
            case .easy: return ("Easy", .green)
            case .medium: return ("Med", .orange)
            case .hard: return ("Hard", .red)
            }
        }()
        Text(label)
            .font(.caption2).bold()
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundStyle(color)
            .background(Capsule().fill(color.opacity(0.12)))
            .overlay(Capsule().stroke(color.opacity(0.6), lineWidth: 1))
    }
}
