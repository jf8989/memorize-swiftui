//  View/Modifiers/SplitVisibilityPersistence.swift

import SwiftUI

/// Keeps `NavigationSplitView` column visibility stable:
/// - Persists per size class (compact vs regular) using @SceneStorage
/// - Re-applies after width changes so rotations/resizes don't override user's choice
struct SplitVisibilityPersistence: ViewModifier {
    // MARK: - Inputs
    @Binding var columnVisibility: NavigationSplitViewVisibility
    let sizeClass: UserInterfaceSizeClass?

    // MARK: - Per-size-class storage (scene-scoped)
    @SceneStorage("ui.splitVisibility.compact") private var compactRaw: String?
    @SceneStorage("ui.splitVisibility.regular") private var regularRaw: String?

    // MARK: - Rotation/resize tracking
    @State private var measuredWidth: CGFloat = 0
    @State private var lastWidthChangeAt: Date? = nil
    private let rotationWindowSeconds: TimeInterval = 0.40

    // MARK: - Body
    func body(content: Content) -> some View {
        content
            .overlay(widthProbe)
            .task { applyFromStorage() }
            .onChange(of: sizeClass) { _, _ in applyFromStorage() }
            .onChange(of: columnVisibility) { _, newValue in
                // Ignore noisy flips during width-change window; otherwise persist.
                if isWithinWidthWindow { return }
                persist(newValue)
            }
    }

    // MARK: - Width probe to detect rotation/resize
    private var widthProbe: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            Color.clear.preference(key: WidthKey.self, value: w)
        }
        .onPreferenceChange(WidthKey.self) { newWidth in
            guard abs(newWidth - measuredWidth) > 0.5 else { return }
            measuredWidth = newWidth
            lastWidthChangeAt = Date()
            // Re-assert stored preference after system completes its flip.
            DispatchQueue.main.async {
                reapplyStoredForCurrentSize()
            }
        }
    }

    private var isWithinWidthWindow: Bool {
        guard let t = lastWidthChangeAt else { return false }
        return Date().timeIntervalSince(t) < rotationWindowSeconds
    }

    // MARK: - Apply / Persist
    private func applyFromStorage() {
        columnVisibility = storedVisibility() ?? defaultVisibility()
    }

    private func reapplyStoredForCurrentSize() {
        let target = storedVisibility() ?? defaultVisibility()
        if columnVisibility != target { columnVisibility = target }
    }

    private func persist(_ v: NavigationSplitViewVisibility) {
        let raw = encode(v)
        if bucketKey() == "compact" {
            compactRaw = raw
        } else {
            regularRaw = raw
        }
    }

    private func storedVisibility() -> NavigationSplitViewVisibility? {
        let raw = (bucketKey() == "compact") ? compactRaw : regularRaw
        return decode(raw)
    }

    private func bucketKey() -> String {
        (sizeClass == .compact) ? "compact" : "regular"
    }

    private func defaultVisibility() -> NavigationSplitViewVisibility {
        (sizeClass == .compact) ? .automatic : .all
    }

    // MARK: - Simple codec (kept local to UI; not Engine)
    private func encode(_ v: NavigationSplitViewVisibility) -> String {
        switch v {
        case .all: return "all"
        case .detailOnly: return "detailOnly"
        case .doubleColumn: return "doubleColumn"
        default: return "automatic"
        }
    }
    private func decode(_ raw: String?) -> NavigationSplitViewVisibility? {
        switch raw {
        case "all": return .all
        case "detailOnly": return .detailOnly
        case "doubleColumn": return .doubleColumn
        case "automatic": return .automatic
        default: return nil
        }
    }
}

// MARK: - Helpers local to the modifier

private struct WidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
