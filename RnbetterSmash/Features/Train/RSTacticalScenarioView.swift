import SwiftUI

/// Tactical decision simulator. No single "right" answer—each choice is scored
/// for soundness and explained, building fight IQ.
struct RSTacticalScenarioView: View {
    @Environment(RSProgressManager.self) private var manager

    private let scenarios = RSContentLibrary.shared.scenarios
    @State private var index = 0
    @State private var chosen: RSTacticalOption?

    var body: some View {
        RSScreenScaffold(title: "Tactical Sim", subtitle: "Read the moment, make the call") {
            let scenario = scenarios[index]

            Text(scenario.situation)
                .font(.rsTitle(19))
                .foregroundStyle(RSTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 18)

            ForEach(scenario.options) { option in
                Button {
                    if chosen == nil { withAnimation { chosen = option }; RSHaptics.tap() }
                } label: {
                    RSTacticalOptionRow(option: option, chosen: chosen)
                }
                .buttonStyle(.plain)
            }

            if let chosen {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Soundness").font(.rsCaption(12)).foregroundStyle(RSTheme.textSecondary)
                        Spacer()
                        Text("\(chosen.soundness)/100").font(.rsMetric(18)).foregroundStyle(tint(for: chosen.soundness))
                    }
                    RSEnergyBar(progress: Double(chosen.soundness) / 100)
                    Text(chosen.feedback).font(.rsBody(14)).foregroundStyle(RSTheme.textPrimary)
                }
                .rsGlassCard(cornerRadius: RSTheme.cornerMedium, padding: 16)

                RSPrimaryButton(title: index == scenarios.count - 1 ? "Restart" : "Next Scenario",
                                systemImage: "arrow.right") {
                    advance()
                }
            }
        }
    }

    private func tint(for score: Int) -> Color {
        score >= 75 ? RSTheme.success : (score >= 50 ? RSTheme.warning : RSTheme.danger)
    }

    private func advance() {
        if let chosen, chosen.soundness >= 75 { manager.logTrainingSession() }
        withAnimation {
            chosen = nil
            index = (index + 1) % scenarios.count
        }
    }
}

struct RSTacticalOptionRow: View {
    let option: RSTacticalOption
    let chosen: RSTacticalOption?

    var body: some View {
        let isChosen = chosen?.id == option.id
        let revealed = chosen != nil
        HStack {
            Text(option.text).font(.rsBody(15)).foregroundStyle(RSTheme.textPrimary)
            Spacer(minLength: 8)
            if revealed && isChosen {
                Image(systemName: option.soundness >= 75 ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(option.soundness >= 75 ? RSTheme.success : RSTheme.warning)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: RSTheme.cornerMedium, style: .continuous)
                .fill(RSTheme.glassFill)
                .overlay(RoundedRectangle(cornerRadius: RSTheme.cornerMedium, style: .continuous)
                    .strokeBorder(isChosen ? RSTheme.glowCyan : RSTheme.glassStroke, lineWidth: 1.5))
        }
        .opacity(revealed && !isChosen ? 0.55 : 1)
    }
}
