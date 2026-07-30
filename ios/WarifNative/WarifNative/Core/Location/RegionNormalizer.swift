import Foundation

/// Maps a reverse-geocoded administrative-area name (Arabic or English) to a
/// `SaudiRegion`. Pure and testable; coordinates are never involved here.
enum RegionNormalizer {
    static func region(forAdministrativeArea area: String?) -> SaudiRegion? {
        guard let raw = area?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else { return nil }
        let n = normalize(raw)

        for region in SaudiRegion.allCases {
            let candidates = keywords(for: region).map(normalize)
            if candidates.contains(where: { n.contains($0) }) {
                return region
            }
        }
        return nil
    }

    private static func normalize(_ s: String) -> String {
        var out = s.lowercased()
        // Strip Arabic administrative words and diacritics-ish variants.
        for token in ["منطقة", "إمارة", "امارة", "region", "province", "governorate"] {
            out = out.replacingOccurrences(of: token, with: "")
        }
        out = out.replacingOccurrences(of: "ال", with: "")
        return out.trimmingCharacters(in: .whitespaces)
    }

    private static func keywords(for region: SaudiRegion) -> [String] {
        switch region {
        case .riyadh: ["الرياض", "riyadh", "riyad"]
        case .makkah: ["مكة", "مكة المكرمة", "makkah", "mecca"]
        case .madinah: ["المدينة", "المدينة المنورة", "madinah", "medina"]
        case .qassim: ["القصيم", "قصيم", "qassim", "al-qassim", "buraidah"]
        case .eastern: ["الشرقية", "المنطقة الشرقية", "eastern", "dammam", "ash sharqiyah"]
        case .asir: ["عسير", "asir", "aseer", "abha"]
        case .tabuk: ["تبوك", "tabuk"]
        case .hail: ["حائل", "hail", "ha'il"]
        case .northernBorders: ["الحدود الشمالية", "northern borders", "northern border", "arar"]
        case .jazan: ["جازان", "جيزان", "jazan", "jizan"]
        case .najran: ["نجران", "najran"]
        case .alBahah: ["الباحة", "باحة", "bahah", "al bahah", "al-baha"]
        case .alJawf: ["الجوف", "جوف", "jawf", "al jawf", "al-jouf", "sakaka"]
        }
    }
}
