import Foundation

class FinglishConverter {

    private let dictionary = FinglishDictionary.shared

    // ZWNJ (Zero Width Non-Joiner) for proper Farsi word separation
    static let ZWNJ = "\u{200C}"

    // Common typo corrections (typo -> correct)
    private let typoCorrections: [String: String] = [
        "slaam": "salam",
        "salma": "salam",
        "sallam": "salam",
        "mamnon": "mamnoon",
        "mamnnon": "mamnoon",
        "mamnonn": "mamnoon",
        "khodahfez": "khodahafez",
        "khodafz": "khodahafez",
        "chetorri": "chetori",
        "chetory": "chetori",
        "chetoir": "chetori",
        "khobam": "khoobam",
        "khubam": "khoobam",
        "koobam": "khoobam",
        "mikahm": "mikham",
        "mikhma": "mikham",
        "miaham": "miam",
        "miyaam": "miyam",
        "mirom": "miram",
        "miream": "miram",
        "mikoonam": "mikonam",
        "mikonma": "mikonam",
        "nemidonam": "nemidoonam",
        "nemidunam": "nemidoonam",
        "nemidunm": "nemidoonam",
        "mitunm": "mitoonam",
        "mitonma": "mitoonam",
        "lotfa": "lotfan",
        "loftan": "lotfan",
        "bebakhsh": "bebakhshid",
        "bebbakhshid": "bebakhshid",
        "mrci": "merci",
        "mrrci": "merci",
        "mrsi": "mersi",
        "ali": "ali",
        "tehrn": "tehran",
        "terhan": "tehran",
        "isfahna": "isfahan",
        "esfhan": "esfahan",
        "shrazi": "shiraz",
        "shriaz": "shiraz",
        "tabrzi": "tabriz",
        "mashahd": "mashhad",
        "mashad": "mashhad",
        "emrouz": "emrooz",
        "emruz": "emrooz",
        "fardat": "farda",
        "diruoz": "dirooz",
        "diroz": "dirooz",
        "alaan": "alan",
        "allaan": "alan",
        "badaan": "baadan",
        "badn": "baadan",
        "khoneh": "khone",
        "khaneh": "khaane",
        "khoone": "khone",
        "khieli": "kheyli",
        "khili": "kheyli",
        "khaili": "kheyli",
        // Technology typos
        "telagram": "telegram",
        "telegramm": "telegram",
        "instgram": "instagram",
        "instagarm": "instagram",
        "wattsapp": "whatsapp",
        "whatsap": "whatsapp",
        "youtueb": "youtube",
        "youtub": "youtube",
        "gogle": "google",
        "googel": "google",
        "downlod": "download",
        "donload": "download",
        "uploade": "upload",
        "uplod": "upload",
        "pssword": "password",
        "passwrod": "password",
        "emial": "email",
        "eamil": "email",
        // Colloquial typos
        "chetoor": "chetor",
        "chkhbr": "chekhabar",
        "chikhabar": "chekhabar",
        "baahall": "bahal",
        "bahaal": "bahal",
        "khafn": "khafan",
        "khshgl": "khoshgel",
        "khushgel": "khoshgel",
        "azizm": "azizam",
        "aziazm": "azizam",
        "joonm": "joonam",
        "juonm": "joonam",
        "doost": "dost",
        "doset": "doset",
        "dostet": "doset",
        "deltangm": "deltangam",
        "deltng": "deltang",
        // Business typos
        "jalsee": "jalase",
        "jalseh": "jalase",
        "proje": "proje",
        "projeh": "proje",
        "gozarsh": "gozaresh",
        "gzarsh": "gozaresh",
        "hokuk": "hoghugh",
        "hoghoogh": "hoghugh",
        "shekrat": "sherkat",
        "shirkta": "sherkat",
    ]

