import Foundation

/// Unknown scan payload. Offers a roster add and does not count as Present.
struct StrayMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var daykey: Int
    var payload: String
}
