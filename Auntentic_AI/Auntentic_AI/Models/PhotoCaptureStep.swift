//
//  PhotoCaptureStep.swift
//  Auntentic_AI
//

import Foundation

/// Represents the core 6 steps in the authentication process
enum PhotoCaptureStep: String, CaseIterable, Identifiable {
    case outerSide = "Outer Side"
    case innerSide = "Inner Side"
    case sizeTag = "Size Tag"
    case soleView = "Sole View"
    case tongueLabel = "Tongue Label"
    case heelDetail = "Heel Detail"

    var id: String { rawValue }
    var title: String { rawValue }

    var instruction: String {
        switch self {
        case .outerSide: return "Capture the full outer side profile clearly."
        case .innerSide: return "Capture the full inner side profile."
        case .sizeTag: return "Close-up of the size tag inside the shoe."
        case .soleView: return "Show the entire tread pattern on the bottom."
        case .tongueLabel: return "Close-up of the tongue label/branding."
        case .heelDetail: return "Capture the back heel and its stitching."
        }
    }

    var iconName: String {
        switch self {
        case .outerSide: return "shoe.fill"
        case .innerSide: return "shoe.2.fill"
        case .sizeTag: return "tag.fill"
        case .soleView: return "shoeprints.fill"
        case .tongueLabel: return "text.viewfinder"
        case .heelDetail: return "app.badge.fill"
        }
    }

    /// For the camera guidance silhouette
    var silhouetteIcon: String {
        switch self {
        case .outerSide, .innerSide, .heelDetail: return "shoe.fill"
        case .sizeTag, .tongueLabel: return "tag.fill"
        case .soleView: return "shoeprints.fill"
        }
    }

    var hintText: String {
        switch self {
        case .outerSide, .innerSide:
            return "Pinch to zoom and tap to focus. Photograph your product in full."
        case .sizeTag, .tongueLabel:
            return "Ensure all text is clearly readable and in focus."
        case .soleView:
            return "Align the entire tread pattern within the guide."
        case .heelDetail:
            return "Capture the back of the shoe, focusing on stitching and logos."
        }
    }

    var qualityRequirements: String {
        switch self {
        case .outerSide, .innerSide:
            return "Focus: Sharp. Lighting: Bright. Framing: Full shoe"
        default:
            return "Focus: Sharp. Lighting: Even. Framing: Close-up"
        }
    }
    var referenceImageName: String {
        switch self {
        case .outerSide: return "ref_outer_side"
        case .innerSide: return "ref_inner_side"
        case .sizeTag: return "ref_sizetag"
        case .soleView: return "ref_sole"
        case .tongueLabel: return "ref_tongue"
        case .heelDetail: return "ref_heel"
        }
    }
}