    // Multi-character mappings - order matters (longest first)
    private let multiCharMappings: [(String, String, Int)] = [
        // 4-character
        ("shch", "شچ", 4),
        // 3-character
        ("kha", "خا", 3),
        ("khe", "خه", 3),
        ("khi", "خی", 3),
        ("kho", "خو", 3),
        ("khu", "خو", 3),
        ("sha", "شا", 3),
        ("she", "شه", 3),
        ("shi", "شی", 3),
        ("sho", "شو", 3),
        ("shu", "شو", 3),
        ("cha", "چا", 3),
        ("che", "چه", 3),
        ("chi", "چی", 3),
        ("cho", "چو", 3),
        ("chu", "چو", 3),
        ("gha", "قا", 3),
        ("ghe", "قه", 3),
        ("ghi", "قی", 3),
        ("gho", "قو", 3),
        ("ghu", "قو", 3),
        ("zha", "ژا", 3),
        ("zhe", "ژه", 3),
        ("zhi", "ژی", 3),
        ("zho", "ژو", 3),
        ("zhu", "ژو", 3),
        // 2-character
        ("kh", "خ", 2),
        ("ch", "چ", 2),
        ("sh", "ش", 2),
        ("zh", "ژ", 2),
        ("gh", "ق", 2),
        ("aa", "آ", 2),
        ("oo", "و", 2),
        ("ee", "ی", 2),
        ("ou", "و", 2),
        ("ei", "ی", 2),
        ("ey", "ی", 2),
        ("ay", "ای", 2),
        ("ai", "ای", 2),
        ("ts", "تس", 2),
    ]

    // Context-aware endings
    private let endingPatterns: [(String, String)] = [
        ("tion", "شن"),
        ("sion", "ژن"),
        ("ism", "یسم"),
        ("ist", "یست"),
        ("ing", "ینگ"),
        ("ment", "منت"),
        ("able", "ابل"),
        ("ible", "یبل"),
        ("ness", "نس"),
        ("ful", "فول"),
        ("less", "لس"),
        ("ous", "وس"),
        ("ive", "یو"),
        ("ian", "یان"),
        ("ery", "ری"),
        ("ary", "اری"),
        ("ory", "وری"),
        ("ity", "یتی"),
        ("ty", "تی"),
        ("ly", "لی"),
        ("er", "ر"),
        ("or", "ور"),
        ("ar", "ار"),
        ("an", "ان"),
        ("en", "ن"),
        ("in", "ین"),
        ("on", "ون"),
        ("ha", "ها"),
        ("am", "م"),
        ("at", "ت"),
        ("esh", "ش"),
        ("ash", "ش"),
    ]

    // Single character mappings with priority scores
    private let singleCharMappings: [Character: [(String, Int)]] = [
        "a": [("ا", 10), ("ه", 5), ("ع", 3)],
        "b": [("ب", 10)],
        "c": [("ک", 10), ("س", 5)],
        "d": [("د", 10)],
        "e": [("ه", 10), ("ی", 8), ("ع", 3)],
        "f": [("ف", 10)],
        "g": [("گ", 10)],
        "h": [("ه", 10), ("ح", 5)],
        "i": [("ی", 10), ("ای", 5)],
        "j": [("ج", 10)],
        "k": [("ک", 10)],
        "l": [("ل", 10)],
        "m": [("م", 10)],
        "n": [("ن", 10)],
        "o": [("و", 10), ("ا", 5)],
        "p": [("پ", 10)],
        "q": [("ق", 10)],
        "r": [("ر", 10)],
        "s": [("س", 10), ("ص", 5), ("ث", 3)],
        "t": [("ت", 10), ("ط", 5)],
        "u": [("و", 10)],
        "v": [("و", 10)],
        "w": [("و", 10)],
        "x": [("خ", 10), ("کس", 5)],
        "y": [("ی", 10)],
        "z": [("ز", 10), ("ض", 5), ("ظ", 3), ("ذ", 2)],
        "'": [("ع", 10), ("ء", 5)],
        " ": [(" ", 10)],
    ]

