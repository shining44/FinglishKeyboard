# Finglish Keyboard

A iOS keyboard extension that converts Finglish (Persian written in Latin characters) to Farsi in real-time.

## Project Structure

```
FinglishKeyboard/
├── FinglishKeyboard/              # Main app target
│   ├── FinglishKeyboardApp.swift  # App entry point
│   ├── ContentView.swift          # Main UI with setup guide, live demo, features
│   └── Assets.xcassets/           # App icons and colors
│
├── KeyboardExtension/             # Keyboard extension target
│   ├── KeyboardViewController.swift  # Main controller, KeyboardState class
│   ├── KeyboardView.swift            # SwiftUI keyboard layout, all key components
│   ├── FinglishConverter.swift       # Transliteration engine, typo corrections
│   ├── FinglishDictionary.swift      # 3200+ word dictionary, fuzzy matching
│   └── Views/
│       ├── KeyButton.swift           # Individual key with popup and alternates
│       └── SuggestionBar.swift       # Suggestion bar with undo button
│
└── FinglishKeyboard.xcodeproj
```

## Key Components

### KeyboardState (KeyboardViewController.swift)
Central state management for the keyboard. Handles:
- Text insertion/deletion via `textDocumentProxy`
- Shift/caps lock state
- Number/symbol mode switching
- Current word tracking and suggestions
- Undo stack for reverting conversions

### FinglishDictionary (FinglishDictionary.swift)
Singleton dictionary with 5000+ Finglish-to-Farsi mappings. Features:
- Prefix indexing for fast lookups
- Levenshtein distance for fuzzy matching
- Common letter substitution handling (aa/a, oo/o, gh/q)
- Next-word prediction pairs (260+)
- Categories: greetings, verbs, nouns, food, tech, business, slang, religious phrases

### FinglishConverter (FinglishConverter.swift)
Smart linguistic transliteration engine with:
- **Morphological Analysis**: Persian verb prefixes (mi-, nemi-, be-, na-) and suffixes (-am, -i, -e, etc.)
- **120+ Verb Stems**: Comprehensive dictionary covering motion, perception, communication, manipulation, emotions
- **Compound Word Recognition**: 60+ compound patterns (chetor, emruz, inja, haminjoor, etc.)
- **Position-Aware Vowels**: Different handling at start/middle/end of words (a→آ at start, ه at end)
- **200+ Typo Corrections**: Common misspellings, abbreviations, internet slang (slm→salam, tnx→mamnoon)
- **Phonetic Variant Generation**: Multiple spellings for ambiguous letters (s→س/ص/ث, z→ز/ض/ظ/ذ)
- **ZWNJ Handling**: Automatic half-space insertion for proper Persian typography
- **Word Ending Patterns**: Support for loanwords (tion→شن, ism→یسم)

## Build & Run

```bash
# Build for simulator
xcodebuild -scheme FinglishKeyboard -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run in simulator
xcrun simctl boot "iPhone 16"
open -a Simulator
xcodebuild -scheme FinglishKeyboard -destination 'platform=iOS Simulator,name=iPhone 16' -derivedDataPath /tmp/FinglishBuild build
xcrun simctl install "iPhone 16" /tmp/FinglishBuild/Build/Products/Debug-iphonesimulator/FinglishKeyboard.app
xcrun simctl launch "iPhone 16" com.alitayyebi.finglish
```

## Bundle IDs

- Main app: `com.alitayyebi.finglish`
- Keyboard extension: `com.alitayyebi.finglish.keyboard`
- Team ID: `R4J2Z4MU56`

## Key Features

1. **Real-time conversion**: Type Finglish, see Farsi suggestions
2. **Fuzzy matching**: Handles typos using Levenshtein distance
3. **Undo**: Revert last conversion to original Finglish
4. **Clear word**: X button to clear current input
5. **Long-press alternates**: All 26 letters have Persian alternatives
6. **Persian numbers**: Toggle for automatic numeral conversion
7. **ZWNJ**: Half-space key for proper Persian typography
8. **Cursor movement**: Swipe on space bar
9. **Double-tap space**: Inserts period
10. **Auto-capitalize**: After sentence endings
11. **Word prediction**: 260+ next-word pairs
12. **Live demo**: Test conversion in main app before enabling

## Adding New Words

In `FinglishDictionary.swift`, add to the appropriate category:

```swift
addWords([
    ("finglish", ["فارسی"], 90),  // (finglish, [farsi options], frequency)
])
```

Higher frequency = higher priority in suggestions.

## Adding Typo Corrections

In `FinglishConverter.swift`, add to `typoCorrections`:

```swift
"typo": "correct",
```

## Testing the Keyboard

1. Build and run on simulator
2. Go to Settings > General > Keyboard > Keyboards > Add New Keyboard
3. Select "Finglish Keyboard"
4. Open Notes or any text field
5. Tap globe icon to switch to Finglish Keyboard
6. Type: salam, mersi, chetori, khobi, mamnoon

## Engine Architecture

The transliteration engine (`FinglishConverter`) processes input through multiple strategies:

1. **Typo Correction**: Common misspellings fixed first (slm→salam)
2. **Dictionary Lookup**: Direct match against 5000+ known words
3. **Compound Word Matching**: Recognizes compound patterns (che+tor→چطور)
4. **Morphological Analysis**: Detects prefix+stem+suffix (mi+rav+am→می‌روم)
5. **Context-Aware Transliteration**: Position-sensitive vowel handling
6. **Phonetic Variants**: Generates alternatives for ambiguous letters
7. **Simple Fallback**: Character-by-character conversion

Each step adds suggestions, with duplicates filtered and results limited to top 5.

## Known Issues & Fixes

### Short Input Crash (Fixed)
**Bug:** App crashed immediately when typing 1-2 characters.
**Cause:** `tryCompoundMatch` created invalid range `2..<0` for short inputs.
**Fix:** Added guard clause: `guard lowered.count >= 3 else { return nil }`

### Important Implementation Notes
- **Keyboard extensions have strict memory limits (~30MB)** - keep dictionaries reasonably sized
- **Always validate range bounds** before creating Swift ranges - `2..<min(count-1, 6)` crashes if count < 3
- **Test with single character inputs** - easy to miss edge cases
- **Duplicate dictionary keys** cause warnings but don't crash - still fix them for clean builds

## App Store Submission

```bash
# Archive and upload to App Store Connect
xcodebuild -scheme FinglishKeyboard archive -archivePath /tmp/FinglishKeyboard.xcarchive -allowProvisioningUpdates
xcodebuild -exportArchive -archivePath /tmp/FinglishKeyboard.xcarchive -exportPath /tmp/FinglishExport -exportOptionsPlist /tmp/ExportOptions.plist -allowProvisioningUpdates
```

## Xcode Cloud Auto-Deploy

To enable automatic TestFlight deployment on every push:

1. Open Xcode → Product → Xcode Cloud → Manage Workflows
2. Select your workflow → Edit
3. Scroll to **Post-Actions**
4. Click **+** → Select **"TestFlight Internal Testing"**
5. Save

Now every push to `main` automatically builds and uploads to TestFlight.
