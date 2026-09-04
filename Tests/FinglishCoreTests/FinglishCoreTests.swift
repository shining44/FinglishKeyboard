import XCTest
@testable import FinglishCore

final class FinglishCoreTests: XCTestCase {
    private let converter = FinglishConverter()

    func testReportedMotasefFamilyUsesCanonicalSpelling() {
        assertTopSuggestions([
            "motasef": "متأسف",
            "moteasef": "متأسف",
            "motasf": "متأسف",
            "motasefam": "متأسفم",
            "moteasefam": "متأسفم",
            "motasefane": "متأسفانه",
            "motasefaneh": "متأسفانه",
            "moteasefane": "متأسفانه",
            "moteasefaneh": "متأسفانه",
            "motasfane": "متأسفانه",
            "motassefane": "متأسفانه",
            "moteassefane": "متأسفانه",
            "motaassefane": "متأسفانه",
        ])

        for input in ["motasefane", "motasefaneh", "moteasefane", "motassefane"] {
            XCTAssertFalse(converter.getSuggestions(for: input).contains("موتاسهفانه"), input)
            XCTAssertFalse(converter.getSuggestions(for: input).contains("متاسفانه"), input)
        }
    }

    func testFormalAndColloquialFormsRemainDistinct() {
        assertTopSuggestions([
            "mikhaham": "می‌خواهم",
            "mikham": "می‌خوام",
            "midaham": "می‌دهم",
            "midam": "می‌دم",
            "miravam": "می‌روم",
            "miram": "می‌رم",
            "miayam": "می‌آیم",
            "miyayam": "می‌آیم",
            "miyayi": "می‌آیی",
            "miyayad": "می‌آید",
            "miyaim": "می‌آییم",
            "miyaid": "می‌آیید",
            "miam": "میام",
            "miguiam": "می‌گویم",
            "migam": "می‌گم",
            "midanam": "می‌دانم",
            "midoonam": "می‌دونم",
            "mitavanam": "می‌توانم",
            "mitoonam": "می‌تونم",
            "nemidanam": "نمی‌دانم",
            "nemidoonam": "نمی‌دونم",
            "khane": "خانه",
            "khune": "خونه",
        ])
    }

    func testArabicLoanwordAndAdverbAliases() {
        assertTopSuggestions([
            "ehtemaalan": "احتمالاً",
            "vaqean": "واقعاً",
            "vagheaan": "واقعاً",
            "etefaghan": "اتفاقاً",
            "ettefaghan": "اتفاقاً",
            "etefaqan": "اتفاقاً",
            "masalan": "مثلاً",
            "mesalan": "مثلاً",
            "masool": "مسئول",
            "masul": "مسئول",
            "masooliyat": "مسئولیت",
            "masooliat": "مسئولیت",
            "soal": "سؤال",
            "soaal": "سؤال",
            "sual": "سؤال",
            "taeed": "تأیید",
            "taeid": "تأیید",
            "tasir": "تأثیر",
            "taasir": "تأثیر",
            "tasis": "تأسیس",
            "tamin": "تأمین",
            "takhir": "تأخیر",
            "motmaen": "مطمئن",
            "masale": "مسئله",
            "moassese": "مؤسسه",
            "heyat": "هیئت",
            "jozi": "جزئی",
            "masayel": "مسائل",
            "mabda": "مبدأ",
            "mansha": "منشأ",
            "momen": "مؤمن",
            "moasser": "مؤثر",
            "moteahel": "متأهل",
        ])
    }

    func testFinalAneAdverbAliases() {
        assertTopSuggestions([
            "khoshbakhtane": "خوشبختانه",
            "khoshbakhtaneh": "خوشبختانه",
            "mohtaramane": "محترمانه",
            "mohtaramaneh": "محترمانه",
            "mohtatane": "محتاطانه",
            "mohtataneh": "محتاطانه",
            "sadeghane": "صادقانه",
            "sadeghaneh": "صادقانه",
            "doostane": "دوستانه",
            "doostaneh": "دوستانه",
            "agahane": "آگاهانه",
            "agahaneh": "آگاهانه",
            "amiyane": "عامیانه",
            "amiyaneh": "عامیانه",
        ])
    }

