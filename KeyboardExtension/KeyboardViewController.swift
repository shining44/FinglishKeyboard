import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {

    private var hostingController: UIHostingController<KeyboardView>?
    private var keyboardState = KeyboardState()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        hostingController?.view.frame = view.bounds
    }

    private func setupKeyboard() {
        keyboardState.textDocumentProxy = textDocumentProxy
        keyboardState.advanceToNextInputMode = { [weak self] in
            self?.advanceToNextInputMode()
        }

        let keyboardView = KeyboardView(state: keyboardState)
        let hostingController = UIHostingController(rootView: keyboardView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        self.hostingController = hostingController
    }

    override func textWillChange(_ textInput: UITextInput?) {
        super.textWillChange(textInput)
    }

    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        updateReturnKeyType()
        checkAutoCapitalize()
    }

    private func checkAutoCapitalize() {
        if keyboardState.shouldAutoCapitalize() {
            keyboardState.isShiftEnabled = true
        }
    }

    private func updateReturnKeyType() {
        keyboardState.returnKeyType = textDocumentProxy.returnKeyType ?? .default
    }
}

class KeyboardState: ObservableObject {
    weak var textDocumentProxy: UITextDocumentProxy?
    var advanceToNextInputMode: (() -> Void)?

    @Published var isShiftEnabled = false
    @Published var isCapsLock = false
    @Published var isNumberMode = false
    @Published var isSymbolMode = false
    @Published var currentWord = ""
    @Published var suggestions: [String] = []
    @Published var returnKeyType: UIReturnKeyType = .default
    @Published var usePersianNumbers = true  // Toggle for Persian numerals
    @Published var autoCapitalize = true  // Auto-capitalize after sentence end

    private let converter = FinglishConverter()
    private let dictionary = FinglishDictionary.shared
    private var lastShiftTapTime: Date?
    private var previousFarsiWord: String = ""  // For next-word prediction
    private let sentenceEndings: Set<Character> = [".", "!", "?", "؟", "۔"]

    // Undo history - stores (inserted farsi text, original finglish text)
    private var undoStack: [(farsi: String, finglish: String)] = []
    private let maxUndoHistory = 10
    @Published var canUndo = false

    // Persian number mapping
    private let persianNumbers: [String: String] = [
        "0": "۰", "1": "۱", "2": "۲", "3": "۳", "4": "۴",
        "5": "۵", "6": "۶", "7": "۷", "8": "۸", "9": "۹"
    ]

    func insertText(_ text: String) {
        guard let proxy = textDocumentProxy else { return }

        let textToInsert: String
        if isShiftEnabled || isCapsLock {
            textToInsert = text.uppercased()
        } else {
            textToInsert = text.lowercased()
        }

        currentWord += textToInsert.lowercased()
        updateSuggestions()

        if isShiftEnabled && !isCapsLock {
            isShiftEnabled = false
        }

        proxy.insertText(textToInsert)
    }

    func insertFarsi(_ text: String) {
        guard let proxy = textDocumentProxy else { return }

        let originalFinglish = currentWord
        let wordLength = currentWord.count
        for _ in 0..<wordLength {
            proxy.deleteBackward()
        }

        proxy.insertText(text)

        // Track for undo
        undoStack.append((farsi: text, finglish: originalFinglish))
        if undoStack.count > maxUndoHistory {
            undoStack.removeFirst()
        }
        canUndo = true

        previousFarsiWord = text  // Track for next-word prediction
        currentWord = ""
        suggestions = []
    }

    // Undo last inserted Farsi word - restore original Finglish
    func undoLastWord() {
        guard let proxy = textDocumentProxy,
              let lastEntry = undoStack.popLast() else { return }

        // Delete the Farsi word
        for _ in lastEntry.farsi {
            proxy.deleteBackward()
        }

        // Restore the Finglish text
        proxy.insertText(lastEntry.finglish)
        currentWord = lastEntry.finglish
        updateSuggestions()

        canUndo = !undoStack.isEmpty
    }

    func deleteBackward() {
        guard let proxy = textDocumentProxy else { return }

        if !currentWord.isEmpty {
            currentWord.removeLast()
            updateSuggestions()
        }

        proxy.deleteBackward()
    }

    func insertSpace() {
        guard let proxy = textDocumentProxy else { return }

        if !currentWord.isEmpty {
            if let firstSuggestion = suggestions.first {
                let wordLength = currentWord.count
                for _ in 0..<wordLength {
                    proxy.deleteBackward()
                }
                proxy.insertText(firstSuggestion)
                previousFarsiWord = firstSuggestion  // Track for next-word prediction
            }
        }

        proxy.insertText(" ")
        currentWord = ""

        // Check if we should auto-capitalize (after sentence ending)
        if autoCapitalize {
            checkAndEnableAutoCapitalize()
        }

        // Show next-word predictions after space
        updateSuggestions()
    }

