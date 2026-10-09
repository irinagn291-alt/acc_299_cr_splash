import Foundation

/// Calendar day as YYYYMMDD. Every roll session is keyed by this integer.
enum Daykey {
    static func make(_ date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10000 + month * 100 + day
    }

    static func date(_ key: Int, calendar: Calendar = .current) -> Date? {
        var parts = DateComponents()
        parts.year = key / 10000
        parts.month = (key / 100) % 100
        parts.day = key % 100
        guard let day = calendar.date(from: parts) else { return nil }
        return calendar.startOfDay(for: day)
    }
}
