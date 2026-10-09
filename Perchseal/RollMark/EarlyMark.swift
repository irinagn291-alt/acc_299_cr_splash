import Foundation

/// Seal attempted before Present plus Gap matches the active roster. The roll stays open.
struct EarlyMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var daykey: Int
}
