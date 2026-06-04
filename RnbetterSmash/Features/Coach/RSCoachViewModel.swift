import SwiftUI
import Observation

/// Drives the AI combat-coach chat: message list, free-tier gating, and the
/// graceful transition to simplified educational answers after the cap.
///
/// The free-tier usage count is persisted via `RSProgressManager` and resets
/// once per calendar day — it survives tab switches, chat clears, and relaunches.
@Observable
@MainActor
final class RSCoachViewModel {

    // MARK: - Constants

    /// Free users get this many full AI-generated responses per day.
    static let freeResponseLimit = 5

    // MARK: - State

    private(set) var messages: [RSCoachMessage] = []
    private(set) var isGenerating = false
    var draft: String = ""

    private let service = RSCoachService()
    @ObservationIgnored private weak var purchases: SubscriptionManagerBPV?
    @ObservationIgnored private weak var progress: RSProgressManager?

    // MARK: - Derived

    var aiBackedAvailable: Bool { service.aiBackedAvailable }
    var aiUnavailableReason: String? { service.aiUnavailableReason }

    /// Only the Elite Fighter Pack removes the AI cap (matches its description).
    var isPremium: Bool { purchases?.ownsEliteFighterPack ?? false }

    private var usedToday: Int { progress?.aiResponsesUsedToday ?? 0 }

    /// Remaining full AI responses today, or `nil` for unlimited (premium).
    var remainingFreeResponses: Int? {
        guard !isPremium else { return nil }
        return max(0, Self.freeResponseLimit - usedToday)
    }

    var hasReachedFreeLimit: Bool {
        guard !isPremium else { return false }
        return usedToday >= Self.freeResponseLimit
    }

    var canSend: Bool {
        !isGenerating && !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Setup

    func configure(purchases: SubscriptionManagerBPV, progress: RSProgressManager) {
        self.purchases = purchases
        self.progress = progress
        if messages.isEmpty {
            messages.append(
                RSCoachMessage(
                    role: .coach,
                    text: "I'm your on-device combat coach. Ask me about technique, conditioning, tactics, or recovery—everything runs privately on your device. What are we working on today?",
                    source: .system
                )
            )
        }
    }

    // MARK: - Actions

    func send() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isGenerating else { return }
        draft = ""
        submit(trimmed)
    }

    /// Used by both text and voice input.
    func submit(_ question: String) {
        let trimmed = question.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isGenerating else { return }

        messages.append(RSCoachMessage(role: .user, text: trimmed, source: .user))
        RSHaptics.tap()

        let useFullAI = !hasReachedFreeLimit
        let history = messages
        let placeholder = RSCoachMessage(role: .coach, text: "", isPending: true,
                                         source: useFullAI ? .foundationModels : .localEngine)
        messages.append(placeholder)
        isGenerating = true

        Task { [weak self] in
            guard let self else { return }
            let reply: RSCoachReply
            if useFullAI {
                reply = await self.service.generateAIReply(to: trimmed, history: history)
                // Persist usage against today's quota (resets daily).
                self.progress?.recordAIResponse()
            } else {
                // Cap reached: keep the chat alive with simplified educational answers.
                reply = self.service.simplifiedReply(to: trimmed)
            }
            self.finish(with: reply, replacing: placeholder.id, cappedNotice: !useFullAI)
        }
    }

    private func finish(with reply: RSCoachReply, replacing id: UUID, cappedNotice: Bool) {
        if let idx = messages.firstIndex(where: { $0.id == id }) {
            var text = reply.text
            if cappedNotice {
                text += "\n\n— You've used today's free AI responses. You're now getting simplified educational answers, and your full AI coaching resets tomorrow. Unlock the Elite Fighter Pack for unlimited advanced AI coaching."
            }
            messages[idx].text = text
            messages[idx].isPending = false
            messages[idx].source = reply.source
        }
        isGenerating = false
    }

    /// Clears the on-screen conversation. Does NOT reset the daily usage count,
    /// so clearing the chat can't be used to bypass the free-tier cap.
    func clear() {
        messages.removeAll()
        if let purchases, let progress {
            configure(purchases: purchases, progress: progress)
        }
    }
}
