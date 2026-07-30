import Foundation

struct DailyInsightInput: Sendable {
    let cyclePhase: CyclePhase
    let cycleDay: Int
    let prediction: CyclePrediction?
    let checkIns: [DailyCheckIn]
    let healthSummaries: [DailyHealthSummary]
    let region: SaudiRegion?
    let wellnessProfile: WellnessProfile
}

enum DailyInsightEngine {
    static func generate(_ input: DailyInsightInput) -> DailyInsight {
        var evidence: [String] = [
            "اليوم \(input.cycleDay) من دورتك",
            "المرحلة الحالية: \(WarifCopy.stateName(input.cyclePhase))",
        ]
        if let region = input.region {
            evidence.append("الثيم النشط: \(region.displayNameAr)")
        }
        if let confidence = input.prediction?.confidence {
            evidence.append("ثقة التوقع: \(WarifCopy.confidence(confidence))")
        }

        let recentPain = input.checkIns.map(\.painIntensity).max() ?? 0
        let averageEnergy = average(input.checkIns.map { Double($0.energy) })
        let averageMood = average(input.checkIns.map { Double($0.mood) })
        let sleepHours = average(input.healthSummaries.compactMap(\.sleepHours))
        let restingHeartRate = average(input.healthSummaries.compactMap(\.restingHeartRate))
        let hrv = average(input.healthSummaries.compactMap(\.hrvSDNN))

        var actions = baseActions(for: input.cyclePhase)
        var title = title(for: input.cyclePhase)
        var body = body(for: input.cyclePhase)
        var tone: InsightTone = .calm

        if recentPain >= 7 {
            title = "الألم يحتاج مساحة وهدوء"
            body = "سجلاتك الأخيرة تشير إلى ألم مرتفع. خذي اليوم بخفة، وراجعي مختصة إذا كان الألم شديداً أو يتكرر بشكل يعطل يومك."
            tone = .caution
            actions.append(.doctorPain)
            evidence.append("أعلى ألم مسجل مؤخراً: \(recentPain)/10")
        } else if let averageEnergy, averageEnergy <= 2.5 {
            title = "طاقتك منخفضة قليلاً"
            body = "قد يساعدك تقليل المهام الثقيلة اليوم، مع وجبة متوازنة وحركة خفيفة إن ناسبتك."
            tone = .encouraging
            actions.append(.energyCare)
            evidence.append("متوسط الطاقة في التسجيلات الأخيرة: \(String(format: "%.1f", averageEnergy))/5")
        } else if let sleepHours, sleepHours < 6.5 {
            title = "النوم يظهر كعامل مهم"
            body = "بيانات النوم من تطبيق صحتي منخفضة نسبياً. استخدمي وريف لملاحظة العلاقة بين النوم والمزاج والطاقة عبر الأيام."
            tone = .encouraging
            actions.append(.sleepCare)
            evidence.append("متوسط النوم: \(String(format: "%.1f", sleepHours)) ساعات")
        } else if let hrv, hrv < 35 {
            title = "جسمك قد يطلب إيقاعاً أهدأ"
            body = "انخفاض HRV قد يرتبط بالإجهاد أو قلة التعافي. اعتبريها إشارة عامة، وليست تشخيصاً."
            tone = .caution
            actions.append(.breathingCare)
            evidence.append("متوسط HRV: \(String(format: "%.0f", hrv)) ms")
        } else if let averageMood, averageMood >= 4 {
            title = "هناك استقرار لطيف في المزاج"
            body = "سجلاتك تميل لمزاج جيد. احفظي ما ساعدك اليوم لتكراره في أيام مشابهة من الدورة."
            tone = .encouraging
            actions.append(.patternNote)
            evidence.append("متوسط المزاج: \(String(format: "%.1f", averageMood))/5")
        }

        if let restingHeartRate {
            evidence.append("متوسط نبض الراحة: \(String(format: "%.0f", restingHeartRate)) نبضة/دقيقة")
        }
        if input.wellnessProfile.sensitiveModeEnabled {
            actions.append(.privacyReminder)
        }

        return DailyInsight(
            id: "daily-\(input.cyclePhase.rawValue)-\(input.cycleDay)",
            titleAr: title,
            bodyAr: body,
            tone: tone,
            actions: actions.sorted { $0.priority < $1.priority },
            evidenceAr: evidence,
            medicalDisclaimerAr: "هذه رؤية تثقيفية مبنية على تسجيلاتك وبياناتك الاختيارية، وليست تشخيصاً أو وسيلة لمنع الحمل أو مراقبة طوارئ."
        )
    }

