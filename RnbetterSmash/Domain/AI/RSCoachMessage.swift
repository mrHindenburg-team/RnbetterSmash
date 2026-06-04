import Foundation

/// A single message in the AI combat-coach conversation.
struct RSCoachMessage: Identifiable, Hashable, Sendable {
    let id: UUID
    let role: Role
    var text: String
    /// True while a response is still streaming/generating.
    var isPending: Bool
    /// Source of the answer, surfaced subtly so users understand the system.
    var source: Source

    enum Role: String, Sendable { case user, coach }
    enum Source: String, Sendable {
        case user
        case foundationModels   // Apple on-device LLM
        case localEngine        // deterministic fallback
        case system             // disclaimers, limit notices
    }

    init(id: UUID = UUID(), role: Role, text: String, isPending: Bool = false, source: Source) {
        self.id = id
        self.role = role
        self.text = text
        self.isPending = isPending
        self.source = source
    }
}

/// Structured response produced by a coaching engine.
struct RSCoachReply: Sendable {
    let text: String
    let source: RSCoachMessage.Source
}
