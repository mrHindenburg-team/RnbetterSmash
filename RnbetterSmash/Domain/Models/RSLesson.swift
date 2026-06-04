import Foundation

/// A single educational lesson within a discipline's pathway.
struct RSLesson: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let discipline: RSDiscipline
    let title: String
    let summary: String
    /// A longer teaching paragraph that opens the lesson.
    let overview: String
    /// Ordered teaching points rendered as an interactive lesson body.
    let keyPoints: [String]
    /// Concrete drills the athlete can perform to train this skill.
    let drills: [String]
    /// Frequent errors to watch for.
    let commonMistakes: [String]
    /// One memorable coaching cue.
    let proTip: String
    /// Difficulty tier 1–5; gates content behind Champion Journey progress.
    let tier: Int
    /// Estimated focused practice time, in minutes.
    let durationMinutes: Int
    /// XP awarded on completion, feeding rank progression.
    let xpReward: Int
    /// Pack required to access this lesson; `nil` means free.
    let requiredPack: RSSubscriptionID?

    /// Convenience: is this lesson behind any paid pack?
    var isPremium: Bool { requiredPack != nil }

    init(
        id: String,
        discipline: RSDiscipline,
        title: String,
        summary: String,
        overview: String,
        keyPoints: [String],
        drills: [String],
        commonMistakes: [String],
        proTip: String,
        tier: Int,
        durationMinutes: Int,
        xpReward: Int = 50,
        requiredPack: RSSubscriptionID? = nil
    ) {
        self.id = id
        self.discipline = discipline
        self.title = title
        self.summary = summary
        self.overview = overview
        self.keyPoints = keyPoints
        self.drills = drills
        self.commonMistakes = commonMistakes
        self.proTip = proTip
        self.tier = tier
        self.durationMinutes = durationMinutes
        self.xpReward = xpReward
        self.requiredPack = requiredPack
    }
}

/// A drillable technique with phase-by-phase mechanics, used by the visualizer.
struct RSTechnique: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let discipline: RSDiscipline
    let name: String
    let category: String          // e.g. "Punch", "Kick", "Takedown", "Submission"
    let mechanics: [String]       // ordered phases for the step visualizer
    let commonMistakes: [String]
    let coachingCue: String
}
