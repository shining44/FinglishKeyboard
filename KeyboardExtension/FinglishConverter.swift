import Foundation

class FinglishConverter {

    private let dictionary = FinglishDictionary.shared

    // ZWNJ (Zero Width Non-Joiner) for proper Farsi word separation
    static let ZWNJ = "\u{200C}"

    // ============================================
    // MORPHOLOGICAL PATTERNS - Persian word structure
    // ============================================

    // Verb prefixes (most specific first)
    private let verbPrefixes: [(finglish: String, farsi: String)] = [
        ("nemi", "نمی"),
        ("bemi", "بمی"),  // rare but exists
        ("mi", "می"),
        ("be", "ب"),
        ("na", "ن"),
        ("bo", "ب"),
        ("bi", "بی"),
    ]

    // Verb suffixes - Present tense conjugations
    private let presentSuffixes: [(finglish: String, farsi: String)] = [
        ("and", "ند"),
        ("am", "م"),
        ("im", "یم"),
        ("in", "ین"),
        ("id", "ید"),
        ("ad", "د"),
        ("i", "ی"),
        ("e", "ه"),
        ("eh", "ه"),
        ("an", "ن"),
    ]

    // Verb suffixes - Past tense conjugations
    private let pastSuffixes: [(finglish: String, farsi: String)] = [
        ("am", "م"),
        ("im", "یم"),
        ("id", "ید"),
        ("in", "ین"),
        ("i", "ی"),
        ("and", "ند"),
        ("an", "ن"),
    ]

    // Past tense stems (for verbs without mi- prefix)
    private let pastTenseStems: [String: String] = [
        // Common past tense verb stems
        "raft": "رفت", "rft": "رفت",
        "amad": "آمد", "omad": "اومد", "umad": "اومد",
        "kard": "کرد", "krd": "کرد",
        "goft": "گفت", "gft": "گفت",
        "did": "دید",
        "khord": "خورد", "khrd": "خورد",
        "shenid": "شنید", "shnid": "شنید",
        "fahmid": "فهمید", "fhmid": "فهمید",
        "gereft": "گرفت", "greft": "گرفت", "grift": "گرفت",
        "nevesht": "نوشت", "nevsht": "نوشت",
        "khund": "خوند", "khand": "خواند",
        "resid": "رسید", "rsid": "رسید",
        "shod": "شد", "shud": "شد",
        "bud": "بود", "bood": "بود",
        "dasht": "داشت", "dsht": "داشت",
        "khast": "خواست", "khst": "خواست",
        "zad": "زد",
        "keshid": "کشید", "kshid": "کشید",
        "doshid": "دوشید",
        "pushid": "پوشید",
        "gozasht": "گذاشت", "gzasht": "گذاشت",
        "afgand": "افکند", "andakht": "انداخت",
        "sakht": "ساخت",
        "bastan": "بست", "bast": "بست",
        "shost": "شست",
        "mord": "مرد", "murd": "مرد",
        "zist": "زیست",
        "kharid": "خرید", "khrid": "خرید",
        "forukht": "فروخت",
        "avord": "آورد", "oovord": "اوورد",
        "bord": "برد",
        "khaband": "خوابوند", "khabid": "خوابید",
        "neshast": "نشست", "nshast": "نشست",
        "istad": "ایستاد", "vastad": "وایستاد",
        "tarsid": "ترسید",
        "khandid": "خندید",
        "gerist": "گریست",
        "oftad": "افتاد",
        "parid": "پرید",
        "david": "دوید",
    ]

    // Imperative prefixes and patterns
    private let imperativePrefixes: [(finglish: String, farsi: String)] = [
        ("be", "ب"),
        ("bo", "ب"),
        ("na", "ن"),  // Negative imperative
    ]

    // Noun/adjective suffixes
    private let nounSuffixes: [(finglish: String, farsi: String)] = [
        ("hayeshan", "هایشان"),
        ("hayeman", "هایمان"),
        ("hayetan", "هایتان"),
        ("hayash", "هایش"),
        ("hayam", "هایم"),
        ("hayat", "هایت"),
        ("hayand", "هایند"),
        ("haye", "های"),
        ("haaye", "های"),
        ("hayee", "هایی"),
        ("haa", "ها"),
        ("ha", "ها"),
        ("ye", "ی"),
        ("iye", "یه"),
        ("aye", "ای"),
        ("ee", "ی"),
        ("tar", "تر"),
        ("tarin", "ترین"),
        ("esh", "ش"),
        ("ash", "ش"),
        ("eshun", "شون"),
        ("ashun", "شون"),
        ("eman", "مان"),
        ("etan", "تان"),
        ("eshan", "شان"),
        ("emun", "مون"),
        ("etun", "تون"),
        ("eshun", "شون"),
        ("am", "م"),
        ("at", "ت"),
        ("i", "ی"),
    ]

    // Conversational object clitics after finite verbs: mibinamet -> می‌بینمت.
    private let objectCliticSuffixes: [(finglish: String, farsi: String)] = [
        ("eshoon", "شون"),
        ("eshun", "شون"),
        ("etoon", "تون"),
        ("etun", "تون"),
        ("emoon", "مون"),
        ("emun", "مون"),
        ("esh", "ش"),
        ("et", "ت"),
        ("em", "م"),
    ]

