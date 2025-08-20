//  View/Modifiers/ConfirmDialogModifier.swift

import SwiftUI

/// Reusable confirmation dialog that binds to an optional presented item.
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
                if let message { Text(message) }
            }
        )
    }
}

extension View {
    /// Confirm dialog tied to an optional item.
    /// - Parameters match SwiftUI's `confirmationDialog` plus a typed confirm.
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
                isPresented: isPresented.wrappedValue == true
                    ? isPresented : isPresented,  // keeps binding as-is
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

// MARK: - Simple (no-item) variant

/// Confirmation dialog without a presented item.
private struct SimpleConfirmDialogModifier: ViewModifier {
    let title: String
    @Binding var isPresented: Bool
    let message: String?
    let confirmTitle: String
    let confirmRole: ButtonRole
    let cancelTitle: String
    let onConfirm: () -> Void

    func body(content: Content) -> some View {
        content.confirmationDialog(
            title,
            isPresented: $isPresented,
            titleVisibility: .automatic,
            actions: {
                Button(confirmTitle, role: confirmRole) { onConfirm() }
                Button(cancelTitle, role: .cancel) {}
            },
            message: { if let message { Text(message) } }
        )
    }
}

extension View {
    /// Simple confirm dialog without an item (e.g., "Sign out?").
    func confirmDialog(
        title: String,
        isPresented: Binding<Bool>,
        message: String? = nil,
        confirmTitle: String = "Confirm",
        confirmRole: ButtonRole = .destructive,
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(
            SimpleConfirmDialogModifier(
                title: title,
                isPresented: isPresented,
                message: message,
                confirmTitle: confirmTitle,
                confirmRole: confirmRole,
                cancelTitle: cancelTitle,
                onConfirm: onConfirm
            )
        )
    }
}
