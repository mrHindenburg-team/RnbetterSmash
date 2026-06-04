import SwiftUI

/// A gamified achievement. Earned achievements trigger a cinematic celebration.
struct RSAchievement: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let xpReward: Int

    /// The condition that unlocks the achievement, evaluated against progress.
    let requirement: RSAchievementRequirement
}

enum RSAchievementRequirement: Codable, Hashable, Sendable {
    case lessonsCompleted(Int)
    case streakDays(Int)
    case techniquesViewed(Int)
    case coachMessages(Int)
    case reachRank(RSAthleteRank)
    case quizPerfect
}

/// Catalog of all achievements available offline.
enum RSAchievementCatalog {
    static let all: [RSAchievement] = [
        .init(id: "first_blood", title: "First Round",
              detail: "Complete your very first lesson.",
              symbol: "flag.checkered", xpReward: 25,
              requirement: .lessonsCompleted(1)),
        .init(id: "student", title: "Dedicated Student",
              detail: "Complete 10 lessons across any disciplines.",
              symbol: "books.vertical.fill", xpReward: 100,
              requirement: .lessonsCompleted(10)),
        .init(id: "scholar", title: "Fight Scholar",
              detail: "Complete 25 lessons.",
              symbol: "graduationcap.fill", xpReward: 250,
              requirement: .lessonsCompleted(25)),
        .init(id: "streak_3", title: "Momentum",
              detail: "Train 3 days in a row.",
              symbol: "flame.fill", xpReward: 60,
              requirement: .streakDays(3)),
        .init(id: "streak_7", title: "Iron Week",
              detail: "Maintain a 7-day training streak.",
              symbol: "bolt.fill", xpReward: 150,
              requirement: .streakDays(7)),
        .init(id: "technician", title: "Technician",
              detail: "Study 15 techniques in the visualizer.",
              symbol: "scope", xpReward: 120,
              requirement: .techniquesViewed(15)),
        .init(id: "inquisitive", title: "Ask the Corner",
              detail: "Send 5 questions to the AI coach.",
              symbol: "bubble.left.and.bubble.right.fill", xpReward: 40,
              requirement: .coachMessages(5)),
        .init(id: "contender_rank", title: "Stepping Up",
              detail: "Reach Contender rank.",
              symbol: "flame.fill", xpReward: 200,
              requirement: .reachRank(.contender)),
        .init(id: "champion_rank", title: "Wear the Belt",
              detail: "Reach Champion rank.",
              symbol: "crown.fill", xpReward: 500,
              requirement: .reachRank(.champion)),
        .init(id: "perfect_quiz", title: "Flawless",
              detail: "Score a perfect combat-sports quiz.",
              symbol: "checkmark.seal.fill", xpReward: 80,
              requirement: .quizPerfect)
    ]
}