    // Comprehensive verb stems dictionary (finglish -> farsi stem)
    private let verbStems: [String: String] = [
        // === MOTION & MOVEMENT ===
        "rav": "رو", "ro": "رو", "raft": "رفت", "boro": "رو",
        "a": "آ", "ay": "آی", "ya": "یا", "amad": "آمد", "bia": "بیا",
        "bar": "بر", "bord": "برد", "bor": "بر",
        "pas": "پس", "pasand": "پسند",
        "gard": "گرد", "gardid": "گردید", "gasht": "گشت",
        "oft": "افت", "oftad": "افتاد", "riz": "ریز",
        "par": "پر", "parid": "پرید", "kiz": "خیز", "khiz": "خیز",
        "dav": "دو", "david": "دوید", "dow": "دو",
        "rand": "راند", "ran": "ران",

        // === PERCEPTION & COGNITION ===
        "bin": "بین", "did": "دید", "binad": "بیند",
        "sheno": "شنو", "shenav": "شنو", "shenid": "شنید",
        "fahm": "فهم", "fahmid": "فهمید",
        "dan": "دان", "dun": "دون", "don": "دون", "danest": "دانست",
        "fekr": "فکر", "andish": "اندیش", "andishid": "اندیشید",
        "yad": "یاد", "yadgir": "یادگیر",
        "shenakh": "شناخت", "shenas": "شناس",

        // === COMMUNICATION ===
        "g": "گ", "gu": "گو", "go": "گو", "goo": "گو", "goft": "گفت",
        "khun": "خون", "khan": "خوان", "khund": "خوند", "khand": "خواند",
        "nevis": "نویس", "nevesht": "نوشت", "nevisand": "نویسند",
        "pors": "پرس", "porsid": "پرسید",
        "neshun": "نشون", "neshan": "نشان", "neshundad": "نشون داد",
        "gush": "گوش", "gushid": "گوشید",

        // === EATING & DRINKING ===
        "khor": "خور", "khord": "خورد",
        "nush": "نوش", "nushid": "نوشید", "noosh": "نوش",
        "paz": "پز", "pokht": "پخت", "pazi": "پزی",
        "chesh": "چش", "cheshid": "چشید",

        // === HANDLING & MANIPULATION ===
        "kon": "کن", "kar": "کار", "kun": "کن", "kard": "کرد",
        "zan": "زن", "zad": "زد",
        "gir": "گیر", "gereft": "گرفت", "greft": "گرفت",
        "gozar": "گذار", "gozasht": "گذاشت", "zar": "ذار", "zasht": "ذاشت",
        "dar": "دار", "dasht": "داشت", "daram": "دارم",
        "de": "ده", "deh": "ده", "dad": "داد", "dadan": "دادن",
        "khast": "خواست", "kha": "خوا", "khah": "خواه",
        "bast": "بست", "band": "بند",
        "chasb": "چسب", "chasbid": "چسبید", "chasband": "چسباند",
        "kash": "کش", "kashid": "کشید",
        "feshar": "فشار", "feshord": "فشرد",
        "lez": "لیز", "laghz": "لغز", "laghzid": "لغزید",
        "tekun": "تکون", "tekan": "تکان",

        // === BEING & BECOMING ===
        "sh": "ش", "shod": "شد", "sho": "شو", "shav": "شو", "shodan": "شدن",
        "bud": "بود", "bood": "بود", "bash": "باش", "budan": "بودن",
        "hast": "هست", "nist": "نیست", "ast": "است",
        "mun": "مون", "man": "مان", "mund": "موند", "mand": "ماند",
        "zist": "زیست", "zindegi": "زندگی",

        // === ABILITY & PERMISSION ===
        "tun": "تون", "ton": "تون", "tavan": "توان", "tunesht": "تونست", "tavanest": "توانست",
        "bayad": "باید",

        // === SLEEP & REST ===
        "khab": "خواب", "khabid": "خوابید", "khoft": "خفت",
        "bidari": "بیداری", "bidar": "بیدار",
        "neshin": "نشین", "neshast": "نشست", "shin": "شین",
        "ist": "ایست", "istad": "ایستاد", "vaist": "وایست",

        // === EMOTIONS ===
        "tars": "ترس", "tarsid": "ترسید",
        "khandid": "خندید",
        "gerye": "گریه", "gerist": "گریست", "geri": "گری",
        "ashegh": "عاشق", "eshgh": "عشق",
        "dard": "درد", "kesh": "کش",
        "khosh": "خوش", "khoshhalam": "خوشحالم",
        "narahat": "ناراحت",
        "ajab": "عجب",

        // === WORK & PRODUCTION ===
        "saz": "ساز", "sakht": "ساخت",
        "barid": "بارید",
        "kand": "کند", "kandeh": "کنده",
        "afarin": "آفرین", "afarid": "آفرید",
        "parvand": "پرورد", "parvar": "پرور",
        "gar": "گر", "gari": "گری",

        // === OPENING & CLOSING ===
        "baz": "باز", "bastan": "بستن",
        "bastand": "بستند",
        "vaz": "واز",

        // === CLEANING & APPEARANCE ===
        "shor": "شور", "shost": "شست", "shuy": "شوی",
        "pak": "پاک", "pakkon": "پاک‌کن",
        "range": "رنگ", "rangkon": "رنگ‌کن",
        "posh": "پوش", "pushid": "پوشید", "push": "پوش",

        // === SEARCHING & FINDING ===
        "gardesh": "گردش",
        "juy": "جو", "jost": "جست", "joy": "جوی",
        "yab": "یاب", "yaft": "یافت",
        "peyda": "پیدا",

        // === SENDING & RECEIVING ===
        "ferest": "فرست", "ferestad": "فرستاد",
        "rasid": "رسید", "res": "رس", "ras": "رس",

        // === LIVING & LIFE ===
        "zindigii": "زندگی",
        "mord": "مرد", "mir": "میر", "mur": "مور",
        "kushit": "کشت", "kosh": "کش",

        // === SPEAKING ===
        "guy": "گوی", "guftan": "گفتن",
        "harf": "حرف", "harfzan": "حرف‌زن",
        "sohbat": "صحبت",
        "sadaa": "صدا", "seda": "صدا",

        // === COLLOQUIAL STEMS ===
        "pich": "پیچ", "pichid": "پیچید", "pichund": "پیچوند",
        "chin": "چین", "chid": "چید",
        "kub": "کوب", "kubid": "کوبید",
        "borid": "برید", "burid": "برید",
        "doz": "دوز", "dukht": "دوخت", "dookht": "دوخت",
        "kes": "کس", "kesid": "کشید",
        "vel": "ول", "volkon": "ول‌کن",

        // === ADDITIONAL COMMON STEMS ===
        "resid": "رسید",
        "navisht": "نوشت",
        "bidarsho": "بیدار شو",
        "afta": "افت",
        "koshid": "کوشید", "kush": "کوش",
        "shenakht": "شناخت",
        "por": "پر", "porkon": "پر کن",
        "khali": "خالی", "khalikon": "خالی کن",
        "azordeh": "آزرده",
        "sanad": "سند",
        "pazand": "پزند",
        "forosh": "فروش",
        "khar": "خر",
    ]

    // Common non-verb stems that should remain lexical when suffixes are added.
    // This keeps words like badi -> بدی from falling back to phonetic بادی.
    private let lexicalStems: [String: String] = [
        "ketab": "کتاب",
        "bad": "بد",
        "khub": "خوب",
        "khoob": "خوب",
        "jadid": "جدید",
        "ghadim": "قدیم",
        "ziba": "زیبا",
        "ghashang": "قشنگ",
        "khoshgel": "خوشگل",
        "khoshkel": "خوشکل",
        "zesht": "زشت",
        "bozorg": "بزرگ",
        "kuchik": "کوچیک",
        "kuchak": "کوچک",
        "sard": "سرد",
        "garm": "گرم",
        "asoon": "آسون",
        "asan": "آسان",
        "sakht": "سخت",
        "rahat": "راحت",
        "kharab": "خراب",
        "dorost": "درست",
        "ghalat": "غلط"
    ]

    // ============================================
    // COMPOUND WORDS & COMMON PATTERNS
    // ============================================

