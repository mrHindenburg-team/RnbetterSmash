import Foundation

/// Coordinates which coaching engine answers a question.
///
/// Prefers Apple Foundation Models when available on the device; otherwise (or
/// on any generation failure) uses the deterministic `RSFallbackCoach`. Fully
/// offline in every path.
@MainActor
final class RSCoachService {

    private let fallback = RSFallbackCoach()
    private var foundationCoach: (any RSCoachEngine)?

    /// True when full AI generation (Foundation Models) is usable right now.
    let aiBackedAvailable: Bool

    /// Reason FM is unavailable, if any (for the disclaimer/info UI).
    let aiUnavailableReason: String?

    init() {
        if #available(iOS 26.0, *), RSFoundationModelsCoach.isAvailable {
            foundationCoach = RSFoundationModelsCoach()
            aiBackedAvailable = true
            aiUnavailableReason = nil
        } else {
            foundationCoach = nil
            aiBackedAvailable = false
            if #available(iOS 26.0, *) {
                aiUnavailableReason = RSFoundationModelsCoach.unavailableReason
            } else {
                aiUnavailableReason = "On-device AI requires iOS 26 or later."
            }
        }
    }

    /// Generate a full AI-backed reply, falling back gracefully on any error.
    func generateAIReply(to prompt: String, history: [RSCoachMessage]) async -> RSCoachReply {
        if let foundationCoach {
            do {
                return try await foundationCoach.reply(to: prompt, history: history)
            } catch {
                // Any FM failure (unavailable, context overflow, etc.) → deterministic answer.
                return (try? await fallback.reply(to: prompt, history: history))
                    ?? RSCoachReply(text: RSFallbackCoach.genericResponse, source: .localEngine)
            }
        }
        return (try? await fallback.reply(to: prompt, history: history))
            ?? RSCoachReply(text: RSFallbackCoach.genericResponse, source: .localEngine)
    }

    /// The simplified, non-AI educational reply used after the free cap is hit.
    func simplifiedReply(to prompt: String) -> RSCoachReply {
        RSCoachReply(text: RSFallbackCoach.answer(for: prompt), source: .localEngine)
    }
}
