//  View/Components/GameInstructionsView.swift

import SwiftUI

/// Polished landing screen with rules, difficulty explainer, and a sidebar toggle.
struct GameInstructionsView: View {
    // MARK: - Inputs
    let difficulty: GameTimeMode
    let isSidebarVisible: Bool
    let onToggleSidebar: () -> Void
    var style: BackgroundStyle = .tintedGradient

    // MARK: - Accent derived from difficulty
    private var accent: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }

    var body: some View {
        ZStack {
            backgroundView.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 22) {

                    // Hero
                    ZStack {
                        Circle()
                            .fill(accent.opacity(0.12))
                            .frame(width: 92, height: 92)
                        Image(systemName: "rectangle.on.rectangle.angled")
                            .font(.system(size: 44, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(accent)
                    }
                    .accessibilityHidden(true)

                    // Title
                    Text("Welcome to Memorize")
                        .font(
                            .system(.largeTitle, design: .rounded).weight(.bold)
                        )
                        .multilineTextAlignment(.center)

                    // Difficulty badge
                    Text("Current difficulty: \(label(for: difficulty))")
                        .font(.headline)
                        .foregroundStyle(accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(accent.opacity(0.12)))

                    // Toggle sidebar button (blue → open, red → close)
                    Button(action: onToggleSidebar) {
                        Label(
                            isSidebarVisible
                                ? "Close Sidebar" : "Choose a Theme",
                            systemImage: isSidebarVisible
                                ? "sidebar.trailing" : "sidebar.leading"
                        )
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isSidebarVisible ? .red : .blue)
                    .frame(maxWidth: 560)
                    .padding(.horizontal, 24)

                    // Cards
                    InfoCard(
                        title: "How to play",
                        icon: "gamecontroller.fill",
                        tint: accent
                    ) {
                        RuleRow(
                            icon: "hand.tap.fill",
                            text: "Pick a theme from the sidebar to start."
                        )
                        RuleRow(
                            icon: "square.stack.3d.down.forward.fill",
                            text: "Flip two cards. A match stays face up."
                        )
                        RuleRow(
                            icon: "exclamationmark.triangle.fill",
                            text: penaltyText(for: difficulty)
                        )
                        RuleRow(
                            icon: "stopwatch.fill",
                            text: "Clear all pairs before time runs out."
                        )
                    }

                    InfoCard(
                        title: "Difficulty",
                        icon: "dial.medium.fill",
                        tint: accent
                    ) {
                        RuleRow(
                            icon: "checkmark.circle.fill",
                            text:
                                "Easy — 10s per pair, −1s per mismatch (most forgiving)."
                        )
                        RuleRow(
                            icon: "checkmark.circle.fill",
                            text:
                                "Medium — 8s per pair, −3s per mismatch (balanced)."
                        )
                        RuleRow(
                            icon: "checkmark.circle.fill",
                            text:
                                "Hard — 6s per pair, −5s per mismatch (tight window)."
                        )
                    }

                    InfoCard(
                        title: "Manage themes",
                        icon: "paintpalette.fill",
                        tint: accent
                    ) {
                        RuleRow(
                            icon: "plus.circle.fill",
                            text: "Create: tap the “+” in the toolbar."
                        )
                        RuleRow(
                            icon: "slider.horizontal.3",
                            text: "Edit: swipe a theme right → Edit."
                        )
                        RuleRow(
                            icon: "trash.fill",
                            text:
                                "Delete: swipe a theme left → Delete, or use Edit mode."
                        )
                        RuleRow(
                            icon: "textformat.123",
                            text: "Emojis: add/remove in the Theme Editor."
                        )
                        RuleRow(
                            icon: "square.grid.2x2.fill",
                            text: "Pairs: adjust number of pairs in the Editor."
                        )
                        RuleRow(
                            icon: "circle.lefthalf.filled",
                            text: "Color: pick a color swatch in the Editor."
                        )
                        RuleRow(
                            icon: "character",
                            text: "Name: rename the theme in the Editor."
                        )
                    }
                }
                .frame(maxWidth: 720)
                .padding(.vertical, 36)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Backgrounds

    enum BackgroundStyle {
        case system  // plain system background
        case tintedGradient  // subtle gradient keyed by difficulty (default)
        case image(String)  // asset name
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .system:
            Color(.systemBackground)

        case .tintedGradient:
            LinearGradient(
                colors: [accent.opacity(0.18), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .image(let name):
            ZStack {
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .saturation(0.9)
                    .brightness(-0.05)
                    .blur(radius: 2)
                // Soften for readability
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.35), Color.black.opacity(0.10),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                Color(.systemBackground).opacity(0.20)
            }
        }
    }

    // MARK: - Helpers
    private func label(for mode: GameTimeMode) -> String {
        switch mode {
        case .easy: "Easy"
        case .medium: "Medium"
        case .hard: "Hard"
        }
    }
    private func penaltyText(for mode: GameTimeMode) -> String {
        switch mode {
        case .easy: "Mismatch penalty scales by difficulty (Easy: −1s)."
        case .medium: "Mismatch penalty scales by difficulty (Medium: −3s)."
        case .hard: "Mismatch penalty scales by difficulty (Hard: −5s)."
        }
    }
}

// MARK: - Components

private struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    let tint: Color
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.title2.weight(.bold))
                Spacer()
            }
            .padding(.bottom, 2)

            VStack(alignment: .leading, spacing: 10) {
                content
                Rectangle().fill(.secondary.opacity(0.12)).frame(height: 1)
                    .padding(.top, 2).opacity(0)  // keeps layout ready for footers
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(tint.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }
}

private struct RuleRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(text)
                .font(.title3)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}
