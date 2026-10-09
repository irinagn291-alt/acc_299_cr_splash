import Foundation

/// The flock for one daykey: active birds and the folded roll phase. Phase is computed, never stored.
struct Flock: Equatable, Sendable {
    var daykey: Int
    var birds: [Bird]
    var phase: RollPhase

    var activeBirds: [Bird] {
        birds.filter { $0.isActive(on: daykey) }
    }
}