    // Persian numbers
    private let persianNumbers: [Character: Character] = [
        "0": "۰", "1": "۱", "2": "۲", "3": "۳", "4": "۴",
        "5": "۵", "6": "۶", "7": "۷", "8": "۸", "9": "۹"
    ]

    func getSuggestions(for input: String) -> [String] {
        var lowercased = input.lowercased()
        var suggestions: [String] = []

        // Check for typo corrections first
        if let corrected = typoCorrections[lowercased] {
            lowercased = corrected
        }

        // Get dictionary matches first (highest priority)
        let dictionaryMatches = dictionary.findMatches(for: lowercased)
        suggestions.append(contentsOf: dictionaryMatches)

        // Generate primary transliteration
        let primary = transliterate(lowercased)
        if !primary.isEmpty && !suggestions.contains(primary) {
            suggestions.append(primary)
        }

        // Generate smart variants
        let variants = generateSmartVariants(for: lowercased)
        for variant in variants {
            if !suggestions.contains(variant) {
                suggestions.append(variant)
            }
        }

        // If original input was a typo, also check the original
        let originalLowercased = input.lowercased()
        if originalLowercased != lowercased {
            let originalMatches = dictionary.findMatches(for: originalLowercased)
            for match in originalMatches {
                if !suggestions.contains(match) {
                    suggestions.append(match)
                }
            }
        }

        return Array(suggestions.prefix(5))
    }

    func transliterate(_ input: String) -> String {
        var result = ""
        var index = input.startIndex

        while index < input.endIndex {
            var matched = false

            // Try multi-character mappings (longest match first)
            for (pattern, replacement, length) in multiCharMappings {
                guard let endIndex = input.index(index, offsetBy: length, limitedBy: input.endIndex) else {
                    continue
                }
                let substring = String(input[index..<endIndex]).lowercased()

                if substring == pattern {
                    result += replacement
                    index = endIndex
                    matched = true
                    break
                }
            }

            if !matched {
                let char = Character(input[index].lowercased())
                if let mappings = singleCharMappings[char], let first = mappings.first {
                    result += first.0
                } else if let persianDigit = persianNumbers[input[index]] {
                    result += String(persianDigit)
                } else {
                    result += String(input[index])
                }
                index = input.index(after: index)
            }
        }

        return cleanupResult(result)
    }

    func convertToPersianNumbers(_ input: String) -> String {
        var result = ""
        for char in input {
            if let persianDigit = persianNumbers[char] {
                result += String(persianDigit)
            } else {
                result += String(char)
            }
        }
        return result
    }

    private func generateSmartVariants(for input: String) -> [String] {
        var variants: [String] = []

        // Variant 1: Different 'a' handling (ا vs ع at start)
        if input.hasPrefix("a") {
            let variantWithAyn = "ع" + transliterateFromIndex(input, startIndex: input.index(after: input.startIndex))
            if !variantWithAyn.isEmpty {
                variants.append(cleanupResult(variantWithAyn))
            }
        }

        // Variant 2: Different 's' handling (س vs ص)
        if input.contains("s") {
            let variantWithSad = transliterateWithMapping(input, charToReplace: "s", replacement: "ص")
            if !variantWithSad.isEmpty && !variants.contains(variantWithSad) {
                variants.append(variantWithSad)
            }
        }

        // Variant 3: Different 'z' handling (ز vs ض vs ظ)
        if input.contains("z") {
            let variantWithZad = transliterateWithMapping(input, charToReplace: "z", replacement: "ض")
            if !variantWithZad.isEmpty && !variants.contains(variantWithZad) {
                variants.append(variantWithZad)
            }
        }

        // Variant 4: Different 'h' handling (ه vs ح)
        if input.contains("h") && !input.contains("kh") && !input.contains("sh") && !input.contains("ch") && !input.contains("gh") && !input.contains("zh") {
            let variantWithHa = transliterateWithMapping(input, charToReplace: "h", replacement: "ح")
            if !variantWithHa.isEmpty && !variants.contains(variantWithHa) {
                variants.append(variantWithHa)
            }
        }

        // Variant 5: Different 't' handling (ت vs ط)
        if input.contains("t") {
            let variantWithTa = transliterateWithMapping(input, charToReplace: "t", replacement: "ط")
            if !variantWithTa.isEmpty && !variants.contains(variantWithTa) {
                variants.append(variantWithTa)
            }
        }

        // Variant 6: آ instead of ا at the beginning
        if input.hasPrefix("a") || input.hasPrefix("aa") {
            var variantInput = input
            if input.hasPrefix("aa") {
                variantInput = String(input.dropFirst(2))
            } else {
                variantInput = String(input.dropFirst())
            }
            let variantWithAlef = "آ" + transliterate(variantInput)
            if !variantWithAlef.isEmpty && !variants.contains(variantWithAlef) {
                variants.append(cleanupResult(variantWithAlef))
            }
        }

        return variants
    }

