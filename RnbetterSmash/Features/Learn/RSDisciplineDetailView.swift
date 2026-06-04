import SwiftUI

/// Lists all lessons and techniques for a discipline, with tier/premium gating.
struct RSDisciplineDetailView: View {
    let discipline: RSDiscipline

    @Environment(RSProgressManager.self) private var manager
    @Environment(SubscriptionManagerBPV.self) private var purchases

    private var lessons: [RSLesson] { RSContentLibrary.shared.lessons(for: discipline) }
    private var techniques: [RSTechnique] { RSContentLibrary.shared.techniques(for: discipline) }

    var body: some View {
        RSScreenScaffold(title: discipline.title, subtitle: discipline.tagline) {
            // Discipline hero.
            HStack {
                Image(systemName: discipline.symbol)
                    .font(.system(size: 44, weight: .black))
                    .foregroundStyle(discipline.accent)
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(lessons.count)").font(.rsMetric(28)).foregroundStyle(RSTheme.textPrimary)
                    Text("lessons").font(.rsCaption(11)).foregroundStyle(RSTheme.textSecondary)
                }
            }
            .rsGlassCard(cornerRadius: RSTheme.cornerLarge, padding: 18)

            RSSectionHeader(title: "Lessons", systemImage: "list.number")
            ForEach(lessons) { lesson in
                let locked = RSContentLibrary.shared.isLessonLocked(lesson, unlockedTier: manager.unlockedTier) { purchases.isPurchased($0) }
                NavigationLink(value: lesson) {
                    RSLessonRow(lesson: lesson,
                                isComplete: manager.isLessonComplete(lesson.id),
                                isLocked: locked)
                }
                .buttonStyle(.plain)
                .disabled(locked)
                .opacity(locked ? 0.6 : 1)
            }

            if !techniques.isEmpty {
                RSSectionHeader(title: "Technique Visualizers", subtitle: "Step through the mechanics", systemImage: "scope")
                ForEach(techniques) { technique in
                    NavigationLink(value: technique) {
                        RSTechniqueRow(technique: technique)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct RSTechniqueRow: View {
    let technique: RSTechnique
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "figure.martial.arts")
                .font(.rsTitle(20))
                .foregroundStyle(technique.discipline.accent)
                .frame(width: 38)
            VStack(alignment: .leading, spacing: 3) {
                Text(technique.name).font(.rsHeadline(16)).foregroundStyle(RSTheme.textPrimary)
                Text(technique.category).font(.rsCaption(11)).foregroundStyle(RSTheme.textSecondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").foregroundStyle(RSTheme.textTertiary)
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerSmall, padding: 14)
    }
}
