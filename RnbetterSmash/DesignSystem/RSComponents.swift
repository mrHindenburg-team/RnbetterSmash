import SwiftUI

// MARK: - Glass Card

/// A reusable glassmorphism container with a glowing energy stroke.
struct RSGlassCard<Content: View>: View {
    var cornerRadius: CGFloat = RSTheme.cornerMedium
    var glow: Bool = true
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(RSTheme.glassFill)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(RSTheme.cardSurface)
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(RSTheme.glassStroke, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: glow ? RSTheme.cardShadow : .clear, radius: 18, y: 10)
    }
}

extension View {
    /// Wraps the view in a glass card with standard padding.
    func rsGlassCard(cornerRadius: CGFloat = RSTheme.cornerMedium,
                     padding: CGFloat = 18,
                     glow: Bool = true) -> some View {
        RSGlassCard(cornerRadius: cornerRadius, glow: glow) {
            self.padding(padding)
        }
    }
}

// MARK: - Primary Button

/// High-energy primary call-to-action button.
struct RSPrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pressed = false

    var body: some View {
        Button(action: {
            RSHaptics.tap()
            action()
        }) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.rsHeadline())
                }
                Text(title)
                    .font(.rsHeadline())
            }
            .foregroundStyle(RSTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(RSTheme.energyHorizontal, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 1))
            .shadow(color: RSTheme.electricBlue.opacity(0.5), radius: 16, y: 8)
            .scaleEffect(pressed && !reduceMotion ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .medium), trigger: pressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}

// MARK: - Secondary / Ghost Button

struct RSGhostButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }
            .font(.rsHeadline(16))
            .foregroundStyle(RSTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .overlay(Capsule().strokeBorder(RSTheme.glassStroke, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section Header

struct RSSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var systemImage: String? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.rsTitle(20))
                    .foregroundStyle(RSTheme.glow)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.rsTitle(22))
                    .foregroundStyle(RSTheme.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.rsCaption())
                        .foregroundStyle(RSTheme.textSecondary)
                }
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Pressable Button Style

/// Scales the button slightly while pressed using `configuration.isPressed`.
///
/// Crucially, this does NOT attach a `DragGesture`, so it coexists with a
/// parent `ScrollView` — the scroll view still receives pan gestures. Prefer
/// this over a manual `DragGesture(minimumDistance: 0)` inside scrollable rows.
struct RSPressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? scale : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == RSPressableButtonStyle {
    static var rsPressable: RSPressableButtonStyle { RSPressableButtonStyle() }
}

// MARK: - Store Button

/// Glowing store/shop button for screen headers. Shows a crown when the user
/// already owns at least one pack.
struct RSStoreButton: View {
    var owned: Bool = false
    var action: () -> Void

    var body: some View {
        Button {
            RSHaptics.tap()
            action()
        } label: {
            Image(systemName: owned ? "crown.fill" : "bag.fill")
                .font(.rsHeadline(18))
                .foregroundStyle(owned ? RSTheme.warning : RSTheme.textPrimary)
                .frame(width: 44, height: 44)
                .background {
                    Circle().fill(RSTheme.energy)
                        .opacity(owned ? 0 : 1)
                    Circle().fill(RSTheme.glassFill)
                        .opacity(owned ? 1 : 0)
                }
                .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1))
                .shadow(color: RSTheme.electricBlue.opacity(0.5), radius: 10)
        }
        .buttonStyle(.rsPressable)
        .accessibilityLabel(owned ? "Store — packs owned" : "Open store")
    }
}

// MARK: - Tag / Pill

struct RSTag: View {
    let text: String
    var tint: Color = RSTheme.icyCyan

    var body: some View {
        Text(text.uppercased())
            .font(.rsCaption(11))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tint.opacity(0.14), in: Capsule())
            .overlay(Capsule().strokeBorder(tint.opacity(0.4), lineWidth: 1))
    }
}
