import Foundation

/// A Present tap with no scan. Allowed once per bird inside the rolling seven-day window.
struct PresentTap: Equatable, Sendable {
    var birdID: UUID
    var daykey: Int
}
