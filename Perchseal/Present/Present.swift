import Foundation

/// A bird counted on the perch for one daykey. `fromScan` is false when a manual tap wrote it.
struct Present: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var birdID: UUID
    var daykey: Int
    var fromScan: Bool
}
