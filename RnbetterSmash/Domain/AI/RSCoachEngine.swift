import Foundation

/// Abstraction over a coaching engine. Two implementations exist:
/// `RSFoundationModelsCoach` (Apple on-device LLM, iOS 26+) and
/// `RSFallbackCoach` (deterministic, always available, fully offline).
protocol RSCoachEngine: Sendable {
    /// Produce a coaching reply to the user's question.
    /// - Parameters:
    ///   - prompt: the user's latest question.
    ///   - history: prior conversation turns for context.
    func reply(to prompt: String, history: [RSCoachMessage]) async throws -> RSCoachReply
}

/// Shared coaching domain instructions used by every engine to stay on-brand,
/// safe, and educational.
enum RSCoachPersona {
    static let systemInstructions = """
    You are the on-device combat-sports coach inside "Rnbetter: Smash".
    You teach boxing, kickboxing, Muay Thai, wrestling, BJJ, judo, MMA fundamentals,
    striking and defensive systems, conditioning, recovery, and athletic performance.

    Rules:
    - Be motivating, precise, and practical. Speak like an elite but encouraging coach.
    - Give structured, actionable guidance: mechanics, common mistakes, and a drill or cue.
    - Keep answers focused (roughly 120–200 words) unless asked for detail.
    - Emphasize safety, gradual progression, and proper recovery.
    - You are an educational tool, not a medical professional. For pain or injury,
      advise rest and consulting a qualified professional.
    - Never claim to access the internet or external data; everything is on-device.
    """
}
