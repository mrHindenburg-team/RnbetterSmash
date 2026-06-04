import SwiftUI

/// Typography helpers. Uses rounded system fonts scaled with Dynamic Type via
/// `relativeTo:` so text remains accessible while keeping a custom, athletic feel.
extension Font {

    static func rsDisplay(_ size: CGFloat = 34) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func rsTitle(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func rsHeadline(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func rsBody(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    static func rsCaption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }

    /// Tabular, mono-ish numerals for metrics and timers.
    static func rsMetric(_ size: CGFloat = 30) -> Font {
        .system(size: size, weight: .heavy, design: .rounded).monospacedDigit()
    }
}

extension Text {
    /// Applies the energy gradient as the text fill.
    func rsEnergyFill() -> some View {
        self.foregroundStyle(RSTheme.energyHorizontal)
    }
}
