//  View/Components/Buttons/NewGameButton.swift

import SwiftUI

/// Primary New Game button.
struct NewGameButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("New Game")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 40)
        }
    }
}
