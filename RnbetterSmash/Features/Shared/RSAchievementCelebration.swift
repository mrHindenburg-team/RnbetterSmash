import SwiftUI

/// Cinematic full-screen celebration shown when an achievement unlocks.
struct RSAchievementCelebration: View {
    let achievement: RSAchievement
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var burst = false
    @State private var appear = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            // Radiating energy rays.
            ForEach(0..<12, id: \.self) { i in
                Capsule()
                    .fill(LinearGradient(colors: [RSTheme.glowCyan.opacity(0.7), .clear],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 6, height: 220)
                    .offset(y: -120)
                    .rotationEffect(.degrees(Double(i) / 12 * 360))
                    .scaleEffect(burst ? 1 : 0.2)
                    .opacity(burst ? 0.9 : 0)
            }

            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(RSTheme.energy)
                        .frame(width: 130, height: 130)
                        .shadow(color: RSTheme.electricBlue.opacity(0.8), radius: 30)
                    Image(systemName: achievement.symbol)
                        .font(.system(size: 60, weight: .black))
                        .foregroundStyle(.white)
                }
                .scaleEffect(appear ? 1 : 0.3)
                .rotationEffect(.degrees(appear ? 0 : -30))

                Text("ACHIEVEMENT UNLOCKED")
                    .font(.rsCaption(12)).tracking(3)
                    .foregroundStyle(RSTheme.glowCyan)
                Text(achievement.title)
                    .font(.rsTitle(26))
                    .foregroundStyle(RSTheme.textPrimary)
                Text(achievement.detail)
                    .font(.rsBody(15))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(RSTheme.textSecondary)
                    .padding(.horizontal, 30)
                RSTag(text: "+\(achievement.xpReward) XP", tint: RSTheme.success)

                RSPrimaryButton(title: "Keep Pushing", systemImage: "flame.fill", action: onDismiss)
                    .padding(.horizontal, 50)
                    .padding(.top, 6)
            }
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            if reduceMotion { burst = true; appear = true; return }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.55)) { appear = true }
            withAnimation(.easeOut(duration: 0.8)) { burst = true }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Achievement unlocked: \(achievement.title). \(achievement.detail). Plus \(achievement.xpReward) XP.")
    }
}
