import SwiftUI

/// Animated, "alive" preview of the AI combat coach for the Home screen.
/// Cycles through animated technique insights and a simulated coach conversation
/// to communicate that the AI coach is the centerpiece of the app.
struct RSAICoachPreview: View {
    var onOpen: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var insightIndex = 0
    @State private var typing = false
    @State private var glow = false

    private let insights = [
        "Snap the jab back—never let it drop.",
        "Power starts from the floor: feet, hips, hand.",
        "Level change before you penetrate the takedown.",
        "Position before submission. Always.",
        "Recovery is where adaptation happens."
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(RSTheme.energy)
                        .frame(width: 46, height: 46)
                        .shadow(color: RSTheme.electricBlue.opacity(glow ? 0.9 : 0.4), radius: glow ? 16 : 6)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Combat Coach")
                        .font(.rsHeadline(17))
                        .foregroundStyle(RSTheme.textPrimary)
                    HStack(spacing: 5) {
                        Circle().fill(RSTheme.success).frame(width: 7, height: 7)
                        Text("On-device · Private · Always ready")
                            .font(.rsCaption(11))
                            .foregroundStyle(RSTheme.textSecondary)
                    }
                }
                Spacer()
            }

            // Simulated conversation bubble.
            VStack(alignment: .leading, spacing: 10) {
                Text("“How do I improve my jab?”")
                    .font(.rsBody(14))
                    .foregroundStyle(RSTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "quote.opening")
                        .font(.rsCaption(12))
                        .foregroundStyle(RSTheme.glowCyan)
                    Text(insights[insightIndex])
                        .font(.rsBody(15))
                        .foregroundStyle(RSTheme.textPrimary)
                        .id(insightIndex)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(RSTheme.glassFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(RSTheme.glassStroke, lineWidth: 1))
            }

            RSPrimaryButton(title: "Ask Your Coach", systemImage: "bubble.left.and.bubble.right.fill", action: onOpen)
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerLarge, padding: 18)
        .onAppear { startAnimations() }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("AI Combat Coach preview. On-device and private. Tap Ask Your Coach to open.")
    }

    private func startAnimations() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) { glow = true }
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3))
                withAnimation(.easeInOut(duration: 0.5)) {
                    insightIndex = (insightIndex + 1) % insights.count
                }
            }
        }
    }
}
