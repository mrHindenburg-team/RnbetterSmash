import SwiftUI

/// Cinematic, always-alive backdrop used behind most screens.
///
/// Layers the base gradient with slowly drifting "energy orbs" and a subtle
/// grid. Honors Reduce Motion by freezing the drift while keeping the visuals.
struct RSAnimatedBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animate = false

    var intensity: Double = 1.0

    var body: some View {
        ZStack {
            RSTheme.appBackground
                .ignoresSafeArea()

            // Drifting energy orbs.
            energyOrb(color: RSTheme.royalPurple, size: 320)
                .offset(x: animate ? -110 : -150, y: animate ? -220 : -260)
            energyOrb(color: RSTheme.electricBlue, size: 280)
                .offset(x: animate ? 140 : 180, y: animate ? -40 : 20)
            energyOrb(color: RSTheme.icyCyan, size: 240)
                .offset(x: animate ? -90 : -60, y: animate ? 300 : 340)

            RSGridOverlay()
                .opacity(0.05 * intensity)
                .ignoresSafeArea()
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }

    private func energyOrb(color: Color, size: CGFloat) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(0.55 * intensity), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 1.6
                )
            )
            .frame(width: size, height: size)
            .blur(radius: 40)
            .allowsHitTesting(false)
    }
}

/// Faint technical grid that reinforces the sports-dashboard aesthetic.
private struct RSGridOverlay: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 44
            var path = Path()
            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }
            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }
            context.stroke(path, with: .color(.white), lineWidth: 0.5)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    RSAnimatedBackground()
}