    // Common compound word parts that should stay together
    private let compoundParts: [(first: String, second: String, result: String)] = [
        // Question words
        ("che", "tor", "چطور"), ("che", "tori", "چطوری"),
        ("che", "gune", "چگونه"), ("che", "goneh", "چگونه"),
        ("chi", "kar", "چیکار"), ("che", "kar", "چکار"),
        ("ko", "ja", "کجا"), ("ko", "jast", "کجاست"),
        ("ki", "ja", "کی"), ("che", "ra", "چرا"),
        ("che", "ghad", "چقدر"), ("che", "ghadr", "چقدر"),

        // Common compound nouns
        ("kho", "daa", "خدا"), ("kho", "da", "خدا"),
        ("ha", "me", "همه"), ("hame", "chi", "همه‌چی"),
        ("ham", "in", "همین"), ("ham", "un", "همون"),
        ("ham", "on", "همون"), ("ham", "inja", "همینجا"),
        ("ham", "unja", "همونجا"),

        // Time words
        ("em", "ruz", "امروز"), ("em", "rooz", "امروز"),
        ("em", "shab", "امشب"), ("far", "da", "فردا"),
        ("di", "ruz", "دیروز"), ("di", "rooz", "دیروز"),
        ("pari", "ruz", "پریروز"), ("pas", "farda", "پس‌فردا"),
        ("sob", "haa", "صبحا"), ("shab", "haa", "شبا"),

        // Compound verbs (noun + kardan/shodan)
        ("ye", "dafe", "یه‌دفعه"), ("yek", "dafe", "یکدفعه"),
        ("dobare", "h", "دوباره"), ("har", "ruz", "هرروز"),
        ("har", "shab", "هرشب"), ("har", "ja", "هرجا"),
        ("har", "ki", "هرکی"), ("har", "chi", "هرچی"),
        ("har", "chand", "هرچند"),

        // Demonstratives
        ("in", "ja", "اینجا"), ("un", "ja", "اونجا"),
        ("oo", "n", "اون"), ("ii", "n", "این"),
        ("in", "ha", "اینها"), ("un", "ha", "اونها"),
        ("in", "tor", "اینطور"), ("un", "tor", "اونطور"),
        ("in", "joori", "اینجوری"), ("un", "joori", "اونجوری"),

        // With ZWNJ patterns
        ("mi", "kham", "می‌خوام"), ("mi", "ram", "می‌رم"),
        ("ne", "mi", "نمی"), ("be", "zan", "بزن"),

        // Family terms
        ("pesar", "am", "پسرم"), ("dokhtar", "am", "دخترم"),
        ("madar", "am", "مادرم"), ("pedar", "am", "پدرم"),
        ("khaharam", "", "خواهرم"), ("baradaram", "", "برادرم"),

        // Common expressions
        ("kho", "sh", "خوش"), ("kho", "b", "خوب"),
        ("be", "htarin", "بهترین"), ("bad", "tarin", "بدترین"),
        ("bi", "shtar", "بیشتر"), ("kam", "tar", "کمتر"),
        ("asan", "tar", "آسان‌تر"), ("sakht", "tar", "سخت‌تر"),

        // Location
        ("bir", "un", "بیرون"), ("tu", "ye", "توی"),
        ("da", "khel", "داخل"), ("ba", "la", "بالا"),
        ("paa", "yin", "پایین"), ("ru", "ye", "روی"),
        ("zi", "re", "زیر"), ("po", "shte", "پشت"),
        ("ja", "lo", "جلو"), ("kan", "ar", "کنار"),
    ]

    // Common word patterns (regex-like patterns)
    private let wordPatterns: [(pattern: String, transform: (String) -> String)] = []

    // Words that typically end with specific sounds
    private let wordEndingPatterns: [String: String] = [
        "tion": "شن",
        "sion": "ژن",
        "ism": "یسم",
        "ist": "یست",
        "ity": "یتی",
        "ness": "نس",
        "ment": "منت",
        "able": "یبل",
        "ible": "یبل",
    ]

    // ============================================
    // PHONETIC MAPPINGS - Context-aware
    // ============================================

    // Digraphs and trigraphs (process first, longest match)
    private let multiCharMappings: [(pattern: String, replacement: String)] = [
        // Trigraphs
        ("sch", "ش"),
        ("tch", "چ"),
        // Persian-specific digraphs
        ("kh", "خ"),
        ("ch", "چ"),
        ("sh", "ش"),
        ("zh", "ژ"),
        ("gh", "غ"),  // Can also be ق
        ("ph", "ف"),
        ("th", "ت"),  // Can also be ث
        // Vowel combinations
        ("aa", "ا"),  // Long a - can be آ at start
        ("oo", "و"),  // Long o/u
        ("ee", "ی"),  // Long i
        ("ou", "و"),
        ("ei", "ی"),
        ("ey", "ی"),
        ("ay", "ای"),
        ("ai", "ای"),
        ("ao", "او"),
        ("ow", "و"),
        ("ie", "یه"),
    ]

    // Position-aware single character mappings
    // Returns: (start, middle, end, standalone) variants
    private let positionalMappings: [Character: (start: String, middle: String, end: String, standalone: String)] = [
        "a": ("آ", "ا", "ه", "ا"),    // آب، نام، خانه، ا
        "e": ("ا", "ِ", "ه", "ه"),    // امروز، ـِـ، خانه، به
        "o": ("ا", "ُ", "و", "و"),    // او، ـُـ، تو، او
        "i": ("ای", "ی", "ی", "ی"),   // ایران، بین، کی
        "u": ("او", "و", "و", "و"),   // او، بود، تو
    ]

    // Simple consonant mappings (default)
    private let consonantMappings: [Character: String] = [
        "b": "ب",
        "p": "پ",
        "t": "ت",
        "s": "س",
        "j": "ج",
        "d": "د",
        "r": "ر",
        "z": "ز",
        "f": "ف",
        "q": "ق",
        "k": "ک",
        "g": "گ",
        "l": "ل",
        "m": "م",
        "n": "ن",
        "v": "و",
        "w": "و",
        "h": "ه",
        "y": "ی",
        "x": "خ",
        "c": "ک",  // Can also be س
        "'": "ع",
    ]

    // Alternative mappings for variant generation
    private let alternativeMappings: [(char: Character, replacements: [String])] = [
        ("a", ["ا", "آ", "ع", "ه"]),
        ("e", ["ه", "ی", "ع", "ا"]),
        ("o", ["و", "ا", "ُ"]),
        ("i", ["ی", "ای", "ئی"]),
        ("u", ["و", "او"]),
        ("s", ["س", "ص", "ث"]),
        ("z", ["ز", "ض", "ظ", "ذ"]),
        ("t", ["ت", "ط"]),
        ("h", ["ه", "ح", "خ"]),
        ("g", ["گ", "غ", "ق"]),
        ("c", ["ک", "س", "چ"]),
        ("q", ["ق", "غ"]),
    ]

    // Colloquial/informal verb transformations (formal -> colloquial)
    private let colloquialTransforms: [(formal: String, colloquial: String, farsi: String)] = [
        // Common colloquial shortenings
        ("mikhaham", "mikham", "می‌خوام"),
        ("midaham", "midam", "می‌دم"),
        ("miravam", "miram", "می‌رم"),
        ("miayam", "miam", "میام"),
        ("mibinam", "mibinam", "می‌بینم"),
        ("mikunam", "mikonam", "می‌کنم"),
        ("miguiam", "migam", "می‌گم"),
        ("midanam", "midoonam", "می‌دونم"),
        ("mitavanam", "mitoonam", "می‌تونم"),

        // Colloquial "oo" for "a" patterns
        ("khane", "khune", "خونه"),
        ("name", "esme", "اسمه"),
        ("daneshgah", "daneshga", "دانشگا"),
        ("an", "un", "اون"),
        ("anha", "una", "اونا"),
        ("inja", "inja", "اینجا"),
        ("unja", "unja", "اونجا"),

        // Past tense colloquial
        ("amadam", "omadam", "اومدم"),
        ("amadand", "omadan", "اومدن"),
        ("goftam", "goftam", "گفتم"),
        ("raftam", "raftam", "رفتم"),
        ("kardam", "kardam", "کردم"),
        ("didam", "didam", "دیدم"),

        // Common expressions
        ("hasti", "hasti", "هستی"),
        ("hastam", "hastam", "هستم"),
        ("nistam", "nistam", "نیستم"),
        ("nadaram", "nadaram", "ندارم"),
        ("nemidanam", "nemidoonam", "نمی‌دونم"),
        ("nemitavanam", "nemitoonam", "نمی‌تونم"),
    ]

    // Persian numbers
    private let persianNumbers: [Character: Character] = [
        "0": "۰", "1": "۱", "2": "۲", "3": "۳", "4": "۴",
        "5": "۵", "6": "۶", "7": "۷", "8": "۸", "9": "۹"
    ]

