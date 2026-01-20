//
//  AuthenticationResult.swift
//  Auntentic_AI
//
//  Created by Claude AI on 12/29/25.
//  Task 11: Authentication result model for OpenAI Vision API response
//  Updated: Legal compliance - probabilistic language only - Jan 3, 2026
//

import Foundation

/// Shoe identification from AI analysis
struct ShoeIdentification: Codable {
    let brand: String           // Nike, Jordan, Adidas, etc.
    let model: String           // Air Jordan 1 Retro High OG, etc.
    let colorway: String        // Chicago, Bred, Black/White/Red, etc.
    let estimatedYear: String   // 2023 or "2023 Retro of 1985 original"
    let styleCode: String?      // ABC123-456 if visible

    /// Formatted display string
    var displayName: String {
        if brand == "Jordan" {
            return model  // "Air Jordan 1 Retro High OG" already includes brand
        }
        return "\(brand) \(model)"
    }
}

/// Shoe condition assessment
struct ShoeCondition: Codable {
    let rating: String          // Like New, Excellent, Very Good, Good, Fair, Poor
    let notes: String           // Brief description
}

/// Per-image validation result from AI
struct PerImageValidation: Codable {
    let photoIndex: Int           // 1-6
    let photoType: String         // "Outer Side", "Inner Side", etc.
    let isValid: Bool
    let invalidReason: String?
    let qualityScore: Int?
}

/// Score breakdown for each analysis category
struct ScoreBreakdown: Codable {
    let stitching: Int      // 0-25
    let logos: Int          // 0-30
    let materials: Int      // 0-25
    let labels: Int         // 0-10
    let shape: Int          // 0-10

    /// Get all scores as array for display
    var allScores: [(name: String, score: Int, maxScore: Int)] {
        [
            ("Stitching", stitching, 25),
            ("Logos & Branding", logos, 30),
            ("Materials", materials, 25),
            ("Labels & Tags", labels, 10),
            ("Shape", shape, 10)
        ]
    }
}

/// Result from OpenAI GPT-4o Vision API sneaker analysis
/// IMPORTANT: This provides AI-assisted analysis only, NOT authentication verdicts
struct AuthenticationResult: Codable, Identifiable {
    var id = UUID()

    /// Shoe identification (brand, model, colorway, year)
    let shoeIdentification: ShoeIdentification?

    /// Shoe condition assessment
    let condition: ShoeCondition?

    /// Confidence level: "high", "moderate", or "low"
    let confidenceLevel: ConfidenceLevel

    /// Confidence score (0-100) based on observable quality indicators
    let confidenceScore: Int

    /// Detailed observations from the AI analysis
    let observations: [String]

    /// Score breakdown by category (optional for backwards compatibility)
    let breakdown: ScoreBreakdown?

    /// Quality concerns observed during analysis
    let concerns: [String]?

    /// Positive quality indicators that align with manufacturer standards
    let positiveIndicators: [String]?

    /// Professional recommendation (e.g., "Professional verification recommended")
    let recommendation: String?

    /// Legal disclaimer (automatically added by API)
    let disclaimer: String?

    /// Additional photos that would help improve the analysis
    let additionalPhotosNeeded: [String]?

    /// Timestamp of analysis
    let analysisTimestamp: String?

    /// Whether the submission contains valid footwear images for analysis
    let isValidSubmission: Bool

    /// Reason if submission is invalid (e.g., "Images do not contain footwear")
    let invalidReason: String?

    /// Per-image validation results (nil for backwards compatibility)
    let perImageValidations: [PerImageValidation]?

    /// Computed: indices of invalid photos (1-6)
    var invalidPhotoIndices: [Int] {
        perImageValidations?.filter { !$0.isValid }.map { $0.photoIndex } ?? []
    }

    /// Computed: are all photos valid?
    var allPhotosValid: Bool {
        invalidPhotoIndices.isEmpty
    }

    /// Confidence levels with legal-compliant display names
    enum ConfidenceLevel: String, Codable {
        case high
        case moderate
        case low
        case unableToAssess = "unable_to_assess"

        var displayName: String {
            switch self {
            case .high: return "High Confidence"
            case .moderate: return "Moderate Confidence"
            case .low: return "Low Confidence"
            case .unableToAssess: return "Unable to Assess"
            }
        }

