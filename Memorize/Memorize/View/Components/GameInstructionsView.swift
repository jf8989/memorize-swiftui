//  View/Components/GameInstructionsPlaceholder.swift

import SwiftUI

/// Friendly landing screen with rules and a sidebar-open button.
struct GameInstructionsView: View {
    // MARK: - Inputs
    let difficulty: GameTimeMode
    let onOpenSidebar: () -> Void

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Icon
                Image(systemName: "rectangle.on.rectangle.angled")
                    .font(.system(size: 64, weight: .regular))
                    .foregroundStyle(.secondary)

                // Title
                Text("Welcome to Memorize")
                    .font(.system(.largeTitle, design: .rounded).weight(.bold))
                    .multilineTextAlignment(.center)

                // Subtitle / current difficulty
                Text("Current difficulty: \(label(for: difficulty))")
                    .font(.title3)
                    .foregroundStyle(color(for: difficulty))

                // Card-like instructions (readable on iPad)
                VStack(alignment: .leading, spacing: 12) {
                    RuleRow(text: "Pick a theme from the sidebar to start.")
                    RuleRow(text: "Flip two cards. A match stays face up.")
                    RuleRow(text: penaltyText(for: difficulty))
                    RuleRow(text: "Clear all pairs before time runs out.")
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                // Open sidebar button
                Button(action: onOpenSidebar) {
                    Label("Choose a Theme", systemImage: "sidebar.leading")
                        .font(.headline)
                        .padding(.vertical, 14)
                        .frame(maxWidth: 420)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .padding(.horizontal, 24)
            }
            .frame(maxWidth: 720)  // keeps line length comfy on iPad
            .padding(.vertical, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Helpers
    private func label(for mode: GameTimeMode) -> String {
        switch mode {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    private func color(for mode: GameTimeMode) -> Color {
        switch mode {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    private func penaltyText(for mode: GameTimeMode) -> String {
        switch mode {
        case .easy: return "Mismatch penalty: −1s; generous base time."
        case .medium: return "Mismatch penalty: −3s; balanced base time."
        case .hard: return "Mismatch penalty: −5s; tighter base time."
        }
    }
}

// MARK: - Components

private struct RuleRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.secondary)
            Text(text)
                .font(.title3)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}
