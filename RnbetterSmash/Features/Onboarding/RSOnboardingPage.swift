import SwiftUI

/// Content model for an onboarding slide.
struct RSOnboardingPage: Identifiable {
    let id = UUID()
    let symbol: String
    let title: String
    let body: String
    let accent: Color
    /// Small orbiting glyphs that reinforce the slide's theme.
    let orbiters: [String]
    /// Feature chips shown beneath the copy.
    let chips: [String]

    static let all: [RSOnboardingPage] = [
        RSOnboardingPage(
            symbol: "figure.boxing",
            title: "Train Like a Champion",
            body: "Master boxing, Muay Thai, wrestling, BJJ and more through deep, interactive lessons—built on real combat-sports principles, available completely offline.",
            accent: RSTheme.electricBlue,
            orbiters: ["figure.kickboxing", "figure.wrestling", "figure.martial.arts", "shield.lefthalf.filled"],
            chips: ["10 disciplines", "Technique visualizers", "Offline-first"]
        ),
        RSOnboardingPage(
            symbol: "brain.head.profile",
            title: "Your On-Device AI Coach",
            body: "Ask anything—technique, conditioning, tactics, recovery. An on-device AI coach answers privately, with nothing ever leaving your phone.",
            accent: RSTheme.royalPurple,
            orbiters: ["bubble.left.and.bubble.right.fill", "mic.fill", "sparkles", "lock.shield.fill"],
            chips: ["100% private", "Voice input", "Works in airplane mode"]
        ),
        RSOnboardingPage(
            symbol: "chart.line.uptrend.xyaxis",
            title: "Rise Through the Ranks",
            body: "Earn XP, build streaks, unlock techniques, and climb the Champion Journey from Novice to Champion as your knowledge grows.",
            accent: RSTheme.icyCyan,
            orbiters: ["flame.fill", "bolt.fill", "crown.fill", "rosette"],
            chips: ["6 ranks", "Achievements", "Daily streaks"]
        ),
        RSOnboardingPage(
            symbol: "bolt.heart.fill",
            title: "Engineer Your Performance",
            body: "Conditioning labs, recovery science, tactical simulators, and performance dashboards—your complete athlete-development system in one place.",
            accent: RSTheme.glowCyan,
            orbiters: ["gamecontroller.fill", "calendar", "scope", "moon.zzz.fill"],
            chips: ["Reaction lab", "Tactical sim", "Weekly planner"]
        )
    ]
}
