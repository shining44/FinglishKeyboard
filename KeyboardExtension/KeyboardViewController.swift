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
    private let userLexicon = UserLexicon.shared
    private var lastShiftTapTime: Date?
    private var previousFarsiWord: String = ""  // For next-word prediction
    private let sentenceEndings: Set<Character> = [".", "!", "?", "؟", "۔"]
    // Undo history - stores enough context to reverse learning when a correction is rejected.
    private var undoStack: [(farsi: String, finglish: String, previousFarsi: String)] = []
    private let maxUndoHistory = 10
    @Published var canUndo = false

    // Persian number mapping
    private let persianNumbers: [String: String] = [
        "0": "۰", "1": "۱", "2": "۲", "3": "۳", "4": "۴",
        "5": "۵", "6": "۶", "7": "۷", "8": "۸", "9": "۹"
    ]

    func insertText(_ text: String) {
        guard let proxy = textDocumentProxy else { return }
        syncCurrentWordFromDocument()

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
        guard textDocumentProxy != nil else { return }
        syncCurrentWordFromDocument()

        let originalFinglish = currentWord
        replaceCurrentWord(with: text, originalFinglish: originalFinglish, recordUndo: true, learningWeight: 5)
    }

    func insertPrediction(_ text: String) {
        guard let proxy = textDocumentProxy else { return }

        let previousWord = previousFarsiWord
        proxy.insertText(text + " ")
        if !previousWord.isEmpty {
            userLexicon.recordNextWordChoice(after: previousWord, next: text, weight: 5)
        }
        previousFarsiWord = text
        currentWord = ""
        updateSuggestions()
    }

    // Undo last inserted Farsi word - restore original Finglish
    func undoLastWord() {
        guard let proxy = textDocumentProxy,
              let lastEntry = undoStack.popLast() else { return }

        guard (proxy.documentContextBeforeInput ?? "").hasSuffix(lastEntry.farsi) else {
            currentWord = trailingFinglishWord(in: proxy.documentContextBeforeInput ?? "")
            updateSuggestions()
            canUndo = !undoStack.isEmpty
            return
        }

        for _ in lastEntry.farsi {
            proxy.deleteBackward()
        }

        userLexicon.recordSuggestionRejection(input: lastEntry.finglish, output: lastEntry.farsi, weight: 3)
        if !lastEntry.previousFarsi.isEmpty {
            userLexicon.recordNextWordRejection(after: lastEntry.previousFarsi, next: lastEntry.farsi, weight: 1)
        }

        // Restore the Finglish text
        proxy.insertText(lastEntry.finglish)
        previousFarsiWord = lastEntry.previousFarsi
        currentWord = lastEntry.finglish
        updateSuggestions()

        canUndo = !undoStack.isEmpty
    }

    func deleteBackward() {
        guard let proxy = textDocumentProxy else { return }

        proxy.deleteBackward()
        syncCurrentWordFromDocument()
    }

    func insertSpace() {
        guard let proxy = textDocumentProxy else { return }
        syncCurrentWordFromDocument()

        if !currentWord.isEmpty {
            if let firstSuggestion = suggestions.first {
                replaceCurrentWord(with: firstSuggestion, originalFinglish: currentWord, recordUndo: true, learningWeight: 1)
                previousFarsiWord = firstSuggestion  // Track for next-word prediction
            } else {
                previousFarsiWord = ""
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
        syncCurrentWordFromDocument()

        if !currentWord.isEmpty {
            if let firstSuggestion = suggestions.first {
                replaceCurrentWord(with: firstSuggestion, originalFinglish: currentWord, recordUndo: true, learningWeight: 1)
            } else {
                previousFarsiWord = ""
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
        currentWord = ""
        suggestions = []
    }

    // Insert Persian numeral
    func insertPersianNumber(_ number: String) {
        guard let proxy = textDocumentProxy else { return }
        if usePersianNumbers, let persianNum = persianNumbers[number] {
            proxy.insertText(persianNum)
        } else {
            proxy.insertText(number)
        }
        previousFarsiWord = ""
        currentWord = ""
        suggestions = []
    }

    func insertRawText(_ text: String) {
        guard let proxy = textDocumentProxy else { return }
        proxy.insertText(text)
        previousFarsiWord = ""
        currentWord = ""
        suggestions = []
    }

    // Insert punctuation - finalize current word first, then insert punctuation
    func insertPunctuation(_ punctuation: String) {
        guard let proxy = textDocumentProxy else { return }
        syncCurrentWordFromDocument()

        if !currentWord.isEmpty {
            if let firstSuggestion = suggestions.first {
                replaceCurrentWord(with: firstSuggestion, originalFinglish: currentWord, recordUndo: true, learningWeight: 1)
            } else {
                previousFarsiWord = ""
            }
        }

        proxy.insertText(punctuation)
        currentWord = ""
        suggestions = []
    }

    // Insert Zero-Width Non-Joiner (half-space)
    func insertZWNJ() {
        guard let proxy = textDocumentProxy else { return }
        proxy.insertText("\u{200C}")  // ZWNJ character
        currentWord = ""
        suggestions = []
    }

    // Toggle Persian numbers on/off
    func togglePersianNumbers() {
        usePersianNumbers.toggle()
    }

    // Move cursor left
    func moveCursorLeft() {
        guard let proxy = textDocumentProxy else { return }
        proxy.adjustTextPosition(byCharacterOffset: -1)
        syncCurrentWordFromDocument()
    }

    // Move cursor right
    func moveCursorRight() {
        guard let proxy = textDocumentProxy else { return }
        proxy.adjustTextPosition(byCharacterOffset: 1)
        syncCurrentWordFromDocument()
    }

    // Insert period after space (double-tap space behavior)
    func insertPeriodAfterSpace() {
        guard let proxy = textDocumentProxy else { return }

        if proxy.documentContextBeforeInput?.last == " " {
            proxy.deleteBackward()
        }

        // Insert period and space (Farsi period: ۔ or standard period)
        proxy.insertText(". ")

        // Reset current word
        previousFarsiWord = ""
        currentWord = ""
        suggestions = []
    }

    // Clear current word (delete all typed characters)
    func clearCurrentWord() {
        guard let proxy = textDocumentProxy else { return }
        syncCurrentWordFromDocument()

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
                let basePredictions = dictionary.getNextWordPredictions(after: previousFarsiWord)
                suggestions = userLexicon.rankedPredictions(after: previousFarsiWord, base: basePredictions)
            } else {
                suggestions = []
            }
        } else {
            let baseSuggestions = converter.getSuggestions(for: currentWord)
            suggestions = userLexicon.rankedSuggestions(for: currentWord, base: baseSuggestions)
        }
    }

    private func replaceCurrentWord(with replacement: String, originalFinglish: String, recordUndo: Bool, learningWeight: Int = 0) {
        guard let proxy = textDocumentProxy else { return }
        let previousBeforeReplacement = previousFarsiWord

        for _ in originalFinglish {
            proxy.deleteBackward()
        }

        proxy.insertText(replacement)

        if recordUndo {
            undoStack.append((farsi: replacement, finglish: originalFinglish, previousFarsi: previousBeforeReplacement))
            if undoStack.count > maxUndoHistory {
                undoStack.removeFirst()
            }
            canUndo = true
        }

        if learningWeight > 0 {
            userLexicon.recordSuggestionChoice(input: originalFinglish, output: replacement, weight: learningWeight)
            if !previousBeforeReplacement.isEmpty {
                userLexicon.recordNextWordChoice(after: previousBeforeReplacement, next: replacement, weight: learningWeight)
            }
        }

        previousFarsiWord = replacement
        currentWord = ""
        suggestions = []
    }

    private func syncCurrentWordFromDocument() {
        let textBefore = textDocumentProxy?.documentContextBeforeInput ?? ""
        currentWord = trailingFinglishWord(in: textBefore)
        updateSuggestions()
    }

    private func trailingFinglishWord(in text: String) -> String {
        var scalars: [UnicodeScalar] = []

        for scalar in text.unicodeScalars.reversed() {
            let isASCIIDigit = scalar.value >= 48 && scalar.value <= 57
            let isUppercaseASCII = scalar.value >= 65 && scalar.value <= 90
            let isLowercaseASCII = scalar.value >= 97 && scalar.value <= 122
            guard isASCIIDigit || isUppercaseASCII || isLowercaseASCII else { break }
            scalars.append(scalar)
        }

        return String(String.UnicodeScalarView(scalars.reversed()))
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

final class UserLexicon {
    static let shared = UserLexicon()

    private let defaults = UserDefaults.standard
    // v2 intentionally leaves behind choices learned from the former lossy
    // repeated-letter cleanup (for example ممنون -> منون).
    private let suggestionChoicesKey = "FinglishKeyboard.UserLexicon.suggestionChoices.v2"
    private let nextWordChoicesKey = "FinglishKeyboard.UserLexicon.nextWordChoices.v2"
    private let maxInputs = 500
    private let maxCandidatesPerInput = 12
    private let maxCandidateWeight = 40

    private var suggestionChoices: [String: [String: Int]]
    private var nextWordChoices: [String: [String: Int]]

    private init() {
        suggestionChoices = Self.loadCounts(from: defaults, key: suggestionChoicesKey)
        nextWordChoices = Self.loadCounts(from: defaults, key: nextWordChoicesKey)
    }

    func rankedSuggestions(for input: String, base: [String], limit: Int = 8) -> [String] {
        let key = normalizedFinglish(input)
        guard !key.isEmpty else { return Array(base.prefix(limit)) }
        return rankedResults(learned: suggestionChoices[key] ?? [:], base: base, limit: limit)
    }

    func rankedPredictions(after previousWord: String, base: [String], limit: Int = 8) -> [String] {
        let key = normalizedFarsi(previousWord)
        guard !key.isEmpty else { return Array(base.prefix(limit)) }
        return rankedResults(learned: nextWordChoices[key] ?? [:], base: base, limit: limit)
    }

    func recordSuggestionChoice(input: String, output: String, weight: Int) {
        adjust(&suggestionChoices, key: normalizedFinglish(input), value: normalizedFarsi(output), delta: max(weight, 1))
        prune(&suggestionChoices)
        saveSuggestions()
    }

    func recordSuggestionRejection(input: String, output: String, weight: Int) {
        adjust(&suggestionChoices, key: normalizedFinglish(input), value: normalizedFarsi(output), delta: -max(weight, 1))
        prune(&suggestionChoices)
        saveSuggestions()
    }

    func recordNextWordChoice(after previousWord: String, next: String, weight: Int) {
        adjust(&nextWordChoices, key: normalizedFarsi(previousWord), value: normalizedFarsi(next), delta: max(weight, 1))
        prune(&nextWordChoices)
        saveNextWords()
    }

    func recordNextWordRejection(after previousWord: String, next: String, weight: Int) {
        adjust(&nextWordChoices, key: normalizedFarsi(previousWord), value: normalizedFarsi(next), delta: -max(weight, 1))
        prune(&nextWordChoices)
        saveNextWords()
    }

    private func rankedResults(learned: [String: Int], base: [String], limit: Int) -> [String] {
        guard limit > 0 else { return [] }

        var baseRank: [String: Int] = [:]
        for (index, candidate) in base.enumerated() where baseRank[candidate] == nil {
            baseRank[candidate] = index
        }

        var candidateSet = Set(base)
        for (candidate, weight) in learned where weight > 0 {
            candidateSet.insert(candidate)
        }

        let ranked = candidateSet
            .filter { !$0.isEmpty }
            .map { candidate -> (candidate: String, score: Int, baseRank: Int) in
                let rank = baseRank[candidate]
                let dictionaryScore = rank.map { max(0, 1_000 - $0 * 90) } ?? 350
                let learnedWeight = min(max(learned[candidate] ?? 0, 0), maxCandidateWeight)
                let learnedScore = learnedWeight * 200

                return (
                    candidate: candidate,
                    score: dictionaryScore + learnedScore,
                    baseRank: rank ?? Int.max
                )
            }
            .sorted {
                if $0.score != $1.score {
                    return $0.score > $1.score
                }
                if $0.baseRank != $1.baseRank {
                    return $0.baseRank < $1.baseRank
                }
                return $0.candidate < $1.candidate
            }

        return ranked.prefix(limit).map { $0.candidate }
    }

    private func adjust(_ map: inout [String: [String: Int]], key: String, value: String, delta: Int) {
        guard !key.isEmpty, !value.isEmpty, delta != 0 else { return }

        var values = map[key] ?? [:]
        let updated = min((values[value] ?? 0) + delta, maxCandidateWeight)
        if updated > 0 {
            values[value] = updated
        } else {
            values.removeValue(forKey: value)
        }

        if values.isEmpty {
            map.removeValue(forKey: key)
        } else {
            map[key] = values
        }
    }

    private func prune(_ map: inout [String: [String: Int]]) {
        for key in Array(map.keys) {
            let topCandidates = (map[key] ?? [:])
                .sorted {
                    if $0.value != $1.value {
                        return $0.value > $1.value
                    }
                    return $0.key < $1.key
                }
                .prefix(maxCandidatesPerInput)

            map[key] = Dictionary(uniqueKeysWithValues: topCandidates.map { ($0.key, $0.value) })
        }

        if map.count > maxInputs {
            let topInputs = map
                .sorted { totalWeight($0.value) > totalWeight($1.value) }
                .prefix(maxInputs)

            map = Dictionary(uniqueKeysWithValues: topInputs.map { ($0.key, $0.value) })
        }
    }

    private func totalWeight(_ values: [String: Int]) -> Int {
        values.values.reduce(0, +)
    }

    private func normalizedFinglish(_ input: String) -> String {
        input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private func normalizedFarsi(_ input: String) -> String {
        input.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func saveSuggestions() {
        Self.saveCounts(suggestionChoices, to: defaults, key: suggestionChoicesKey)
    }

    private func saveNextWords() {
        Self.saveCounts(nextWordChoices, to: defaults, key: nextWordChoicesKey)
    }

    private static func loadCounts(from defaults: UserDefaults, key: String) -> [String: [String: Int]] {
        guard let data = defaults.data(forKey: key),
              let counts = try? JSONDecoder().decode([String: [String: Int]].self, from: data) else {
            return [:]
        }
        return counts
    }

    private static func saveCounts(_ counts: [String: [String: Int]], to defaults: UserDefaults, key: String) {
        guard let data = try? JSONEncoder().encode(counts) else { return }
        defaults.set(data, forKey: key)
    }
}
