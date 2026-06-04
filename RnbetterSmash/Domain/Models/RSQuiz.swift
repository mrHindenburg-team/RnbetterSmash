import Foundation

/// A single multiple-choice quiz question for the combat-sports quiz system.
struct RSQuizQuestion: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let discipline: RSDiscipline
    let prompt: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

/// A tactical scenario for the decision-simulator system.
struct RSTacticalScenario: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let situation: String
    let options: [RSTacticalOption]
}

struct RSTacticalOption: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let text: String
    /// Tactical soundness score 0–100 — drives feedback, no single "right" answer.
    let soundness: Int
    let feedback: String
}
