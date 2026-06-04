import SwiftUI

// MARK: - Quick Actions

/// A horizontal row of tappable quick-action chips that jump into key systems.
struct RSQuickActionBar: View {
    let onLog: () -> Void
    let onQuiz: () -> Void
    let onPlan: () -> Void
    let onCoach: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                RSQuickActionChip(title: "Log Session", icon: "checkmark.circle.fill", tint: RSTheme.success, action: onLog)
                RSQuickActionChip(title: "Quick Quiz", icon: "questionmark.circle.fill", tint: RSTheme.electricBlue, action: onQuiz)
                RSQuickActionChip(title: "Plan Week", icon: "calendar", tint: RSTheme.icyCyan, action: onPlan)
                RSQuickActionChip(title: "Ask Coach", icon: "brain.head.profile", tint: RSTheme.royalPurple, action: onCoach)
            }
            .padding(.horizontal, 2)
        }
    }
}

struct RSQuickActionChip: View {
    let title: String
    let icon: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button {
            RSHaptics.tap()
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.rsHeadline(15)).foregroundStyle(tint)
                Text(title).font(.rsHeadline(14)).foregroundStyle(RSTheme.textPrimary)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background {
                Capsule().fill(RSTheme.glassFill)
                    .overlay(Capsule().strokeBorder(tint.opacity(0.4), lineWidth: 1))
            }
        }
        // ButtonStyle-based press scaling does not block the parent ScrollView's pan.
        .buttonStyle(.rsPressable)
    }
}

// MARK: - Combo Drill Trainer

/// Interactive shadow-boxing combo trainer. Tap the pad to fire each strike in
/// sequence; complete the combo to bank a rep with a satisfying flash + haptic.
struct RSComboDrillCard: View {
    @Environment(RSProgressManager.self) private var manager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let combos: [[String]] = [
        ["Jab", "Cross", "Hook"],
        ["Jab", "Jab", "Cross", "Roll"],
        ["Teep", "Cross", "Low Kick"],
        ["Jab", "Cross", "Hook", "Cross"]
    ]
    private let xpPerCombo = 5
    @State private var comboIndex = 0
    @State private var step = 0
    @State private var reps = 0
    @State private var flash = false

    private var combo: [String] { combos[comboIndex] }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                RSSectionHeader(title: "Combo Drill", subtitle: "Tap to fire the sequence", systemImage: "hand.tap.fill")
                Spacer(minLength: 0)
                Button {
                    withAnimation { comboIndex = (comboIndex + 1) % combos.count; step = 0 }
                    RSHaptics.tap()
                } label: {
                    Image(systemName: "shuffle").font(.rsHeadline(16)).foregroundStyle(RSTheme.glowCyan)
                }
                .accessibilityLabel("Shuffle combo")
            }

            // Sequence chips with current-step highlight.
            HStack(spacing: 8) {
                ForEach(Array(combo.enumerated()), id: \.offset) { i, strike in
                    Text(strike)
                        .font(.rsCaption(12))
                        .foregroundStyle(i < step ? RSTheme.voidPurple : RSTheme.textPrimary)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background {
                            Capsule().fill(i < step ? AnyShapeStyle(RSTheme.glow) : AnyShapeStyle(RSTheme.glassFill))
                                .overlay(Capsule().strokeBorder(i == step ? RSTheme.glowCyan : RSTheme.glassStroke,
                                                                lineWidth: i == step ? 2 : 1))
                        }
                        .scaleEffect(i == step ? 1.06 : 1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: step)
                }
                Spacer(minLength: 0)
            }

            // Strike pad.
            Button(action: strike) {
                ZStack {
                    RoundedRectangle(cornerRadius: RSTheme.cornerMedium, style: .continuous)
                        .fill(flash ? AnyShapeStyle(RSTheme.energy) : AnyShapeStyle(RSTheme.cardSurface))
                        .overlay(RoundedRectangle(cornerRadius: RSTheme.cornerMedium, style: .continuous)
                            .strokeBorder(RSTheme.glassStroke, lineWidth: 1))
                    VStack(spacing: 4) {
                        Image(systemName: "figure.boxing").font(.system(size: 34, weight: .black))
                            .foregroundStyle(.white)
                        Text(flash ? "COMBO!" : (step == 0 ? "TAP TO START" : combo[step].uppercased()))
                            .font(.rsHeadline(15)).foregroundStyle(.white)
                    }
                    .scaleEffect(flash && !reduceMotion ? 1.1 : 1)
                }
                .frame(height: 110)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Strike pad. Next: \(step < combo.count ? combo[step] : combo[0])")

            HStack {
                Label("\(reps) reps banked", systemImage: "flame.fill")
                    .font(.rsCaption(12)).foregroundStyle(RSTheme.warning)
                Spacer()
                if reps > 0 {
                    Text("+\(reps * xpPerCombo) XP earned").font(.rsCaption(12)).foregroundStyle(RSTheme.success)
                }
            }
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerLarge, padding: 18)
    }

    private func strike() {
        RSHaptics.tap()
        step += 1
        if step >= combo.count {
            reps += 1
            step = 0
            RSHaptics.success()
            withAnimation(.easeOut(duration: 0.15)) { flash = true }
            Task {
                try? await Task.sleep(for: .milliseconds(450))
                withAnimation { flash = false }
            }
            // Award real XP per completed combo so the on-screen total is honest.
            manager.awardActivityXP(xpPerCombo)
        }
    }
}

