import SwiftUI

/// Interactive lesson reader. Key points reveal progressively; the lesson also
/// includes an overview, drills, common mistakes, and a pro tip. Completing the
/// lesson awards XP and may trigger achievements.
struct RSLessonDetailView: View {
    let lesson: RSLesson

    @Environment(RSProgressManager.self) private var manager
    @State private var revealedPoints = 0

    private var isComplete: Bool { manager.isLessonComplete(lesson.id) }

    var body: some View {
        RSScreenScaffold(title: lesson.title, subtitle: lesson.discipline.title) {
            metaTags

            // Overview
            Text(lesson.overview)
                .font(.rsBody(16))
                .foregroundStyle(RSTheme.textPrimary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 16)

            // Key points (progressive)
            RSSectionHeader(title: "Key Points", systemImage: "list.bullet.rectangle.fill")
            ForEach(Array(lesson.keyPoints.enumerated()), id: \.offset) { idx, point in
                if idx < revealedPoints {
                    RSKeyPointCard(index: idx + 1, text: point, accent: lesson.discipline.accent)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
            if revealedPoints < lesson.keyPoints.count {
                RSGhostButton(title: "Reveal Next Point (\(revealedPoints)/\(lesson.keyPoints.count))",
                              systemImage: "plus.circle.fill") {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                        revealedPoints = min(revealedPoints + 1, lesson.keyPoints.count)
                    }
                }
            }

            // Drills
            RSSectionHeader(title: "Drills", subtitle: "Train it, don't just read it", systemImage: "figure.run")
            ForEach(Array(lesson.drills.enumerated()), id: \.offset) { idx, drill in
                RSBulletRow(icon: "\(idx + 1).circle.fill", text: drill, tint: lesson.discipline.accent)
            }

            // Common mistakes
            RSSectionHeader(title: "Common Mistakes", systemImage: "exclamationmark.triangle.fill")
            ForEach(lesson.commonMistakes, id: \.self) { mistake in
                RSBulletRow(icon: "xmark.octagon.fill", text: mistake, tint: RSTheme.danger)
            }

            // Pro tip
            RSSectionHeader(title: "Coach's Pro Tip", systemImage: "quote.bubble.fill")
            Text(lesson.proTip)
                .font(.rsBody(15)).italic()
                .foregroundStyle(RSTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 16)

            completion
        }
        .onAppear {
            if revealedPoints == 0 { revealedPoints = 1 }
        }
    }

    private var metaTags: some View {
        HStack(spacing: 10) {
            RSTag(text: "Tier \(lesson.tier)", tint: lesson.discipline.accent)
            RSTag(text: "\(lesson.durationMinutes) min", tint: RSTheme.icyCyan)
            RSTag(text: "+\(lesson.xpReward) XP", tint: RSTheme.success)
            if let pack = lesson.requiredPack {
                RSTag(text: pack.displayName, tint: RSTheme.warning)
            }
        }
    }

    @ViewBuilder private var completion: some View {
        if isComplete {
            Label("Lesson completed", systemImage: "checkmark.seal.fill")
                .font(.rsHeadline(16))
                .foregroundStyle(RSTheme.success)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        } else {
            RSPrimaryButton(title: "Complete Lesson · +\(lesson.xpReward) XP", systemImage: "checkmark.circle.fill") {
                withAnimation { revealedPoints = lesson.keyPoints.count }
                manager.completeLesson(lesson)
                RSHaptics.success()
            }
        }
    }
}

struct RSKeyPointCard: View {
    let index: Int
    let text: String
    let accent: Color

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(index)")
                .font(.rsMetric(20))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(accent.opacity(0.8), in: Circle())
            Text(text)
                .font(.rsBody(15))
                .foregroundStyle(RSTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 14)
    }
}

/// Generic icon + text row used for drills and mistakes.
struct RSBulletRow: View {
    let icon: String
    let text: String
    var tint: Color = RSTheme.icyCyan

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.rsHeadline(15))
                .foregroundStyle(tint)
            Text(text)
                .font(.rsBody(14))
                .foregroundStyle(RSTheme.textSecondary)
            Spacer(minLength: 0)
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerSmall, padding: 13)
    }
}
