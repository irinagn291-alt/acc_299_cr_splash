import Foundation

/// Drops the latest Present, Gap, or Manual mark and reopens a sealed roll.
enum Peel {
    static func apply(_ chart: inout PerchChart, daykey: Int) -> RollEffect {
        guard let index = chart.rhumbs.lastIndex(where: { rhumb in
            switch rhumb {
            case .present(let mark): return mark.daykey == daykey
            case .gap(let mark): return mark.daykey == daykey
            case .manual(let mark): return mark.daykey == daykey
            default: return false
            }
        }) else {
            return .refused("Nothing to reopen. Scan, or photograph the empty perch.")
        }
        chart.rhumbs.remove(at: index)
        chart.rhumbs.removeAll { rhumb in
            if case .roll(let mark) = rhumb { return mark.daykey == daykey }
            return false
        }
        return .peeled
    }
}
