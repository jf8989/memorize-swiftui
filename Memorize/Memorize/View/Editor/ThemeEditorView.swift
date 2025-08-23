//  View/Editor/ThemeEditorView.swift

import SwiftUI

/// Sheet editor for a Theme. Edits persist live via ThemeStore.
struct ThemeEditorView: View {
    @EnvironmentObject private var store: ThemeStore
    @Environment(\.dismiss) private var dismiss

    // Local draft so we can validate/clamp before persisting.
    @State private var draft: Theme
    @State private var emojiInput: String = ""
    @FocusState private var isEmojiInputFocused: Bool

    @State private var liveColor: Color = .gray

    init(theme: Theme) {
        _draft = State(initialValue: theme)
        _liveColor = State(initialValue: Color(rgba: theme.rgba))
    }

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                emojisSection
                pairsSection
                colorSection
            }
            .navigationTitle("Edit Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        // Persist on every validated change.
        .onChange(of: draft) { _, new in
            store.upsert(new)
        }
    }

    // MARK: - Sections

    private var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Theme Name", text: binding(\.name))
                .textInputAutocapitalization(.words)
        }
    }

    private var emojisSection: some View {
        Section(header: Text("Emojis")) {
            HStack {
                TextField(
                    "Type or paste emojis",
                    text: $emojiInput,
                    axis: .horizontal
                )
                .focused($isEmojiInputFocused)
                .onSubmit(addEmojisFromInput)
                Button("Add") { addEmojisFromInput() }
                    .disabled(emojiInput.isEmpty)
            }

            // Tap-to-remove; never drop below 2 total.
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 36))], spacing: 8) {
                ForEach(draft.emojis, id: \.self) { e in
                    Text(e)
                        .font(.title2)
                        .padding(6)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture { removeEmoji(e) }
                }
            }
            .animation(.default, value: draft.emojis)

            if draft.emojis.count < 2 {
                Text("At least 2 emojis are required.")
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
    }

    /// Pairs editor with live clamping to the emoji count (min 2).
    private var pairsSection: some View {
        Section(header: Text("Pairs")) {
            Stepper(
                value: binding(\.pairs),
                in: 2...max(draft.emojis.count, 2)
            ) {
                Text("Pairs: \(draft.pairs)")
            }
            .disabled(draft.emojis.count < 2)
            // If emojis change, keep pairs within 2...emojiCount.
            .onChange(of: draft.emojis) { _, new in
                draft.pairs = min(
                    max(draft.pairs, 2),
                    max(new.count, 2)
                )
            }
        }
    }

    private var colorSection: some View {
        Section(header: Text("Color")) {
            ColorPicker(
                "Theme Color",
                selection: $liveColor,
                supportsOpacity: true
            )
            .onChange(of: liveColor) { _, new in
                // coalesce the writes to draft (reduces Form churn)
                draft.rgba = RGBA(new)
            }
        }
    }

    // MARK: - Intent

    private func addEmojisFromInput() {
        guard !emojiInput.isEmpty else { return }
        let new = extractUniqueEmojis(from: emojiInput)
        var set = Set(draft.emojis)
        var combined = draft.emojis
        for e in new where !set.contains(e) {
            set.insert(e)
            combined.append(e)
        }
        draft.emojis = combined
        // Clamp pairs upper bound to new emoji count.
        draft.pairs = min(draft.pairs, combined.count)
        emojiInput = ""
        isEmojiInputFocused = true
    }

    private func removeEmoji(_ e: String) {
        // Enforce minimum of 2 emojis.
        guard draft.emojis.count > 2 else { return }
        draft.emojis.removeAll { $0 == e }
        draft.pairs = min(draft.pairs, draft.emojis.count)
    }

    // MARK: - Helpers

    /// Binding maker for a `Theme` field in `draft`.
    private func binding<Value>(_ keyPath: WritableKeyPath<Theme, Value>)
        -> Binding<Value>
    {
        Binding(
            get: { draft[keyPath: keyPath] },
            set: { draft[keyPath: keyPath] = $0 }
        )
    }
}
