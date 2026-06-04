import SwiftUI

/// The athlete-rank ladder for the Champion Journey progression mode.
/// Users evolve from a raw beginner into a highly educated practitioner.
enum RSAthleteRank: Int, CaseIterable, Identifiable, Codable, Sendable, Comparable {
    case novice = 0
    case prospect
    case contender
    case ranked
    case elite
    case champion

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .novice: "Novice"
        case .prospect: "Prospect"
        case .contender: "Contender"
        case .ranked: "Ranked Fighter"
        case .elite: "Elite Athlete"
        case .champion: "Champion"
        }
    }

    var symbol: String {
        switch self {
        case .novice: "circle.dotted"
        case .prospect: "flame"
        case .contender: "flame.fill"
        case .ranked: "bolt.fill"
        case .elite: "crown"
        case .champion: "crown.fill"
        }
    }

    var accent: Color {
        switch self {
        case .novice: RSTheme.textSecondary
        case .prospect: RSTheme.icyCyan
        case .contender: RSTheme.electricBlue
        case .ranked: RSTheme.royalPurple
        case .elite: RSTheme.warning
        case .champion: RSTheme.glowCyan
        }
    }

    /// Cumulative XP required to reach this rank.
    var xpThreshold: Int {
        switch self {
        case .novice: 0
        case .prospect: 300
        case .contender: 800
        case .ranked: 1800
        case .elite: 3500
        case .champion: 6000
        }
    }

    /// Highest content tier unlocked at this rank.
    var unlockedTier: Int { rawValue + 1 }

    static func rank(forXP xp: Int) -> RSAthleteRank {
        allCases.last { xp >= $0.xpThreshold } ?? .novice
    }

    var next: RSAthleteRank? {
        RSAthleteRank(rawValue: rawValue + 1)
    }

    static func < (lhs: RSAthleteRank, rhs: RSAthleteRank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
