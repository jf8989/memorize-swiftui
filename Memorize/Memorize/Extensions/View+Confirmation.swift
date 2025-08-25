//  Extensions/View+ConfirmDialog.swift

import SwiftUI
import UIKit

/// Presents a destructive confirmation. Uses `alert` on iPad (centered),
/// and `confirmationDialog` on iPhone (action sheet).
extension View {
    @ViewBuilder
    func confirmDialog<Item>(
        title: String,
        isPresented: Binding<Bool>,
        presenting item: Item?,
        message: String? = nil,
        confirmTitle: (Item) -> String,
        confirmRole: ButtonRole = .destructive,
        onConfirm: @escaping (Item) -> Void
    ) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad: centered alert to avoid awkward popover anchoring from swipe actions
            alert(
                title,
                isPresented: isPresented,
                presenting: item
            ) { item in
                Button(confirmTitle(item), role: confirmRole) {
                    onConfirm(item)
                }
                Button("Cancel", role: .cancel) {
                    isPresented.wrappedValue = false
                }
            } message: { _ in
                if let message { Text(message) }
            }
        } else {
            // iPhone: action sheet-style confirmation
            confirmationDialog(
                title,
                isPresented: isPresented,
                presenting: item
            ) { item in
                Button(confirmTitle(item), role: confirmRole) {
                    onConfirm(item)
                }
                Button("Cancel", role: .cancel) {}
            } message: { _ in
                if let message { Text(message) }
            }
        }
    }
}
