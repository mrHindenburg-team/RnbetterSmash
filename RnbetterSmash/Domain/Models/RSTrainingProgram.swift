import Foundation

/// A structured, multi-day training program template (offline content).
struct RSTrainingProgram: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let focus: String
    let level: String                 // "Beginner", "Intermediate", "Advanced"
    let days: [RSTrainingDay]
    /// Pack required to access this program; `nil` means free.
    let requiredPack: RSSubscriptionID?

    var isPremium: Bool { requiredPack != nil }
    var totalMinutes: Int { days.reduce(0) { $0 + $1.blocks.reduce(0) { $0 + $1.minutes } } }
}

struct RSTrainingDay: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let label: String                 // "Day 1 — Striking"
    let blocks: [RSTrainingBlock]
}

struct RSTrainingBlock: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let detail: String
    let minutes: Int
    let kind: Kind

    enum Kind: String, Codable, Sendable {
        case warmup, technique, conditioning, sparring, recovery, mobility
    }
}

/// A single weekly-planner slot the user can fill from the planner UI.
struct RSPlannerSlot: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let weekday: Int                  // 1 = Mon ... 7 = Sun
    var disciplineRaw: String?
    var note: String
}
