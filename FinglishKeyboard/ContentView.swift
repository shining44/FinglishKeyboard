import SwiftUI

struct ContentView: View {
    @State private var demoInput = ""
    @State private var demoSuggestions: [String] = []

    private let converter = FinglishConverter()
    private let exampleWords = [
        ExampleWord(finglish: "salam", farsi: "سلام"),
        ExampleWord(finglish: "mersi", farsi: "مرسی"),
        ExampleWord(finglish: "khobi", farsi: "خوبی"),
        ExampleWord(finglish: "chetori", farsi: "چطوری"),
        ExampleWord(finglish: "mamnoon", farsi: "ممنون"),
        ExampleWord(finglish: "mikham", farsi: "می‌خوام")
    ]

    private let exampleColumns = [
        GridItem(.adaptive(minimum: 92), spacing: 10)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    statusSection
                    liveDemo
                    setupStepsSection
                    featuresSection
                    tipsSection
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Finglish Keyboard")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.07, green: 0.35, blue: 0.95), Color(red: 0.48, green: 0.18, blue: 0.86)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("ف")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 88, height: 88)
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Type Persian the way you text it.")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Write Finglish, choose the right Persian word, and keep typing without sending your text anywhere.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 8) {
                TrustBadge(icon: "lock.shield", title: "On-device")
                TrustBadge(icon: "keyboard", title: "No Full Access")
                TrustBadge(icon: "textformat.abc", title: "Finglish first")
            }
        }
    }

    private var statusSection: some View {
        Card {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.14))
                        .frame(width: 44, height: 44)

                    Image(systemName: "keyboard.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.blue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Keyboard settings")
                        .font(.headline)

                    Text("Add Finglish Keyboard in iOS Settings, then use the globe key to switch to it in any text field.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Button(action: openSettings) {
                    Text("Open")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var liveDemo: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Try The Feel", subtitle: "The real keyboard has the full dictionary and prediction engine. This preview shows the interaction model.")

            Card {
                VStack(alignment: .leading, spacing: 14) {
                    TextField("Try: salam, mikham, chetori", text: $demoInput)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .onChange(of: demoInput) { updateDemoSuggestions(for: $0) }

                    if demoSuggestions.isEmpty {
                        Text("Suggestions appear here as Persian choices, just like the keyboard bar.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(demoSuggestions.prefix(5).enumerated()), id: \.offset) { index, suggestion in
                                    DemoSuggestionChip(text: suggestion, isPrimary: index == 0)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }

                    LazyVGrid(columns: exampleColumns, spacing: 10) {
                        ForEach(exampleWords) { word in
                            ExampleWordView(word: word) {
                                demoInput = word.finglish
                                updateDemoSuggestions(for: word.finglish)
                            }
                        }
                    }
                }
            }
        }
    }

    private var setupStepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Setup", subtitle: "iOS requires every custom keyboard to be added manually.")

            Card {
                VStack(spacing: 0) {
                    SetupStepRow(
                        number: 1,
                        title: "Open this app in Settings",
                        description: "Tap Open, then choose Keyboards.",
                        isCompleted: false,
                        action: openSettings
                    )

                    Divider().padding(.leading, 56)

                    SetupStepRow(
                        number: 2,
                        title: "Add Finglish Keyboard",
                        description: "In Keyboards, enable Finglish Keyboard.",
                        isCompleted: false
                    )

                    Divider().padding(.leading, 56)

                    SetupStepRow(
                        number: 3,
                        title: "Switch with the globe key",
                        description: "Use it anywhere you type. Full Access is not required.",
                        isCompleted: false
                    )
                }
            }
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Built For Persian Typing", subtitle: "Fast suggestions, careful typography, and controls that stay out of the way.")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                CapabilityCard(icon: "wand.and.stars", title: "Smart conversion", detail: "Dictionary, phonetics, typo handling, and verb patterns.")
                CapabilityCard(icon: "arrow.uturn.backward", title: "Undo", detail: "Restore the original Finglish when a choice is wrong.")
                CapabilityCard(icon: "rectangle.split.1x2", title: "Half-space", detail: "Dedicated ZWNJ key for proper Persian word forms.")
                CapabilityCard(icon: "arrow.left.and.right", title: "Cursor control", detail: "Swipe on space to move through text precisely.")
            }
        }
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Typing Details", subtitle: "Small shortcuts that make the keyboard feel native.")

            Card {
                VStack(spacing: 0) {
                    TipRow(tip: "Tap space to accept the first suggestion and continue.", icon: "space")
                    Divider().padding(.leading, 40)
                    TipRow(tip: "Tap a suggestion when you want a different Persian spelling.", icon: "text.cursor")
                    Divider().padding(.leading, 40)
                    TipRow(tip: "Long-press letters for Persian alternates.", icon: "hand.point.up.left.fill")
                    Divider().padding(.leading, 40)
                    TipRow(tip: "Double-tap space for period and space.", icon: "circle.fill")
                }
            }
        }
    }

    private func updateDemoSuggestions(for input: String) {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        demoSuggestions = trimmed.isEmpty ? [] : converter.getSuggestions(for: trimmed)
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

}

struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(12)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 2)
    }
}

struct TrustBadge: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))

            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundColor(.blue)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

struct SetupStepRow: View {
    let number: Int
    let title: String
    let description: String
    var isCompleted = false
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : Color.blue)
                    .frame(width: 32, height: 32)

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(number)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let action = action {
                    Button(action: action) {
                        Text("Open Settings")
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.top, 4)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
    }
}

struct ExampleWord: Identifiable {
    let id = UUID()
    let finglish: String
    let farsi: String
}

struct ExampleWordView: View {
    let word: ExampleWord
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(word.farsi)
                    .font(.title3.weight(.medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(word.finglish)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 62)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct DemoSuggestionChip: View {
    let text: String
    let isPrimary: Bool

    var body: some View {
        Text(text)
            .font(.title3.weight(isPrimary ? .semibold : .regular))
            .foregroundColor(isPrimary ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isPrimary ? Color.blue : Color(.secondarySystemBackground))
            .cornerRadius(8)
    }
}

struct CapabilityCard: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 34, height: 34)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            Text(title)
                .font(.subheadline.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            Text(detail)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 138, alignment: .topLeading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct TipRow: View {
    let tip: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(tip)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 11)
    }
}

#Preview {
    ContentView()
}
