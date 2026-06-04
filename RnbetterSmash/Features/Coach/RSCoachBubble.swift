import SwiftUI

/// A single chat bubble. Coach replies carry a subtle source badge so users
/// understand whether the answer came from the AI model or the local engine.
struct RSCoachBubble: View {
    let message: RSCoachMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 40) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 6) {
                if message.isPending {
                    RSTypingIndicator()
                } else {
                    Text(message.text)
                        .font(.rsBody(15))
                        .foregroundStyle(RSTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                }

                if !isUser && !message.isPending {
                    sourceBadge
                }
            }
            .padding(14)
            .background {
                if isUser {
                    RoundedRectangle(cornerRadius: 18, style: .continuous).fill(RSTheme.energy)
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(RSTheme.glassFill)
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(RSTheme.glassStroke, lineWidth: 1))
                }
            }

            if !isUser { Spacer(minLength: 40) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel((isUser ? "You said: " : "Coach: ") + message.text)
    }

    @ViewBuilder private var sourceBadge: some View {
        switch message.source {
        case .foundationModels:
            label("Apple on-device AI", "sparkles", RSTheme.glowCyan)
        case .localEngine:
            label("On-device engine", "cpu", RSTheme.icyCyan)
        case .system:
            label("Coach", "shield.lefthalf.filled", RSTheme.textTertiary)
        case .user:
            EmptyView()
        }
    }

    private func label(_ text: String, _ icon: String, _ tint: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 9))
            Text(text).font(.rsCaption(9))
        }
        .foregroundStyle(tint)
    }
}

/// Animated three-dot typing indicator.
struct RSTypingIndicator: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase = 0

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(RSTheme.glowCyan)
                    .frame(width: 7, height: 7)
                    .opacity(phase == i ? 1 : 0.3)
                    .scaleEffect(phase == i ? 1.2 : 0.85)
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(280))
                    withAnimation(.easeInOut(duration: 0.25)) { phase = (phase + 1) % 3 }
                }
            }
        }
        .accessibilityLabel("Coach is thinking")
    }
}
