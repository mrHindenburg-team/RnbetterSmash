import SwiftUI

/// Four-slide, skippable onboarding with premium storytelling and animation.
struct RSOnboardingView: View {
    let onFinish: () -> Void

    @State private var index = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let pages = RSOnboardingPage.all

    var body: some View {
        ZStack {
            RSAnimatedBackground()

            // Per-page accent wash that crossfades as you move between slides.
            RadialGradient(colors: [pages[index].accent.opacity(0.35), .clear],
                           center: .top, startRadius: 20, endRadius: 520)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: index)

            VStack(spacing: 0) {
                // Skip control + progress count.
                HStack {
                    Text("\(index + 1) / \(pages.count)")
                        .font(.rsCaption(12)).foregroundStyle(RSTheme.textTertiary)
                    Spacer()
                    Button("Skip") { onFinish() }
                        .font(.rsHeadline(15))
                        .foregroundStyle(RSTheme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .accessibilityHint("Skip the introduction and go to the app")
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                TabView(selection: $index) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { i, page in
                        RSOnboardingSlide(page: page, isActive: i == index)
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: index)

                // Custom page indicator.
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { i in
                        Capsule()
                            .fill(i == index ? AnyShapeStyle(RSTheme.energyHorizontal)
                                             : AnyShapeStyle(RSTheme.textTertiary))
                            .frame(width: i == index ? 26 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: index)
                    }
                }
                .padding(.vertical, 18)

                RSPrimaryButton(
                    title: index == pages.count - 1 ? "Enter the Arena" : "Continue",
                    systemImage: index == pages.count - 1 ? "bolt.fill" : "arrow.right"
                ) {
                    if index == pages.count - 1 {
                        onFinish()
                    } else {
                        withAnimation { index += 1 }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

/// A single onboarding slide: a glowing hero glyph encircled by counter-rotating
/// energy rings and orbiting theme glyphs, with copy and feature chips below.
private struct RSOnboardingSlide: View {
    let page: RSOnboardingPage
    let isActive: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var float = false
    @State private var spin = false
    @State private var counterSpin = false
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 26) {
            Spacer(minLength: 0)

            heroStage
                .frame(height: 300)

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.rsTitle(28))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(RSTheme.textPrimary)

                Text(page.body)
                    .font(.rsBody(16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(RSTheme.textSecondary)
                    .padding(.horizontal, 30)

                // Feature chips.
                FlowChips(items: page.chips, accent: page.accent)
                    .padding(.top, 4)
                    .padding(.horizontal, 20)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .onAppear { startAnimations() }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(page.title). \(page.body)")
    }

    private var heroStage: some View {
        ZStack {
            // Aura.
            Circle()
                .fill(RadialGradient(colors: [page.accent.opacity(0.5), .clear],
                                     center: .center, startRadius: 10, endRadius: 160))
                .frame(width: 300, height: 300)
                .scaleEffect(pulse && !reduceMotion ? 1.08 : 0.92)
                .blur(radius: 6)

            // Outer dashed ring (spins one way).
            Circle()
                .strokeBorder(page.accent.opacity(0.5),
                              style: StrokeStyle(lineWidth: 2, dash: [3, 10]))
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(spin ? 360 : 0))

            // Inner gradient ring (spins the other way).
            Circle()
                .stroke(RSTheme.energy, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [60, 40]))
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(counterSpin ? -360 : 0))
                .shadow(color: page.accent.opacity(0.6), radius: 16)

            // Orbiting theme glyphs around the inner ring.
            ForEach(Array(page.orbiters.enumerated()), id: \.offset) { i, glyph in
                Image(systemName: glyph)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(RSTheme.textPrimary)
                    .padding(8)
                    .background(RSTheme.glassFill, in: Circle())
                    .overlay(Circle().strokeBorder(page.accent.opacity(0.5), lineWidth: 1))
                    .offset(y: -118)
                    .rotationEffect(.degrees(Double(i) / Double(page.orbiters.count) * 360))
                    .rotationEffect(.degrees(spin ? 360 : 0))
            }
            .rotationEffect(.degrees(spin ? 0 : 0)) // container anchor

            // Hero glyph.
            Image(systemName: page.symbol)
                .font(.system(size: 88, weight: .black))
                .foregroundStyle(RSTheme.glow)
                .shadow(color: page.accent.opacity(0.85), radius: 26)
                .offset(y: float && !reduceMotion ? -10 : 0)
                .scaleEffect(isActive ? 1 : 0.8)
        }
    }

    private func startAnimations() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { float = true }
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { pulse = true }
        withAnimation(.linear(duration: 26).repeatForever(autoreverses: false)) { spin = true }
        withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) { counterSpin = true }
    }
}

/// Simple wrapping row of pill chips.
private struct FlowChips: View {
    let items: [String]
    let accent: Color

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.rsCaption(11))
                    .foregroundStyle(RSTheme.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(accent.opacity(0.18), in: Capsule())
                    .overlay(Capsule().strokeBorder(accent.opacity(0.45), lineWidth: 1))
            }
        }
        .frame(maxWidth: .infinity)
    }
}
