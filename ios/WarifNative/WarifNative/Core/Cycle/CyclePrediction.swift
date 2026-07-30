import Foundation

enum CyclePhase: String, Sendable, CaseIterable {
    case menstruation, follicular, ovulation, luteal
}

enum PredictionConfidence: String, Sendable {
    case insufficient, low, medium, high
}

struct CyclePrediction: Sendable {
    var confidence: PredictionConfidence
    /// Number of complete cycles (intervals between starts) used.
    var sampleCount: Int
    /// Number of logged period starts.
    var cyclesUsed: Int
    var medianCycleLength: Int?
    var dataThroughDate: Date?
    var estimatedDate: Date?
    var earliestDate: Date?
    var latestDate: Date?
    let isEstimate = true
}

enum CycleEngine {
    private static let lutealLength = 14
    private static let fertileBefore = 5
    private static let fertileAfter = 1

    static func phase(cycleDay: Int, periodLength: Int, cycleLength: Int) -> CyclePhase {
        let ovulation = min(max(cycleLength - lutealLength, 1), cycleLength)
        let fertileStart = min(max(ovulation - fertileBefore, 1), cycleLength)
        let fertileEnd = min(max(ovulation + fertileAfter, 1), cycleLength)
        if cycleDay <= periodLength { return .menstruation }
        if cycleDay >= fertileStart && cycleDay <= fertileEnd { return .ovulation }
        if cycleDay < fertileStart { return .follicular }
        return .luteal
    }

    /// Current 1-based cycle day for `today`, given the last period start.
    static func cycleDay(
        lastPeriodStart: Date, cycleLength: Int, today: Date,
        calendar: Calendar = WarifCalendar.riyadh
    ) -> Int {
        let elapsed = WarifCalendar.days(from: lastPeriodStart, to: today, calendar)
        let length = max(cycleLength, 1)
        let into = ((elapsed % length) + length) % length
        return into + 1
    }

    private static func median(_ values: [Int]) -> Double {
        let sorted = values.sorted()
        guard !sorted.isEmpty else { return 0 }
        let mid = sorted.count / 2
        return sorted.count % 2 == 0
            ? Double(sorted[mid - 1] + sorted[mid]) / 2
            : Double(sorted[mid])
    }

    /// Predict the next period as an estimate with a confidence level, using
    /// the median cycle length and MAD over recent cycles. Deterministic.
    static func predict(
        periodStarts: [Date], today: Date,
        calendar: Calendar = WarifCalendar.riyadh
    ) -> CyclePrediction {
        let starts = Array(Set(periodStarts.map { WarifCalendar.startOfDay($0, calendar) }))
            .sorted()

        var result = CyclePrediction(
            confidence: .insufficient, sampleCount: 0, cyclesUsed: starts.count,
            medianCycleLength: nil, dataThroughDate: starts.last,
            estimatedDate: nil, earliestDate: nil, latestDate: nil
        )
        guard starts.count >= 2 else { return result }

        let recent = Array(starts.suffix(13))
        var intervals: [Int] = []
        for i in 1..<recent.count {
            intervals.append(WarifCalendar.days(from: recent[i - 1], to: recent[i], calendar))
        }
        let valid = intervals.filter { $0 >= 15 && $0 <= 60 }
        guard !valid.isEmpty else { return result }

        let med = Int(median(valid).rounded())
        let spread = median(valid.map { abs($0 - med) })
        let sampleCount = valid.count

        let confidence: PredictionConfidence
        if sampleCount <= 2 {
            confidence = .low
        } else if sampleCount <= 5 {
            confidence = spread <= 2 ? .medium : .low
        } else {
            confidence = spread <= 1 ? .high : (spread <= 3 ? .medium : .low)
        }

        let marginByConfidence: [PredictionConfidence: Int] =
            [.insufficient: 7, .low: 6, .medium: 3, .high: 2]
        let margin = max(marginByConfidence[confidence] ?? 6, Int(spread.rounded()))

        guard let lastStart = recent.last else { return result }
        var estimated = WarifCalendar.adding(med, to: lastStart, calendar)
        var guardCount = 0
        while WarifCalendar.days(from: estimated, to: today, calendar) >= 0 && guardCount < 60 {
            estimated = WarifCalendar.adding(med, to: estimated, calendar)
            guardCount += 1
        }

        result.confidence = confidence
        result.sampleCount = sampleCount
        result.medianCycleLength = med
        result.estimatedDate = estimated
        result.earliestDate = WarifCalendar.adding(-margin, to: estimated, calendar)
        result.latestDate = WarifCalendar.adding(margin, to: estimated, calendar)
        return result
    }
}
