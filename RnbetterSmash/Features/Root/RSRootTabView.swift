import SwiftUI

/// The five primary destinations of the app.
enum RSTab: Int, CaseIterable, Identifiable {
    case home, learn, train, coach, journey
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .learn: "Learn"
        case .train: "Train"
        case .coach: "Coach"
        case .journey: "Journey"
        }
    }

    var symbol: String {
        switch self {
        case .home: "house.fill"
        case .learn: "books.vertical.fill"
        case .train: "dumbbell.fill"
        case .coach: "brain.head.profile"
        case .journey: "crown.fill"
        }
    }
}

/// Root container hosting the custom tab bar, paywall presentation, and the
/// cinematic achievement-celebration overlay shown above everything.
struct RSRootTabView: View {
    @Environment(RSProgressManager.self) private var manager
    @State private var selection: RSTab = .home
    @State private var showPaywall = false

    var body: some View {
        ZStack(alignment: .bottom) {
            RSAnimatedBackground()

            Group {
                switch selection {
                case .home: RSHomeView(selection: $selection, showPaywall: $showPaywall)
                case .learn: RSLearnView()
                case .train: RSTrainView(showPaywall: $showPaywall)
                case .coach: RSCoachView(showPaywall: $showPaywall)
                case .journey: RSJourneyView(showPaywall: $showPaywall)
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.25), value: selection)

            RSTabBar(selection: $selection)
        }
        .sheet(isPresented: $showPaywall) {
            RSPaywallView()
        }
        .overlay {
            if let achievement = manager.pendingCelebration {
                RSAchievementCelebration(achievement: achievement) {
                    manager.pendingCelebration = nil
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .animation(.easeInOut, value: manager.pendingCelebration?.id)
    }
}

/// Custom glassmorphic tab bar with a glowing active indicator.
private struct RSTabBar: View {
    @Binding var selection: RSTab
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 0) {
            ForEach(RSTab.allCases) { tab in
                Button {
                    RSHaptics.tap()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        selection = tab
                    }
                } label: {
                    VStack(spacing: 5) {
                        ZStack {
                            if selection == tab {
                                Circle()
                                    .fill(RSTheme.energy)
                                    .frame(width: 42, height: 42)
                                    .matchedGeometryEffect(id: "tabhighlight", in: ns)
                                    .shadow(color: RSTheme.electricBlue.opacity(0.6), radius: 10)
                            }
                            Image(systemName: tab.symbol)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(selection == tab ? RSTheme.textPrimary : RSTheme.textTertiary)
                        }
                        .frame(height: 42)

                        Text(tab.title)
                            .font(.rsCaption(10))
                            .foregroundStyle(selection == tab ? RSTheme.textPrimary : RSTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
                .accessibilityAddTraits(selection == tab ? [.isSelected, .isButton] : .isButton)
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 8)
        .padding(.bottom, 6)
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(RSTheme.glassStroke, lineWidth: 1))
                .environment(\.colorScheme, .dark)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 6)
    }
}
