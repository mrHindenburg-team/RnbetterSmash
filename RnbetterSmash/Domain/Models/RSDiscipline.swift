import SwiftUI

/// A combat-sports discipline taught in the app. Drives the Learn catalog,
/// technique visualizers, and AI coaching context.
enum RSDiscipline: String, CaseIterable, Identifiable, Codable, Sendable {
    case boxing
    case kickboxing
    case muayThai
    case wrestling
    case bjj
    case judo
    case mma
    case striking
    case defense
    case conditioning

    var id: String { rawValue }

    var title: String {
        switch self {
        case .boxing: "Boxing"
        case .kickboxing: "Kickboxing"
        case .muayThai: "Muay Thai"
        case .wrestling: "Wrestling"
        case .bjj: "Brazilian Jiu-Jitsu"
        case .judo: "Judo"
        case .mma: "MMA Fundamentals"
        case .striking: "Striking Systems"
        case .defense: "Defensive Systems"
        case .conditioning: "Conditioning Science"
        }
    }

    var tagline: String {
        switch self {
        case .boxing: "Hands, footwork, the sweet science"
        case .kickboxing: "Punches and kicks in fluid combination"
        case .muayThai: "The art of eight limbs"
        case .wrestling: "Takedowns, control, top pressure"
        case .bjj: "Leverage, position, submission"
        case .judo: "Off-balancing and explosive throws"
        case .mma: "Blending every range of combat"
        case .striking: "Power mechanics across all strikes"
        case .defense: "Read, react, never get hit clean"
        case .conditioning: "The engine behind every technique"
        }
    }

    /// SF Symbol used as the discipline glyph (custom emoji sets are avoided).
    var symbol: String {
        switch self {
        case .boxing: "figure.boxing"
        case .kickboxing: "figure.kickboxing"
        case .muayThai: "figure.martial.arts"
        case .wrestling: "figure.wrestling"
        case .bjj: "figure.core.training"
        case .judo: "figure.martial.arts"
        case .mma: "figure.mixed.cardio"
        case .striking: "bolt.fill"
        case .defense: "shield.lefthalf.filled"
        case .conditioning: "bolt.heart.fill"
        }
    }

    var accent: Color {
        switch self {
        case .boxing: RSTheme.electricBlue
        case .kickboxing: RSTheme.royalPurple
        case .muayThai: RSTheme.danger
        case .wrestling: RSTheme.glowCyan
        case .bjj: RSTheme.icyCyan
        case .judo: RSTheme.warning
        case .mma: RSTheme.royalPurple
        case .striking: RSTheme.electricBlue
        case .defense: RSTheme.success
        case .conditioning: RSTheme.glowCyan
        }
    }

    /// Difficulty floor at which the discipline becomes most relevant (1–5).
    var baseTier: Int {
        switch self {
        case .boxing, .conditioning, .defense: 1
        case .kickboxing, .striking, .wrestling: 2
        case .muayThai, .judo: 3
        case .bjj: 4
        case .mma: 5
        }
    }
}
