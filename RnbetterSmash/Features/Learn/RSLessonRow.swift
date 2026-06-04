import SwiftUI

/// Reusable lesson row used on Home and discipline detail.
struct RSLessonRow: View {
    let lesson: RSLesson
    var isComplete: Bool
    var isLocked: Bool
    var onTap: (() -> Void)? = nil

    var body: some View {
        let content = HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(lesson.discipline.accent.opacity(0.5), lineWidth: 2)
                    .frame(width: 44, height: 44)
                Image(systemName: isComplete ? "checkmark" : (isLocked ? "lock.fill" : "play.fill"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(isComplete ? RSTheme.success : (isLocked ? RSTheme.warning : lesson.discipline.accent))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(lesson.title)
                    .font(.rsHeadline(16))
                    .foregroundStyle(RSTheme.textPrimary)
                    .lineLimit(1)
                Text(lesson.summary)
                    .font(.rsCaption(12))
                    .foregroundStyle(RSTheme.textSecondary)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    RSTag(text: "T\(lesson.tier)", tint: lesson.discipline.accent)
                    RSTag(text: "\(lesson.durationMinutes) min", tint: RSTheme.icyCyan)
                    RSTag(text: "+\(lesson.xpReward) XP", tint: RSTheme.success)
                    if lesson.isPremium { RSTag(text: "Premium", tint: RSTheme.warning) }
                }
            }
            Spacer(minLength: 0)
        }
        .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 14)

        if let onTap {
            Button(action: onTap) { content }.buttonStyle(.plain)
        } else {
            content
        }
    }
}
