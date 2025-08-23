//  Extensions/View+ModePicker.swift

import SwiftUI

//MARK: - Public API
extension View {
    /// Presents a difficulty picker with colored options (sheet on all devices).
    /// - The view that calls this decides when to show it via `isPresented`.
    func difficultyPicker(
        isPresented: Binding<Bool>,
        onPick: @escaping (GameTimeMode) -> Void
    ) -> some View {
        sheet(isPresented: isPresented) {
            DifficultyPickerSheet(isPresented: isPresented, onPick: onPick)
                .presentationDetents([.fraction(0.33), .medium])
                .presentationDragIndicator(.visible)
        }
    }
}

//MARK: - Sheet Content

private struct DifficultyPickerSheet: View {
    @Binding var isPresented: Bool
    let onPick: (GameTimeMode) -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Title + message
            VStack(spacing: 6) {
                Text("Difficulty")
                    .font(.headline)
                Text(
                    "Change difficulty for all games. Current game will restart."
                )
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            }
            .padding(.top, 8)

            // Colored options
            VStack(spacing: 12) {
                ModeButton(title: "Easy", color: .green) {
                    pick(.easy)
                }
                ModeButton(title: "Medium", color: .orange) {
                    pick(.medium)
                }
                ModeButton(title: "Hard", color: .red) {
                    pick(.hard)
                }
            }

            // Clear "Cancel" affordance (neutral styling)
            Button(role: .cancel) {
                isPresented = false
            } label: {
                Text("Cancel")
                    .font(.body)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func pick(_ mode: GameTimeMode) {
        isPresented = false
        onPick(mode)
    }
}

private struct ModeButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(color)
                .background(
                    Capsule()
                        .fill(color.opacity(0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.65), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }
}
