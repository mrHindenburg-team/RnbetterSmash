import SwiftUI

/// Interactive, animated step-through visualizer for a technique's mechanics.
struct RSTechniqueVisualizerView: View {
    let technique: RSTechnique

    @Environment(RSProgressManager.self) private var manager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase = 0
    @State private var playing = false
    @State private var pulse = false

    var body: some View {
        RSScreenScaffold(title: technique.name, subtitle: "\(technique.discipline.title) · \(technique.category)") {
            // Visual stage — an abstract animated "kinetic" diagram.
            ZStack {
                RoundedRectangle(cornerRadius: RSTheme.cornerLarge, style: .continuous)
                    .fill(RSTheme.cardSurface)
                    .overlay(RoundedRectangle(cornerRadius: RSTheme.cornerLarge, style: .continuous)
                        .strokeBorder(technique.discipline.accent.opacity(0.4), lineWidth: 1))

                // Motion trail dots indicating the phase along an arc.
                ForEach(0..<technique.mechanics.count, id: \.self) { i in
                    Circle()
                        .fill(i == phase ? AnyShapeStyle(RSTheme.energy) : AnyShapeStyle(RSTheme.glassStroke))
                        .frame(width: i == phase ? 26 : 14, height: i == phase ? 26 : 14)
                        .shadow(color: i == phase ? technique.discipline.accent : .clear, radius: 10)
                        .offset(x: CGFloat(i - (technique.mechanics.count - 1)) * 26)
                        .scaleEffect(i == phase && pulse && !reduceMotion ? 1.25 : 1)
                }

                Image(systemName: "figure.martial.arts")
                    .font(.system(size: 70, weight: .black))
                    .foregroundStyle(technique.discipline.accent.opacity(0.5))
                    .offset(y: -30)
            }
            .frame(height: 200)

            // Phase description.
            VStack(alignment: .leading, spacing: 8) {
                Text("Phase \(phase + 1) of \(technique.mechanics.count)")
                    .font(.rsCaption(12)).foregroundStyle(RSTheme.glowCyan)
                Text(technique.mechanics[phase])
                    .font(.rsTitle(20))
                    .foregroundStyle(RSTheme.textPrimary)
                    .id(phase)
                    .transition(.opacity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 16)

            HStack(spacing: 12) {
                RSGhostButton(title: "Back", systemImage: "chevron.left") {
                    withAnimation { phase = max(0, phase - 1) }
                }
                RSGhostButton(title: "Next", systemImage: "chevron.right") {
                    withAnimation { phase = min(technique.mechanics.count - 1, phase + 1) }
                }
            }

            RSSectionHeader(title: "Coaching Cue", systemImage: "quote.bubble.fill")
            Text(technique.coachingCue)
                .font(.rsBody(15))
                .italic()
                .foregroundStyle(RSTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 16)

            RSSectionHeader(title: "Common Mistakes", systemImage: "exclamationmark.triangle.fill")
            ForEach(technique.commonMistakes, id: \.self) { mistake in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "xmark.octagon.fill").foregroundStyle(RSTheme.danger)
                    Text(mistake).font(.rsBody(14)).foregroundStyle(RSTheme.textSecondary)
                    Spacer(minLength: 0)
                }
                .rsGlassCard(cornerRadius: RSTheme.cornerSmall, padding: 12)
            }
        }
        .onAppear {
            manager.viewTechnique(technique)
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { pulse = true }
            }
        }
    }
}
