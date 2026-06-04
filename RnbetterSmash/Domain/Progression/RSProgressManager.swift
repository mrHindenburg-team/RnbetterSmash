import SwiftUI
import SwiftData
import Observation

/// Domain service for all progression and gamification.
///
/// Wraps the SwiftData `RSUserProgress` record and exposes safe, idempotent
/// mutations (duplicate events never double-count). Computes rank, manages
/// streaks, and surfaces newly unlocked achievements for cinematic celebration.
@Observable
@MainActor
final class RSProgressManager {

    private let context: ModelContext
    private(set) var progress: RSUserProgress

    /// Achievement awaiting its celebration sequence (consumed by the UI).
    var pendingCelebration: RSAchievement?

    init(context: ModelContext) {
        self.context = context
        self.progress = RSProgressManager.loadOrCreate(in: context)
    }

    // MARK: - Derived

    var xp: Int { progress.xp }
    var rank: RSAthleteRank { RSAthleteRank.rank(forXP: progress.xp) }
    var unlockedTier: Int { rank.unlockedTier }
    var currentStreak: Int { progress.currentStreak }

    /// Progress (0–1) toward the next rank.
    var rankProgress: Double {
        let current = rank
        guard let next = current.next else { return 1 }
        let span = next.xpThreshold - current.xpThreshold
        guard span > 0 else { return 1 }
        return min(1, max(0, Double(progress.xp - current.xpThreshold) / Double(span)))
    }

    var xpToNextRank: Int {
        guard let next = rank.next else { return 0 }
        return max(0, next.xpThreshold - progress.xp)
    }

    /// Full AI responses consumed today. Reads as 0 once the calendar day rolls
    /// over, so the free-tier cap effectively resets once per day.
    var aiResponsesUsedToday: Int {
        guard let day = progress.aiUsageDay, Calendar.current.isDateInToday(day) else { return 0 }
        return progress.aiResponsesUsedToday
    }

    func isLessonComplete(_ id: String) -> Bool { progress.completedLessonIDs.contains(id) }
    func isAchievementUnlocked(_ id: String) -> Bool { progress.unlockedAchievementIDs.contains(id) }

    var unlockedAchievements: [RSAchievement] {
        RSAchievementCatalog.all.filter { progress.unlockedAchievementIDs.contains($0.id) }
    }

    // MARK: - Mutations (idempotent)

    func completeLesson(_ lesson: RSLesson) {
        guard !progress.completedLessonIDs.contains(lesson.id) else { return }
        progress.completedLessonIDs.append(lesson.id)
        award(xp: lesson.xpReward)
        registerActivity()
        evaluateAchievements()
        save()
    }

    func viewTechnique(_ technique: RSTechnique) {
        guard !progress.viewedTechniqueIDs.contains(technique.id) else { return }
        progress.viewedTechniqueIDs.append(technique.id)
        award(xp: 10)
        evaluateAchievements()
        save()
    }

    func recordCoachMessage() {
        progress.coachMessageCount += 1
        evaluateAchievements()
        save()
    }

    /// Records one full AI-generated response against today's free-tier quota,
    /// rolling the counter over to a fresh day when needed.
    func recordAIResponse() {
        let cal = Calendar.current
        if let day = progress.aiUsageDay, cal.isDateInToday(day) {
            progress.aiResponsesUsedToday += 1
        } else {
            progress.aiUsageDay = cal.startOfDay(for: Date())
            progress.aiResponsesUsedToday = 1
        }
        save()
    }

    func recordQuizResult(correct: Int, total: Int) {
        guard total > 0 else { return }
        award(xp: correct * 10)
        if correct == total {
            progress.hasPerfectQuiz = true
        }
        registerActivity()
        evaluateAchievements()
        save()
    }

    /// Logs a training session for streak purposes (e.g. from the planner).
    func logTrainingSession() {
        registerActivity()
        award(xp: 20)
        evaluateAchievements()
        save()
    }

    /// Awards XP for a small in-app micro-activity (e.g. a completed drill rep)
    /// without touching the day-streak. Used so XP shown in the UI is always real.
    func awardActivityXP(_ amount: Int) {
        award(xp: amount)
        evaluateAchievements()
        save()
    }

    func completeOnboarding() {
        progress.hasCompletedOnboarding = true
        save()
    }

    func markCoachDisclaimerSeen() {
        progress.hasSeenCoachDisclaimer = true
        save()
    }

    // MARK: - Internals

    private func award(xp amount: Int) {
        guard amount > 0 else { return }
        progress.xp += amount
    }

    /// Updates the day-streak. Safe against multiple calls in one day.
    private func registerActivity() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)

        guard let last = progress.lastActiveDay else {
            progress.currentStreak = 1
            progress.longestStreak = max(progress.longestStreak, 1)
            progress.lastActiveDay = today
            return
        }

        let lastDay = cal.startOfDay(for: last)
        guard let days = cal.dateComponents([.day], from: lastDay, to: today).day else { return }

        switch days {
        case 0:
            break // already counted today
        case 1:
            progress.currentStreak += 1
        default:
            progress.currentStreak = 1 // streak broken
        }
        progress.longestStreak = max(progress.longestStreak, progress.currentStreak)
        progress.lastActiveDay = today
    }

    private func evaluateAchievements() {
        for achievement in RSAchievementCatalog.all
        where !progress.unlockedAchievementIDs.contains(achievement.id) && satisfies(achievement.requirement) {
            progress.unlockedAchievementIDs.append(achievement.id)
            progress.xp += achievement.xpReward
            // Surface the first newly unlocked achievement for celebration.
            if pendingCelebration == nil {
                pendingCelebration = achievement
                RSHaptics.celebrate()
            }
        }
    }

    private func satisfies(_ requirement: RSAchievementRequirement) -> Bool {
        switch requirement {
        case .lessonsCompleted(let n): progress.completedLessonIDs.count >= n
        case .streakDays(let n): progress.currentStreak >= n
        case .techniquesViewed(let n): progress.viewedTechniqueIDs.count >= n
        case .coachMessages(let n): progress.coachMessageCount >= n
        case .reachRank(let r): rank >= r
        case .quizPerfect: progress.hasPerfectQuiz
        }
    }

    private func save() {
        do {
            try context.save()
        } catch {
            // Persistence failure must never crash the app or lose the in-memory state.
            print("RSProgressManager save failed: \(error)")
        }
    }

    // MARK: - Bootstrapping

    /// Loads the existing progress record, recovering gracefully from a missing
    /// or corrupted store by creating a fresh one.
    private static func loadOrCreate(in context: ModelContext) -> RSUserProgress {
        let descriptor = FetchDescriptor<RSUserProgress>()
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let fresh = RSUserProgress()
        context.insert(fresh)
        try? context.save()
        return fresh
    }
}
