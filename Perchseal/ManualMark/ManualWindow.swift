import Foundation

/// Rolling seven daykeys, inclusive of today, using start-of-day dates.
enum ManualWindow {
    static func contains(_ markDay: Int, today: Int, calendar: Calendar = .current) -> Bool {
        guard let todayDate = Daykey.date(today, calendar: calendar),
              let markDate = Daykey.date(markDay, calendar: calendar),
              let start = calendar.date(byAdding: .day, value: -6, to: todayDate) else {
            return false
        }
        let open = calendar.startOfDay(for: start)
        return markDate >= open && markDate <= todayDate
    }
}
