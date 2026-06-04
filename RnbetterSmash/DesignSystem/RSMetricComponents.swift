import SwiftUI

/// Animated circular progress ring used across dashboards.
struct RSProgressRing: View {
    var progress: Double          // 0...1
    var lineWidth: CGFloat = 10
    var size: CGFloat = 120
    var label: String? = nil
    var value: String? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animated: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(RSTheme.glassStroke, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animated)
                .stroke(RSTheme.energy,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: RSTheme.electricBlue.opacity(0.6), radius: 8)

            VStack(spacing: 2) {
                if let value {
                    Text(value).font(.rsMetric(min(size / 4, 30)))
                        .foregroundStyle(RSTheme.textPrimary)
                }
                if let label {
                    Text(label).font(.rsCaption(11))
                        .foregroundStyle(RSTheme.textSecondary)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear { set(progress) }
        .onChange(of: progress) { _, new in set(new) }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label ?? "Progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }

    private func set(_ target: Double) {
        if reduceMotion { animated = target }
        else { withAnimation(.easeOut(duration: 0.9)) { animated = target } }
    }
}

/// A compact stat tile (value + caption) for performance dashboards.
struct RSStatTile: View {
    let value: String
    let caption: String
    var symbol: String
    var tint: Color = RSTheme.icyCyan

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol)
                .font(.rsHeadline(16))
                .foregroundStyle(tint)
            Text(value)
                .font(.rsMetric(24))
                .foregroundStyle(RSTheme.textPrimary)
            Text(caption)
                .font(.rsCaption(11))
                .foregroundStyle(RSTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .rsGlassCard(cornerRadius: RSTheme.cornerSmall, padding: 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(caption): \(value)")
    }
}

/// Animated horizontal energy bar.
struct RSEnergyBar: View {
    var progress: Double
    var height: CGFloat = 10

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animated: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(RSTheme.glassStroke)
                Capsule()
                    .fill(RSTheme.energyHorizontal)
                    .frame(width: geo.size.width * animated)
                    .shadow(color: RSTheme.electricBlue.opacity(0.5), radius: 6)
            }
        }
        .frame(height: height)
        .onAppear { animated = reduceMotion ? progress : 0; if !reduceMotion { withAnimation(.easeOut(duration: 0.9)) { animated = progress } } }
        .onChange(of: progress) { _, new in withAnimation(.easeOut(duration: 0.6)) { animated = new } }
    }
}
