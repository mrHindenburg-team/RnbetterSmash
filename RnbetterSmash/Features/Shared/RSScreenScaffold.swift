import SwiftUI

/// Standard scrollable screen container: large title, optional trailing accessory,
/// and bottom inset so content clears the custom tab bar.
struct RSScreenScaffold<Content: View, Accessory: View>: View {
    let title: String
    var subtitle: String?
    var accessory: Accessory
    var content: Content

    init(title: String,
         subtitle: String? = nil,
         @ViewBuilder accessory: () -> Accessory,
         @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.accessory = accessory()
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.rsDisplay(32))
                            .foregroundStyle(RSTheme.textPrimary)
                        if let subtitle {
                            Text(subtitle)
                                .font(.rsCaption(13))
                                .foregroundStyle(RSTheme.textSecondary)
                        }
                    }
                    Spacer()
                    accessory
                }
                .padding(.top, 8)

                content
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 120) // clears the tab bar
        }
        .scrollIndicators(.hidden)
        // Own the animated background so every scaffolded screen looks identical,
        // even inside a NavigationStack (whose host view is otherwise opaque and
        // would hide the root background behind the tab content).
        .background { RSAnimatedBackground().ignoresSafeArea() }
    }
}

extension RSScreenScaffold where Accessory == EmptyView {
    init(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.accessory = EmptyView()
        self.content = content()
    }
}
