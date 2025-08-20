//  View/Modifiers/ConfirmDialogModifier.swift

import SwiftUI

/// Reusable confirmation dialog that works with any presented item.
/// Usage:
/// `.confirmDialog(title: "Delete?", isPresented: $show, presenting: item,
///                 message: "This cannot be undone.",
///                 confirmTitle: { "Delete “\($0.name)”" },
///                 confirmRole: .destructive) { item in /* handle */ }`
struct ConfirmDialogModifier<Item>: ViewModifier {
    // MARK: - Inputs
    let title: String
    @Binding var isPresented: Bool
    let presenting: Item?
    let message: String?

    let confirmTitle: (Item) -> String
    let confirmRole: ButtonRole
    let cancelTitle: String
    let onConfirm: (Item) -> Void

    // MARK: - Body
    func body(content: Content) -> some View {
        content.confirmationDialog(
            title,
            isPresented: $isPresented,
            presenting: presenting,
            actions: { item in
                Button(confirmTitle(item), role: confirmRole) {
                    onConfirm(item)
                }
                Button(cancelTitle, role: .cancel) {}
            },
            message: { _ in
                if let message {
                    Text(message)
                }
            }
        )
    }
}

extension View {
    /// Attach a reusable confirmation dialog to any view.
    func confirmDialog<Item>(
        title: String,
        isPresented: Binding<Bool>,
        presenting: Item?,
        message: String? = nil,
        confirmTitle: @escaping (Item) -> String = { _ in "Confirm" },
        confirmRole: ButtonRole = .destructive,
        cancelTitle: String = "Cancel",
        onConfirm: @escaping (Item) -> Void
    ) -> some View {
        modifier(
            ConfirmDialogModifier(
                title: title,
                isPresented: isPresented,
                presenting: presenting,
                message: message,
                confirmTitle: confirmTitle,
                confirmRole: confirmRole,
                cancelTitle: cancelTitle,
                onConfirm: onConfirm
            )
        )
    }
}
