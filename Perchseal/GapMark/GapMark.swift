import Foundation

/// A roster shortfall filed with a local photo. The JPEG lives beside the chart, not inside it.
struct GapMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var daykey: Int
    var note: String
    var photoFile: String

    var hasSnap: Bool { !photoFile.isEmpty }
}
