import Foundation

/// Date helpers pinned to Asia/Riyadh so local-day boundaries are correct
/// (mirrors the web app's `getLocalDateISO`). Never derive a local day from a
/// UTC timestamp directly.
enum WarifCalendar {
    static var riyadh: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Riyadh") ?? .current
        return calendar
    }

    static func startOfDay(_ date: Date, _ calendar: Calendar = riyadh) -> Date {
        calendar.startOfDay(for: date)
    }

    static func days(from: Date, to: Date, _ calendar: Calendar = riyadh) -> Int {
        calendar.dateComponents(
            [.day], from: startOfDay(from, calendar), to: startOfDay(to, calendar)
        ).day ?? 0
    }

    static func adding(_ days: Int, to date: Date, _ calendar: Calendar = riyadh) -> Date {
        calendar.date(byAdding: .day, value: days, to: date) ?? date
    }
}