    // ============================================
    // TYPO CORRECTIONS
    // ============================================

    private let typoCorrections: [String: String] = [
        // === GREETINGS ===
        "slm": "salam", "slaam": "salam", "salma": "salam",
        "slaaam": "salam", "salm": "salam", "slam": "salam",
        "mrc": "merci", "mrsi": "mersi", "mers": "mersi", "merc": "merci",
        "mersy": "mersi", "mercy": "merci", "marsi": "mersi",
        "mmnon": "mamnoon", "mamnon": "mamnoon", "mamno": "mamnoon",
        "mamnun": "mamnoon", "mamnu": "mamnoon", "mamnoun": "mamnoon",
        "khdahfz": "khodahafez", "khdhfz": "khodahafez", "khodaafez": "khodahafez",
        "khdafez": "khodahafez", "khodahfez": "khodahafez", "khodahaez": "khodahafez",
        "bbkhshid": "bebakhshid", "bebkhshid": "bebakhshid", "bebakhshd": "bebakhshid",
        "bebbakhshid": "bebakhshid", "bbakhshid": "bebakhshid",
        "tshkr": "tashakor", "tashkor": "tashakor", "tashakr": "tashakor",
        "tashakkor": "tashakor", "tshakur": "tashakor",
        "lotfn": "lotfan", "ltfan": "lotfan", "lotfa": "lotfan",
        "loftan": "lotfan", "ltfa": "lotfan",

        // === QUESTIONS ===
        "chetri": "chetori", "chtori": "chetori", "chetory": "chetori",
        "chetooori": "chetori", "chtoori": "chetori", "chetoor": "chetor",
        "chtoor": "chetor", "chtory": "chetori",
        "khbi": "khobi", "khoobi": "khobi",
        "khub": "khob", "khb": "khob", "khoob": "khob",
        "chra": "chera", "cheraaa": "chera", "chr": "chera",
        "keii": "key", "kii": "key", "kay": "key",
        "koj": "koja", "kojaaa": "koja",
        "kji": "koji", "kojast": "kojast",
        "chii": "chi", "chiii": "chi",
        "chish": "chish", "chishe": "chisheh",
        "kiist": "kist",
        "kiaa": "kia",

        // === COMMON VERBS - PRESENT ===
        "mikahm": "mikham", "mikhm": "mikham", "mkhm": "mikham",
        "mikha": "mikham", "mikhaam": "mikham",
        "mirm": "miram", "miraam": "miram",
        "mknm": "mikonam", "miknam": "mikonam", "mikonm": "mikonam",
        "mkunam": "mikonam", "mkonm": "mikonam",
        "midunm": "midoonam", "midunam": "midoonam", "midnom": "midoonam",
        "midoonm": "midoonam", "mdoonam": "midoonam",
        "mtunm": "mitoonam", "mtnm": "mitoonam", "mitunam": "mitoonam",
        "mitoonm": "mitoonam", "mtoonam": "mitoonam",
        "miyam": "miam", "miyaam": "miam",
        "myam": "miam", "miaam": "miam",
        "migm": "migam", "mygam": "migam",
        "mibinm": "mibinam", "mibinaam": "mibinam",
        "mishnvam": "mishnevam", "mishnavm": "mishnevam",
        "mifhmm": "mifahmam", "mifahmm": "mifahmam",
        "mikhorm": "mikhoram", "mkhoram": "mikhoram",
        "minvisam": "minevisam", "minvisaam": "minevisam",
        "migirm": "migiram",
        "miresm": "miresam",
        "mishm": "misham", "mishaam": "misham",

        // === COMMON VERBS - PAST ===
        "raftm": "raftam", "rafta": "raftam", "rftam": "raftam",
        "omadm": "omadam", "oomadm": "omadam", "amaadm": "amadam",
        "krdm": "kardam", "karda": "kardam", "krdam": "kardam",
        "gftm": "goftam", "gooftam": "goftam", "goftm": "goftam",
        "diidm": "didam", "didaam": "didam", "deedm": "didam",
        "khordm": "khordam", "khurdam": "khordam",
        "shndidm": "shenidam", "sheniidm": "shenidam",
        "fahmiidm": "fahmidam", "fahmidm": "fahmidam",
        "grftm": "gereftam", "gereftm": "gereftam", "griftam": "gereftam",
        "nevshtm": "neveshtam", "neveshta": "neveshtam",
        "rsidm": "residam", "residm": "residam",
        "shodm": "shodam", "shudm": "shodam", "shdm": "shodam",
        "mundom": "mundam", "mandom": "mandam",

        // === COMMON VERBS - NEGATIVE ===
        "nmidunam": "nemidoonam", "nmidunm": "nemidoonam", "nemidonam": "nemidoonam",
        "nmidoonam": "nemidoonam", "nemidunm": "nemidoonam",
        "nmitunm": "nemitoonam", "nemitunm": "nemitoonam", "nemitnam": "nemitoonam",
        "nmitoonam": "nemitoonam",
        "nmiram": "nemiram", "nemiraam": "nemiram", "nmirm": "nemiram",
        "nmikham": "nemikham", "nemikhaam": "nemikham", "nmkhm": "nemikham",
        "nmikonm": "nemikonam", "nemikonm": "nemikonam",
        "nmigam": "nemigam", "nemigaam": "nemigam",
        "nmibinam": "nemibinam", "nemibinm": "nemibinam",
        "nmishm": "nemisham", "nemishaam": "nemisham",

        // === COMMON WORDS ===
        "inj": "inja", "injaa": "inja",
        "unjaa": "unja", "unj": "unja", "onja": "unja",
        "alaan": "alan", "aln": "alan",
        "farad": "farda", "fardaa": "farda", "frda": "farda",
        "diiruz": "diruz", "diroz": "diruz", "druz": "diruz",
        "imruz": "emruz", "emrooz": "emruz", "imrooz": "emruz",
        "insha": "inshallah", "inshaallah": "inshallah", "inshala": "inshallah",
        "mashaalla": "mashallah", "mashaallah": "mashallah",
        "yarb": "yarabb", "yarab": "yarabb", "yaraab": "yarabb",
        "khudaam": "khodam", "khdam": "khodam",
        "oonaa": "oona", "unaa": "oona",
        "inaa": "ina", "inhaa": "inha",
        "khane": "khaneh", "khuneh": "khuneh", "khoone": "khuneh",
        "ketaab": "ketab", "ktab": "ketab", "kitab": "ketab",
        "madrse": "madrese", "madrseh": "madrese", "madreseh": "madrese",

        // === ADJECTIVES ===
        "khoshgl": "khoshgel", "khoshgeel": "khoshgel", "khoshgol": "khoshgel",
        "ghashng": "ghashang", "qashang": "ghashang",
        "zaleem": "zaalim", "zaalm": "zaalim", "zalim": "zaalim",
        "bade": "bad", "badd": "bad",
        "khube": "khub", "khoobe": "khub",
        "aalie": "aali", "aly": "aali",
        "kucik": "kuchik", "kuchek": "kuchik", "koochik": "kuchik",
        "bzrg": "bozorg", "bozrg": "bozorg", "bozarg": "bozorg",
        "jadeed": "jadid", "jdid": "jadid",
        "qadim": "ghadim", "ghadeem": "ghadim", "qdim": "ghadim",
        "raahat": "rahat", "raht": "rahat",
        "sakhtt": "sakht", "skht": "sakht",
        "asun": "asoon", "asaan": "asoon", "ason": "asoon",

        // === PRONOUNS ===
        "mn": "man", "maan": "man",
        "tou": "to",
        "ooo": "oo", "ou": "oo", "un": "oon",
        "maa": "ma", "mah": "ma",
        "shomaa": "shoma", "shma": "shoma",
        "unha": "oona", "onhaa": "oona",

        // === NUMBERS ===
        "yeki": "yek", "yekk": "yek",
        "dou": "do",
        "sre": "se", "seh": "se",
        "chhar": "chahar", "chaar": "chahar", "4ta": "chaharta",
        "pnj": "panj",
        "shish": "shesh",
        "haftt": "haft", "haff": "haft",
        "hasth": "hasht",
        "nooh": "noh", "nuh": "noh",
        "dahh": "dah", "deh": "dah",

        // === COLLOQUIAL ===
        "bba": "baba", "babaa": "baba",
        "mma": "mama", "mamaan": "maman",
        "dadsh": "dadash", "daadash": "dadash", "dadaash": "dadash",
        "abii": "abi", "aabji": "abji",
        "azizm": "azizam", "aziizm": "azizam", "azzzam": "azizam",
        "jonm": "jonam", "junam": "jonam", "joonam": "jonam",
        "dusset": "duset", "dooset": "duset", "doset": "duset",
        "asheghtm": "asheghetam", "ashegheetm": "asheghetam",
        "delm": "delam", "dlm": "delam", "dellam": "delam",
        "tangt": "tangat", "tengit": "tangit",
        "khstm": "khastam", "khaste": "khaste",
        "bisho": "besho", "bsho": "besho",
        "bro": "boro", "borro": "boro",
        "biya": "bia", "byia": "bia", "biaa": "bia",
        "bzar": "bezar", "bozar": "bezar",
        "nagoo": "nagu", "nago": "nagu", "ngu": "nagu",
        "bbin": "bebin", "bbiin": "bebin",
        "chkar": "chikar", "chikaar": "chikar",
        "kojii": "koji", "kojaayi": "kojayi", "kojay": "kojayi",

        // === INTERNET/TEXT SLANG ===
        "tnx": "mamnoon", "tx": "mamnoon", "thx": "mamnoon", "ty": "mamnoon",
        "plz": "lotfan", "pls": "lotfan", "pliz": "lotfan",
        "sry": "bebakhshid", "sorry": "bebakhshid", "srry": "bebakhshid",
        "np": "khahesh", "nprob": "khahesh mikonam", "nw": "khahesh mikonam",
        "omg": "vaay", "vay": "vaay", "vaaay": "vaay", "vai": "vaay",
        "lol": "khandeh", "xd": "khandeh", "lmao": "khandeh",
        "k": "ok", "kk": "ok", "okk": "ok", "oki": "ok",
        "hmm": "hmm", "hm": "hmm", "hmmm": "hmm", "umm": "hmm",
        "aha": "aha", "ahaa": "aha", "aham": "aha",
        "uhuh": "uhuh", "ohoh": "ohoh", "oho": "ohoh",
        "brb": "miram miam", "bbl": "baadan miam", "b4": "ghabl",
        "gtg": "bayad beram", "g2g": "bayad beram", "gotta": "bayad",
        "idk": "nemidoonam", "dk": "nemidoonam", "dunno": "nemidoonam",
        "idc": "baraam mohem nist", "dgaf": "baraam mohem nist",
        "tbh": "rast begi", "ngl": "rast begi",
        "btw": "rasti", "anyway": "rasti",
        "ily": "duset daram", "ilysm": "kheyli duset daram", "luv": "duset daram",
        "asap": "harchezotar", "rn": "alan",
        "jk": "shookhi kardam", "jking": "shookhi kardam",
        "wbu": "to chetori", "hbu": "to chetori",
        "wya": "kojayi", "wyd": "chikari",
        "cuz": "chon", "bcz": "chon", "coz": "chon",
        "bc": "chon", "bcs": "chon",
        "gn": "shab bekheyr", "gm": "sobh bekheyr",
        "ttyl": "baadan harf mizanim", "cya": "mibinamet",
        "yw": "khahesh mikonam", "ur": "to",
        "ppl": "mardom", "pplz": "mardom",
        "2day": "emruz", "2morrow": "farda", "2nite": "emshab",
        "4ever": "hamishe", "4u": "barat",

        // === COMMON MISTAKES (keyboard adjacency) ===
        "sakam": "salam", "aslam": "salam", "salsm": "salam",
        "mwrsi": "mersi", "nersi": "mersi", "mrrsi": "mersi", "meesi": "mersi",
        "khobu": "khobi", "khonu": "khobi", "kgibi": "khobi", "khubi": "khobi",
        "chetoei": "chetori", "chwtori": "chetori",
        "mikhan": "mikham", "mukhsm": "mikham", "mokham": "mikham", "mikhsm": "mikham",
        "mukonam": "mikonam", "mukinam": "mikonam", "mokonam": "mikonam", "mikonwm": "mikonam",
        "mudoonam": "midoonam", "midoimam": "midoonam", "modonam": "midoonam", "midoonwm": "midoonam",
        "mamnoin": "mamnoon", "mamnoob": "mamnoon", "mamnopn": "mamnoon",
        "bashr": "bashe", "bashw": "bashe", "bash3": "bashe",
        "chetore": "chetor", "chetroi": "chetori", "chetoti": "chetori",
        "kojwyi": "kojayi",
        "emroix": "emruz", "emruiz": "emruz", "emrouz": "emruz",
        "fardw": "farda", "farsa": "farda",
        "dirux": "diruz", "diruiz": "diruz", "dierooz": "diruz",
        "instsa": "inshallah", "enshala": "inshallah",
        "mashala": "mashallah", "mashalah": "mashallah", "mashsllah": "mashallah",
        "dooser": "doset", "dosrt": "doset",
        "azozam": "azizam", "azizwm": "azizam", "azizsm": "azizam",
        "joonsm": "joonam", "joonwm": "joonam",

        // === RELIGIOUS PHRASES ===
        "alhamd": "alhamdulillah", "alhamdolellah": "alhamdulillah",
        "subhan": "subhanallah", "sobhanallah": "subhanallah",
        "astaghfr": "astaghfurullah", "astaghfor": "astaghfurullah",
        "bismilla": "bismillah", "besmellah": "bismillah",
        "jazak": "jazakallah", "jazakalla": "jazakallah",
        "aamiin": "amin", "aameen": "amin", "amiin": "amin",
    ]

