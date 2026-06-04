import SwiftUI

/// Champion Journey: the rank progression ladder, achievement gallery, and a
/// dynamic athlete-development map.
struct RSJourneyView: View {
    @Binding var showPaywall: Bool
    @Environment(RSProgressManager.self) private var manager
    @Environment(SubscriptionManagerBPV.self) private var purchases

    var body: some View {
        NavigationStack {
            RSScreenScaffold(title: "Champion Journey", subtitle: "From Novice to Champion") {
                currentRankBanner

                RSSectionHeader(title: "Tools", systemImage: "wrench.and.screwdriver.fill")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    NavigationLink(value: RSJourneyDest.journal) {
                        RSSystemTile(title: "Training Journal", subtitle: "Log every session", icon: "book.closed.fill", tint: RSTheme.icyCyan)
                    }.buttonStyle(.plain)
                    NavigationLink(value: RSJourneyDest.goals) {
                        RSSystemTile(title: "Goals", subtitle: "Set & track targets", icon: "target", tint: RSTheme.royalPurple)
                    }.buttonStyle(.plain)
                }

                RSSectionHeader(title: "The Path", subtitle: "Unlock content as you rise", systemImage: "point.topleft.down.to.point.bottomright.curvepath.fill")
                rankLadder

                RSSectionHeader(title: "Achievements", subtitle: "\(manager.unlockedAchievements.count)/\(RSAchievementCatalog.all.count) unlocked", systemImage: "rosette")
                achievementGrid

                if !purchases.hasPremiumAccess {
                    RSPremiumTeaser { showPaywall = true }
                }
            }
            .navigationDestination(for: RSJourneyDest.self) { dest in
                switch dest {
                case .journal: RSJournalView()
                case .goals: RSGoalsView()
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .tint(RSTheme.icyCyan)
    }

    private var currentRankBanner: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle().fill(RadialGradient(colors: [manager.rank.accent.opacity(0.5), .clear], center: .center, startRadius: 8, endRadius: 90))
                    .frame(width: 160, height: 160)
                Image(systemName: manager.rank.symbol)
                    .font(.system(size: 64, weight: .black))
                    .foregroundStyle(RSTheme.glow)
            }
            Text(manager.rank.title.uppercased())
                .font(.rsTitle(24)).tracking(2).foregroundStyle(RSTheme.textPrimary)
            RSEnergyBar(progress: manager.rankProgress)
            if let next = manager.rank.next {
                Text("\(manager.xpToNextRank) XP to \(next.title)")
                    .font(.rsCaption(12)).foregroundStyle(RSTheme.textSecondary)
            } else {
                Text("You've reached the summit.").font(.rsCaption(12)).foregroundStyle(RSTheme.glowCyan)
            }
        }
        .frame(maxWidth: .infinity)
        .rsGlassCard(cornerRadius: RSTheme.cornerLarge, padding: 22)
    }

    private var rankLadder: some View {
        VStack(spacing: 0) {
            ForEach(RSAthleteRank.allCases) { rank in
                let reached = manager.rank >= rank
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(reached ? AnyShapeStyle(rank.accent) : AnyShapeStyle(RSTheme.glassFill))
                            .frame(width: 44, height: 44)
                            .overlay(Circle().strokeBorder(reached ? Color.clear : RSTheme.glassStroke, lineWidth: 1))
                        Image(systemName: rank.symbol)
                            .foregroundStyle(reached ? .white : RSTheme.textTertiary)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(rank.title).font(.rsHeadline(16))
                            .foregroundStyle(reached ? RSTheme.textPrimary : RSTheme.textSecondary)
                        Text("Unlocks Tier \(rank.unlockedTier) content · \(rank.xpThreshold) XP")
                            .font(.rsCaption(11)).foregroundStyle(RSTheme.textTertiary)
                    }
                    Spacer(minLength: 0)
                    if reached { Image(systemName: "checkmark.circle.fill").foregroundStyle(RSTheme.success) }
                }
                .padding(.vertical, 8)

                if rank != RSAthleteRank.allCases.last {
                    Rectangle().fill(RSTheme.glassStroke).frame(width: 2, height: 16).padding(.leading, 21)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 16)
    }

    private var achievementGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(RSAchievementCatalog.all) { achievement in
                let unlocked = manager.isAchievementUnlocked(achievement.id)
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: achievement.symbol)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(unlocked ? RSTheme.warning : RSTheme.textTertiary)
                    Text(achievement.title).font(.rsHeadline(14))
                        .foregroundStyle(unlocked ? RSTheme.textPrimary : RSTheme.textSecondary)
                    Text(achievement.detail).font(.rsCaption(10)).foregroundStyle(RSTheme.textTertiary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
                .padding(14)
                .background {
                    RoundedRectangle(cornerRadius: RSTheme.cornerMedium, style: .continuous)
                        .fill(RSTheme.glassFill)
                        .overlay(RoundedRectangle(cornerRadius: RSTheme.cornerMedium, style: .continuous)
                            .strokeBorder(unlocked ? RSTheme.warning.opacity(0.5) : RSTheme.glassStroke, lineWidth: 1))
                }
                .opacity(unlocked ? 1 : 0.6)
            }
        }
    }
}

/// Navigation destinations within the Champion Journey tab.
enum RSJourneyDest: Hashable {
    case journal, goals
}
