import SwiftUI

/// A decorative regional theme. Colors are stored as hex so themes are simple
/// values; decorative elements never encode a medical phase or diagnosis.
struct RegionTheme: Identifiable, Sendable {
    enum Motif: String, Sendable {
        case steppedGeometry, mountainCurves, palmArcs, seedLeaf, waves
        case geometricBands, canyonLayers, twinMountains, horizonStars
        case terraceCurves, steppedBlocks, mistLayers, oliveLeaves, warifPetal
    }

    enum ContrastStyle: String, Sendable {
        case light, dark
    }

    let id: String
    let primaryHex: String
    let secondaryHex: String
    let accentHex: String
    let backgroundTopHex: String
    let backgroundBottomHex: String
    let surfaceHex: String
    let textPrimaryHex: String
    let motif: Motif
    let contrastStyle: ContrastStyle

    var primary: Color { Color(hex: primaryHex) }
    var secondary: Color { Color(hex: secondaryHex) }
    var accent: Color { Color(hex: accentHex) }
    var backgroundTop: Color { Color(hex: backgroundTopHex) }
    var backgroundBottom: Color { Color(hex: backgroundBottomHex) }
    var surface: Color { Color(hex: surfaceHex) }
    var textPrimary: Color { Color(hex: textPrimaryHex) }
}

extension RegionTheme {
    /// The neutral "Warif base" theme (also the fallback).
    static let warifBase = RegionTheme(
        id: "warif",
        primaryHex: "#895B75",
        secondaryHex: "#C98D9E",
        accentHex: "#AAA0C8",
        backgroundTopHex: "#FFF9F6",
        backgroundBottomHex: "#F4E7EC",
        surfaceHex: "#FFFFFF",
        textPrimaryHex: "#30272D",
        motif: .warifPetal,
        contrastStyle: .light
    )

    /// Theme for each region. All share the Warif berry/ivory anchors.
    static func theme(for region: SaudiRegion) -> RegionTheme {
        switch region {
        case .riyadh:
            RegionTheme(id: region.slug, primaryHex: "#895B75", secondaryHex: "#C89B6A",
                accentHex: "#E7A27E", backgroundTopHex: "#FFF9F6", backgroundBottomHex: "#E9D5CE",
                surfaceHex: "#FFFFFF", textPrimaryHex: "#30272D", motif: .steppedGeometry, contrastStyle: .light)
        case .makkah:
            RegionTheme(id: region.slug, primaryHex: "#895B75", secondaryHex: "#A38C7A",
                accentHex: "#C9A24B", backgroundTopHex: "#FFF9F6", backgroundBottomHex: "#EBE1D4",
                surfaceHex: "#FFFFFF", textPrimaryHex: "#30272D", motif: .mountainCurves, contrastStyle: .light)
        case .madinah:
            RegionTheme(id: region.slug, primaryHex: "#5E7466", secondaryHex: "#C98D9E",
                accentHex: "#8FAF9B", backgroundTopHex: "#FFF9F6", backgroundBottomHex: "#DCE4DE",
                surfaceHex: "#FFFFFF", textPrimaryHex: "#2B2E2B", motif: .palmArcs, contrastStyle: .light)
        case .qassim:
            RegionTheme(id: region.slug, primaryHex: "#8C5A6B", secondaryHex: "#C9A24B",
                accentHex: "#7C9A6A", backgroundTopHex: "#FFF9F6", backgroundBottomHex: "#EEE2CE",
                surfaceHex: "#FFFFFF", textPrimaryHex: "#30272D", motif: .seedLeaf, contrastStyle: .light)
        case .eastern:
            RegionTheme(id: region.slug, primaryHex: "#3E7C86", secondaryHex: "#895B75",
                accentHex: "#8FC6CE", backgroundTopHex: "#FFF9F6", backgroundBottomHex: "#D9E9EA",
                surfaceHex: "#FFFFFF", textPrimaryHex: "#26343A", motif: .waves, contrastStyle: .light)
        case .asir:
            RegionTheme(id: region.slug, primaryHex: "#3E6B57", secondaryHex: "#895B75",
                accentHex: "#7C9BC0", backgroundTopHex: "#FFF9F6", backgroundBottomHex: "#DCE3E4",
                surfaceHex: "#FFFFFF", textPrimaryHex: "#28322B", motif: .geometricBands, contrastStyle: .light)
        case .tabuk:
            RegionTheme(id: region.slug, primaryHex: "#A85F49", secondaryHex: "#3E7C86",
                accentHex: "#D89A7E", backgroundTopHex: "#FFF9F6", backgroundBottomHex: "#EAD9CF",
                surfaceHex: "#FFFFFF", textPrimaryHex: "#382A26", motif: .canyonLayers, contrastStyle: .light)
        case .hail:
            RegionTheme(id: region.slug, primaryHex: "#9C5A47", secondaryHex: "#B87333",
                accentHex: "#C98D9E", backgroundTopHex: "#FFF9F6", backgroundBottomHex: "#E7D3C8",
                surfaceHex: "#FFFFFF", textPrimaryHex: "#33261F", motif: .twinMountains, contrastStyle: .light)
        case .northernBorders:
            RegionTheme(id: region.slug, primaryHex: "#6B6488", secondaryHex: "#895B75",
                accentHex: "#B9B2CE", backgroundTopHex: "#FFF9F6", backgroundBottomHex: "#E3DFEA",
                surfaceHex: "#FFFFFF", textPrimaryHex: "#2B2833", motif: .horizonStars, contrastStyle: .light)
        case .jazan:
            RegionTheme(id: region.slug, primaryHex: "#2F7A5F", secondaryHex: "#E27D6B",
                accentHex: "#57B0A6", backgroundTopHex: "#FFF9F6", backgroundBottomHex: "#DCEAE2",
                surfaceHex: "#FFFFFF", textPrimaryHex: "#243530", motif: .terraceCurves, contrastStyle: .light)
        case .najran:
            RegionTheme(id: region.slug, primaryHex: "#A85F49", secondaryHex: "#3B4A7A",
                accentHex: "#B87333", backgroundTopHex: "#FFF9F6", backgroundBottomHex: "#E9DAC9",
                surfaceHex: "#FFFFFF", textPrimaryHex: "#312722", motif: .steppedBlocks, contrastStyle: .light)
        case .alBahah:
            RegionTheme(id: region.slug, primaryHex: "#54685A", secondaryHex: "#895B75",
                accentHex: "#9AA6A0", backgroundTopHex: "#FFF9F6", backgroundBottomHex: "#DEE3DF",
                surfaceHex: "#FFFFFF", textPrimaryHex: "#2A302B", motif: .mistLayers, contrastStyle: .light)
        case .alJawf:
            RegionTheme(id: region.slug, primaryHex: "#6E7A46", secondaryHex: "#895B75",
                accentHex: "#8FB0C6", backgroundTopHex: "#FFF9F6", backgroundBottomHex: "#E6E3D3",
                surfaceHex: "#FFFFFF", textPrimaryHex: "#2F3126", motif: .oliveLeaves, contrastStyle: .light)
        }
    }
}
