import Foundation

/// CSV of sealed rolls for Settings. Counts come from the chart, not a second store.
enum RollCSV {
    static func document(chart: PerchChart) -> String {
        var lines = ["Date,Counted,Photographed,Hand,Birds"]
        let sealed = chart.rhumbs.compactMap { rhumb -> Int? in
            if case .roll(let mark) = rhumb { return mark.daykey }
            return nil
        }
        for day in sealed.sorted() {
            let present = chart.presents(on: day).count
            let gap = chart.gaps(on: day).count
            let manual = chart.manuals(on: day).count
            let roster = chart.books.active(on: day).count
            lines.append("\(day),\(present),\(gap),\(manual),\(roster)")
        }
        return lines.joined(separator: "\n")
    }

    static func sealedDays(chart: PerchChart) -> Int {
        chart.rhumbs.reduce(into: 0) { count, rhumb in
            if case .roll = rhumb { count += 1 }
        }
    }
}

/// Seven-day gap rate and tonight's headcount drift. Mash and egg quotients stay nil.
struct WeekReadout: Equatable {
    var gapRate: Double?
    var drift: Int
    var health: Int
    var costLine: String
    var fcrLine: String

    static func make(chart: PerchChart, daykey: Int, calendar: Calendar = .current) -> WeekReadout {
        let active = chart.books.active(on: daykey).count
        let filled = chart.presents(on: daykey).count + chart.gaps(on: daykey).count
        var gapMarks = 0
        var considered = 0
        for offset in 0..<7 {
            guard let today = Daykey.date(daykey, calendar: calendar),
                  let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let key = Daykey.make(date, calendar: calendar)
            let gaps = chart.gaps(on: key).count
            let presents = chart.presents(on: key).count
            if gaps + presents == 0 && !chart.isSealed(on: key) { continue }
            considered += 1
            gapMarks += gaps
        }
        let rate: Double? = considered == 0 ? nil : Double(gapMarks) / Double(max(considered, 1))
        let cost = FlockLedger.costPerUnit(feeds: [], production: [])
        let fcr = FlockLedger.fcr(feeds: [], production: [])
        return WeekReadout(
            gapRate: rate,
            drift: active - filled,
            health: FlockLedger.healthScore(events: []),
            costLine: cost == nil ? "No mash on this census" : "Cost recorded",
            fcrLine: fcr == nil ? "No egg count on this census" : "Feed recorded"
        )
    }
}
