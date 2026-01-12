import SwiftUI

struct ContentView: View {
    @State private var keyboardEnabled = false
    @State private var demoInput = ""
    @State private var demoSuggestions: [String] = []
    @Environment(\.colorScheme) var colorScheme

    private let converter = DemoConverter()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    liveDemo
                    featuresSection
                    setupStepsSection
                    testSection
                    tipsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Finglish Keyboard")
            .onAppear {
                checkKeyboardEnabled()
            }
        }
        .navigationViewStyle(.stack)
    }

    private var liveDemo: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Live Demo")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 12) {
                Text("Type Finglish below to see the conversion:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Input field
                TextField("Type here... (e.g., salam)", text: $demoInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .onChange(of: demoInput) { newValue in
                        updateDemoSuggestions(for: newValue)
                    }

                // Suggestions
                if !demoSuggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Suggestions:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack(spacing: 12) {
                            ForEach(demoSuggestions.prefix(3), id: \.self) { suggestion in
                                Text(suggestion)
                                    .font(.title2)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                if demoInput.isEmpty {
                    Text("Examples: salam, mersi, chetori, khobi")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }

    private func updateDemoSuggestions(for input: String) {
        if input.isEmpty {
            demoSuggestions = []
        } else {
            demoSuggestions = converter.getSuggestions(for: input)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Text("ف")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }

            Text("Type in Finglish, Get Farsi")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("Convert your Latin-script Persian typing to beautiful Farsi characters in real-time")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 20)
    }

    private var setupStepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Setup Instructions")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                SetupStepRow(
                    number: 1,
                    title: "Open Settings",
                    description: "Tap the button below to open keyboard settings",
                    isCompleted: false,
                    action: openSettings
                )

                Divider()
                    .padding(.leading, 56)

                SetupStepRow(
                    number: 2,
                    title: "Add New Keyboard",
                    description: "Tap 'Keyboards' then 'Add New Keyboard...'",
                    isCompleted: false
                )

                Divider()
                    .padding(.leading, 56)

                SetupStepRow(
                    number: 3,
                    title: "Select Finglish Keyboard",
                    description: "Find and tap 'Finglish Keyboard' in the list",
                    isCompleted: keyboardEnabled
                )

                Divider()
                    .padding(.leading, 56)

                SetupStepRow(
                    number: 4,
                    title: "Start Typing",
                    description: "Use the globe key to switch to Finglish",
                    isCompleted: false
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Features")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                FeatureRow(
                    icon: "wand.and.stars",
                    iconColor: .purple,
                    title: "Smart Conversion",
                    description: "2800+ words with intelligent transliteration"
                )

                Divider().padding(.leading, 56)

                FeatureRow(
                    icon: "character.cursor.ibeam",
                    iconColor: .blue,
                    title: "Fuzzy Matching",
                    description: "Handles typos and spelling variations"
                )

                Divider().padding(.leading, 56)

                FeatureRow(
                    icon: "arrow.uturn.backward",
                    iconColor: .orange,
                    title: "Undo Support",
                    description: "Restore original Finglish if needed"
                )

                Divider().padding(.leading, 56)

                FeatureRow(
                    icon: "hand.tap",
                    iconColor: .green,
                    title: "Long Press Alternates",
                    description: "Access alternate Persian characters"
                )

                Divider().padding(.leading, 56)

                FeatureRow(
                    icon: "number",
                    iconColor: .red,
                    title: "Persian Numbers",
                    description: "Automatic Persian numeral conversion"
                )

                Divider().padding(.leading, 56)

                FeatureRow(
                    icon: "arrow.left.and.right",
                    iconColor: .teal,
                    title: "Cursor Control",
                    description: "Swipe on space bar to move cursor"
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }

    private var testSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Try It Out")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 16) {
                Text("Once enabled, try typing these words:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 20) {
                    ExampleWordView(finglish: "salam", farsi: "سلام")
                    ExampleWordView(finglish: "mersi", farsi: "مرسی")
                    ExampleWordView(finglish: "khobi", farsi: "خوبی")
                }

                HStack(spacing: 20) {
                    ExampleWordView(finglish: "chetori", farsi: "چطوری")
                    ExampleWordView(finglish: "mamnoon", farsi: "ممنون")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pro Tips")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 0) {
                TipRow(
                    tip: "Double-tap space to insert a period",
                    icon: "circle.fill"
                )

                Divider().padding(.leading, 40)

                TipRow(
                    tip: "Long-press any letter for Persian alternates",
                    icon: "hand.point.up.left.fill"
                )

                Divider().padding(.leading, 40)

                TipRow(
                    tip: "Use the half-space key for proper ZWNJ",
                    icon: "rectangle.split.1x2"
                )

                Divider().padding(.leading, 40)

                TipRow(
                    tip: "Tap suggestions to insert Farsi words",
                    icon: "text.cursor"
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func checkKeyboardEnabled() {
        if let keyboards = UserDefaults.standard.object(forKey: "AppleKeyboards") as? [String] {
            keyboardEnabled = keyboards.contains { $0.contains("com.finglish.keyboard") }
        }
    }
}

struct SetupStepRow: View {
    let number: Int
    let title: String
    let description: String
    var isCompleted: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
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
                    .font(.body)
                    .fontWeight(.medium)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let action = action {
                    Button(action: action) {
                        Text("Open Settings")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 4)
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct ExampleWordView: View {
    let finglish: String
    let farsi: String

    var body: some View {
        VStack(spacing: 4) {
            Text(farsi)
                .font(.title3)
                .fontWeight(.medium)

            Text(finglish)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
    }
}

struct TipRow: View {
    let tip: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(tip)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding()
    }
}

// Simple demo converter for the main app
class DemoConverter {
    private let commonWords: [String: String] = [
        "salam": "سلام",
        "salaam": "سلام",
        "mersi": "مرسی",
        "merci": "مرسی",
        "mamnoon": "ممنون",
        "mamnun": "ممنون",
        "khobi": "خوبی",
        "khoobi": "خوبی",
        "chetori": "چطوری",
        "chetory": "چطوری",
        "che khabar": "چه خبر",
        "chekhabar": "چه خبر",
        "khodahafez": "خداحافظ",
        "khodafez": "خداحافظ",
        "bebakhshid": "ببخشید",
        "lotfan": "لطفاً",
        "khone": "خونه",
        "khaane": "خانه",
        "kar": "کار",
        "ketab": "کتاب",
        "doost": "دوست",
        "dost": "دوست",
        "mikham": "می‌خوام",
        "miram": "می‌رم",
        "miam": "می‌آم",
        "emrooz": "امروز",
        "farda": "فردا",
        "dirooz": "دیروز",
        "alan": "الان",
        "hala": "حالا",
        "khaste": "خسته",
        "goshne": "گشنه",
        "tashne": "تشنه",
        "khoshhal": "خوشحال",
        "narahat": "ناراحت",
        "azizam": "عزیزم",
        "joonam": "جونم",
        "eshgh": "عشق",
        "doset daram": "دوست دارم",
        "kheyli": "خیلی",
        "ziad": "زیاد",
        "kam": "کم",
        "bozorg": "بزرگ",
        "kuchik": "کوچیک",
        "khub": "خوب",
        "bad": "بد",
        "inja": "اینجا",
        "oonja": "اونجا",
        "koja": "کجا",
        "key": "کی",
        "chera": "چرا",
        "chi": "چی",
        "bashe": "باشه",
        "ok": "اوکی",
        "yani": "یعنی",
        "vali": "ولی",
        "ama": "اما",
        "bahal": "باحال",
        "khafan": "خفن",
    ]

    private let charMappings: [Character: String] = [
        "a": "ا", "b": "ب", "c": "ک", "d": "د", "e": "ه",
        "f": "ف", "g": "گ", "h": "ه", "i": "ی", "j": "ج",
        "k": "ک", "l": "ل", "m": "م", "n": "ن", "o": "و",
        "p": "پ", "q": "ق", "r": "ر", "s": "س", "t": "ت",
        "u": "و", "v": "و", "w": "و", "x": "خ", "y": "ی", "z": "ز"
    ]

    func getSuggestions(for input: String) -> [String] {
        let lowercased = input.lowercased()
        var results: [String] = []

        // Check dictionary first
        if let match = commonWords[lowercased] {
            results.append(match)
        }

        // Check partial matches
        for (key, value) in commonWords {
            if key.hasPrefix(lowercased) && key != lowercased {
                results.append(value)
            }
        }

        // Simple transliteration
        let transliterated = transliterate(lowercased)
        if !results.contains(transliterated) {
            results.append(transliterated)
        }

        return Array(results.prefix(5))
    }

    private func transliterate(_ input: String) -> String {
        var result = ""
        var i = input.startIndex

        while i < input.endIndex {
            let remaining = String(input[i...])

            // Check multi-char patterns
            if remaining.hasPrefix("kh") {
                result += "خ"
                i = input.index(i, offsetBy: 2)
            } else if remaining.hasPrefix("sh") {
                result += "ش"
                i = input.index(i, offsetBy: 2)
            } else if remaining.hasPrefix("ch") {
                result += "چ"
                i = input.index(i, offsetBy: 2)
            } else if remaining.hasPrefix("zh") {
                result += "ژ"
                i = input.index(i, offsetBy: 2)
            } else if remaining.hasPrefix("gh") {
                result += "ق"
                i = input.index(i, offsetBy: 2)
            } else if remaining.hasPrefix("aa") {
                result += "آ"
                i = input.index(i, offsetBy: 2)
            } else if remaining.hasPrefix("oo") {
                result += "و"
                i = input.index(i, offsetBy: 2)
            } else if remaining.hasPrefix("ee") {
                result += "ی"
                i = input.index(i, offsetBy: 2)
            } else {
                // Single char
                let char = input[i]
                result += charMappings[char] ?? String(char)
                i = input.index(after: i)
            }
        }

        return result
    }
}

#Preview {
    ContentView()
}
