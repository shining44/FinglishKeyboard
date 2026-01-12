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
        ("am", "م"),
        ("im", "یم"),
        ("in", "ین"),
        ("id", "ید"),
        ("i", "ی"),
        ("e", "ه"),
        ("eh", "ه"),
        ("an", "ن"),
        ("and", "ند"),
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
        "posht": "پوشت", "pushid": "پوشید",
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
        "neshun": "نشون", "neshan": "نشان", "neshundad": "نشونداد",
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
        "khast": "خواست", "kha": "خوا",
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
        "kes": "کس", "kesid": "کسید",
        "vel": "ول", "volkon": "ول‌کن",
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
    private let alternativeMappings: [Character: [String]] = [
        "a": ["ا", "آ", "ع", "ه"],
        "e": ["ه", "ی", "ع", "ا"],
        "o": ["و", "ا", "ُ"],
        "i": ["ی", "ای", "ئی"],
        "u": ["و", "او"],
        "s": ["س", "ص", "ث"],
        "z": ["ز", "ض", "ظ", "ذ"],
        "t": ["ت", "ط"],
        "h": ["ه", "ح", "خ"],
        "g": ["گ", "غ", "ق"],
        "c": ["ک", "س", "چ"],
        "q": ["ق", "غ"],
    ]

    // Colloquial/informal verb transformations (formal -> colloquial)
    private let colloquialTransforms: [(formal: String, colloquial: String, farsi: String)] = [
        // Common colloquial shortenings
        ("mikhaham", "mikham", "می‌خوام"),
        ("midaham", "midam", "می‌دم"),
        ("miravam", "miram", "می‌رم"),
        ("miayam", "miam", "می‌آم"),
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
        "kosh": "kojayi",

        // === INTERNET/TEXT SLANG ===
        "tnx": "mamnoon", "tx": "mamnoon", "thx": "mamnoon",
        "plz": "lotfan", "pls": "lotfan",
        "sry": "bebakhshid", "sorry": "bebakhshid",
        "np": "khahesh", "nprob": "khahesh mikonam",
        "omg": "vaay", "vay": "vaay", "vaaay": "vaay",
        "lol": "khandeh", "xd": "khandeh",
        "k": "ok", "kk": "ok", "okk": "ok",
        "hmm": "hmm", "hm": "hmm", "hmmm": "hmm",
        "aha": "aha", "ahaa": "aha",
        "uhuh": "uhuh", "ohoh": "ohoh",
        "brb": "miram miam", "bbl": "baadan miam",
        "gtg": "bayad beram", "g2g": "bayad beram",
        "idk": "nemidoonam", "dk": "nemidoonam",
        "idc": "baraam mohem nist",
        "tbh": "rast begi",
        "btw": "rasti",
        "ily": "duset daram", "ilysm": "kheyli duset daram",
        "asap": "harchezotar",

        // === COMMON MISTAKES (keyboard adjacency) ===
        "sakam": "salam",
        "mwrsi": "mersi", "nersi": "mersi",
        "khobu": "khobi", "khonu": "khobi",
        "chetoru": "chetori", "chetoei": "chetori",
        "mikhan": "mikham", "mukhsm": "mikham",
        "mukonam": "mikonam", "mukinam": "mikonam",
        "mudoonam": "midoonam", "midoimam": "midoonam",

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

        var suggestions: [String] = []
        var seenSuggestions = Set<String>()

        func addSuggestion(_ s: String) {
            let cleaned = cleanupResult(s)
            if !cleaned.isEmpty && !seenSuggestions.contains(cleaned) {
                seenSuggestions.insert(cleaned)
                suggestions.append(cleaned)
            }
        }

        // 1. Apply typo correction if available
        let corrected = typoCorrections[lowercased] ?? lowercased

        // 2. Check for direct colloquial match first (highest priority for common verbs)
        if let colloquialMatch = tryColloquialMatch(corrected) {
            addSuggestion(colloquialMatch)
        }

        // 3. Dictionary lookup (highest priority)
        let dictMatches = dictionary.findMatches(for: corrected)
        for match in dictMatches {
            addSuggestion(match)
        }

        // If typo was corrected, also try original
        if corrected != lowercased {
            let originalMatches = dictionary.findMatches(for: lowercased)
            for match in originalMatches {
                addSuggestion(match)
            }
        }

        // 4. Check for compound word matches
        if let compoundResult = tryCompoundMatch(corrected) {
            addSuggestion(compoundResult)
        }

        // 5. Smart morphological transliteration
        let morphResult = morphologicalTransliterate(corrected)
        addSuggestion(morphResult)

        // 6. Context-aware transliteration
        let contextResult = contextAwareTransliterate(corrected)
        if contextResult != morphResult {
            addSuggestion(contextResult)
        }

        // 7. Generate phonetic variants
        let variants = generatePhoneticVariants(corrected)
        for variant in variants {
            addSuggestion(variant)
        }

        // 8. Simple fallback transliteration
        let simpleResult = simpleTransliterate(corrected)
        addSuggestion(simpleResult)

        // 9. Try word ending patterns (for loanwords)
        if let endingResult = tryWordEndingPattern(corrected) {
            addSuggestion(endingResult)
        }

        return Array(suggestions.prefix(5))
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

        // Also match formal forms and return farsi
        for (formal, _, farsi) in colloquialTransforms {
            if lowered == formal {
                return farsi
            }
        }

        return nil
    }

    // ============================================
    // MORPHOLOGICAL TRANSLITERATION
    // ============================================

    /// Analyzes word structure and transliterates based on Persian morphology
    private func morphologicalTransliterate(_ input: String) -> String {
        var word = input.lowercased()
        var prefix = ""
        var suffix = ""
        var isImperative = false
        var isPastTense = false

        // 1. Check for imperative prefix first (be-, bo-, na-)
        for (finglish, farsi) in imperativePrefixes {
            if word.hasPrefix(finglish) && word.count > finglish.count + 1 {
                // Check if remainder looks like a verb stem
                let remainder = String(word.dropFirst(finglish.count))
                if verbStems[remainder] != nil || pastTenseStems[remainder] != nil || remainder.count >= 2 {
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
                    prefix = farsi
                    word = String(word.dropFirst(finglish.count))
                    break
                }
            }
        }

        // 3. Check for past tense (no prefix, ends with past suffix, has past stem)
        if prefix.isEmpty && !isImperative {
            isPastTense = checkPastTense(word)
        }

        // 4. Check if this looks like a verb
        let isLikelyVerb = !prefix.isEmpty || isImperative || isPastTense || matchesVerbPattern(word)

        // 5. Extract suffix based on word type - try multiple suffixes (suffix chaining)
        var suffixes: [String] = []

        if isLikelyVerb {
            // Try verb suffixes
            for (finglish, farsi) in presentSuffixes {
                if word.hasSuffix(finglish) && word.count > finglish.count {
                    suffixes.insert(farsi, at: 0)
                    word = String(word.dropLast(finglish.count))
                    break
                }
            }
            // Also try past suffixes if it looks like past tense
            if isPastTense {
                for (finglish, farsi) in pastSuffixes {
                    if word.hasSuffix(finglish) && word.count > finglish.count {
                        if suffixes.isEmpty {
                            suffixes.insert(farsi, at: 0)
                            word = String(word.dropLast(finglish.count))
                        }
                        break
                    }
                }
            }
        } else {
            // Try noun suffixes - support chaining (e.g., ketabhayam = کتاب‌هایم)
            var foundSuffix = true
            while foundSuffix && word.count > 2 {
                foundSuffix = false
                for (finglish, farsi) in nounSuffixes {
                    if word.hasSuffix(finglish) && word.count > finglish.count {
                        suffixes.insert(farsi, at: 0)
                        word = String(word.dropLast(finglish.count))
                        foundSuffix = true
                        break
                    }
                }
            }
        }

        suffix = suffixes.joined()

        // 6. Transliterate the stem
        var stem: String

        // Check past tense stems first
        if let pastStem = pastTenseStems[word] {
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
        // Check if the word (minus possible suffix) matches a past tense stem
        for (stem, _) in pastTenseStems {
            if word.hasPrefix(stem) {
                return true
            }
        }

        // Common past tense endings
        let pastEndings = ["id", "ad", "od", "ast", "esht", "aft", "ord", "urd"]
        for ending in pastEndings {
            if word.contains(ending) {
                return true
            }
        }

        return false
    }

    /// Check if a word matches common verb patterns
    private func matchesVerbPattern(_ word: String) -> Bool {
        // Common verb stem patterns
        let verbPatterns = ["am", "im", "id", "i", "e", "and", "an"]
        for pattern in verbPatterns {
            if word.hasSuffix(pattern) {
                return true
            }
        }

        // Check for known verb stems
        for stem in verbStems.keys {
            if word.hasPrefix(stem) || word.contains(stem) {
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
            let isStart = (i == 0)
            let isEnd = (i == chars.count - 1)
            let isAfterConsonant = i > 0 && isConsonant(chars[i-1])
            let isBeforeConsonant = i < chars.count - 1 && isConsonant(chars[i+1])

            if let positional = positionalMappings[char] {
                if isStart {
                    result += positional.start
                } else if isEnd {
                    result += positional.end
                } else if isAfterConsonant && isBeforeConsonant {
                    // Middle of word between consonants - often silent or short
                    result += positional.middle
                } else {
                    result += positional.standalone
                }
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
                for alt in alternatives.prefix(2) {
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
            let withGhain = input.replacingOccurrences(of: "gh", with: "GHAIN_TEMP")
            var temp = contextAwareTransliterate(withGhain.replacingOccurrences(of: "GHAIN_TEMP", with: ""))
            temp = temp.replacingOccurrences(of: "غ", with: "ق")
            if !variants.contains(temp) {
                variants.append(temp)
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
                } else if let positional = positionalMappings[c] {
                    result += positional.standalone
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
        var result = input

        // Remove diacritics placeholders if any
        result = result.replacingOccurrences(of: "ِ", with: "")
        result = result.replacingOccurrences(of: "ُ", with: "")

        // Clean consecutive similar characters
        let patterns = [
            ("اا", "ا"),
            ("آا", "آ"),
            ("اآ", "آ"),
            ("وو", "و"),
            ("یی", "ی"),
            ("هه", "ه"),
            ("نن", "ن"),
            ("مم", "م"),
            ("رر", "ر"),
            ("لل", "ل"),
        ]

        for (pattern, replacement) in patterns {
            while result.contains(pattern) {
                result = result.replacingOccurrences(of: pattern, with: replacement)
            }
        }

        // Fix common issues
        result = result.replacingOccurrences(of: "ءی", with: "ئی")
        result = result.replacingOccurrences(of: "ءا", with: "ئا")

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
