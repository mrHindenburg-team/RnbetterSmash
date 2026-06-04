import SwiftUI

/// The Learn catalog: every discipline, gated by Champion Journey tier and
/// premium status. Uses a NavigationStack with value-based destinations.
struct RSLearnView: View {
    @Environment(RSProgressManager.self) private var manager
    @Environment(SubscriptionManagerBPV.self) private var purchases

    var body: some View {
        NavigationStack {
            RSScreenScaffold(title: "Academy", subtitle: "Master every discipline, offline") {
                RSSectionHeader(title: "Disciplines", systemImage: "books.vertical.fill")

                ForEach(RSDiscipline.allCases) { discipline in
                    NavigationLink(value: discipline) {
                        RSDisciplineCard(discipline: discipline,
                                         lessonCount: RSContentLibrary.shared.lessons(for: discipline).count,
                                         locked: discipline.baseTier > manager.unlockedTier)
                    }
                    .buttonStyle(.plain)
                }

                RSSectionHeader(title: "Sports Science", subtitle: "The why behind the work", systemImage: "atom")
                ForEach(RSContentLibrary.shared.sportsScience) { module in
                    NavigationLink(value: module) {
                        RSScienceRow(module: module, locked: module.requiredPack.map { !purchases.isPurchased($0) } ?? false)
                    }
                    .buttonStyle(.plain)
                }

                RSSectionHeader(title: "Legends & Case Studies", systemImage: "trophy.fill")
                ForEach(RSContentLibrary.shared.legends) { legend in
                    RSLegendRow(legend: legend)
                }
            }
            .background(Color.clear)
            .navigationDestination(for: RSDiscipline.self) { discipline in
                RSDisciplineDetailView(discipline: discipline)
            }
            .navigationDestination(for: RSLesson.self) { lesson in
                RSLessonDetailView(lesson: lesson)
            }
            .navigationDestination(for: RSTechnique.self) { technique in
                RSTechniqueVisualizerView(technique: technique)
            }
            .navigationDestination(for: RSScienceModule.self) { module in
                RSScienceDetailView(module: module)
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .tint(RSTheme.icyCyan)
    }
}

/// Discipline summary card with lock state.
struct RSDisciplineCard: View {
    let discipline: RSDiscipline
    let lessonCount: Int
    let locked: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(discipline.accent.opacity(0.18))
                    .frame(width: 58, height: 58)
                Image(systemName: discipline.symbol)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(discipline.accent)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(discipline.title)
                    .font(.rsHeadline(18))
                    .foregroundStyle(RSTheme.textPrimary)
                Text(discipline.tagline)
                    .font(.rsCaption(12))
                    .foregroundStyle(RSTheme.textSecondary)
                    .lineLimit(2)
                RSTag(text: "\(lessonCount) lessons", tint: discipline.accent)
            }
            Spacer(minLength: 0)
            Image(systemName: locked ? "lock.fill" : "chevron.right")
                .foregroundStyle(locked ? RSTheme.warning : RSTheme.textTertiary)
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 14)
    }
}

struct RSScienceRow: View {
    let module: RSScienceModule
    let locked: Bool
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: module.icon)
                .font(.rsTitle(20))
                .foregroundStyle(RSTheme.glowCyan)
                .frame(width: 38)
            Text(module.title)
                .font(.rsHeadline(16))
                .foregroundStyle(RSTheme.textPrimary)
            Spacer(minLength: 0)
            Image(systemName: locked ? "lock.fill" : "chevron.right")
                .foregroundStyle(locked ? RSTheme.warning : RSTheme.textTertiary)
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerSmall, padding: 14)
    }
}

struct RSLegendRow: View {
    let legend: RSLegend
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill").foregroundStyle(RSTheme.warning)
                Text(legend.name).font(.rsHeadline(16)).foregroundStyle(RSTheme.textPrimary)
                Spacer()
                RSTag(text: legend.discipline.title, tint: legend.discipline.accent)
            }
            Text(legend.lesson)
                .font(.rsBody(14))
                .foregroundStyle(RSTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .rsGlassCard(cornerRadius: RSTheme.cornerSmall, padding: 14)
    }
}