    // ============================================
    // MAIN PUBLIC API
    // ============================================

    func getSuggestions(for input: String) -> [String] {
        let lowercased = input.lowercased().trimmingCharacters(in: .whitespaces)
        guard !lowercased.isEmpty else { return [] }

        var candidates: [(text: String, score: Int, order: Int)] = []
        var order = 0

        func addCandidate(_ s: String, score: Int, preservesCuratedSpelling: Bool = false) {
            let canonical = PersianOrthography.canonicalize(s)
            let cleaned = preservesCuratedSpelling ? canonical : cleanupResult(canonical)
            guard !cleaned.isEmpty else { return }
            candidates.append((cleaned, score, order))
            order += 1
        }

        func rankedUniqueSuggestions() -> [String] {
            let ranked = candidates.sorted {
                if $0.score == $1.score {
                    return $0.order < $1.order
                }
                return $0.score > $1.score
            }

            var seen = Set<String>()
            var suggestions: [String] = []
            for candidate in ranked {
                if seen.insert(candidate.text).inserted {
                    suggestions.append(candidate.text)
                }
                if suggestions.count >= 8 { break }
            }

            return suggestions
        }

        // 1. Apply a typo alias only when the input is not already a real
        // dictionary key. Several valid conversational words are one edit away
        // from another word (mah/ma, yeki/yek, mikhan/mikham, chetore/chetor).
        // Exact user intent must win over a broad correction rule.
        let corrected = dictionary.hasExactMatch(for: lowercased)
            ? lowercased
            : (typoCorrections[lowercased] ?? lowercased)

        // 2. Check for direct colloquial match first (highest priority for common verbs)
        if let colloquialMatch = tryColloquialMatch(corrected) {
            addCandidate(colloquialMatch, score: 12_000, preservesCuratedSpelling: true)
        }

        // 3. Handle object clitics before dictionary fallbacks.
        if let objectCliticMatch = tryObjectCliticMatch(corrected) {
            addCandidate(objectCliticMatch, score: 11_800)
        }

        // 4. Dictionary exact/prefix lookup. Fuzzy matches are intentionally
        // delayed until after morphology so near-misses don't bury plausible words.
        let dictCandidates = dictionary.findCandidates(for: corrected, includeFuzzy: false, limit: 10)
        for candidate in dictCandidates {
            addCandidate(candidate.value, score: candidate.score, preservesCuratedSpelling: true)
        }

        // If typo was corrected, also try original
        if corrected != lowercased {
            let originalCandidates = dictionary.findCandidates(for: lowercased, includeFuzzy: false, limit: 10)
            for candidate in originalCandidates {
                addCandidate(candidate.value, score: candidate.score - 150, preservesCuratedSpelling: true)
            }
        }

        // Once a current exact key resolves, generated morphology and phonetic
        // variants can only add lower-confidence junk. Keep curated semantic
        // alternatives and prefix completions, then stop the expensive fallback
        // pipeline. This also prevents an exact spelling correction from being
        // shown beside newly manufactured misspellings.
        let hasExactDictionaryMatch = dictCandidates.contains { candidate in
            if case .exact = candidate.source {
                return true
            }
            return false
        }
        if hasExactDictionaryMatch {
            return rankedUniqueSuggestions()
        }

        // 5. Check for compound word matches
        if let compoundResult = tryCompoundMatch(corrected) {
            addCandidate(compoundResult, score: 9_300, preservesCuratedSpelling: true)
        }

        // 6. Smart morphological transliteration
        let morphResult = morphologicalTransliterate(corrected)
        addCandidate(morphResult, score: 7_200)

        // 7. Context-aware transliteration
        let contextResult = contextAwareTransliterate(corrected)
        if contextResult != morphResult {
            addCandidate(contextResult, score: 6_200)
        }

        // 8. Generate phonetic variants
        for (index, variant) in generatePhoneticVariants(corrected).enumerated() {
            addCandidate(variant, score: 4_300 - index * 50)
        }

        // 9. Simple fallback transliteration
        let simpleResult = simpleTransliterate(corrected)
        addCandidate(simpleResult, score: 3_500)

        // 10. Try word ending patterns (for loanwords)
        if let endingResult = tryWordEndingPattern(corrected) {
            addCandidate(endingResult, score: 3_800)
        }

        // 11. Fuzzy dictionary matches. They are useful, but should not
        // outrank morphology for an exactly typed unknown word.
        let fuzzyCandidates = dictionary.findCandidates(for: corrected, includeFuzzy: true, limit: 12)
        for candidate in fuzzyCandidates {
            switch candidate.source {
            case .fuzzy, .substitution:
                addCandidate(candidate.value, score: candidate.score, preservesCuratedSpelling: true)
            case .exact, .prefix:
                break
            }
        }

        if corrected != lowercased {
            let originalFuzzyCandidates = dictionary.findCandidates(for: lowercased, includeFuzzy: true, limit: 12)
            for candidate in originalFuzzyCandidates {
                switch candidate.source {
                case .fuzzy, .substitution:
                    addCandidate(candidate.value, score: candidate.score - 150, preservesCuratedSpelling: true)
                case .exact, .prefix:
                    break
                }
            }
        }

        return rankedUniqueSuggestions()
    }