    private func transliterateFromIndex(_ input: String, startIndex: String.Index) -> String {
        let substring = String(input[startIndex...])
        return transliterate(substring)
    }

    private func transliterateWithMapping(_ input: String, charToReplace: Character, replacement: String) -> String {
        var result = ""
        var index = input.startIndex
        var firstReplaced = false

        while index < input.endIndex {
            var matched = false

            // Check multi-char patterns first
            for (pattern, rep, length) in multiCharMappings {
                guard let endIndex = input.index(index, offsetBy: length, limitedBy: input.endIndex) else {
                    continue
                }
                let substring = String(input[index..<endIndex]).lowercased()

                if substring == pattern {
                    result += rep
                    index = endIndex
                    matched = true
                    break
                }
            }

            if !matched {
                let char = Character(input[index].lowercased())
                if char == charToReplace && !firstReplaced {
                    result += replacement
                    firstReplaced = true
                } else if let mappings = singleCharMappings[char], let first = mappings.first {
                    result += first.0
                } else if let persianDigit = persianNumbers[input[index]] {
                    result += String(persianDigit)
                } else {
                    result += String(input[index])
                }
                index = input.index(after: index)
            }
        }

        return cleanupResult(result)
    }

    private func cleanupResult(_ input: String) -> String {
        var result = input

        // Clean consecutive alefs
        while result.contains("اا") {
            result = result.replacingOccurrences(of: "اا", with: "ا")
        }

        // Clean up آا to آ
        result = result.replacingOccurrences(of: "آا", with: "آ")

        // Clean consecutive vavs
        while result.contains("وو") {
            result = result.replacingOccurrences(of: "وو", with: "و")
        }

        // Clean consecutive yes
        while result.contains("یی") {
            result = result.replacingOccurrences(of: "یی", with: "ی")
        }

        return result
    }

    // Check if a word should have ZWNJ
    func shouldAddZWNJ(after word: String, nextChar: Character) -> Bool {
        let zwnjPrefixes = ["می", "نمی", "بر", "در", "با"]
        for prefix in zwnjPrefixes {
            if word.hasSuffix(prefix) {
                return true
            }
        }
        return false
    }

    // Insert ZWNJ at appropriate positions
    func insertZWNJ(in text: String) -> String {
        var result = text

        // Common patterns that need ZWNJ
        let patterns: [(String, String)] = [
            ("می ", "می\(FinglishConverter.ZWNJ)"),
            ("نمی ", "نمی\(FinglishConverter.ZWNJ)"),
            (" ها", "\(FinglishConverter.ZWNJ)ها"),
            (" های", "\(FinglishConverter.ZWNJ)های"),
            (" ام", "\(FinglishConverter.ZWNJ)ام"),
            (" ات", "\(FinglishConverter.ZWNJ)ات"),
            (" اش", "\(FinglishConverter.ZWNJ)اش"),
            (" ای", "\(FinglishConverter.ZWNJ)ای"),
            (" اند", "\(FinglishConverter.ZWNJ)اند"),
        ]

        for (pattern, replacement) in patterns {
            result = result.replacingOccurrences(of: pattern, with: replacement)
        }

        return result
    }
}
