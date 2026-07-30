import Foundation

/// The 13 administrative regions of Saudi Arabia.
enum SaudiRegion: String, Codable, CaseIterable, Identifiable, Sendable {
    case riyadh
    case makkah
    case madinah
    case qassim
    case eastern
    case asir
    case tabuk
    case hail
    case northernBorders
    case jazan
    case najran
    case alBahah
    case alJawf

    var id: String { rawValue }

    /// Stable internal slug (kept identical to the raw value).
    var slug: String { rawValue }

    var displayNameAr: String {
        switch self {
        case .riyadh: "الرياض"
        case .makkah: "مكة المكرمة"
        case .madinah: "المدينة المنورة"
        case .qassim: "القصيم"
        case .eastern: "المنطقة الشرقية"
        case .asir: "عسير"
        case .tabuk: "تبوك"
        case .hail: "حائل"
        case .northernBorders: "الحدود الشمالية"
        case .jazan: "جازان"
        case .najran: "نجران"
        case .alBahah: "الباحة"
        case .alJawf: "الجوف"
        }
    }

    var displayNameEn: String {
        switch self {
        case .riyadh: "Riyadh"
        case .makkah: "Makkah"
        case .madinah: "Madinah"
        case .qassim: "Qassim"
        case .eastern: "Eastern Province"
        case .asir: "Asir"
        case .tabuk: "Tabuk"
        case .hail: "Hail"
        case .northernBorders: "Northern Borders"
        case .jazan: "Jazan"
        case .najran: "Najran"
        case .alBahah: "Al Bahah"
        case .alJawf: "Al Jawf"
        }
    }

    /// Localized display name for the current locale (Arabic-first).
    func displayName(for locale: Locale = .current) -> String {
        locale.language.languageCode?.identifier == "en"
            ? displayNameEn : displayNameAr
    }

    /// How the region was chosen. Coordinates are never stored.
    enum Source: String, Codable, Sendable {
        case manual
        case approximateLocation = "approximate_location"
    }
}
