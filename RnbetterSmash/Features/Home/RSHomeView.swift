import SwiftUI

/// The Home dashboard: live rank/streak header, the animated AI coach preview,
/// a performance snapshot, discipline shortcuts, and the lesson of the day.
struct RSHomeView: View {
    @Binding var selection: RSTab
    @Binding var showPaywall: Bool

    @Environment(RSProgressManager.self) private var manager
    @Environment(SubscriptionManagerBPV.self) private var purchases

    private var lessonOfDay: RSLesson {
        let lib = RSContentLibrary.shared
        let available = lib.availableLessons(unlockedTier: manager.unlockedTier) { purchases.isPurchased($0) }
        let pool = available.isEmpty ? lib.lessons : available
        let idx = manager.currentStreak % max(pool.count, 1)
        return pool[idx]
    }

    var body: some View {
        RSScreenScaffold(title: "Ready to Smash", subtitle: "Forge the complete combat athlete") {
            RSStoreButton(owned: purchases.hasPremiumAccess) { showPaywall = true }
        } content: {
            rankCard

            RSQuickActionBar(
                onLog: { manager.logTrainingSession(); RSHaptics.success() },
                onQuiz: { selection = .train },
                onPlan: { selection = .train },
                onCoach: { selection = .coach }
            )

            RSAICoachPreview { selection = .coach }

            RSComboDrillCard()

            performanceSnapshot

            RSReadinessCard()

            RSStreakStrip()

            if !purchases.hasPremiumAccess {
                RSPremiumTeaser { showPaywall = true }
            }

            RSSectionHeader(title: "Disciplines", subtitle: "Tap to explore the full curriculum", systemImage: "square.grid.2x2.fill")
            disciplineCarousel

            RSSectionHeader(title: "Lesson of the Day", systemImage: "bolt.fill")
            RSLessonRow(lesson: lessonOfDay, isComplete: manager.isLessonComplete(lessonOfDay.id), isLocked: false) {
                selection = .learn
            }

            RSSectionHeader(title: "Fighter's Mindset", systemImage: "quote.bubble.fill")
            RSMindsetCard()
        }
    }

    // MARK: - Rank card

    private var rankCard: some View {
        HStack(spacing: 18) {
            RSProgressRing(progress: manager.rankProgress,
                           size: 96,
                           label: "to next",
                           value: "\(manager.xp)")
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: manager.rank.symbol)
                        .foregroundStyle(manager.rank.accent)
                    Text(manager.rank.title)
                        .font(.rsTitle(22))
                        .foregroundStyle(RSTheme.textPrimary)
                }
                if let next = manager.rank.next {
                    Text("\(manager.xpToNextRank) XP to \(next.title)")
                        .font(.rsCaption(12))
                        .foregroundStyle(RSTheme.textSecondary)
                } else {
                    Text("Maximum rank reached — Champion")
                        .font(.rsCaption(12))
                        .foregroundStyle(RSTheme.glowCyan)
                }
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill").foregroundStyle(RSTheme.warning)
                    Text("\(manager.currentStreak)-day streak")
                        .font(.rsCaption(12))
                        .foregroundStyle(RSTheme.textPrimary)
                }
            }
            Spacer(minLength: 0)
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerLarge, padding: 18)
    }

    // MARK: - Performance snapshot

    private var performanceSnapshot: some View {
        let completed = manager.progress.completedLessonIDs.count
        let techniques = manager.progress.viewedTechniqueIDs.count
        let achievements = manager.unlockedAchievements.count
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            RSStatTile(value: "\(completed)", caption: "Lessons", symbol: "checkmark.seal.fill", tint: RSTheme.success)
            RSStatTile(value: "\(techniques)", caption: "Techniques", symbol: "scope", tint: RSTheme.icyCyan)
            RSStatTile(value: "\(achievements)", caption: "Badges", symbol: "rosette", tint: RSTheme.warning)
        }
    }

    // MARK: - Discipline carousel

    private var disciplineCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(RSDiscipline.allCases) { discipline in
                    Button {
                        RSHaptics.tap()
                        selection = .learn
                    } label: {
                        RSDisciplineChip(discipline: discipline)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

/// Small premium upsell banner — describes only real, shipped functionality.
struct RSPremiumTeaser: View {
    var onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: "crown.fill")
                    .font(.rsTitle(22))
                    .foregroundStyle(RSTheme.warning)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Unlock the Premium Packs")
                        .font(.rsHeadline(16))
                        .foregroundStyle(RSTheme.textPrimary)
                    Text("Unlimited AI coaching, premium lessons, science modules & programs")
                        .font(.rsCaption(12))
                        .foregroundStyle(RSTheme.textSecondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").foregroundStyle(RSTheme.textTertiary)
            }
            .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 16)
        }
        .buttonStyle(.plain)
    }
}

/// A square discipline shortcut chip.
struct RSDisciplineChip: View {
    let discipline: RSDiscipline
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: discipline.symbol)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(discipline.accent)
            Spacer(minLength: 0)
            Text(discipline.title)
                .font(.rsHeadline(15))
                .foregroundStyle(RSTheme.textPrimary)
                .lineLimit(2)
            Text(discipline.tagline)
                .font(.rsCaption(10))
                .foregroundStyle(RSTheme.textSecondary)
                .lineLimit(2)
        }
        .padding(14)
        .frame(width: 150, height: 150, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: RSTheme.cornerMedium, style: .continuous)
                .fill(RSTheme.glassFill)
                .overlay(RoundedRectangle(cornerRadius: RSTheme.cornerMedium, style: .continuous)
                    .strokeBorder(discipline.accent.opacity(0.35), lineWidth: 1))
        }
    }
}