    // ============================================
    // COMPOUND WORD MATCHING
    // ============================================

    /// Tries to match input against compound word patterns
    private func tryCompoundMatch(_ input: String) -> String? {
        let lowered = input.lowercased()

        // Need at least 3 characters for compound matching
        guard lowered.count >= 3 else { return nil }

        // Direct compound lookup
        for (first, second, result) in compoundParts {
            let combined = first + second
            if lowered == combined {
                return result
            }
            // Also check with common variations
            if !second.isEmpty {
                if lowered == first + second.replacingOccurrences(of: "a", with: "aa") ||
                   lowered == first.replacingOccurrences(of: "o", with: "oo") + second {
                    return result
                }
            }
        }

        // Try splitting the word at various points (only if word is long enough)
        let maxSplit = min(lowered.count - 1, 6)
        if maxSplit > 2 {
            for i in 2..<maxSplit {
                let index = lowered.index(lowered.startIndex, offsetBy: i)
                let firstPart = String(lowered[..<index])
                let secondPart = String(lowered[index...])

                for (first, second, result) in compoundParts {
                    if firstPart == first && secondPart == second {
                        return result
                    }
                }
            }
        }

        return nil
    }

    /// Tries to apply word ending patterns (for loanwords/borrowed words)
    private func tryWordEndingPattern(_ input: String) -> String? {
        let lowered = input.lowercased()

        for (ending, farsiEnding) in wordEndingPatterns {
            if lowered.hasSuffix(ending) {
                let stem = String(lowered.dropLast(ending.count))
                let transliteratedStem = contextAwareTransliterate(stem)
                return transliteratedStem + farsiEnding
            }
        }

        return nil
    }

    /// Tries to match colloquial verb forms
    private func tryColloquialMatch(_ input: String) -> String? {
        let lowered = input.lowercased()

        // Direct match on colloquial forms
        for (_, colloquial, farsi) in colloquialTransforms {
            if lowered == colloquial {
                return farsi
            }
        }

        return nil
    }

    private func tryObjectCliticMatch(_ input: String) -> String? {
        let lowered = input.lowercased()

        for (suffix, farsiSuffix) in objectCliticSuffixes {
            guard lowered.hasSuffix(suffix), lowered.count > suffix.count + 3 else { continue }

            let base = String(lowered.dropLast(suffix.count))
            guard looksLikeVerbTakingObject(base) else { continue }

            if let baseFarsi = bestVerbBaseSuggestion(for: base) {
                return baseFarsi + farsiSuffix
            }
        }

        return nil
    }

    private func bestVerbBaseSuggestion(for base: String) -> String? {
        if let colloquialMatch = tryColloquialMatch(base) {
            return colloquialMatch
        }

        if let dictionaryMatch = dictionary.findMatches(for: base, includeFuzzy: false).first,
           isPersianVerbPhrase(dictionaryMatch) {
            return dictionaryMatch
        }

        let morphResult = morphologicalTransliterate(base)
        if isPersianVerbPhrase(morphResult) {
            return morphResult
        }

        return nil
    }

    private func looksLikeVerbTakingObject(_ base: String) -> Bool {
        if base.hasPrefix("mi") || base.hasPrefix("nemi") || base.hasPrefix("nem") {
            return true
        }

        if checkPastTense(base) {
            return true
        }

        return matchesVerbPattern(base)
    }

