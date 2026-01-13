import SwiftUI

struct KeyboardView: View {
    @ObservedObject var state: KeyboardState
    @Environment(\.colorScheme) var colorScheme

    // Alternate characters for long-press
    private let alternates: [String: [String]] = [
        "a": ["آ", "ا", "ع", "أ"],
        "b": ["ب"],
        "c": ["چ", "ک", "س"],
        "d": ["د", "ذ"],
        "e": ["ه", "ی", "ع", "ئ"],
        "f": ["ف"],
        "g": ["گ", "غ", "ق"],
        "h": ["ه", "ح", "ﻫ"],
        "i": ["ی", "ای", "إ"],
        "j": ["ج"],
        "k": ["ک", "خ"],
        "l": ["ل", "لا"],
        "m": ["م"],
        "n": ["ن"],
        "o": ["و", "ا", "ؤ"],
        "p": ["پ"],
        "q": ["ق", "غ"],
        "r": ["ر", "ڕ"],
        "s": ["س", "ص", "ث", "ش"],
        "t": ["ت", "ط", "ث"],
        "u": ["و", "ؤ"],
        "v": ["و", "ڤ"],
        "w": ["و", "ۆ"],
        "x": ["خ", "کس"],
        "y": ["ی", "ئ"],
        "z": ["ز", "ض", "ظ", "ذ", "ژ"],
    ]

    private let letterRows = [
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
        ["z", "x", "c", "v", "b", "n", "m"]
    ]

    private let numberRows = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
        [".", ",", "؟", "!", "،"]  // Persian question mark and comma
    ]

    private let symbolRows = [
        ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
        ["_", "\\", "|", "~", "<", ">", "«", "»", "؛", "•"],  // Persian quotes and semicolon
        ["۔", "،", "؟", "!", "٪"]  // Persian period, comma, question, percent
    ]

    var body: some View {
        VStack(spacing: 0) {
            SuggestionBar(state: state)
                .frame(height: 44)

            VStack(spacing: 10) {
                if state.isNumberMode {
                    if state.isSymbolMode {
                        symbolKeyboard
                    } else {
                        numberKeyboard
                    }
                } else {
                    letterKeyboard
                }

                bottomRow
            }
            .padding(.horizontal, 3)
            .padding(.vertical, 6)
            .padding(.bottom, 2)
        }
        .background(keyboardBackground)
    }

    private var keyboardBackground: Color {
        colorScheme == .dark ? Color(white: 0.13) : Color(red: 0.82, green: 0.84, blue: 0.86)
    }

    private var letterKeyboard: some View {
        VStack(spacing: 10) {
            // First row
            HStack(spacing: 6) {
                ForEach(letterRows[0], id: \.self) { key in
                    KeyButton(
                        title: displayTitle(for: key),
                        action: { handleKeyPress(key) },
                        alternates: alternates[key] ?? [],
                        onAlternateSelected: { alt in
                            state.insertDirectFarsi(alt)
                        }
                    )
                }
            }

            // Second row (slightly indented)
            HStack(spacing: 6) {
                ForEach(letterRows[1], id: \.self) { key in
                    KeyButton(
                        title: displayTitle(for: key),
                        action: { handleKeyPress(key) },
                        alternates: alternates[key] ?? [],
                        onAlternateSelected: { alt in
                            state.insertDirectFarsi(alt)
                        }
                    )
                }
            }
            .padding(.horizontal, 18)

            // Third row with shift and delete
            HStack(spacing: 6) {
                ShiftKey(state: state)

                HStack(spacing: 6) {
                    ForEach(letterRows[2], id: \.self) { key in
                        KeyButton(
                            title: displayTitle(for: key),
                            action: { handleKeyPress(key) },
                            alternates: alternates[key] ?? [],
                            onAlternateSelected: { alt in
                                state.insertDirectFarsi(alt)
                            }
                        )
                    }
                }

                DeleteKey(state: state)
            }
        }
    }

    private var numberKeyboard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                ForEach(numberRows[0], id: \.self) { key in
                    KeyButton(title: key, action: {
                        if state.usePersianNumbers {
                            state.insertPersianNumber(key)
                        } else {
                            state.textDocumentProxy?.insertText(key)
                        }
                        triggerHaptic()
                    })
                }
            }

            HStack(spacing: 6) {
                ForEach(numberRows[1], id: \.self) { key in
                    KeyButton(title: key, action: {
                        state.textDocumentProxy?.insertText(key)
                        triggerHaptic()
                    })
                }
            }

            HStack(spacing: 6) {
                SymbolToggleKey(state: state)

                HStack(spacing: 6) {
                    ForEach(numberRows[2], id: \.self) { key in
                        KeyButton(title: key, action: {
                            state.insertPunctuation(key)
                            triggerHaptic()
                        })
                    }
                }

                DeleteKey(state: state)
            }
        }
    }

    private var symbolKeyboard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                ForEach(symbolRows[0], id: \.self) { key in
                    KeyButton(title: key, action: {
                        state.textDocumentProxy?.insertText(key)
                        triggerHaptic()
                    })
                }
            }

            HStack(spacing: 6) {
                ForEach(symbolRows[1], id: \.self) { key in
                    KeyButton(title: key, action: {
                        state.textDocumentProxy?.insertText(key)
                        triggerHaptic()
                    })
                }
            }

            HStack(spacing: 6) {
                SymbolToggleKey(state: state, showNumbers: true)

                HStack(spacing: 6) {
                    ForEach(symbolRows[2], id: \.self) { key in
                        KeyButton(title: key, action: {
                            state.insertPunctuation(key)
                            triggerHaptic()
                        })
                    }
                }

                DeleteKey(state: state)
            }
        }
    }

    private var bottomRow: some View {
        HStack(spacing: 6) {
            NumberToggleKey(state: state)

            GlobeKey(state: state)

            // ZWNJ Key (Half-space)
            ZWNJKey(state: state)

            SpaceKey(state: state)

            ReturnKey(state: state)
        }
    }

    private func displayTitle(for key: String) -> String {
        return (state.isShiftEnabled || state.isCapsLock) ? key.uppercased() : key
    }

    private func handleKeyPress(_ key: String) {
        state.insertText(key)
        triggerHaptic()
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Special Keys

struct ShiftKey: View {
    @ObservedObject var state: KeyboardState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            state.toggleShift()
            triggerHaptic()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(keyColor)
                    .shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 1)

                Image(systemName: shiftIconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
            }
        }
        .frame(width: 44, height: 42)
    }

    private var shiftIconName: String {
        if state.isCapsLock {
            return "capslock.fill"
        } else if state.isShiftEnabled {
            return "shift.fill"
        } else {
            return "shift"
        }
    }

    private var keyColor: Color {
        if state.isShiftEnabled || state.isCapsLock {
            return .white
        }
        return colorScheme == .dark ? Color(white: 0.35) : Color(white: 0.68)
    }

    private var iconColor: Color {
        if state.isShiftEnabled || state.isCapsLock {
            return .black
        }
        return colorScheme == .dark ? .white : .black
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

struct DeleteKey: View {
    @ObservedObject var state: KeyboardState
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    @State private var deleteTimer: Timer?

    var body: some View {
        Button(action: {}) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(isPressed ?
                          (colorScheme == .dark ? Color(white: 0.5) : Color(white: 0.55)) :
                          (colorScheme == .dark ? Color(white: 0.35) : Color(white: 0.68)))
                    .shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 1)

                Image(systemName: "delete.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
        .frame(width: 44, height: 42)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                        state.deleteBackward()
                        triggerHaptic()

                        // Start repeat delete after delay
                        deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                            state.deleteBackward()
                            triggerHaptic()
                        }
                    }
                }
                .onEnded { _ in
                    isPressed = false
                    deleteTimer?.invalidate()
                    deleteTimer = nil
                }
        )
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

