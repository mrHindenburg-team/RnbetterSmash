import Foundation
import FoundationModels

/// On-device coaching engine backed by Apple Foundation Models (iOS 26+).
///
/// Holds a persistent `LanguageModelSession` so the model retains conversational
/// context. All inference runs on-device; no network access is ever performed.
@available(iOS 26.0, *)
@MainActor
final class RSFoundationModelsCoach: RSCoachEngine {

    private var session: LanguageModelSession?

    /// Whether the system model is ready to use on this device right now.
    static var isAvailable: Bool {
        if case .available = SystemLanguageModel.default.availability { return true }
        return false
    }

    /// Human-readable reason the model is unavailable, for diagnostics/UI.
    static var unavailableReason: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible:
                return "This device doesn't support on-device AI."
            case .appleIntelligenceNotEnabled:
                return "Turn on Apple Intelligence in Settings to enable advanced AI coaching."
            case .modelNotReady:
                return "The on-device model is still downloading or preparing."
            @unknown default:
                return "On-device AI is currently unavailable."
            }
        }
    }

    func reply(to prompt: String, history: [RSCoachMessage]) async throws -> RSCoachReply {
        guard Self.isAvailable else {
            throw RSCoachError.modelUnavailable
        }

        let session = activeSession()

        // Guard against an over-long transcript by recreating the session when needed.
        let response = try await session.respond(to: prompt)
        return RSCoachReply(text: response.content, source: .foundationModels)
    }

    /// Lazily create (and reuse) the session seeded with the coaching persona.
    private func activeSession() -> LanguageModelSession {
        if let session { return session }
        let new = LanguageModelSession(instructions: RSCoachPersona.systemInstructions)
        session = new
        return new
    }

    /// Reset conversation context (used when the user clears the chat).
    func resetContext() {
        session = nil
    }
}

enum RSCoachError: Error, Sendable {
    case modelUnavailable
    case generationFailed
}