    private func isPersianVerbPhrase(_ value: String) -> Bool {
        value.contains("می") ||
            value.contains("نمی") ||
            value.hasSuffix("م") ||
            value.hasSuffix("ی") ||
            value.hasSuffix("ه") ||
            value.hasSuffix("یم") ||
            value.hasSuffix("ین") ||
            value.hasSuffix("ن")
    }

    // ============================================
    // MORPHOLOGICAL TRANSLITERATION
    // ============================================

    /// Analyzes word structure and transliterates based on Persian morphology
    private func morphologicalTransliterate(_ input: String) -> String {
        var word = input.lowercased()

        // Handle Persian words ending in ه before generic suffix parsing.
        // Directly concatenating the person ending produces forms such as
        // دیدهی and رفتهم instead of دیده‌ای and رفته‌ام.
        if let hehFinalResult = tryHehFinalPersonEnding(word) {
            return hehFinalResult
        }

        var prefix = ""
        var suffix = ""
        var isImperative = false
        var isPastTense = false

        // 1. Check for imperative prefix first (be-, bo-, na-)
        for (finglish, farsi) in imperativePrefixes {
            if word.hasPrefix(finglish) && word.count > finglish.count + 1 {
                // Check if remainder looks like a verb stem
                let remainder = String(word.dropFirst(finglish.count))
                if matchesVerbPattern(remainder) {
                    prefix = farsi
                    word = remainder
                    isImperative = true
                    break
                }
            }
        }

        // 2. Extract verb prefix (mi-, nemi-)
        if !isImperative {
            for (finglish, farsi) in verbPrefixes {
                if word.hasPrefix(finglish) && word.count > finglish.count + 1 {
                    let remainder = String(word.dropFirst(finglish.count))
                    if matchesVerbPattern(remainder) {
                        prefix = farsi
                        word = remainder
                        break
                    }
                }
            }
        }

        // 3. Check for past tense (no prefix, ends with past suffix, has past stem)
        if prefix.isEmpty && !isImperative {
            isPastTense = checkPastTense(word)
        }

        // 4. Check if this looks like a verb
        let isLikelyVerb = !prefix.isEmpty || isImperative || isPastTense || matchesVerbPattern(word)
        let wholeVerbStem = pastTenseStems[word] ?? verbStems[word]

        // 5. Extract one structurally licensed ending.
        var suffixes: [String] = []

        if isLikelyVerb && wholeVerbStem == nil {
            // Try verb suffixes
            for (finglish, farsi) in presentSuffixes {
                if word.hasSuffix(finglish) && word.count > finglish.count {
                    let possibleStem = String(word.dropLast(finglish.count))
                    if verbStems[possibleStem] != nil || pastTenseStems[possibleStem] != nil {
                        suffixes.insert(farsi, at: 0)
                        word = possibleStem
                        break
                    }
                }
            }
        } else if !isLikelyVerb {
            // Longest combined endings appear first in nounSuffixes. Remove
            // exactly one licensed ending: repeated stripping turned rahat+tar
            // into rah+at+tar and produced راهتتر.
            for (finglish, farsi) in nounSuffixes {
                if word.hasSuffix(finglish) && word.count > finglish.count {
                    suffixes.append(farsi)
                    word = String(word.dropLast(finglish.count))
                    break
                }
            }
        }

        suffix = suffixes.joined()

        // 6. Transliterate the stem
        var stem: String

        // Check lexical stems first so adjective/noun suffixes keep their meaning.
        if let wholeVerbStem {
            stem = wholeVerbStem
        }
        // Prefer an explicitly curated lexical stem.
        else if let lexicalStem = lexicalStems[word] {
            stem = lexicalStem
        }
        // A stripped productive noun ending should reuse an exact dictionary
        // base when available (pedarha -> پدر‌ها), rather than phonetic fallback.
        else if let exactDictionaryStem = dictionary.findCandidates(
            for: word,
            includeFuzzy: false,
            limit: 12
        ).first(where: { candidate in
            if case .exact = candidate.source { return true }
            return false
        }) {
            stem = exactDictionaryStem.value
        }
        // Check past tense stems
        else if let pastStem = pastTenseStems[word] {
            stem = pastStem
        }
        // Then check present verb stems
        else if let verbStem = verbStems[word] {
            stem = verbStem
        }
        // Context-aware transliteration of stem
        else {
            stem = contextAwareTransliterate(word)
        }

        // 7. Combine with ZWNJ where appropriate
        var result = ""

        if !prefix.isEmpty {
            // Add ZWNJ after می/نمی
            if prefix == "می" || prefix == "نمی" {
                result = prefix + FinglishConverter.ZWNJ + stem
            } else {
                result = prefix + stem
            }
        } else {
            result = stem
        }

        if !suffix.isEmpty {
            // Add ZWNJ before های/ها
            if suffix.hasPrefix("ها") || suffix.hasPrefix("های") {
                result = result + FinglishConverter.ZWNJ + suffix
            } else {
                result = result + suffix
            }
        }

        return result
    }

    /// Check if a word looks like past tense
    private func checkPastTense(_ word: String) -> Bool {
        if pastTenseStems[word] != nil {
            return true
        }

        // A past reading is licensed only when stripping one person ending
        // leaves a complete known past stem. Prefix/substring scans caused
        // unrelated nouns to enter the verb path.
        let suffixes = Array(Set(pastSuffixes.map { $0.finglish }))
            .sorted { $0.count > $1.count }
        for suffix in suffixes where word.hasSuffix(suffix) && word.count > suffix.count {
            let stem = String(word.dropLast(suffix.count))
            if pastTenseStems[stem] != nil {
                return true
            }
        }

        return false
    }

    /// Handles a heh-final noun/adjective clitic or a past participle ending.
    /// The Latin boundary is explicit (…e + person ending), and a known exact
    /// heh-final word or known past stem is required, keeping the rule bounded.
    private func tryHehFinalPersonEnding(_ word: String) -> String? {
        let endings: [(finglish: String, farsi: String)] = [
            ("and", "اند"),
            ("im", "ایم"),
            ("id", "اید"),
            ("am", "ام"),
            ("i", "ای"),
        ]

        for ending in endings where word.hasSuffix(ending.finglish) {
            let baseWord = String(word.dropLast(ending.finglish.count))
            guard baseWord.hasSuffix("e"), baseWord.count > 1 else { continue }

            let exactCandidates = dictionary.findCandidates(
                for: baseWord,
                includeFuzzy: false,
                limit: 12
            )
            if let exactHehFinal = exactCandidates.first(where: { candidate in
                guard candidate.value.hasSuffix("ه") else { return false }
                if case .exact = candidate.source { return true }
                return false
            }) {
                return exactHehFinal.value + FinglishConverter.ZWNJ + ending.farsi
            }

            let stemKey = String(baseWord.dropLast())
            if let pastStem = pastTenseStems[stemKey] {
                return pastStem + "ه" + FinglishConverter.ZWNJ + ending.farsi
            }
        }

        return nil
    }

