import SwiftUI

/// Central design tokens for Rnbetter: Smash.
///
/// The palette is built around deep purple, electric blue, icy cyan and white,
/// with white as the primary text color throughout. All colors are defined
/// explicitly (no system colors) so the look is identical in light/dark and
/// fully offline.
enum RSTheme {

    // MARK: - Core Palette

    static let voidPurple = Color(red: 0.05, green: 0.03, blue: 0.13)   // near-black base
    static let deepPurple = Color(red: 0.16, green: 0.07, blue: 0.40)
    static let royalPurple = Color(red: 0.36, green: 0.16, blue: 0.78)
    static let electricBlue = Color(red: 0.20, green: 0.40, blue: 1.00)
    static let icyCyan = Color(red: 0.36, green: 0.86, blue: 0.99)
    static let glowCyan = Color(red: 0.56, green: 0.95, blue: 1.00)

    // MARK: - Text

    /// Primary text color — white per the design language.
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.72)
    static let textTertiary = Color.white.opacity(0.45)

    // MARK: - Surfaces

    /// Translucent surface used by glass cards.
    static let glassFill = Color.white.opacity(0.06)
    static let glassStroke = Color.white.opacity(0.14)
    static let cardShadow = Color(red: 0.20, green: 0.40, blue: 1.00).opacity(0.35)

    // MARK: - Semantic energy accents

    static let success = Color(red: 0.30, green: 0.95, blue: 0.74)
    static let warning = Color(red: 1.00, green: 0.78, blue: 0.34)
    static let danger = Color(red: 1.00, green: 0.36, blue: 0.52)

    // MARK: - Gradients

    /// Full-screen background gradient: void → deep purple → hint of blue.
    static let appBackground = LinearGradient(
        colors: [voidPurple, deepPurple, Color(red: 0.09, green: 0.10, blue: 0.32)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Signature energetic accent gradient (purple → blue → cyan).
    static let energy = LinearGradient(
        colors: [royalPurple, electricBlue, icyCyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let energyHorizontal = LinearGradient(
        colors: [royalPurple, electricBlue, icyCyan],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Cyan-forward glow for highlights and active indicators.
    static let glow = LinearGradient(
        colors: [glowCyan, icyCyan, electricBlue],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardSurface = LinearGradient(
        colors: [Color.white.opacity(0.10), Color.white.opacity(0.02)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Metrics

    static let cornerLarge: CGFloat = 28
    static let cornerMedium: CGFloat = 20
    static let cornerSmall: CGFloat = 14
}