struct NumberToggleKey: View {
    @ObservedObject var state: KeyboardState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            state.toggleNumberMode()
            triggerHaptic()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(colorScheme == .dark ? Color(white: 0.35) : Color(white: 0.68))
                    .shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 1)

                Text(state.isNumberMode ? "ABC" : "123")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
        .frame(width: 44, height: 42)
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

struct SymbolToggleKey: View {
    @ObservedObject var state: KeyboardState
    var showNumbers: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            state.toggleSymbolMode()
            triggerHaptic()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(colorScheme == .dark ? Color(white: 0.35) : Color(white: 0.68))
                    .shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 1)

                Text(showNumbers ? "123" : "#+=")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
        .frame(width: 44, height: 42)
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

struct GlobeKey: View {
    @ObservedObject var state: KeyboardState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            state.switchKeyboard()
            triggerHaptic()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(colorScheme == .dark ? Color(white: 0.35) : Color(white: 0.68))
                    .shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 1)

                Image(systemName: "globe")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
        .frame(width: 38, height: 42)
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

struct ZWNJKey: View {
    @ObservedObject var state: KeyboardState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            state.insertZWNJ()
            triggerHaptic()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(colorScheme == .dark ? Color(white: 0.35) : Color(white: 0.68))
                    .shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 1)

                Text("‌") // ZWNJ symbol
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .overlay(
                        Text("‌‌") // Visual indicator
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    )

                // Visual line indicator for half-space
                Rectangle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.3))
                    .frame(width: 2, height: 16)
            }
        }
        .frame(width: 32, height: 42)
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

struct SpaceKey: View {
    @ObservedObject var state: KeyboardState
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    @State private var isDragging = false
    @State private var lastDragX: CGFloat = 0
    @State private var lastSpaceTap: Date?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(isPressed || isDragging ?
                      (colorScheme == .dark ? Color(white: 0.45) : Color(white: 0.9)) :
                      (colorScheme == .dark ? Color(white: 0.55) : .white))
                .shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 1)

            Text(isDragging ? "←  →" : "فینگلیش")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 42)
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    if !isDragging {
                        isDragging = true
                        lastDragX = value.location.x
                        triggerHaptic(.light)
                    }

                    let deltaX = value.location.x - lastDragX
                    let threshold: CGFloat = 12  // pixels per cursor move

                    if abs(deltaX) >= threshold {
                        let moves = Int(deltaX / threshold)
                        if moves > 0 {
                            // Move cursor right
                            for _ in 0..<moves {
                                state.moveCursorRight()
                            }
                        } else if moves < 0 {
                            // Move cursor left
                            for _ in 0..<abs(moves) {
                                state.moveCursorLeft()
                            }
                        }
                        lastDragX = value.location.x
                        triggerHaptic(.light)
                    }
                }
                .onEnded { _ in
                    isDragging = false
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    if !isDragging {
                        let now = Date()
                        // Double-tap for period
                        if let lastTap = lastSpaceTap, now.timeIntervalSince(lastTap) < 0.3 {
                            state.insertPeriodAfterSpace()
                            lastSpaceTap = nil
                        } else {
                            state.insertSpace()
                            lastSpaceTap = now
                        }
                        triggerHaptic(.light)
                    }
                }
        )
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct SpaceKeyStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}

struct ReturnKey: View {
    @ObservedObject var state: KeyboardState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            state.insertReturn()
            triggerHaptic()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.blue)
                    .shadow(color: Color.black.opacity(0.25), radius: 0, x: 0, y: 1)

                Text(state.returnKeyTitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 88, height: 42)
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
