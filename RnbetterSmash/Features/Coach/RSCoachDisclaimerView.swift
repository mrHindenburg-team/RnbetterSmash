import SwiftUI

/// Fully custom (non-system) disclaimer shown the first time the AI chat opens.
/// Explains on-device privacy and AI limitations in the combat-sports aesthetic.
struct RSCoachDisclaimerView: View {
    var onAcknowledge: () -> Void

    @State private var appear = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle().fill(RSTheme.energy).frame(width: 84, height: 84)
                        .shadow(color: RSTheme.electricBlue.opacity(0.7), radius: 20)
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text("Private, On-Device AI")
                    .font(.rsTitle(24))
                    .foregroundStyle(RSTheme.textPrimary)

                VStack(alignment: .leading, spacing: 14) {
                    RSDisclaimerPoint(icon: "wifi.slash",
                                      text: "Your coach runs entirely on your device. No questions or data are ever sent to a server.")
                    RSDisclaimerPoint(icon: "airplane",
                                      text: "Everything works fully in airplane mode—no network is ever used.")
                    RSDisclaimerPoint(icon: "exclamationmark.bubble",
                                      text: "On-device AI is powerful but can make mistakes and may be more limited than cloud AI. Use it as educational guidance, not medical advice.")
                }
                .padding(.horizontal, 4)

                RSPrimaryButton(title: "I Understand", systemImage: "checkmark.circle.fill", action: onAcknowledge)
            }
            .padding(24)
            .rsGlassCard(cornerRadius: RSTheme.cornerLarge, padding: 8)
            .padding(.horizontal, 28)
            .scaleEffect(appear ? 1 : 0.85)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { appear = true }
        }
        .accessibilityAddTraits(.isModal)
    }
}

struct RSDisclaimerPoint: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.rsHeadline(16))
                .foregroundStyle(RSTheme.glowCyan)
                .frame(width: 26)
            Text(text)
                .font(.rsBody(14))
                .foregroundStyle(RSTheme.textSecondary)
            Spacer(minLength: 0)
        }
    }
}
