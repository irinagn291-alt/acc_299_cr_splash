import Foundation

/// One Codable chart root. Birds are islands, the roster is the book, each daykey is a session,
/// the perch tally is the run, and marks are rhumbs. Computed totals are not stored.
struct PerchChart: Codable, Equatable, Sendable {
    static let schema = 1

    var schemaVersion: Int
    var islands: [Bird]
    var books: Roster
    var sessions: [Int]
    var runs: [Int]
    var rhumbs: [Rhumb]
    var onboardingComplete: Bool

    static let empty = PerchChart(
        schemaVersion: schema,
        islands: [],
        books: Roster(birds: []),
        sessions: [],
        runs: [],
        rhumbs: [],
        onboardingComplete: false
    )

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, islands, books, sessions, runs, rhumbs, onboardingComplete
    }

    init(
        schemaVersion: Int,
        islands: [Bird],
        books: Roster,
        sessions: [Int],
        runs: [Int],
        rhumbs: [Rhumb],
        onboardingComplete: Bool
    ) {
        self.schemaVersion = schemaVersion
        self.islands = islands
        self.books = books
        self.sessions = sessions
        self.runs = runs
        self.rhumbs = rhumbs
        self.onboardingComplete = onboardingComplete
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let version = try c.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            islands = try c.decode([Bird].self, forKey: .islands)
            books = try c.decode(Roster.self, forKey: .books)
            sessions = try c.decode([Int].self, forKey: .sessions)
            runs = try c.decode([Int].self, forKey: .runs)
            rhumbs = try c.decode([Rhumb].self, forKey: .rhumbs)
            onboardingComplete = try c.decode(Bool.self, forKey: .onboardingComplete)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: c,
                debugDescription: "Unknown chart schema \(version)."
            )
        }
    }

    var birds: [Bird] {
        get { islands }
        set {
            islands = newValue
            books.birds = newValue
        }
    }

    mutating func remember(daykey: Int) {
        if !sessions.contains(daykey) {
            sessions.append(daykey)
        }
        if !runs.contains(daykey) {
            runs.append(daykey)
        }
    }

    func presents(on daykey: Int) -> [Present] {
        rhumbs.compactMap { rhumb in
            if case .present(let mark) = rhumb, mark.daykey == daykey { return mark }
            return nil
        }
    }

    func gaps(on daykey: Int) -> [GapMark] {
        rhumbs.compactMap { rhumb in
            if case .gap(let mark) = rhumb, mark.daykey == daykey { return mark }
            return nil
        }
    }

    func manuals(on daykey: Int) -> [ManualMark] {
        rhumbs.compactMap { rhumb in
            if case .manual(let mark) = rhumb, mark.daykey == daykey { return mark }
            return nil
        }
    }

    func hollows(on daykey: Int) -> [HollowMark] {
        rhumbs.compactMap { rhumb in
            if case .hollow(let mark) = rhumb, mark.daykey == daykey { return mark }
            return nil
        }
    }

    func isSealed(on daykey: Int) -> Bool {
        rhumbs.contains { rhumb in
            if case .roll(let mark) = rhumb { return mark.daykey == daykey }
            return false
        }
    }

    static func demo(daykey: Int) -> PerchChart {
        var chart = PerchChart.empty
        chart.onboardingComplete = true
        let names = ["Maple", "Brass", "Cinder", "Pebble"]
        let codes = ["PSL-MAPLE", "PSL-BRASS", "PSL-CINDER", "PSL-PEBBLE"]
        for pair in zip(names, codes) {
            let bird = chart.books.band(name: pair.0, code: pair.1, daykey: daykey)
            chart.islands.append(bird)
        }
        let counted = chart.books.active(on: daykey).dropLast()
        for bird in counted {
            chart.rhumbs.append(.present(Present(id: UUID(), birdID: bird.id, daykey: daykey, fromScan: true)))
        }
        chart.remember(daykey: daykey)
        return chart
    }
}
