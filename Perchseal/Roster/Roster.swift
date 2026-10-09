import Foundation

/// The books of the chart: who is banded, and who has been retired.
struct Roster: Codable, Equatable, Sendable {
    var birds: [Bird]

    func active(on daykey: Int) -> [Bird] {
        birds.filter { $0.isActive(on: daykey) }
    }

    func bird(band code: String) -> Bird? {
        let needle = Band(code: code).normalized
        return birds.first { $0.band.normalized == needle }
    }

    mutating func band(name: String, code: String, daykey: Int) -> Bird {
        let bird = Bird(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            band: Band(code: code),
            bandedOn: daykey,
            retiredOn: nil
        )
        birds.append(bird)
        return bird
    }

    mutating func retire(_ birdID: UUID, daykey: Int) {
        guard let index = birds.firstIndex(where: { $0.id == birdID }) else { return }
        birds[index].retiredOn = daykey
    }
}
