import Foundation

enum WarifFormat {
    static func mediumDate(_ date: Date, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.calendar = WarifCalendar.riyadh
        formatter.timeZone = WarifCalendar.riyadh.timeZone
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

enum WarifCopy {
    static func stateName(_ phase: CyclePhase) -> String {
        switch phase {
        case .menstruation: "السكون"
        case .follicular: "التجدد"
        case .ovulation: "التوازن"
        case .luteal: "الاحتواء"
        }
    }

    static func confidence(_ confidence: PredictionConfidence) -> String {
        switch confidence {
        case .insufficient: "بيانات غير كافية"
        case .low: "ثقة منخفضة"
        case .medium: "ثقة متوسطة"
        case .high: "ثقة عالية"
        }
    }
}
