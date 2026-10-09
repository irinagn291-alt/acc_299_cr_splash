import Foundation

/// One banded bird on the islands of the chart. Active when it has no retire day on or before the roll.
struct Bird: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var name: String
    var band: Band
    var bandedOn: Int
    var retiredOn: Int?

    func isActive(on daykey: Int) -> Bool {
        guard let retiredOn else { return true }
        return retiredOn > daykey
    }
}
