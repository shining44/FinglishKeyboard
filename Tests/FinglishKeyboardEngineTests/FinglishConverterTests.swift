import XCTest
@testable import FinglishKeyboardEngine

final class FinglishConverterTests: XCTestCase {
    private let converter = FinglishConverter()

    func testExactDictionaryCandidatesOutrankGeneratedHeuristics() {
        let cases = [
            (input: "moalem", expected: "معلم"),
            (input: "moallem", expected: "معلم"),
            (input: "hoselaem", expected: "حوصله‌ام"),
            (input: "khane", expected: "خانه"),
            (input: "mikhan", expected: "می‌خوان"),
            (input: "chetore", expected: "چطوره"),
            (input: "mah", expected: "ماه"),
            (input: "yeki", expected: "یکی"),
        ]

        for testCase in cases {
            XCTAssertEqual(
                converter.getSuggestions(for: testCase.input).first,
                testCase.expected,
                "Unexpected first suggestion for \(testCase.input)"
            )
        }
    }

    func testGeneratedObjectCliticStillWorksForUnknownCompound() {
        XCTAssertEqual(
            converter.getSuggestions(for: "mibinamet").first,
            "می‌بینمت"
        )
    }

    func testCuratedPersianSpellingRemainsLossless() {
        let cases = [
            (input: "mamnoon", expected: "ممنون"),
            (input: "nemidonam", expected: "نمی‌دونم"),
            (input: "mikahm", expected: "می‌خوام"),
            (input: "vaseye", expected: "واسه‌ی"),
            (input: "felan", expected: "فعلاً"),
        ]

        for testCase in cases {
            XCTAssertEqual(
                converter.getSuggestions(for: testCase.input).first,
                testCase.expected,
                "Curated spelling changed for \(testCase.input)"
            )
        }
    }

    func testBoundedTypoRecoveryFindsExpectedWords() {
        XCTAssertTrue(converter.getSuggestions(for: "slma").prefix(3).contains("سلام"))
        XCTAssertEqual(converter.getSuggestions(for: "xodafez").first, "خداحافظ")
        XCTAssertEqual(converter.getSuggestions(for: "qabel").first, "قابل")
    }
}
