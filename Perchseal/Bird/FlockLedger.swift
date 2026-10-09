import Foundation

/// Family ledger math. This census does not store mash or egg quantity.
/// Quotients are nil when quantity is zero so a headcount roll never invents FCR.
struct Feed: Equatable, Sendable {
    var cost: Decimal
    var kilograms: Decimal
}

struct Production: Equatable, Sendable {
    var quantity: Decimal
}

struct HealthEvent: Equatable, Sendable {
    var mortality: Int
    var notes: Int
}

enum FlockLedger {
    static func costPerUnit(feeds: [Feed], production: [Production]) -> Decimal? {
        let quantity = production.reduce(Decimal.zero) { $0 + $1.quantity }
        guard quantity > 0 else { return nil }
        let feedCost = feeds.reduce(Decimal.zero) { $0 + $1.cost }
        return feedCost / quantity
    }

    static func fcr(feeds: [Feed], production: [Production]) -> Decimal? {
        let quantity = production.reduce(Decimal.zero) { $0 + $1.quantity }
        guard quantity > 0 else { return nil }
        let feedKg = feeds.reduce(Decimal.zero) { $0 + $1.kilograms }
        return feedKg / quantity
    }

    /// healthScore = clamp(100 − mortality×140 − min(20, notes)).
    static func healthScore(mortality: Int, notes: Int) -> Int {
        let raw = 100 - mortality * 140 - min(20, max(0, notes))
        return min(100, max(0, raw))
    }

    static func healthScore(events: [HealthEvent]) -> Int {
        let mortality = events.reduce(0) { $0 + $1.mortality }
        let notes = events.reduce(0) { $0 + $1.notes }
        return healthScore(mortality: mortality, notes: notes)
    }
}
