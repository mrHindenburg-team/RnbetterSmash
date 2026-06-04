import SwiftUI


struct RSSplashView: View {
    var showTagline: Bool = false
    /// How long the intro plays before signalling completion.
    var duration: Double = 2.4
    /// Called once the intro animation finishes. When `nil`, the splash simply
    /// displays indefinitely (e.g. while bootstrapping). This is the hook used
    /// by router-driven flows such as `ScreenRouterKit`'s `splash:` closure.
    var onComplete: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealed = false
    @State private var sweep = false
    @State private var pulse = false

    var body: some View {
        ZStack {
            RSAnimatedBackground(intensity: 1.4)

            // Arena spotlight beams.
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(
                            LinearGradient(colors: [RSTheme.icyCyan.opacity(0.35), .clear],
                                           startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 90, height: 520)
                        .rotationEffect(.degrees(Double(i - 1) * 22))
                        .offset(y: -120)
                        .blur(radius: 18)
                        .opacity(sweep ? 0.9 : 0.3)
                }
            }
            .opacity(revealed ? 1 : 0)

            VStack(spacing: 22) {
                // Combat-athlete silhouette inside an energy ring.
                ZStack {
                    Circle()
                        .stroke(RSTheme.energy, lineWidth: 4)
                        .frame(width: 168, height: 168)
                        .scaleEffect(pulse ? 1.08 : 0.94)
                        .shadow(color: RSTheme.electricBlue.opacity(0.6), radius: 30)

                    Image(systemName: "figure.boxing")
                        .font(.system(size: 86, weight: .black))
                        .foregroundStyle(RSTheme.glow)
                        .shadow(color: RSTheme.glowCyan.opacity(0.8), radius: 18)
                        .scaleEffect(revealed ? 1 : 0.5)
                }

                VStack(spacing: 6) {
                    Text("RNBETTER")
                        .font(.rsDisplay(40))
                        .foregroundStyle(RSTheme.textPrimary)
                        .tracking(8)
                    Text("SMASH")
                        .font(.rsDisplay(48))
                        .foregroundStyle(RSTheme.energyHorizontal)
                        .tracking(14)
                }
                .opacity(revealed ? 1 : 0)
                .offset(y: revealed ? 0 : 24)

                if showTagline {
                    Text("FORGE THE COMPLETE COMBAT ATHLETE")
                        .font(.rsCaption(12))
                        .tracking(3)
                        .foregroundStyle(RSTheme.textSecondary)
                        .opacity(revealed ? 1 : 0)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { animateIn() }
        .task {
            // Drive completion through the callback when one is supplied.
            guard let onComplete else { return }
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            onComplete()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rnbetter Smash. Forge the complete combat athlete.")
    }

    private func animateIn() {
        guard !reduceMotion else {
            revealed = true; pulse = true; sweep = true
            return
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            revealed = true
        }
        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
            pulse = true
        }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            sweep = true
        }
    }
}

#Preview {
    RSSplashView(showTagline: true)
}
