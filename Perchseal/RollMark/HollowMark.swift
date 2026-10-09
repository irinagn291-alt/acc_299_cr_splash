import Foundation

/// Gap without a snap, or Seal while a gap is still unfilled. The roll stays open.
struct HollowMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var daykey: Int
}
