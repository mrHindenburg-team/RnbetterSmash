import SwiftUI

/// Detailed view of a multi-day training program with per-block breakdown.
struct RSProgramDetailView: View {
    let program: RSTrainingProgram
    @Environment(RSProgressManager.self) private var manager

    var body: some View {
        RSScreenScaffold(title: program.title, subtitle: program.focus) {
            HStack(spacing: 8) {
                RSTag(text: program.level, tint: RSTheme.icyCyan)
                RSTag(text: "\(program.days.count) days", tint: RSTheme.electricBlue)
                RSTag(text: "\(program.totalMinutes) min total", tint: RSTheme.success)
            }

            ForEach(program.days) { day in
                VStack(alignment: .leading, spacing: 10) {
                    Text(day.label).font(.rsHeadline(17)).foregroundStyle(RSTheme.textPrimary)
                    ForEach(day.blocks) { block in
                        RSBlockRow(block: block)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 16)
            }

            RSPrimaryButton(title: "Mark Today Trained", systemImage: "checkmark.circle.fill") {
                manager.logTrainingSession()
                RSHaptics.success()
            }
        }
    }
}

struct RSBlockRow: View {
    let block: RSTrainingBlock

    private var tint: Color {
        switch block.kind {
        case .warmup: RSTheme.warning
        case .technique: RSTheme.electricBlue
        case .conditioning: RSTheme.icyCyan
        case .sparring: RSTheme.danger
        case .recovery: RSTheme.success
        case .mobility: RSTheme.glowCyan
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(tint).frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(block.name).font(.rsBody(15)).foregroundStyle(RSTheme.textPrimary)
                Text(block.detail).font(.rsCaption(11)).foregroundStyle(RSTheme.textSecondary)
            }
            Spacer(minLength: 0)
            Text("\(block.minutes)m").font(.rsMetric(15)).foregroundStyle(tint)
        }
    }
}
