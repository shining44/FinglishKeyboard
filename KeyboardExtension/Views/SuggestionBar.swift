import SwiftUI

struct SuggestionBar: View {
    @ObservedObject var state: KeyboardState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            // Undo button (appears when available)
            if state.canUndo {
                Button(action: {
                    state.undoLastWord()
                    triggerHaptic()
                }) {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 12, weight: .medium))
                        Text("برگرد")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue.opacity(0.1))
                    )
                }
                .padding(.leading, 6)

                Divider()
                    .frame(height: 24)
                    .padding(.horizontal, 4)
            }

            if state.suggestions.isEmpty {
                Spacer()
                Text("فینگلیش بنویسید")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                // Show current Finglish word being typed
                if !state.currentWord.isEmpty {
                    HStack(spacing: 4) {
                        Text(state.currentWord)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)

                        // Clear button
                        Button(action: {
                            state.clearCurrentWord()
                            triggerHaptic()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 8)

                    Divider()
                        .frame(height: 24)
                }

                ForEach(Array(state.suggestions.prefix(suggestionCount).enumerated()), id: \.offset) { index, suggestion in
                    if index > 0 {
                        Divider()
                            .frame(height: 24)
                    }

                    SuggestionButton(
                        suggestion: suggestion,
                        isFirst: index == 0,
                        isPrediction: state.currentWord.isEmpty,
                        action: {
                            if state.currentWord.isEmpty {
                                // Next-word prediction - insert directly with space
                                state.textDocumentProxy?.insertText(suggestion + " ")
                            } else {
                                state.insertFarsi(suggestion)
                            }
                            triggerHaptic()
                        }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(suggestionBarBackground)
    }

    private var suggestionBarBackground: Color {
        colorScheme == .dark ? Color(white: 0.18) : Color(white: 0.95)
    }

    // Calculate how many suggestions to show based on available space
    private var suggestionCount: Int {
        if state.canUndo && !state.currentWord.isEmpty {
            return 2  // Undo + current word + 2 suggestions
        } else if state.canUndo || !state.currentWord.isEmpty {
            return 2  // Either undo or current word + 2 suggestions
        } else {
            return 3  // Full 3 suggestions
        }
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

struct SuggestionButton: View {
    let suggestion: String
    let isFirst: Bool
    var isPrediction: Bool = false
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isPrediction && isFirst {
                    // Show a small indicator for predictions
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue.opacity(0.7))
                }
                Text(suggestion)
                    .font(.system(size: 18, weight: isFirst ? .semibold : .regular))
                    .foregroundColor(textColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(SuggestionButtonStyle())
    }

    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
}

struct SuggestionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.gray.opacity(0.2) : Color.clear)
    }
}

#Preview {
    VStack {
        SuggestionBar(state: {
            let state = KeyboardState()
            state.suggestions = ["سلام", "سالم", "سلامت"]
            return state
        }())

        SuggestionBar(state: KeyboardState())
    }
}
