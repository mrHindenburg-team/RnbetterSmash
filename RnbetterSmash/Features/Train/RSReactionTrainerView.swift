import SwiftUI

/// Reaction-training exercise: tap the target the instant it ignites. Measures
/// reaction time across rounds. Honors Reduce Motion by removing flashing.
struct RSReactionTrainerView: View {
    @Environment(RSProgressManager.self) private var manager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    enum Phase: Equatable { case ready, waiting, go, tooSoon, result(Int) }

    @State private var phase: Phase = .ready
    @State private var armTask: Task<Void, Never>?
    @State private var startedAt: ContinuousClock.Instant?
    @State private var times: [Int] = []

    private let clock = ContinuousClock()

    var body: some View {
        RSScreenScaffold(title: "Reaction Lab", subtitle: "Train explosive reflexes") {
            instructions

            targetButton
                .frame(height: 280)

            if !times.isEmpty {
                statsCard
            }
        }
        .onDisappear { armTask?.cancel() }
    }

    private var instructions: some View {
        Text("Tap **Start**, wait for the panel to ignite cyan, then tap as fast as you can. Tapping early resets the round.")
            .font(.rsBody(14)).foregroundStyle(RSTheme.textSecondary)
            .rsGlassCard(cornerRadius: RSTheme.cornerSmall, padding: 14)
    }

    private var targetButton: some View {
        Button(action: tap) {
            ZStack {
                RoundedRectangle(cornerRadius: RSTheme.cornerLarge, style: .continuous)
                    .fill(panelFill)
                    .overlay(RoundedRectangle(cornerRadius: RSTheme.cornerLarge, style: .continuous)
                        .strokeBorder(RSTheme.glassStroke, lineWidth: 1))
                VStack(spacing: 10) {
                    Image(systemName: panelIcon).font(.system(size: 54, weight: .black)).foregroundStyle(.white)
                    Text(panelText).font(.rsTitle(22)).foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(panelText)
    }

    private var statsCard: some View {
        let best = times.min() ?? 0
        let avg = times.reduce(0, +) / times.count
        return HStack(spacing: 14) {
            RSStatTile(value: "\(best) ms", caption: "Best", symbol: "bolt.fill", tint: RSTheme.success)
            RSStatTile(value: "\(avg) ms", caption: "Average", symbol: "chart.bar.fill", tint: RSTheme.icyCyan)
            RSStatTile(value: "\(times.count)", caption: "Reps", symbol: "repeat", tint: RSTheme.warning)
        }
    }

    // MARK: - State visuals

    private var panelFill: AnyShapeStyle {
        switch phase {
        case .go: AnyShapeStyle(RSTheme.glow)
        case .tooSoon: AnyShapeStyle(RSTheme.danger.opacity(0.7))
        default: AnyShapeStyle(RSTheme.cardSurface)
        }
    }
    private var panelIcon: String {
        switch phase {
        case .ready: "play.fill"
        case .waiting: "hourglass"
        case .go: "bolt.fill"
        case .tooSoon: "xmark.octagon.fill"
        case .result: "checkmark.circle.fill"
        }
    }
    private var panelText: String {
        switch phase {
        case .ready: "Start"
        case .waiting: "Wait…"
        case .go: "TAP!"
        case .tooSoon: "Too soon — tap to retry"
        case .result(let ms): "\(ms) ms"
        }
    }

    // MARK: - Logic

    private func tap() {
        switch phase {
        case .ready, .tooSoon, .result:
            arm()
        case .waiting:
            // Tapped before ignition.
            armTask?.cancel()
            phase = .tooSoon
            RSHaptics.tap()
        case .go:
            guard let startedAt else { return }
            let elapsed = clock.now - startedAt
            let ms = Int(elapsed.components.seconds * 1000) + Int(elapsed.components.attoseconds / 1_000_000_000_000_000)
            times.append(ms)
            phase = .result(ms)
            RSHaptics.success()
            if times.count == 3 { manager.logTrainingSession() }
        }
    }

    private func arm() {
        phase = .waiting
        armTask?.cancel()
        armTask = Task {
            // Random delay 1.2–3.0s. Vary by current count to avoid Date/random APIs.
            let jitter = Double((times.count * 37) % 18) / 10.0
            try? await Task.sleep(for: .seconds(1.2 + jitter))
            guard !Task.isCancelled else { return }
            startedAt = clock.now
            withAnimation(reduceMotion ? nil : .easeIn(duration: 0.1)) { phase = .go }
        }
    }
}
