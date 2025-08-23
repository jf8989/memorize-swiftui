//  Extensions/View+ModePicker.swift

import SwiftUI
import UIKit

/// Presents a difficulty picker that uses a centered alert on iPad
/// and a bottom action sheet (confirmationDialog) on iPhone.
extension View {
    @ViewBuilder
    func difficultyPicker(
        isPresented: Binding<Bool>,
        onPick: @escaping (GameTimeMode) -> Void
    ) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert("Difficulty", isPresented: isPresented) {
                Button("Easy") { onPick(.easy) }
                Button("Medium") { onPick(.medium) }
                Button("Hard") { onPick(.hard) }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(
                    "Change difficulty for all games. Current game will restart."
                )
            }
        } else {
            confirmationDialog("Difficulty", isPresented: isPresented) {
                Button("Easy") { onPick(.easy) }
                Button("Medium") { onPick(.medium) }
                Button("Hard") { onPick(.hard) }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(
                    "Change difficulty for all games. Current game will restart."
                )
            }
        }
    }
}