    // Check text before cursor and enable shift if after sentence ending
    private func checkAndEnableAutoCapitalize() {
        guard let proxy = textDocumentProxy,
              let textBefore = proxy.documentContextBeforeInput else { return }

        // Look for sentence ending pattern (. ! ? followed by space)
        let trimmed = textBefore.trimmingCharacters(in: .whitespaces)
        if let lastChar = trimmed.last, sentenceEndings.contains(lastChar) {
            isShiftEnabled = true
        }
    }

    // Check if at start of document or after sentence ending
    func shouldAutoCapitalize() -> Bool {
        guard autoCapitalize,
              let proxy = textDocumentProxy else { return false }

        let textBefore = proxy.documentContextBeforeInput ?? ""

        // At start of document
        if textBefore.isEmpty {
            return true
        }

        // After sentence ending followed by space
        let trimmed = textBefore.trimmingCharacters(in: .whitespaces)
        if let lastChar = trimmed.last, sentenceEndings.contains(lastChar) {
            return true
        }

        return false
    }

    func insertReturn() {
        guard let proxy = textDocumentProxy else { return }

        if !currentWord.isEmpty {
            if let firstSuggestion = suggestions.first {
                let wordLength = currentWord.count
                for _ in 0..<wordLength {
                    proxy.deleteBackward()
                }
                proxy.insertText(firstSuggestion)
            }
        }

        proxy.insertText("\n")
        currentWord = ""
        suggestions = []
    }

    func toggleShift() {
        let now = Date()

        if let lastTap = lastShiftTapTime, now.timeIntervalSince(lastTap) < 0.3 {
            isCapsLock = true
            isShiftEnabled = true
            lastShiftTapTime = nil
        } else {
            if isCapsLock {
                isCapsLock = false
                isShiftEnabled = false
            } else {
                isShiftEnabled.toggle()
            }
            lastShiftTapTime = now
        }
    }

    func toggleNumberMode() {
        isNumberMode.toggle()
        isSymbolMode = false
    }

    func toggleSymbolMode() {
        isSymbolMode.toggle()
    }

    func switchKeyboard() {
        advanceToNextInputMode?()
    }

    // Insert Farsi text directly (from alternate character selection)
    func insertDirectFarsi(_ text: String) {
        guard let proxy = textDocumentProxy else { return }
        proxy.insertText(text)
        // Don't affect the current word tracking for direct Farsi insertion
    }

    // Insert Persian numeral
    func insertPersianNumber(_ number: String) {
        guard let proxy = textDocumentProxy else { return }
        if usePersianNumbers, let persianNum = persianNumbers[number] {
            proxy.insertText(persianNum)
        } else {
            proxy.insertText(number)
        }
    }

    // Insert Zero-Width Non-Joiner (half-space)
    func insertZWNJ() {
        guard let proxy = textDocumentProxy else { return }
        proxy.insertText("\u{200C}")  // ZWNJ character
    }

    // Toggle Persian numbers on/off
    func togglePersianNumbers() {
        usePersianNumbers.toggle()
    }

    // Move cursor left
    func moveCursorLeft() {
        guard let proxy = textDocumentProxy else { return }
        proxy.adjustTextPosition(byCharacterOffset: -1)
    }

    // Move cursor right
    func moveCursorRight() {
        guard let proxy = textDocumentProxy else { return }
        proxy.adjustTextPosition(byCharacterOffset: 1)
    }

    // Insert period after space (double-tap space behavior)
    func insertPeriodAfterSpace() {
        guard let proxy = textDocumentProxy else { return }

        // Delete the space we just inserted
        proxy.deleteBackward()

        // Insert period and space (Farsi period: ۔ or standard period)
        proxy.insertText(". ")

        // Reset current word
        currentWord = ""
        suggestions = []
    }

    // Clear current word (delete all typed characters)
    func clearCurrentWord() {
        guard let proxy = textDocumentProxy else { return }

        // Delete all characters in the current word
        let wordLength = currentWord.count
        for _ in 0..<wordLength {
            proxy.deleteBackward()
        }

        currentWord = ""
        suggestions = []
    }

    private func updateSuggestions() {
        if currentWord.isEmpty {
            // Show next-word predictions when no word is being typed
            if !previousFarsiWord.isEmpty {
                suggestions = dictionary.getNextWordPredictions(after: previousFarsiWord)
            } else {
                suggestions = []
            }
        } else {
            suggestions = converter.getSuggestions(for: currentWord)
        }
    }

    var returnKeyTitle: String {
        switch returnKeyType {
        case .go: return "Go"
        case .google: return "Google"
        case .join: return "Join"
        case .next: return "Next"
        case .route: return "Route"
        case .search: return "Search"
        case .send: return "Send"
        case .yahoo: return "Yahoo"
        case .done: return "Done"
        case .emergencyCall: return "Emergency"
        case .continue: return "Continue"
        default: return "return"
        }
    }
}
