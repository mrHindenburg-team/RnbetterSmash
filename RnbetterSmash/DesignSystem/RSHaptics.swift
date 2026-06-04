import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Lightweight haptic feedback helper. Fully on-device; no-ops on platforms
/// without UIKit feedback generators.
enum RSHaptics {
    static func tap() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    static func success() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    static func celebrate() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        #endif
    }
}
