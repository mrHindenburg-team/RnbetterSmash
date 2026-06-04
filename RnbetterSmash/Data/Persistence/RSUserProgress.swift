import Foundation
import SwiftData

/// The single persisted record of the athlete's progression. Stored locally via
/// SwiftData; never synced or transmitted.
@Model
final class RSUserProgress {
    /// Total accumulated experience points (drives rank).
    var xp: Int

    var completedLessonIDs: [String]
    var viewedTechniqueIDs: [String]
    var unlockedAchievementIDs: [String]
    var coachMessageCount: Int
    var hasPerfectQuiz: Bool

    // Streak tracking
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDay: Date?

    // AI coaching daily usage (free-tier cap resets each calendar day).
    // Inline defaults keep SwiftData lightweight migration safe for existing stores.
    var aiResponsesUsedToday: Int = 0
    var aiUsageDay: Date? = nil

    // Onboarding / first-run flags
    var hasCompletedOnboarding: Bool
    var hasSeenCoachDisclaimer: Bool

    init(
        xp: Int = 0,
        completedLessonIDs: [String] = [],
        viewedTechniqueIDs: [String] = [],
        unlockedAchievementIDs: [String] = [],
        coachMessageCount: Int = 0,
        hasPerfectQuiz: Bool = false,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastActiveDay: Date? = nil,
        aiResponsesUsedToday: Int = 0,
        aiUsageDay: Date? = nil,
        hasCompletedOnboarding: Bool = false,
        hasSeenCoachDisclaimer: Bool = false
    ) {
        self.xp = xp
        self.completedLessonIDs = completedLessonIDs
        self.viewedTechniqueIDs = viewedTechniqueIDs
        self.unlockedAchievementIDs = unlockedAchievementIDs
        self.coachMessageCount = coachMessageCount
        self.hasPerfectQuiz = hasPerfectQuiz
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActiveDay = lastActiveDay
        self.aiResponsesUsedToday = aiResponsesUsedToday
        self.aiUsageDay = aiUsageDay
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.hasSeenCoachDisclaimer = hasSeenCoachDisclaimer
    }
}

/// A user-authored training journal entry.
@Model
final class RSJournalEntry {
    var id: UUID
    var date: Date
    var title: String
    var body: String
    var disciplineRaw: String?

    init(id: UUID = UUID(), date: Date = .now, title: String, body: String, disciplineRaw: String? = nil) {
        self.id = id
        self.date = date
        self.title = title
        self.body = body
        self.disciplineRaw = disciplineRaw
    }

    var discipline: RSDiscipline? {
        disciplineRaw.flatMap(RSDiscipline.init(rawValue:))
    }
}

/// A user-managed training goal.
@Model
final class RSGoal {
    var id: UUID
    var title: String
    var detail: String
    var targetDate: Date?
    var isComplete: Bool
    var createdAt: Date

    init(id: UUID = UUID(), title: String, detail: String = "", targetDate: Date? = nil, isComplete: Bool = false, createdAt: Date = .now) {
        self.id = id
        self.title = title
        self.detail = detail
        self.targetDate = targetDate
        self.isComplete = isComplete
        self.createdAt = createdAt
    }
}
