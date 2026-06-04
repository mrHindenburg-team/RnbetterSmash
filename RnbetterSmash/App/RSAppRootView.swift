import SwiftUI
import SwiftData

/// Main application content, shown by ScreenRouterKit **after** its splash phase.
///
/// This view intentionally renders NO splash of its own — the cinematic splash
/// is provided solely through ScreenRouterKit's `splash:` closure in the app
/// entry (`RnbetterSmashApp`). Here we only bootstrap progress state and route
/// onboarding → main.
struct RSAppRootView: View {
    @Environment(\.modelContext) private var context
    @State private var manager: RSProgressManager?

    var body: some View {
        ZStack {
            if let manager {
                RSMainFlowView()
                    .environment(manager)
                    .transition(.opacity)
            } else {
                // Brief backdrop while the local store bootstraps — not a splash.
                RSAnimatedBackground()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: manager == nil)
        .task {
            if manager == nil {
                manager = RSProgressManager(context: context)
            }
        }
    }
}

/// Routes between onboarding and the main tab experience. No splash phase —
/// the splash lives entirely in ScreenRouterKit.
private struct RSMainFlowView: View {
    @Environment(RSProgressManager.self) private var manager

    var body: some View {
        ZStack {
            if manager.progress.hasCompletedOnboarding {
                RSRootTabView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            } else {
                RSOnboardingView(onFinish: { manager.completeOnboarding() })
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: manager.progress.hasCompletedOnboarding)
    }
}
