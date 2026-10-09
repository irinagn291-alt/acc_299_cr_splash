import Foundation

/// Band-scan roll ADT. Bare, Open, Tallying, and Sealed are a fold over birds for one daykey.
enum RollPhase: Equatable, Sendable {
    case bare
    case open
    case tallying
    case sealed
}

enum RollEffect: Equatable, Sendable {
    case bare
    case present
    case manualThenPresent
    case stray
    case gap
    case hollow
    case early
    case sealed
    case peeled
    case refused(String)
}

enum RollFold {
    static func phase(_ chart: PerchChart, daykey: Int) -> RollPhase {
        let active = chart.books.active(on: daykey)
        if active.isEmpty { return .bare }
        if chart.isSealed(on: daykey) { return .sealed }
        if chart.presents(on: daykey).isEmpty { return .open }
        return .tallying
    }

    static func flock(_ chart: PerchChart, daykey: Int) -> Flock {
        Flock(daykey: daykey, birds: chart.birds, phase: phase(chart, daykey: daykey))
    }

    static func scan(_ chart: inout PerchChart, payload: String, daykey: Int) -> RollEffect {
        let active = chart.books.active(on: daykey)
        if active.isEmpty {
            return .bare
        }
        if chart.isSealed(on: daykey) {
            return .refused("Tonight is sealed. Reopen if a count needs to change.")
        }
        chart.remember(daykey: daykey)
        guard let bird = chart.books.bird(band: payload), bird.isActive(on: daykey) else {
            chart.rhumbs.append(.stray(StrayMark(id: UUID(), daykey: daykey, payload: payload)))
            return .stray
        }
        if chart.presents(on: daykey).contains(where: { $0.birdID == bird.id }) {
            return .refused(alreadyCounted)
        }
        if rosterFilled(chart, daykey: daykey) {
            return .refused(countsMatch)
        }
        chart.rhumbs.append(.present(Present(id: UUID(), birdID: bird.id, daykey: daykey, fromScan: true)))
        return .present
    }

    static func tapPresent(_ chart: inout PerchChart, birdID: UUID, daykey: Int, calendar: Calendar = .current) -> RollEffect {
        let active = chart.books.active(on: daykey)
        if active.isEmpty { return .bare }
        if chart.isSealed(on: daykey) {
            return .refused("Tonight is sealed. Reopen if a count needs to change.")
        }
        guard active.contains(where: { $0.id == birdID }) else {
            return .refused("That bird is not on the active roster. Band a bird first.")
        }
        if chart.presents(on: daykey).contains(where: { $0.birdID == birdID }) {
            return .refused(alreadyCounted)
        }
        if rosterFilled(chart, daykey: daykey) {
            return .refused(countsMatch)
        }
        let used = chart.rhumbs.contains { rhumb in
            guard case .manual(let mark) = rhumb, mark.birdID == birdID else { return false }
            return ManualWindow.contains(mark.daykey, today: daykey, calendar: calendar)
        }
        if used {
            return .refused("Manual mark already used this week. Scan the band.")
        }
        chart.remember(daykey: daykey)
        chart.rhumbs.append(.manual(ManualMark(id: UUID(), birdID: birdID, daykey: daykey)))
        chart.rhumbs.append(.present(Present(id: UUID(), birdID: birdID, daykey: daykey, fromScan: false)))
        return .manualThenPresent
    }

    static func snapGap(_ chart: inout PerchChart, daykey: Int, note: String, photoFile: String) -> RollEffect {
        guard !photoFile.isEmpty else {
            return markHollow(chart: &chart, daykey: daykey)
        }
        if chart.books.active(on: daykey).isEmpty { return .bare }
        if chart.isSealed(on: daykey) {
            return .refused("Tonight is sealed. Reopen if a count needs to change.")
        }
        let activeCount = chart.books.active(on: daykey).count
        let filled = chart.presents(on: daykey).count + chart.gaps(on: daykey).count
        if filled >= activeCount {
            return .refused(countsMatch)
        }
        chart.remember(daykey: daykey)
        chart.rhumbs.append(.gap(GapMark(id: UUID(), daykey: daykey, note: note, photoFile: photoFile)))
        return .gap
    }

    static func markHollow(chart: inout PerchChart, daykey: Int) -> RollEffect {
        if chart.books.active(on: daykey).isEmpty { return .bare }
        chart.remember(daykey: daykey)
        chart.rhumbs.append(.hollow(HollowMark(id: UUID(), daykey: daykey)))
        return .hollow
    }

    static func seal(_ chart: inout PerchChart, daykey: Int) -> RollEffect {
        let activeCount = chart.books.active(on: daykey).count
        if activeCount == 0 { return .bare }
        if chart.isSealed(on: daykey) {
            return .refused("Tonight is already sealed.")
        }
        chart.remember(daykey: daykey)
        let gaps = chart.gaps(on: daykey)
        let unfilled = gaps.contains { !$0.hasSnap } || !chart.hollows(on: daykey).isEmpty
        if unfilled {
            chart.rhumbs.append(.hollow(HollowMark(id: UUID(), daykey: daykey)))
            return .hollow
        }
        let filled = chart.presents(on: daykey).count + gaps.count
        if filled != activeCount {
            chart.rhumbs.append(.early(EarlyMark(id: UUID(), daykey: daykey)))
            return .early
        }
        chart.rhumbs.append(.roll(RollMark(id: UUID(), daykey: daykey)))
        return .sealed
    }

    static func peel(_ chart: inout PerchChart, daykey: Int) -> RollEffect {
        Peel.apply(&chart, daykey: daykey)
    }

    private static let alreadyCounted = "That bird is already counted. Photograph the gap, or seal."
    private static let countsMatch = "Counts already match. Seal the night."

    private static func rosterFilled(_ chart: PerchChart, daykey: Int) -> Bool {
        let activeCount = chart.books.active(on: daykey).count
        let filled = chart.presents(on: daykey).count + chart.gaps(on: daykey).count
        return activeCount > 0 && filled >= activeCount
    }
}