    /// Check if a word matches common verb patterns
    private func matchesVerbPattern(_ word: String) -> Bool {
        if verbStems[word] != nil || pastTenseStems[word] != nil {
            return true
        }

        // A person suffix is evidence of a verb only when removing it leaves a
        // known stem. The former substring scan matched one-letter stems such as
        // "a" and "g", causing ordinary plurals like ketabha to be conjugated.
        let suffixes = Array(Set(
            presentSuffixes.map { $0.finglish } + pastSuffixes.map { $0.finglish }
        )).sorted { $0.count > $1.count }

        for suffix in suffixes where word.hasSuffix(suffix) && word.count > suffix.count {
            let stem = String(word.dropLast(suffix.count))
            if verbStems[stem] != nil || pastTenseStems[stem] != nil {
                return true
            }
        }

        return false
    }

    // ============================================
    // CONTEXT-AWARE TRANSLITERATION
    // ============================================

    /// Transliterates with awareness of letter position and context
    private func contextAwareTransliterate(_ input: String) -> String {
        var result = ""
        let chars = Array(input.lowercased())
        var i = 0

        while i < chars.count {
            // 1. Try multi-character mappings first (longest match)
            var matched = false

            for length in stride(from: min(3, chars.count - i), through: 2, by: -1) {
                let endIndex = min(i + length, chars.count)
                let substring = String(chars[i..<endIndex])

                if let mapping = multiCharMappings.first(where: { $0.pattern == substring }) {
                    // Special case: aa at start becomes آ
                    if substring == "aa" && i == 0 {
                        result += "آ"
                    } else {
                        result += mapping.replacement
                    }
                    i += length
                    matched = true
                    break
                }
            }

            if matched { continue }

            // 2. Handle vowels with position awareness
            let char = chars[i]
            if let positional = positionalVowelMapping(for: char, at: i, in: chars) {
                result += positional
                i += 1
                continue
            }

            // 3. Handle consonants
            if let mapping = consonantMappings[char] {
                result += mapping
            } else if let digit = persianNumbers[char] {
                result += String(digit)
            } else {
                result += String(char)
            }

            i += 1
        }

        return result
    }

    private func positionalVowelMapping(
        for character: Character,
        at index: Int,
        in characters: [Character]
    ) -> String? {
        guard let positional = positionalMappings[character] else { return nil }

        if index == 0 {
            return positional.start
        }

        if index == characters.count - 1 {
            return positional.end
        }

        if isConsonant(characters[index - 1]),
           isConsonant(characters[index + 1]) {
            return positional.middle
        }

        return positional.standalone
    }

    private func isConsonant(_ char: Character) -> Bool {
        let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
        return char.isLetter && !vowels.contains(char)
    }

    // ============================================
    // SIMPLE TRANSLITERATION (Fallback)
    // ============================================

    private func simpleTransliterate(_ input: String) -> String {
        var result = ""
        let chars = Array(input.lowercased())
        var i = 0

        while i < chars.count {
            // Try multi-char first
            var matched = false
            for length in stride(from: min(3, chars.count - i), through: 2, by: -1) {
                let substring = String(chars[i..<min(i + length, chars.count)])
                if let mapping = multiCharMappings.first(where: { $0.pattern == substring }) {
                    result += mapping.replacement
                    i += length
                    matched = true
                    break
                }
            }

            if !matched {
                let char = chars[i]
                if let mapping = consonantMappings[char] {
                    result += mapping
                } else if char == "a" || char == "e" {
                    result += "ه"
                } else if char == "o" || char == "u" {
                    result += "و"
                } else if char == "i" {
                    result += "ی"
                } else if let digit = persianNumbers[char] {
                    result += String(digit)
                } else {
                    result += String(char)
                }
                i += 1
            }
        }

        return result
    }

    // ============================================
    // PHONETIC VARIANT GENERATION
    // ============================================

    /// Generates alternative spellings based on Persian phonology
    private func generatePhoneticVariants(_ input: String) -> [String] {
        var variants: [String] = []
        let base = contextAwareTransliterate(input)

        // 1. Generate variants by substituting ambiguous letters
        for (char, alternatives) in alternativeMappings {
            if input.contains(char) {
                for alt in alternatives.prefix(3) {
                    guard isPlausibleSubstitution(char: char, replacement: alt, in: input) else {
                        continue
                    }
                    let variant = generateVariantWithSubstitution(input, char: char, replacement: alt)
                    if variant != base && !variants.contains(variant) {
                        variants.append(variant)
                    }
                }
            }
        }

        // 2. Special case: initial آ vs ا
        if input.hasPrefix("a") && !input.hasPrefix("aa") {
            let withAlef = "آ" + contextAwareTransliterate(String(input.dropFirst()))
            if withAlef != base && !variants.contains(withAlef) {
                variants.append(cleanupResult(withAlef))
            }
        }

        // 3. Handle gh -> غ vs ق
        if input.contains("gh") {
            let withQaf = contextAwareTransliterate(input.replacingOccurrences(of: "gh", with: "q"))
            if withQaf != base && !variants.contains(withQaf) {
                variants.append(cleanupResult(withQaf))
            }
        }

        // 4. Add tashkeel variations (فتحه، کسره، ضمه) - simplified
        // For words ending in 'e', try 'ه' vs 'ی'
        if input.hasSuffix("e") && !input.hasSuffix("ee") {
            let withYe = contextAwareTransliterate(String(input.dropLast())) + "ی"
            if withYe != base && !variants.contains(withYe) {
                variants.append(cleanupResult(withYe))
            }
        }

        return variants.map { cleanupResult($0) }
    }

    private func isPlausibleSubstitution(char: Character, replacement: String, in input: String) -> Bool {
        guard let firstIndex = input.firstIndex(of: char) else { return false }
        let isFirstCharacter = firstIndex == input.startIndex
        let isLastCharacter = input.index(after: firstIndex) == input.endIndex

        if char == "a" {
            if replacement == "آ" && !isFirstCharacter { return false }
            if replacement == "ه" && !isLastCharacter { return false }
        }

        if char == "e", replacement == "ا", !isFirstCharacter {
            return false
        }

        if char == "i", (replacement == "ای" || replacement == "ئی"), !isFirstCharacter {
            return false
        }

        return true
    }

    private func generateVariantWithSubstitution(_ input: String, char: Character, replacement: String) -> String {
        var result = ""
        let chars = Array(input.lowercased())
        var i = 0
        var firstReplaced = false

        while i < chars.count {
            // Multi-char check
            var matched = false
            for length in stride(from: min(3, chars.count - i), through: 2, by: -1) {
                let substring = String(chars[i..<min(i + length, chars.count)])
                if let mapping = multiCharMappings.first(where: { $0.pattern == substring }) {
                    result += mapping.replacement
                    i += length
                    matched = true
                    break
                }
            }

            if !matched {
                let c = chars[i]
                if c == char && !firstReplaced {
                    result += replacement
                    firstReplaced = true
                } else if let mapping = consonantMappings[c] {
                    result += mapping
                } else if let positional = positionalVowelMapping(for: c, at: i, in: chars) {
                    result += positional
                } else if let digit = persianNumbers[c] {
                    result += String(digit)
                } else {
                    result += String(c)
                }
                i += 1
            }
        }

        return result
    }

    // ============================================
    // UTILITY FUNCTIONS
    // ============================================

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

    private func cleanupResult(_ input: String) -> String {
        // The converter uses kasra and damma as positional placeholders while
        // generating unknown words. Strip only those generated placeholders;
        // curated dictionary candidates bypass this function so their Persian
        // spelling, repeated letters, hamza, tanvin, and ZWNJ stay lossless.
        let stripped = input
            .replacingOccurrences(of: "ِ", with: "")
            .replacingOccurrences(of: "ُ", with: "")
        return PersianOrthography.canonicalize(stripped)
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