        var description: String {
            switch self {
            case .high:
                return "Quality indicators align with expected manufacturer standards"
            case .moderate:
                return "Mixed indicators - some observations warrant further inspection"
            case .low:
                return "Multiple indicators deviate from expected standards"
            case .unableToAssess:
                return "Could not identify footwear in the provided images"
            }
        }

        var emoji: String {
            switch self {
            case .high: return "✓"
            case .moderate: return "?"
            case .low: return "!"
            case .unableToAssess: return "?"
            }
        }

        var hexColor: String {
            switch self {
            case .high: return "#22C55E"     // Green
            case .moderate: return "#F59E0B" // Amber
            case .low: return "#EF4444"      // Red
            case .unableToAssess: return "#6B7280"  // Gray
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case shoeIdentification
        case condition
        case confidenceLevel
        case confidenceScore
        case observations
        case breakdown
        case concerns
        case positiveIndicators
        case recommendation
        case disclaimer
        case additionalPhotosNeeded
        case analysisTimestamp
        case isValidSubmission
        case invalidReason
        case perImageValidations
    }

    // Explicit memberwise initializer (needed because we have a custom decoder)
    init(
        shoeIdentification: ShoeIdentification? = nil,
        condition: ShoeCondition? = nil,
        confidenceLevel: ConfidenceLevel,
        confidenceScore: Int,
        observations: [String],
        breakdown: ScoreBreakdown? = nil,
        concerns: [String]? = nil,
        positiveIndicators: [String]? = nil,
        recommendation: String? = nil,
        disclaimer: String? = nil,
        additionalPhotosNeeded: [String]? = nil,
        analysisTimestamp: String? = nil,
        isValidSubmission: Bool = true,
        invalidReason: String? = nil,
        perImageValidations: [PerImageValidation]? = nil
    ) {
        self.id = UUID()
        self.shoeIdentification = shoeIdentification
        self.condition = condition
        self.confidenceLevel = confidenceLevel
        self.confidenceScore = confidenceScore
        self.observations = observations
        self.breakdown = breakdown
        self.concerns = concerns
        self.positiveIndicators = positiveIndicators
        self.recommendation = recommendation
        self.disclaimer = disclaimer
        self.additionalPhotosNeeded = additionalPhotosNeeded
        self.analysisTimestamp = analysisTimestamp
        self.isValidSubmission = isValidSubmission
        self.invalidReason = invalidReason
        self.perImageValidations = perImageValidations
    }

    // Custom decoder for backwards compatibility with older API responses
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = UUID()
        self.shoeIdentification = try container.decodeIfPresent(ShoeIdentification.self, forKey: .shoeIdentification)
        self.condition = try container.decodeIfPresent(ShoeCondition.self, forKey: .condition)
        self.confidenceLevel = try container.decode(ConfidenceLevel.self, forKey: .confidenceLevel)
        self.confidenceScore = try container.decode(Int.self, forKey: .confidenceScore)
        self.observations = try container.decode([String].self, forKey: .observations)
        self.breakdown = try container.decodeIfPresent(ScoreBreakdown.self, forKey: .breakdown)
        self.concerns = try container.decodeIfPresent([String].self, forKey: .concerns)
        self.positiveIndicators = try container.decodeIfPresent([String].self, forKey: .positiveIndicators)
        self.recommendation = try container.decodeIfPresent(String.self, forKey: .recommendation)
        self.disclaimer = try container.decodeIfPresent(String.self, forKey: .disclaimer)
        self.additionalPhotosNeeded = try container.decodeIfPresent([String].self, forKey: .additionalPhotosNeeded)
        self.analysisTimestamp = try container.decodeIfPresent(String.self, forKey: .analysisTimestamp)

        // New fields with defaults for backwards compatibility
        self.isValidSubmission = try container.decodeIfPresent(Bool.self, forKey: .isValidSubmission) ?? true
        self.invalidReason = try container.decodeIfPresent(String.self, forKey: .invalidReason)
        self.perImageValidations = try container.decodeIfPresent([PerImageValidation].self, forKey: .perImageValidations)
    }
}

// MARK: - Mock Data for Previews

extension AuthenticationResult {
    static let mockHighConfidence = AuthenticationResult(
        shoeIdentification: ShoeIdentification(
            brand: "Jordan",
            model: "Air Jordan 1 Retro High OG",
            colorway: "Chicago",
            estimatedYear: "2022 Retro of 1985 Original",
            styleCode: "DZ5485-612"
        ),
        condition: ShoeCondition(
            rating: "Excellent",
            notes: "Minimal wear, light creasing on toe box, soles near-perfect"
        ),
        confidenceLevel: .high,
        confidenceScore: 95,
        observations: [
            "Stitching quality appears consistent - uniform 2.5mm spacing observed throughout",
            "Swoosh positioning and angle appear consistent with manufacturer standards",
            "Leather shows natural grain pattern consistent with quality materials",
            "Size tag formatting appears consistent with expected standards",
            "Shape profile aligns with expected silhouette for this model"
        ],
        breakdown: ScoreBreakdown(stitching: 24, logos: 29, materials: 24, labels: 9, shape: 9),
        concerns: [],
        positiveIndicators: ["Consistent stitching pattern", "Quality material indicators", "Expected shape profile", "Clean construction"],
        recommendation: nil,
        disclaimer: "AI-Assisted Analysis Only. This assessment is for informational purposes and should not be considered a guarantee of authenticity.",
        additionalPhotosNeeded: nil,
        analysisTimestamp: "2026-01-03T12:00:00Z",
        isValidSubmission: true,
        invalidReason: nil
    )

