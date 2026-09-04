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

    func testCanonicalVerbTokensAreCorrectInsideWordsAndPhrases() {
        assertTopSuggestions([
            "mireh": "می‌ره",
            "mirin": "می‌رین",
            "mideh": "می‌ده",
            "midin": "می‌دین",
            "migeh": "می‌گه",
            "mikoneh": "می‌کنه",
            "nemitonam": "نمی‌تونم",
            "cant": "نمی‌تونم",
            "anha": "آن‌ها",
            "miyan": "میان",
            "tabrik migam": "تبریک می‌گم",
            "chikar mikoni": "چیکار می‌کنی",
            "dorugh migi": "دروغ می‌گی",
            "rast migi": "راست می‌گی",
            "gush mide": "گوش می‌ده",
            "yad midam": "یاد می‌دم",
        ])

        XCTAssertEqual(
            PersianOrthography.canonicalize("چیکار میکنی؟"),
            "چیکار می‌کنی؟"
        )
        XCTAssertEqual(
            PersianOrthography.canonicalize("تبریک میگم"),
            "تبریک می‌گم"
        )
    }

    func testProductiveSuffixesAndCompoundsKeepCanonicalBoundaries() {
        assertTopSuggestions([
            "ketabha": "کتاب‌ها",
            "ketabhaye": "کتاب‌های",
            "ketabhayi": "کتاب‌هایی",
            "ketabhayam": "کتاب‌هایم",
            "khaneha": "خانه‌ها",
            "golha": "گل‌ها",
            "khaneam": "خانه‌ام",
            "khaneash": "خانه‌اش",
            "rafteam": "رفته‌ام",
            "rafteim": "رفته‌ایم",
            "dideam": "دیده‌ام",
            "didei": "دیده‌ای",
            "zibatar": "زیباتر",
            "rahattar": "راحت‌تر",
            "bozorgtar": "بزرگ‌تر",
            "bozorgtarin": "بزرگ‌ترین",
            "narmafzar": "نرم‌افزار",
            "dastneveshte": "دست‌نوشته",
            "bikhabar": "بی‌خبر",
            "jostoju": "جست‌وجو",
            "josteju": "جست‌وجو",
        ])
    }

    func testPreviouslyDanglingTypoTargetsResolveLexically() {
        assertTopSuggestions([
            "amadam": "آمدم",
            "amaadm": "آمدم",
            "bezar": "بذار",
            "bzar": "بذار",
            "bozar": "بذار",
            "besho": "بشو",
            "bisho": "بشو",
            "bsho": "بشو",
            "chish": "چیش",
            "khuneh": "خونه",
            "khoone": "خونه",
            "miresam": "می‌رسم",
            "miresm": "می‌رسم",
            "lol": "خنده",
            "lmao": "خنده",
            "xd": "خنده",
            "ppl": "مردم",
            "pplz": "مردم",
            "cya": "می‌بینمت",
            "btw": "راستی",
            "anyway": "راستی",
            "jk": "شوخی کردم",
            "jking": "شوخی کردم",
            "zalim": "ظالم",
            "zaleem": "ظالم",
            "zaalm": "ظالم",
            "astaghfr": "استغفرالله",
            "astaghfor": "استغفرالله",
            "kji": "کجایی",
            "kojii": "کجایی",
            "jonm": "جونم",
            "yarb": "یا رب",
            "yarab": "یا رب",
            "yaraab": "یا رب",
            "jazak": "جزاک‌الله",
            "jazakalla": "جزاک‌الله",
            "kiaa": "کیا",
            "inhaa": "این‌ها",
            "aha": "آها",
            "ahaa": "آها",
            "tangt": "تنگت",
            "tengit": "تنگیت",
        ])
    }

    func testMalformedStemAndPersonFormsAreCorrected() {
        assertTopSuggestions([
            "poshtam": "پشتم",
            "poshti": "پشتی",
            "neshundad": "نشون داد",
            "neshundadam": "نشون دادم",
            "kesid": "کشید",
            "kesidam": "کشیدم",
            "biayin": "بیاین",
            "mishinan": "می‌شینن",
            "miyayand": "می‌آیند",
            "mikhahi": "می‌خواهی",
            "mikhahad": "می‌خواهد",
            "midanad": "می‌داند",
            "mitavanad": "می‌تواند",
            "nemikhahad": "نمی‌خواهد",
            "nemidanad": "نمی‌داند",
            "nemitavanad": "نمی‌تواند",
            "khasteam": "خسته‌ام",
        ])

        XCTAssertFalse(FinglishDictionary.shared.hasExactMatch(for: "nishinan"))
    }

    func testAdditionalCanonicalHamzaAliases() {
        assertTopSuggestions([
            "taakid": "تأکید",
            "takid": "تأکید",
            "taalif": "تألیف",
            "talif": "تألیف",
            "taammol": "تأمل",
            "taasof": "تأسف",
            "moteasser": "متأثر",
            "moteakher": "متأخر",
            "moallef": "مؤلف",
            "moaddab": "مؤدب",
            "roasa": "رؤسا",
            "shooun": "شئون",
            "jorat": "جرئت",
            "mamoor": "مأمور",
            "mamur": "مأمور",
            "mayoos": "مأیوس",
            "mayus": "مأیوس",
            "maakhaz": "مأخذ",
            "makhaz": "مأخذ",
            "moakhaze": "مؤاخذه",
        ])

        let migrations = [
            "تاکید": "تأکید",
            "تالیف": "تألیف",
            "تامل": "تأمل",
            "تاسف": "تأسف",
            "متاثر": "متأثر",
            "متاخر": "متأخر",
            "مولف": "مؤلف",
            "مودب": "مؤدب",
            "روسا": "رؤسا",
            "جرات": "جرئت",
            "مامور": "مأمور",
            "مایوس": "مأیوس",
            "ماخذ": "مأخذ",
            "مواخذه": "مؤاخذه",
        ]

        for (legacy, canonical) in migrations {
            XCTAssertEqual(PersianOrthography.canonicalize(legacy), canonical, legacy)
        }
    }

    func testHighConfidenceLexicalFallbackGapsAreExactWords() {
        assertTopSuggestions([
            "daghigh": "دقیق",
            "daghighan": "دقیقاً",
            "kamelan": "کاملاً",
            "rasman": "رسماً",
            "shey": "شیء",
            "qoran": "قرآن",
            "etelaat": "اطلاعات",
            "ertebat": "ارتباط",
            "entezar": "انتظار",
            "elm": "علم",
            "omr": "عمر",
            "zarf": "ظرف",
            "mosbat": "مثبت",
            "ensaf": "انصاف",
            "ensan": "انسان",
            "emkan": "امکان",
            "emza": "امضا",
            "ehtiyat": "احتیاط",
            "estelah": "اصطلاح",
            "dalil": "دلیل",
            "nazar": "نظر",
            "darkhast": "درخواست",
            "vaziyat": "وضعیت",
            "sharayet": "شرایط",
            "ahamiyat": "اهمیت",
            "mozu": "موضوع",
            "mozoo": "موضوع",
            "ayande": "آینده",
        ])
    }

    func testAmbiguousLatinKeysKeepTheirIntendedLexicalFamilies() {
        assertTopSuggestions([
            "sher": "شعر",
            "shir": "شیر",
            "shar": "شر",
            "abi": "آبی",
            "abji": "آبجی",
            "unja": "اونجا",
            "anja": "آنجا",
            "hichchi": "هیچ‌چی",
            "hichi": "هیچی",
            "egg": "تخم‌مرغ",
        ])

        let forbidden: [String: Set<String>] = [
            "abi": ["آبجی"],
            "unja": ["آنجا"],
            "hichchi": ["هیچی"],
            "sher": ["شیر", "شر"],
            "egg": ["تخم مرغ"],
        ]

        for (input, removed) in forbidden {
            XCTAssertTrue(
                Set(converter.getSuggestions(for: input)).isDisjoint(with: removed),
                input
            )
        }
    }

    func testExactDictionaryWordsDoNotLeakGeneratedAlternatives() {
        let input = "motasefane"
        let dictionarySuggestions = Set(
            FinglishDictionary.shared
                .findCandidates(for: input, includeFuzzy: false, limit: 10)
                .map(\.value)
        )
        let converterSuggestions = Set(converter.getSuggestions(for: input))

        XCTAssertFalse(dictionarySuggestions.isEmpty)
        XCTAssertTrue(
            converterSuggestions.isSubset(of: dictionarySuggestions),
            "generated alternatives leaked for an exact key: \(converterSuggestions)"
        )
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
