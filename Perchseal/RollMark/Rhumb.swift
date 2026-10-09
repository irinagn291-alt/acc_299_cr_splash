import Foundation

/// One mark on the chart: Present, Gap, Manual, Roll, Stray, Hollow, or Early.
enum Rhumb: Codable, Equatable, Sendable, Identifiable {
    case present(Present)
    case gap(GapMark)
    case manual(ManualMark)
    case roll(RollMark)
    case stray(StrayMark)
    case hollow(HollowMark)
    case early(EarlyMark)

    var id: UUID {
        switch self {
        case .present(let mark): return mark.id
        case .gap(let mark): return mark.id
        case .manual(let mark): return mark.id
        case .roll(let mark): return mark.id
        case .stray(let mark): return mark.id
        case .hollow(let mark): return mark.id
        case .early(let mark): return mark.id
        }
    }

    private enum Kind: String, Codable {
        case present, gap, manual, roll, stray, hollow, early
    }

    private enum CodingKeys: String, CodingKey {
        case kind, id, birdID, daykey, fromScan, note, photoFile, payload
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .kind)
        let id = try c.decode(UUID.self, forKey: .id)
        let daykey = try c.decode(Int.self, forKey: .daykey)
        switch kind {
        case .present:
            let birdID = try c.decode(UUID.self, forKey: .birdID)
            let fromScan = try c.decode(Bool.self, forKey: .fromScan)
            self = .present(Present(id: id, birdID: birdID, daykey: daykey, fromScan: fromScan))
        case .gap:
            let note = try c.decode(String.self, forKey: .note)
            let photoFile = try c.decode(String.self, forKey: .photoFile)
            self = .gap(GapMark(id: id, daykey: daykey, note: note, photoFile: photoFile))
        case .manual:
            let birdID = try c.decode(UUID.self, forKey: .birdID)
            self = .manual(ManualMark(id: id, birdID: birdID, daykey: daykey))
        case .roll:
            self = .roll(RollMark(id: id, daykey: daykey))
        case .stray:
            let payload = try c.decode(String.self, forKey: .payload)
            self = .stray(StrayMark(id: id, daykey: daykey, payload: payload))
        case .hollow:
            self = .hollow(HollowMark(id: id, daykey: daykey))
        case .early:
            self = .early(EarlyMark(id: id, daykey: daykey))
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .present(let mark):
            try c.encode(Kind.present, forKey: .kind)
            try c.encode(mark.id, forKey: .id)
            try c.encode(mark.birdID, forKey: .birdID)
            try c.encode(mark.daykey, forKey: .daykey)
            try c.encode(mark.fromScan, forKey: .fromScan)
        case .gap(let mark):
            try c.encode(Kind.gap, forKey: .kind)
            try c.encode(mark.id, forKey: .id)
            try c.encode(mark.daykey, forKey: .daykey)
            try c.encode(mark.note, forKey: .note)
            try c.encode(mark.photoFile, forKey: .photoFile)
        case .manual(let mark):
            try c.encode(Kind.manual, forKey: .kind)
            try c.encode(mark.id, forKey: .id)
            try c.encode(mark.birdID, forKey: .birdID)
            try c.encode(mark.daykey, forKey: .daykey)
        case .roll(let mark):
            try c.encode(Kind.roll, forKey: .kind)
            try c.encode(mark.id, forKey: .id)
            try c.encode(mark.daykey, forKey: .daykey)
        case .stray(let mark):
            try c.encode(Kind.stray, forKey: .kind)
            try c.encode(mark.id, forKey: .id)
            try c.encode(mark.daykey, forKey: .daykey)
            try c.encode(mark.payload, forKey: .payload)
        case .hollow(let mark):
            try c.encode(Kind.hollow, forKey: .kind)
            try c.encode(mark.id, forKey: .id)
            try c.encode(mark.daykey, forKey: .daykey)
        case .early(let mark):
            try c.encode(Kind.early, forKey: .kind)
            try c.encode(mark.id, forKey: .id)
            try c.encode(mark.daykey, forKey: .daykey)
        }
    }
}