    static let mockLowConfidence = AuthenticationResult(
        shoeIdentification: ShoeIdentification(
            brand: "Jordan",
            model: "Air Jordan 1 Retro High OG",
            colorway: "Chicago",
            estimatedYear: "Unknown",
            styleCode: nil
        ),
        condition: ShoeCondition(
            rating: "Like New",
            notes: "Appears unworn, some construction observations noted"
        ),
        confidenceLevel: .low,
        confidenceScore: 38,
        observations: [
            "Stitching spacing appears inconsistent in some areas",
            "Logo positioning shows some deviation from expected placement",
            "Material texture appears different from typical retail products",
            "Size tag formatting shows variations from standard",
            "Shape profile differs from expected silhouette"
        ],
        breakdown: ScoreBreakdown(stitching: 10, logos: 12, materials: 8, labels: 4, shape: 4),
        concerns: ["Inconsistent stitching observed", "Logo positioning variance", "Material texture concerns", "Shape deviation"],
        positiveIndicators: [],
        recommendation: "Professional verification strongly recommended before purchase",
        disclaimer: "AI-Assisted Analysis Only. This assessment is for informational purposes and should not be considered a guarantee of authenticity.",
        additionalPhotosNeeded: nil,
        analysisTimestamp: "2026-01-03T12:00:00Z",
        isValidSubmission: true,
        invalidReason: nil
    )

    static let mockModerateConfidence = AuthenticationResult(
        shoeIdentification: ShoeIdentification(
            brand: "Nike",
            model: "Appears to be Nike Dunk Low",
            colorway: "Black/White",
            estimatedYear: "Estimated 2021-2023",
            styleCode: nil
        ),
        condition: ShoeCondition(
            rating: "Good",
            notes: "Moderate wear visible, some creasing"
        ),
        confidenceLevel: .moderate,
        confidenceScore: 55,
        observations: [
            "Stitching appears clean but lighting limits detailed assessment",
            "Logo positioning seems consistent but angle verification limited",
            "Material quality assessment limited by image resolution"
        ],
        breakdown: nil,
        concerns: ["Image quality limits full assessment"],
        positiveIndicators: ["General construction appears consistent"],
        recommendation: "Professional verification recommended for high-value transactions",
        disclaimer: "AI-Assisted Analysis Only. This assessment is for informational purposes and should not be considered a guarantee of authenticity.",
        additionalPhotosNeeded: ["Close-up of size tag with better lighting", "Heel view for shape assessment", "Better angle showing logo details"],
        analysisTimestamp: "2026-01-03T12:00:00Z",
        isValidSubmission: true,
        invalidReason: nil
    )

    /// Mock invalid submission for testing
    static let mockInvalidSubmission = AuthenticationResult(
        shoeIdentification: nil,
        condition: nil,
        confidenceLevel: .unableToAssess,
        confidenceScore: 0,
        observations: [],
        breakdown: nil,
        concerns: [],
        positiveIndicators: [],
        recommendation: "Please provide clear photos of the footwear you want to authenticate",
        disclaimer: "AI-Assisted Analysis Only. This assessment is for informational purposes and should not be considered a guarantee of authenticity.",
        additionalPhotosNeeded: nil,
        analysisTimestamp: "2026-01-03T12:00:00Z",
        isValidSubmission: false,
        invalidReason: "The images do not appear to contain footwear"
    )
}