    func testCanonicalOrthographyWinsExactKeyCollisions() {
        assertTopSuggestions([
            "hatman": "حتماً",
            "hichvaght": "هیچ‌وقت",
            "abmive": "آب‌میوه",
            "website": "وب‌سایت",
            "aslaan": "اصلاً",
            "inshallah": "ان‌شاءالله",
            "enshallah": "ان‌شاءالله",
            "mashallah": "ماشاءالله",
            "mishe": "می‌شه",
            "nemishe": "نمی‌شه",
            "mikonam": "می‌کنم",
            "miran": "می‌رن",
            "midam": "می‌دم",
            "mituni": "می‌تونی",
        ])
    }

    func testChatAliasesAndObjectClitics() {
        assertTopSuggestions([
            "doset": "دوستت",
            "dooset": "دوستت",
            "ily": "دوستت دارم",
            "luv": "دوستت دارم",
            "ilysm": "خیلی دوستت دارم",
            "brb": "می‌رم و برمی‌گردم",
            "bbl": "بعداً میام",
            "gtg": "باید برم",
            "g2g": "باید برم",
            "idc": "برام مهم نیست",
            "dgaf": "برام مهم نیست",
            "tbh": "راستش",
            "ngl": "راستش",
            "ttyl": "بعداً حرف می‌زنیم",
            "wbu": "تو چطور؟",
            "hbu": "تو چطور؟",
            "gm": "صبح بخیر",
            "gn": "شب بخیر",
            "asap": "هرچه زودتر",
        ])
    }

    func testLegacyPersianValuesCanonicalizeBeforeRanking() {
        XCTAssertEqual(PersianOrthography.canonicalize("متاسفانه"), "متأسفانه")
        XCTAssertEqual(PersianOrthography.canonicalize("انشاالله"), "ان‌شاءالله")
        XCTAssertEqual(PersianOrthography.canonicalize("میشه"), "می‌شه")
        XCTAssertEqual(PersianOrthography.canonicalize("ميشه"), "می‌شه")
        XCTAssertEqual(PersianOrthography.canonicalize("می‌آم"), "میام")
    }

    func testDictionaryOrthographicInvariants() {
        XCTAssertEqual(FinglishDictionary.shared.orthographicInvariantViolations(), [])
    }

    func testRemovedSpellingsDoNotSurviveAsAlternatives() {
        let cases: [String: Set<String>] = [
            "motasefane": ["متاسفانه", "موتاسهفانه"],
            "enshallah": ["انشاالله", "انشالله"],
            "mashallah": ["ماشالله", "ماشاالله"],
            "miam": ["می‌آم"],
            "miyad": ["می‌آد"],
            "miyai": ["می‌آی"],
            "mikoni": ["میکنی"],
            "migam": ["میگم"],
            "midam": ["میدم"],
            "miram": ["میرم"],
            "nemishe": ["نمیشه"],
        ]

        for (input, forbidden) in cases {
            let suggestions = Set(converter.getSuggestions(for: input))
            XCTAssertTrue(suggestions.isDisjoint(with: forbidden), "\(input): \(suggestions)")
        }
    }

    func testAnInfinitivesDoNotExposeFormalThirdPersonPlural() {
        let dictionary = FinglishDictionary.shared
        for input in [
            "raftan", "oomadan", "khastan", "donestan", "didan",
            "goftan", "khordan", "dadan", "gereftan", "toonestan",
        ] {
            let exactValues = dictionary
                .findCandidates(for: input, includeFuzzy: false, limit: 20)
                .compactMap { candidate -> String? in
                    if case .exact = candidate.source {
                        return candidate.value
                    }
                    return nil
                }

            XCTAssertFalse(exactValues.contains(where: { $0.hasSuffix("ند") }), "\(input): \(exactValues)")
        }
    }

    private func assertTopSuggestions(
        _ cases: [String: String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for (input, expected) in cases.sorted(by: { $0.key < $1.key }) {
            XCTAssertEqual(
                converter.getSuggestions(for: input).first,
                expected,
                input,
                file: file,
                line: line
            )
        }
    }
}
