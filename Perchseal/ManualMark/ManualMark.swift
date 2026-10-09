import Foundation

/// Recorded before Present when the keeper taps a bird instead of scanning the band.
struct ManualMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var birdID: UUID
    var daykey: Int
}