// MARK: - Readiness Self-Check

/// Interactive readiness dial. Tap each factor to cycle Low → Med → High; the
/// ring and coaching line update live to reflect today's training readiness.
struct RSReadinessCard: View {
    private let factors = ["Sleep", "Energy", "Focus", "Recovery"]
    @State private var levels: [Int] = [1, 1, 1, 1]   // 0 = low, 1 = med, 2 = high

    private var readiness: Double {
        Double(levels.reduce(0, +)) / Double(levels.count * 2)
    }

    private var advice: String {
        switch readiness {
        case ..<0.34: "Low readiness — prioritize mobility and recovery today."
        case ..<0.67: "Moderate — technical work and steady conditioning."
        default: "Primed — green light for hard sparring or intensity."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            RSSectionHeader(title: "Readiness Check", subtitle: "Tap to rate how you feel", systemImage: "gauge.with.dots.needle.67percent")

            HStack(spacing: 18) {
                RSProgressRing(progress: readiness, size: 96, label: "ready",
                               value: "\(Int(readiness * 100))%")
                VStack(spacing: 10) {
                    ForEach(Array(factors.enumerated()), id: \.offset) { i, name in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                levels[i] = (levels[i] + 1) % 3
                            }
                            RSHaptics.tap()
                        } label: {
                            HStack(spacing: 8) {
                                Text(name).font(.rsCaption(12)).foregroundStyle(RSTheme.textSecondary)
                                    .frame(width: 64, alignment: .leading)
                                ForEach(0..<3, id: \.self) { dot in
                                    Capsule()
                                        .fill(dot <= levels[i] ? AnyShapeStyle(RSTheme.energyHorizontal)
                                                               : AnyShapeStyle(RSTheme.glassStroke))
                                        .frame(height: 7)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(name) level \(levels[i] + 1) of 3")
                    }
                }
            }

            Text(advice)
                .font(.rsBody(13)).foregroundStyle(RSTheme.textPrimary)
                .padding(.top, 2)
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerLarge, padding: 18)
    }
}

// MARK: - Fighter's Mindset

/// Interactive motivational card. Tap to cycle through combat-mindset principles.
struct RSMindsetCard: View {
    private let lines = [
        "Discipline is choosing what you want most over what you want now.",
        "You don't rise to the occasion—you fall to the level of your training.",
        "Defense wins when offense gets tired. Build both.",
        "Champions are made from something deep inside: a desire, a dream, a vision.",
        "Slow is smooth, smooth is fast. Master the basics relentlessly.",
        "Recover like a pro, or break like an amateur."
    ]
    @State private var index = 0

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.35)) { index = (index + 1) % lines.count }
            RSHaptics.tap()
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "bolt.shield.fill")
                    .font(.rsTitle(24)).foregroundStyle(RSTheme.glow)
                Text(lines[index])
                    .font(.rsBody(16)).italic()
                    .foregroundStyle(RSTheme.textPrimary)
                    .id(index)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.rsCaption(13)).foregroundStyle(RSTheme.textTertiary)
            }
            .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 18)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Mindset principle. Tap for the next one.")
    }
}

// MARK: - Streak Calendar

/// Interactive 7-day streak strip. Tap today's node to log a session.
struct RSStreakStrip: View {
    @Environment(RSProgressManager.self) private var manager
    private let labels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RSSectionHeader(title: "This Week", subtitle: "Tap today to log training", systemImage: "flame.fill")
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { day in
                    let active = day < min(manager.currentStreak, 7)
                    let isToday = day == min(manager.currentStreak, 6)
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(active ? AnyShapeStyle(RSTheme.energy) : AnyShapeStyle(RSTheme.glassFill))
                                .overlay(Circle().strokeBorder(isToday ? RSTheme.glowCyan : RSTheme.glassStroke,
                                                               lineWidth: isToday ? 2 : 1))
                                .frame(width: 36, height: 36)
                            Image(systemName: active ? "flame.fill" : "circle")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(active ? .white : RSTheme.textTertiary)
                        }
                        Text(labels[day]).font(.rsCaption(10)).foregroundStyle(RSTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        manager.logTrainingSession()
                        RSHaptics.success()
                    }
                }
            }
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 16)
    }
}
