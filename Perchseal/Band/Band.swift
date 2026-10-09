import Foundation

/// Wing-band code scanned on the perch strip. Matching is local.
struct Band: Codable, Equatable, Hashable, Sendable {
    var code: String

    var normalized: String {
        code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }
}