    private static func average(_ values: [Double]) -> Double? {
        values.isEmpty ? nil : values.reduce(0, +) / Double(values.count)
    }

    private static func title(for phase: CyclePhase) -> String {
        switch phase {
        case .menstruation: "يوم للعناية الهادئة"
        case .follicular: "مساحة لبداية أخف"
        case .ovulation: "انتبهي لإشارات جسمك"
        case .luteal: "ثبات واحتواء قبل الموعد المتوقع"
        }
    }

    private static func body(for phase: CyclePhase) -> String {
        switch phase {
        case .menstruation:
            "ركزي على الراحة، السوائل، وتسجيل الألم أو النزف بوضوح حتى تظهر الأنماط لاحقاً."
        case .follicular:
            "إذا بدأت الطاقة ترتفع، اختاري هدفاً صغيراً لهذا الأسبوع وراقبي أثره على مزاجك."
        case .ovulation:
            "قد تتغير الإفرازات والطاقة حول هذه الأيام. سجلي الملاحظات بدون افتراضات قطعية."
        case .luteal:
            "راقبي النوم، الشهية، والمزاج بلطف. التحضير المبكر يجعل الأيام القادمة أوضح."
        }
    }

    private static func baseActions(for phase: CyclePhase) -> [CareAction] {
        switch phase {
        case .menstruation: [.logPain, .hydration]
        case .follicular: [.patternNote, .gentleMovement]
        case .ovulation: [.logSignals, .hydration]
        case .luteal: [.sleepCare, .patternNote]
        }
    }
}

extension CareAction {
    static let logPain = CareAction(
        id: "log-pain", kind: .log,
        titleAr: "سجلي الألم بدقة",
        bodyAr: "درجة الألم ومكانه تساعدك في تجهيز ملخص واضح للطبيبة عند الحاجة.",
        priority: 10
    )
    static let logSignals = CareAction(
        id: "log-signals", kind: .log,
        titleAr: "التقطي إشارات الجسم",
        bodyAr: "الإفرازات، الطاقة، والرغبة بالطعام قد توضح نمطك عبر الشهور.",
        priority: 12
    )
    static let hydration = CareAction(
        id: "hydration", kind: .hydration,
        titleAr: "ماء ووجبة خفيفة",
        bodyAr: "اختاري شيئاً بسيطاً يدعم جسمك بدون ضغط.",
        priority: 20
    )
    static let gentleMovement = CareAction(
        id: "gentle-movement", kind: .movement,
        titleAr: "حركة خفيفة",
        bodyAr: "مشي قصير أو تمطيط بسيط إن كان مناسباً لك اليوم.",
        priority: 22
    )
    static let sleepCare = CareAction(
        id: "sleep-care", kind: .sleep,
        titleAr: "نامي أبكر قليلاً",
        bodyAr: "حتى 20 دقيقة إضافية قد تجعل تسجيلات الغد أوضح.",
        priority: 24
    )
    static let energyCare = CareAction(
        id: "energy-care", kind: .nutrition,
        titleAr: "خففي الحمل",
        bodyAr: "قدمي مهمة واحدة مهمة، واتركي الباقي ليوم أعلى طاقة.",
        priority: 18
    )
    static let breathingCare = CareAction(
        id: "breathing-care", kind: .breathing,
        titleAr: "دقيقتان تنفس",
        bodyAr: "تنفس هادئ قبل النوم أو بعد التوتر يساعدك تلاحظين أثر التعافي.",
        priority: 16
    )
    static let patternNote = CareAction(
        id: "pattern-note", kind: .log,
        titleAr: "اكتبي ملاحظة قصيرة",
        bodyAr: "جملة واحدة عن يومك تكفي لبناء ذاكرة صحية نافعة.",
        priority: 14
    )
    static let doctorPain = CareAction(
        id: "doctor-pain", kind: .doctor,
        titleAr: "جهزي ملخصاً للطبيبة",
        bodyAr: "راجعي مختصة إذا كان الألم شديداً، جديداً، أو يعطلك عن يومك.",
        priority: 5
    )
    static let privacyReminder = CareAction(
        id: "privacy-reminder", kind: .privacy,
        titleAr: "راجعي الخصوصية",
        bodyAr: "يمكنك إخفاء القيم الحساسة أو حذف البيانات المحلية من مركز الخصوصية.",
        priority: 40
    )
}
